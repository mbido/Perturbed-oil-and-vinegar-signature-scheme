import random
load("sign.sage")
load("utils.sage")

def forge_key(public_key):
    invertible_pub = list(filter(lambda M: (M+M.transpose()).is_invertible(),public_key))
    candidate = None
    while candidate is None:
        i = random.randrange(len(invertible_pub))
        j = random.randrange(len(invertible_pub))
        G_i = invertible_pub[i] + invertible_pub[i].transpose()
        G_j = invertible_pub[j] + invertible_pub[j].transpose()
        candidate = G_i.inverse() * G_j
        charpoly = candidate.charpoly()
        factors = charpoly.factor()
        sqrt = 1
        for f in factors:
            sqrt *= f[0]^(f[1]//2)
        ker = sqrt(candidate).right_kernel()
        #print('kernel')
        #print(ker)
        if (ker.dimension()*2 != G_i.nrows()):
            candidate = None
      
    fake_A = complete_basis(ker).transpose().inverse()
    
    #rand_oil = vector([fake_A.base_ring().random_element() for i in range(G_i.nrows()//2)]+[0 for i in range(G_i.nrows()//2)])
    #rand_vin = vector([0 for i in range(G_i.nrows()//2)]+[fake_A.base_ring().random_element() for i in range(G_i.nrows()//2)])
    #print(rand_oil)
    #print(rand_vin)
    #print(fake_A * rand_oil)
    #print(fake_A * rand_vin)
    
    #for i in range(len(public_key)):
        #M = fake_A.inverse().transpose() * public_key[i] * fake_A.inverse()
        #print(M)
        #print(M.rank())
    
    fake_F = [fake_A.inverse().transpose()*G*fake_A.inverse() for G in public_key]
    return fake_A,fake_F

def forge_signature(message,public_key):
    A,F = forge_key(public_key)
    s = sign(message,A,F)
    print(s)
    print(certify(public_key,message,s))

def complete_basis(partial):
    bm = partial.basis_matrix()
    #print('bm')
    #print(bm)
    complement = bm.right_kernel().basis()
    complete = bm.rows() + complement
    #print('complete')
    #print(Matrix(complete))
    return Matrix(complete)

def reverse_rows(M):
    return matrix(M.base_ring(),M.rows()[::-1])

def forge_sign(public_key,message):
    [forged_A,forged_F] = forge_key(public_key)
    sign(message,A,F)
