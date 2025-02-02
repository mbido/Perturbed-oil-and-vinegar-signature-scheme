load("sign.sage")
load("utils.sage")

def certify(public_key,message,signature, verbose=0):
    """
    Check whether a given message and signature are valid
    for a corresponding public key.
    
    Parameters
    ----------
    public_key : list of k (2k x 2k)-matrices
      The public key 
    message : String
      The message to check
    vector : 2k-vector
      The signature to check
    
    Returns
    -------
    boolean
      Whether this is a valid signature for the message given the public key
    """
    if verbose > 0:
        print(f"\n=======\nBegin certify() with verbose = {verbose}\n=======\n")
    k = len(public_key)
    # basic checks
    ring = public_key[0].base_ring()
    for matrix in public_key:
        if matrix.nrows() != 2*k or matrix.ncols() != 2*k or matrix.base_ring() != ring:
            return False
    if signature.length() != 2*k or signature.base_ring() != ring:
        return False
    
    message_vector = encode_message(message, ring, k) # ... size k
    
    if verbose > 0:
        print(f"message_vector : {message_vector}")

    #verify
    for i in range(k):
        if verbose > 1:
            print(f"signature * public_key[{i}] * signature : ")
            print(signature)
            print("*")
            print(public_key[i])
            print("*")
            print(signature)
            print("=")
            print(signature * public_key[i] * signature)
            print()
        if (signature * public_key[i] * signature != message_vector[i]):
            if verbose > 1:
                print(f"This is not equal to message_vector[{i}] : {message_vector[i]}")
            return False
    return True