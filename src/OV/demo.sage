load("sign.sage")
load("utils.sage")
load("certify.sage")
load("forge.sage")

if True:
  # --- Timing Calculation ---
  import time
  # import pprint # No longer needed if debug prints are removed

  # Configuration: Set these flags to True or False to control which operations are timed.
  test_keygen = True
  test_sign = True
  test_certify = True
  test_forge = True   # New flag for the forging attack

  # Helper function to time an operation and get the result of its first execution
  def time_operation_and_get_first_result(op_callable, num_iterations_local):
      total_time = 0.0
      first_run_result = None

      if num_iterations_local <= 0:
          print(f"Warning: num_iterations ({num_iterations_local}) is not positive. Attempting a single run.")
          start_time_single = time.time()
          first_run_result = op_callable()
          end_time_single = time.time()
          return end_time_single - start_time_single, first_run_result
      
      for i in range(num_iterations_local): 
          start_time = time.time()
          current_run_result = op_callable()
          end_time = time.time()
          total_time += (end_time - start_time)
          if i == 0:
              first_run_result = current_run_result
        
      avg_time = total_time / num_iterations_local
      return avg_time, first_run_result

  parameters_q = {
      "128": {"q": 251},
      "192": {"q": 4093},
      "256": {"q": 65521}
  }

  k_values_to_test = [2**(i) for i in range(3, 8)] 
  num_iterations = 1 # Keeping num_iterations = 1 as per your latest log
  test_message = "UOV Signature Scheme Test Message"

  results_key_gen = {}
  results_sign = {}
  results_certify = {} 
  results_forge = {}   # New dictionary for forge results

  print(f"Starting timing calculations with {num_iterations} iterations per (q, k) pair.")
  print(f"K values to be tested: {k_values_to_test}")
  print(f"Timing active for: KeyGen={test_keygen}, Sign={test_sign}, Certify={test_certify}, Forge={test_forge}")

  for sec_level_str, params_q_val in parameters_q.items():
      q_val = params_q_val["q"]
      field = GF(q_val) 
      
      print(f"\nProcessing Security Level: {sec_level_str} (q={q_val})")

      results_key_gen[sec_level_str] = {}
      results_sign[sec_level_str] = {}
      results_certify[sec_level_str] = {}
      results_forge[sec_level_str] = {} # Initialize for this security level

      for k_val in k_values_to_test:
          print(f"  Testing with k = {k_val}")

          A_priv, F_mats, G_pub = None, None, None
          X_sig = None

          def keygen_op_base_callable():
              A = generate_private_key(field, k_val, verbose=0)
              Fm = generate_F_matrices(field, k_val, verbose=0)
              Gp = generate_public_key(A, Fm, verbose=0)
              return A, Fm, Gp

          # --- Key Generation Phase ---
          if test_keygen:
              avg_kg_time, (A_priv, F_mats, G_pub) = \
                  time_operation_and_get_first_result(keygen_op_base_callable, num_iterations)
              results_key_gen[sec_level_str][k_val] = avg_kg_time
              print(f"    Avg Key Gen Time: {avg_kg_time:.6f} seconds")
          else: 
              results_key_gen[sec_level_str][k_val] = "SKIPPED"
              # Generate materials untimed if needed by any subsequent *timed* operation
              if test_sign or test_certify or test_forge: 
                  print(f"    Key Generation: SKIPPED (generating materials untimed)")
                  A_priv, F_mats, G_pub = keygen_op_base_callable() 
              else:
                  print(f"    Key Generation: SKIPPED")
          
          # --- Signing Phase ---
          if test_sign:
              if A_priv and F_mats: 
                  def sign_op_timed_callable(): 
                      return sign(test_message, A_priv, F_mats, verbose=0)
                  avg_s_time, X_sig = \
                      time_operation_and_get_first_result(sign_op_timed_callable, num_iterations)
                  results_sign[sec_level_str][k_val] = avg_s_time
                  print(f"    Avg Sign Time:    {avg_s_time:.6f} seconds")
              else: 
                  results_sign[sec_level_str][k_val] = "N/A (No Key)"
                  print(f"    Avg Sign Time:    SKIPPED (Key materials not available)")
          else: 
              results_sign[sec_level_str][k_val] = "SKIPPED"
              # Generate signature untimed if needed for *timed* certification 
              # (forging generates its own signature using forged keys)
              if test_certify: 
                  if A_priv and F_mats:
                      print(f"    Signing: SKIPPED (generating signature untimed for certification test)")
                      X_sig = sign(test_message, A_priv, F_mats, verbose=0) 
                  else:
                      print(f"    Signing: SKIPPED (Key materials not available for generating signature)")
              else:
                  print(f"    Signing: SKIPPED")

          # --- Certification Phase ---
          if test_certify:
              if G_pub and X_sig: # X_sig should be from a legitimate signing process
                  def certify_op_timed_callable(): 
                      return certify(G_pub, test_message, X_sig, verbose=0)
                  avg_c_time, _ = \
                      time_operation_and_get_first_result(certify_op_timed_callable, num_iterations)
                  results_certify[sec_level_str][k_val] = avg_c_time
                  print(f"    Avg Certify Time: {avg_c_time:.6f} seconds")
              else:
                  results_certify[sec_level_str][k_val] = "N/A (No PK/Sig)"
                  missing_items = []
                  if not G_pub: missing_items.append("Public Key")
                  if not X_sig: missing_items.append("Legit Signature") # Clarify X_sig source
                  print(f"    Avg Certify Time: SKIPPED ({', '.join(missing_items)} not available)")
          else: 
              results_certify[sec_level_str][k_val] = "SKIPPED"
              print(f"    Avg Certify Time: SKIPPED")

          # --- Forging Phase ---
          if test_forge:
              if G_pub: # Forging attack needs the public key
                  def forge_op_timed_callable():
                      # forge_signature internally calls forge_key and then sign
                      return forge_signature(test_message, G_pub) 
                  
                  avg_f_time, forged_sig_example = \
                      time_operation_and_get_first_result(forge_op_timed_callable, num_iterations)
                  results_forge[sec_level_str][k_val] = avg_f_time
                  print(f"    Avg Forge Time:   {avg_f_time:.6f} seconds")
                  # Optionally, one could try to certify the forged_sig_example here as a sanity check (untimed)
                  # if forged_sig_example and G_pub:
                  #     is_forged_valid = certify(G_pub, test_message, forged_sig_example, verbose=0)
                  #     print(f"      (Sanity Check: Forged signature for k={k_val} certified as: {is_forged_valid})")

              else: # G_pub not available
                  results_forge[sec_level_str][k_val] = "N/A (No PK)"
                  print(f"    Avg Forge Time:   SKIPPED (Public Key not available)")
          else:
              results_forge[sec_level_str][k_val] = "SKIPPED"
              print(f"    Avg Forge Time:   SKIPPED")


  # --- Output Tables ---
  print("\n\n--- Results ---")

  k_headers = [str(k) for k in k_values_to_test]
  
  max_q_len = 0
  if parameters_q:
      q_lengths = [len(str(pqv.get("q",""))) for pqv in parameters_q.values() if isinstance(pqv, dict)]
      if q_lengths: 
           max_q_len = max(q_lengths) if q_lengths else 0 
  
  q_col_width = max(max_q_len, len("q\\k")) + 2 
  data_col_widths = [max(len(kh), 22) for kh in k_headers] 

  def print_table(table_data, table_title):
      print(f"\n{table_title}:")
      header_parts = [f"{'q\\k':<{q_col_width}}"] + [f"{k_head:>{dw}}" for k_head, dw in zip(k_headers, data_col_widths)]
      print(" | ".join(header_parts))
      separator_parts = ['-' * q_col_width] + ['-' * dw for dw in data_col_widths]
      print("-+-".join(separator_parts))

      for sec_level_str_table, k_times_table in table_data.items():
          q_val_param_table = parameters_q.get(sec_level_str_table)
          q_display_table = str(q_val_param_table["q"]) if q_val_param_table and isinstance(q_val_param_table, dict) and "q" in q_val_param_table else sec_level_str_table
          
          row_parts = [f"{q_display_table:<{q_col_width}}"]
          for i_table, k_val_table in enumerate(k_values_to_test):
              time_val = k_times_table.get(k_val_table)
              
              handled = False
              if time_val is not None:
                  try:
                      float_val = float(time_val) 
                      row_parts.append(f"{float_val:>{data_col_widths[i_table]}.4f}")
                      handled = True
                  except (TypeError, ValueError):
                      if isinstance(time_val, str): 
                          row_parts.append(f"{time_val:>{data_col_widths[i_table]}}")
                          handled = True
              
              if not handled: 
                  row_parts.append(f"{'N/C':>{data_col_widths[i_table]}}") 
          print(" | ".join(row_parts))

  if test_keygen: print_table(results_key_gen, "Average Key Generation Time (seconds)")
  if test_sign: print_table(results_sign, "Average Signing Time (seconds)")
  if test_certify: print_table(results_certify, "Average Certification Time (seconds)")
  if test_forge: print_table(results_forge, "Average Forging Time (seconds)") # New table

  print("\nNote:")
  print("  'N/C' (Not Computed): Data for this (q, k) pair was not generated or found.")
  print("  'SKIPPED': This operation was not selected for timing via the configuration flags.")
  print("  'N/A (Reason)': A prerequisite for this timed operation was missing.")