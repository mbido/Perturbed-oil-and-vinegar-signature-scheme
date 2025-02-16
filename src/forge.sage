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
        ker = sqrt(candidate).kernel()
        if (ker.dimension() * 2 != G_i.nrows()):
            candidate = None
    print(ker)
    fake_A = complete_basis(ker)
    fake_F = [fake_A.inverse().transpose()*G*fake_A.inverse() for G in public_key]
    return fake_A,fake_F

def forge_signature(message,public_key):
    A,F = forge_key(public_key)
    s = sign(message,A,F)
    print(s)
    print(certify(public_key,message,s))

def complete_basis(partial):
    bm = partial.basis_matrix()
    complement = bm.right_kernel().basis()
    complete = complement + bm.rows()
    return Matrix(complete)
    

def forge_sign(public_key,message):
    [forged_A,forged_F] = forge_key(public_key)
    sign(message,A,F)
    