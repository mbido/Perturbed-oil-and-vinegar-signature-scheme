import utils

def fake_encode(k):
    return [0] * k

def certify(public_key,message,signature):
    """
    Check whether a given message and signature are valid
    for a corresponding public key.
    
    Parameters
    ----------
    public_key : list of k (2k x 2k)-matrices
      The public key 
    message : String
      The message to check
    signature : (2k x 1)-matrix
      The signature to check
    """
    k = len(public_key)
    # basic checks
    if len(signature) != k:
        return False
    if k == 0:
        return True
    ring = public_key[0].base_ring()
    for matrix in public_key:
        if matrix.nrows() != 2*k or matrix.ncols() != 2*k or matrix.base_ring() != ring:
            return False
    if signature.nrows() != 2*k or signature.ncols() != 1 or signature.base_ring() != ring:
        return False
    
    message_vector = utils.encode_message(message, ring, 2*k) # ... size 2k
    
    #verify
    for i in range(k):
        G_i = public_key[i]
        if (signature.transpose() * G_i * signature != message_vector):
            return False
    return True

if __name__ == "__main__":
    q = 2
    k = 4
    '''public_key = [block_diagonal_matrix(zero_matrix(GF(q),k),identity_matrix(GF(q),k)] * k
    message = "hello"
    #text to vector
    #message_vector = fake_encode(k) # ... size 2k
    signature = fake_encode(k)
    
    print(public_key,message,signature)'''