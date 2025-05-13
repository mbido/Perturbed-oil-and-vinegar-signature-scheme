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
    for i in range(len(public_key)):
        matrix = public_key[i]
        if matrix.nrows() != 2*k or matrix.ncols() != 2*k:
            if verbose > 0:
                print('key list has length',k)
                print('key',i,'is of size',matrix.nrows(),'x',matrix.nrows(),'not',2*k,'x',2*k)
                print(matrix)
                print()
            return False
        if matrix.base_ring() != ring:
            if verbose > 0:
                print('key',i,'has base ring',matrix.base_ring(),'instead of',ring)
                print('key 0 (',ring,'):')
                print(public_key[0])
                print('key',i,'(',matrix.base_ring(),'):')
            return False
    if signature.length() != 2*k:
        if verbose > 0:
            print('signature is of size',signature.length(),'instead of',2*k)
            print('signature:')
            print(signature)
        return False
    if signature.base_ring() != ring:
        if verbose > 0:
            print('signature has base ring',signature.base_ring(),'instead of',ring)
            print('signature:')
            print(signature)
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