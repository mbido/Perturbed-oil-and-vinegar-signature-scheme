def certify(public_key,message,signature):
    k = len(public_key)/2
    
	#text to vector
    message_vector = # ... size 2k
    
    #verify
    for i in range(2*k):
        G_i = public_key[i]
        x_i = signature[i]
        m_i = message_vector[i]
        if (x_i.transpose() * G_i * x_i != m_i):
            return False
    return True

if __name__ == "__main__":
    q = 2
    k = 4
    public_key = [identity_matrix(GF(q), )] * 2k
    print(0)