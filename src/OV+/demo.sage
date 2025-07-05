load("sign.sage")
load("utils.sage")
load("certify.sage")

"""
if __name__ == "__main__":
  # setting up the environment 
  field = GF(7, 'a')
  k = 8
  t = 3

  # Alice's Keys
  A_f = generate_F_matrices(field, k, t, 1)
  A_S = generate_S_mixer(field, k, t, 1)
  A_T = generate_T_mixer(field, k, 1)
  A_public = generate_public_key(A_S, A_T, A_f, 1)

  # Bob's Keys
  B_f = generate_F_matrices(field, k, t)
  B_S = generate_S_mixer(field, k, t)
  B_T = generate_T_mixer(field, k)
  B_public = generate_public_key(B_S, B_T, B_f)

  # Messages
  message1 = "First message to sign"
  message2 = "Second message to sign"

  # Alice signing the messages
  A_signed_1 = sign(message1, A_S, A_T, A_f, t, 1)
  A_signed_2 = sign(message2, A_S, A_T, A_f, t)

  # Bob signing the messages
  B_signed_1 = sign(message1, B_S, B_T, B_f, t)
  B_signed_2 = sign(message2, B_S, B_T, B_f, t)

  # Validations 
  ## Valid signatures
  print("======== Valid signatures ========")
  print(certify(A_public, message1, A_signed_1))
  print(certify(A_public, message2, A_signed_2))
  print(certify(B_public, message1, B_signed_1))
  print(certify(B_public, message2, B_signed_2))

  ## Invalid signatures -> wrong message tested
  print("======== Wrong message tested ========")
  print(certify(A_public, message2, A_signed_1))
  print(certify(A_public, message1, A_signed_2))
  print(certify(B_public, message2, B_signed_1))
  print(certify(B_public, message1, B_signed_2))

  ## Invalid signatures -> wrong signature tested
  print("======== Wrong signature tested ========")
  print(certify(A_public, message1, A_signed_2))
  print(certify(A_public, message2, A_signed_1))
  print(certify(B_public, message1, B_signed_2))
  print(certify(B_public, message2, B_signed_1))

  ## Invalid signatures -> wrong person tested
  print("======== Wrong person tested ========")
  print(certify(A_public, message1, B_signed_1))
  print(certify(A_public, message2, B_signed_2))
  print(certify(B_public, message1, A_signed_1))
  print(certify(B_public, message2, A_signed_2, 2))
  
  ## Invalid signatures -> inconsistent length
  print("======= Inconsistent length =======")
  print(certify(A_public[:-1], message1, A_signed_1,2))
  print(certify(A_public+[A_public[0]], message1, A_signed_1,2))
  
  # Setting up different fields
  other_field = GF(5, 'a')
  
  # Charlie's keys
  C_f = generate_F_matrices(other_field, k, t)
  C_S = generate_S_mixer(other_field, k, t)
  C_T = generate_T_mixer(other_field, k)
  C_public = generate_public_key(C_S, C_T, C_f)
  
  # Charlie signing the messages
  C_signed_1 = sign(message1, C_S, C_T, C_f, t)
  C_signed_2 = sign(message2, C_S, C_T, C_f, t)
  
  #More validations
  ## Valid signatures
  print("======== Valid signatures ========")
  print(certify(C_public, message1, C_signed_1))
  print(certify(C_public, message2, C_signed_2))
  
  ## Invalid 
  print("======= Inconsistent base field =======")
  print(certify(C_public, message1, A_signed_1))
  print(certify(A_public, message1, C_signed_1))
  print(certify(C_public, message2, A_signed_2,2))
  print(certify(A_public, message2, C_signed_2,2))
"""


# Global variables to be set by the timing script for the scheme's functions
k = 0
t = 0

if True:
    # --- Timing Calculation for Modified Scheme ---
    import time
    # import pprint # For debugging, if needed later

    # Configuration: Set these flags to True or False to control which operations are timed.
    test_keygen_new_scheme = True
    test_sign_new_scheme = True
    test_certify_new_scheme = True
    # test_forge_new_scheme = False # Forging functions for this new scheme are not specified here

    # Helper function to time an operation and get the result of its first execution
    def time_operation_and_get_first_result(op_callable, num_iterations_local):
        total_time = 0.0
        first_run_result = None

        if num_iterations_local <= 0:
            # This case is for num_iterations being 0 or negative.
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

    parameters_q_new = {
        "128": {"q": 251}, 
        "192": {"q": 4093}, 
        "256": {"q": 65521}, 
    }
    k_values_new = [39, 53, 69] 
    
    num_iterations_new = 50 # As per your latest log
    test_message_new = "Message for modified scheme"

    results_keygen_new = {}
    results_sign_new = {}
    results_certify_new = {}

    print(f"MODIFIED SCHEME: Starting timing calculations with {num_iterations_new} iterations.")
    print(f"K values: {k_values_new}")
    print(f"Timing active for: KeyGen={test_keygen_new_scheme}, Sign={test_sign_new_scheme}, Certify={test_certify_new_scheme}")

    for sec_level_label, params_q_val in parameters_q_new.items():
        q_val = params_q_val["q"]
        try:
            field = GF(q_val)
        except Exception as e:
            print(f"\nError creating field GF({q_val}): {e}. Skipping this q for modified scheme.")
            results_keygen_new[sec_level_label] = {k_val_loop: "Field Error" for k_val_loop in k_values_new}
            results_sign_new[sec_level_label] = {k_val_loop: "Field Error" for k_val_loop in k_values_new}
            results_certify_new[sec_level_label] = {k_val_loop: "Field Error" for k_val_loop in k_values_new}
            continue
            
        print(f"\nProcessing Field: {sec_level_label} (q={q_val})")

        results_keygen_new[sec_level_label] = {}
        results_sign_new[sec_level_label] = {}
        results_certify_new[sec_level_label] = {}

        for k_val_loop in k_values_new: # Renamed k_val to k_val_loop to avoid confusion with global k
            t_val_loop = max(1, k_val_loop // 4) 
            if k_val_loop > 0 and t_val_loop > k_val_loop : 
                t_val_loop = k_val_loop
            if t_val_loop == 0 and k_val_loop > 0:
                t_val_loop = 1
            
            t_val_loop = 5

            print(f"  Testing with k = {k_val_loop}, t = {t_val_loop}")

            # WORKAROUND: Set global 'k' and 't' that user's functions might expect
            # This assumes that the loaded functions (e.g., solve_quadratic_system)
            # will see these globals if they try to access 'k' or 't' directly.
            globals()['k'] = k_val_loop
            globals()['t'] = t_val_loop

            S_priv, T_priv, F_priv_list, Pub_key_for_ops = None, None, None, None
            signature_for_ops = None

            def keygen_op_new_scheme_callable():
                # These functions take k_val_loop and t_val_loop explicitly.
                _S = generate_S_mixer(field, k_val_loop, t_val_loop, verbose=0)
                _T = generate_T_mixer(field, k_val_loop, verbose=0)
                _F_list = generate_F_matrices(field, k_val_loop, t_val_loop, verbose=0)
                # generate_public_key doesn't take k or t in its signature.
                # If its verbose>0 print for 't' runs, it will use the global 't' set above.
                _Pub_key = generate_public_key(_S, _T, _F_list, verbose=0)
                return (_S, _T, _F_list), _Pub_key

            if test_keygen_new_scheme:
                avg_kg_time, ((S_priv, T_priv, F_priv_list), Pub_key_for_ops) = \
                    time_operation_and_get_first_result(keygen_op_new_scheme_callable, num_iterations_new)
                results_keygen_new[sec_level_label][k_val_loop] = avg_kg_time
                print(f"    Avg Key Gen Time: {avg_kg_time:.6f} seconds")
            else:
                results_keygen_new[sec_level_label][k_val_loop] = "SKIPPED"
                if test_sign_new_scheme or test_certify_new_scheme: 
                    print(f"    Key Generation: SKIPPED (generating materials untimed)")
                    (S_priv, T_priv, F_priv_list), Pub_key_for_ops = keygen_op_new_scheme_callable()
                else:
                    print(f"    Key Generation: SKIPPED")
            
            if test_sign_new_scheme:
                if S_priv and T_priv and F_priv_list: 
                    def sign_op_new_scheme_callable():
                        # The 'sign' function is called with t_val_loop.
                        # Its internal call to solve_quadratic_system is where global 'k' is needed by your impl.
                        return sign(test_message_new, S_priv, T_priv, F_priv_list, t_val_loop, verbose=0)
                    
                    avg_s_time, signature_for_ops = \
                        time_operation_and_get_first_result(sign_op_new_scheme_callable, num_iterations_new)
                    results_sign_new[sec_level_label][k_val_loop] = avg_s_time
                    print(f"    Avg Sign Time:    {avg_s_time:.6f} seconds")
                else:
                    results_sign_new[sec_level_label][k_val_loop] = "N/A (No PrivKey)"
                    print(f"    Avg Sign Time:    SKIPPED (Private key components not available)")
            else:
                results_sign_new[sec_level_label][k_val_loop] = "SKIPPED"
                if test_certify_new_scheme: 
                    if S_priv and T_priv and F_priv_list:
                        print(f"    Signing: SKIPPED (generating signature untimed for certification test)")
                        signature_for_ops = sign(test_message_new, S_priv, T_priv, F_priv_list, t_val_loop, verbose=0)
                    else:
                        print(f"    Signing: SKIPPED (Private key components not available)")
                else:
                    print(f"    Signing: SKIPPED")

            if test_certify_new_scheme:
                if Pub_key_for_ops and signature_for_ops:
                    def certify_op_new_scheme_callable():
                        return certify(Pub_key_for_ops, test_message_new, signature_for_ops, verbose=0)
                    
                    avg_c_time, _ = \
                        time_operation_and_get_first_result(certify_op_new_scheme_callable, num_iterations_new)
                    results_certify_new[sec_level_label][k_val_loop] = avg_c_time
                    print(f"    Avg Certify Time: {avg_c_time:.6f} seconds")
                else:
                    results_certify_new[sec_level_label][k_val_loop] = "N/A (No PK/Sig)"
                    missing_items = []
                    if not Pub_key_for_ops: missing_items.append("Public Key")
                    if not signature_for_ops: missing_items.append("Signature")
                    print(f"    Avg Certify Time: SKIPPED ({', '.join(missing_items)} not available)")
            else:
                results_certify_new[sec_level_label][k_val_loop] = "SKIPPED"
                print(f"    Avg Certify Time: SKIPPED")

    # --- Output Tables (Modified Scheme) ---
    print("\n\n--- TIMING RESULTS FOR MODIFIED SCHEME ---")

    k_headers_new = [str(k_h) for k_h in k_values_new] 
    
    max_q_label_len = 0
    if parameters_q_new:
        label_lengths = [len(label) for label in parameters_q_new.keys()]
        if label_lengths:
            max_q_label_len = max(label_lengths)
    
    q_col_width_new = max(max_q_label_len, len("Field\\k")) + 2
    data_col_widths_new = [max(len(kh), 18) for kh in k_headers_new]

    def print_table_new_scheme(table_data, table_title):
        print(f"\n{table_title}:")
        header_parts = [f"{'Field\\k':<{q_col_width_new}}"] + \
                       [f"{k_head:>{dw}}" for k_head, dw in zip(k_headers_new, data_col_widths_new)]
        print(" | ".join(header_parts))
        separator_parts = ['-' * q_col_width_new] + ['-' * dw for dw in data_col_widths_new]
        print("-+-".join(separator_parts))

        for field_label_table, k_times_table in table_data.items():
            row_parts = [f"{field_label_table:<{q_col_width_new}}"]
            for i_table, k_val_table_loop in enumerate(k_values_new): # Renamed k_val_table to avoid clash
                time_val = k_times_table.get(k_val_table_loop)
                
                handled = False
                if time_val is not None:
                    try:
                        float_val = float(time_val) 
                        row_parts.append(f"{float_val:>{data_col_widths_new[i_table]}.4f}")
                        handled = True
                    except (TypeError, ValueError):
                        if isinstance(time_val, str): 
                            row_parts.append(f"{time_val:>{data_col_widths_new[i_table]}}")
                            handled = True
                if not handled: 
                    row_parts.append(f"{'N/C':>{data_col_widths_new[i_table]}}") 
            print(" | ".join(row_parts))

    if test_keygen_new_scheme: print_table_new_scheme(results_keygen_new, "Average Key Generation Time (Modified Scheme, seconds)")
    if test_sign_new_scheme: print_table_new_scheme(results_sign_new, "Average Signing Time (Modified Scheme, seconds)")
    if test_certify_new_scheme: print_table_new_scheme(results_certify_new, "Average Certification Time (Modified Scheme, seconds)")

    print("\nNote (Modified Scheme):")
    print("  'N/C': Data not computed/found (e.g., interruption or error).")
    print("  'SKIPPED': Operation not selected for timing.")
    print("  'N/A (Reason)': Prerequisite missing for a timed operation.")
    print("  'Field Error': GF(q) initialization failed for this q value.")