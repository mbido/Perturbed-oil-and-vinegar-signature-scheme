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
    k = len(public_key)
    # basic checks
    ring = public_key[0].base_ring()
    for matrix in public_key:
        if matrix.nrows() != 2*k or matrix.ncols() != 2*k or matrix.base_ring() != ring:
            return False
    if signature.length() != 2*k or signature.base_ring() != ring:
        return False
    
    message_vector = encode_message(message, ring, k) # ... size k
    
    #verify
    for i in range(k):
        if (signature * public_key[i] * signature != message_vector[i]):
            return False
    return True