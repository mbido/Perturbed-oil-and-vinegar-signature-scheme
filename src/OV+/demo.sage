load("sign.sage")
load("utils.sage")
load("certify.sage")

# (Функции forge_key, forge_signature, complete_basis не используются в этом скрипте,
# так как они были для предыдущей схемы. Для новой схемы нужны адаптированные функции атаки.)

if True:
    # --- Timing Calculation for Modified Scheme ---
    import time
    # import pprint # Для отладки, если потребуется

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

    # Parameters for the new scheme's complexity study
    parameters_q_new = {
        "GF_251": {"q": 251}, # Example small prime
        "GF_1009": {"q": 1009}, # Example medium prime (GF(4093) might be too slow with variety())
        # "GF_small_k_optimized": {"q": 7} # As per your example for very small k
    }
    # Adjust k_values based on expected performance. variety() can be slow.
    k_values_new = [4, 8, 12] # Start with smaller k values
    
    # num_iterations should be low due to potential cost of I.variety()
    num_iterations_new = 1
    test_message_new = "Message for modified scheme"

    # Results dictionaries
    results_keygen_new = {}
    results_sign_new = {}
    results_certify_new = {}
    # results_forge_new = {} # If forging were to be added

    print(f"MODIFIED SCHEME: Starting timing calculations with {num_iterations_new} iterations.")
    print(f"K values: {k_values_new}")
    print(f"Timing active for: KeyGen={test_keygen_new_scheme}, Sign={test_sign_new_scheme}, Certify={test_certify_new_scheme}")

    for sec_level_label, params_q_val in parameters_q_new.items():
        q_val = params_q_val["q"]
        try:
            field = GF(q_val)
        except Exception as e:
            print(f"\nError creating field GF({q_val}): {e}. Skipping this q for modified scheme.")
            # Populate results with error for this field
            results_keygen_new[sec_level_label] = {k_val: "Field Error" for k_val in k_values_new}
            results_sign_new[sec_level_label] = {k_val: "Field Error" for k_val in k_values_new}
            results_certify_new[sec_level_label] = {k_val: "Field Error" for k_val in k_values_new}
            continue
            
        print(f"\nProcessing Field: {sec_level_label} (q={q_val})")

        results_keygen_new[sec_level_label] = {}
        results_sign_new[sec_level_label] = {}
        results_certify_new[sec_level_label] = {}

        for k_val in k_values_new:
            # Determine t_val for the current k_val. Ensure t >= 1 for solve_quadratic_system.
            t_val = max(1, k_val // 4) 
            if k_val < 4 and t_val > k_val : # Ensure t <= k, especially for very small k
                t_val = k_val
            if t_val == 0 and k_val > 0: # If k//4 is 0, but k > 0 ensure t is at least 1 if k allows.
                t_val = 1 if k_val >=1 else 0


            print(f"  Testing with k = {k_val}, t = {t_val}")

            # Initialize materials that might be passed between stages
            S_priv, T_priv, F_priv_list, Pub_key_for_ops = None, None, None, None
            signature_for_ops = None

            # --- Key Generation Phase (New Scheme) ---
            def keygen_op_new_scheme_callable():
                # Note: generate_S_mixer takes t, though its internal logic might not use it extensively.
                _S = generate_S_mixer(field, k_val, t_val, verbose=0)
                _T = generate_T_mixer(field, k_val, verbose=0)
                _F_list = generate_F_matrices(field, k_val, t_val, verbose=0)
                _Pub_key = generate_public_key(_S, _T, _F_list, verbose=0)
                return (_S, _T, _F_list), _Pub_key # Return (private components), public_key

            if test_keygen_new_scheme:
                avg_kg_time, ((S_priv, T_priv, F_priv_list), Pub_key_for_ops) = \
                    time_operation_and_get_first_result(keygen_op_new_scheme_callable, num_iterations_new)
                results_keygen_new[sec_level_label][k_val] = avg_kg_time
                print(f"    Avg Key Gen Time: {avg_kg_time:.6f} seconds")
            else:
                results_keygen_new[sec_level_label][k_val] = "SKIPPED"
                if test_sign_new_scheme or test_certify_new_scheme: # Materials needed
                    print(f"    Key Generation: SKIPPED (generating materials untimed)")
                    (S_priv, T_priv, F_priv_list), Pub_key_for_ops = keygen_op_new_scheme_callable()
                else:
                    print(f"    Key Generation: SKIPPED")
            
            # --- Signing Phase (New Scheme) ---
            if test_sign_new_scheme:
                if S_priv and T_priv and F_priv_list: # Check if private materials are available
                    def sign_op_new_scheme_callable():
                        return sign(test_message_new, S_priv, T_priv, F_priv_list, t_val, verbose=0)
                    
                    avg_s_time, signature_for_ops = \
                        time_operation_and_get_first_result(sign_op_new_scheme_callable, num_iterations_new)
                    results_sign_new[sec_level_label][k_val] = avg_s_time
                    print(f"    Avg Sign Time:    {avg_s_time:.6f} seconds")
                else:
                    results_sign_new[sec_level_label][k_val] = "N/A (No PrivKey)"
                    print(f"    Avg Sign Time:    SKIPPED (Private key components not available)")
            else:
                results_sign_new[sec_level_label][k_val] = "SKIPPED"
                if test_certify_new_scheme: # Signature needed for timed certification
                    if S_priv and T_priv and F_priv_list:
                        print(f"    Signing: SKIPPED (generating signature untimed for certification test)")
                        signature_for_ops = sign(test_message_new, S_priv, T_priv, F_priv_list, t_val, verbose=0)
                    else:
                        print(f"    Signing: SKIPPED (Private key components not available)")
                else:
                    print(f"    Signing: SKIPPED")

            # --- Certification Phase (New Scheme, uses same certify logic) ---
            if test_certify_new_scheme:
                if Pub_key_for_ops and signature_for_ops:
                    def certify_op_new_scheme_callable():
                        return certify(Pub_key_for_ops, test_message_new, signature_for_ops, verbose=0)
                    
                    avg_c_time, _ = \
                        time_operation_and_get_first_result(certify_op_new_scheme_callable, num_iterations_new)
                    results_certify_new[sec_level_label][k_val] = avg_c_time
                    print(f"    Avg Certify Time: {avg_c_time:.6f} seconds")
                else:
                    results_certify_new[sec_level_label][k_val] = "N/A (No PK/Sig)"
                    missing_items = []
                    if not Pub_key_for_ops: missing_items.append("Public Key")
                    if not signature_for_ops: missing_items.append("Signature")
                    print(f"    Avg Certify Time: SKIPPED ({', '.join(missing_items)} not available)")
            else:
                results_certify_new[sec_level_label][k_val] = "SKIPPED"
                print(f"    Avg Certify Time: SKIPPED")

    # --- Output Tables (Modified Scheme) ---
    print("\n\n--- TIMING RESULTS FOR MODIFIED SCHEME ---")

    # (Using k_values_new for headers)
    k_headers_new = [str(k) for k in k_values_new] 
    
    max_q_label_len = 0
    if parameters_q_new:
        label_lengths = [len(label) for label in parameters_q_new.keys()]
        if label_lengths:
            max_q_label_len = max(label_lengths)
    
    q_col_width_new = max(max_q_label_len, len("Field\\k")) + 2
    data_col_widths_new = [max(len(kh), 18) for kh in k_headers_new] # For "XXX.XXXX" or status strings

    def print_table_new_scheme(table_data, table_title):
        print(f"\n{table_title}:")
        header_parts = [f"{'Field\\k':<{q_col_width_new}}"] + \
                       [f"{k_head:>{dw}}" for k_head, dw in zip(k_headers_new, data_col_widths_new)]
        print(" | ".join(header_parts))
        separator_parts = ['-' * q_col_width_new] + ['-' * dw for dw in data_col_widths_new]
        print("-+-".join(separator_parts))

        for field_label_table, k_times_table in table_data.items():
            # Field label is used directly (e.g., "GF_251")
            row_parts = [f"{field_label_table:<{q_col_width_new}}"]
            for i_table, k_val_table in enumerate(k_values_new):
                time_val = k_times_table.get(k_val_table)
                
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