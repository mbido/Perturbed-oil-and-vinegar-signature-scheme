import random
load("sign.sage")
load("utils.sage")

def forge_key(public_key):
    
    invertible_pub = list(filter(lambda M: M.is_invertible(),public_key))
    # loop until good candidate found
    candidate = None
    timeout = 100
    while candidate is None:
        # select a random G_i^-1 G_j
        i = random.randrange(len(invertible_pub))
        j = random.randrange(len(invertible_pub))
        candidate = invertible_pub[i].inverse() * invertible_pub[j]
        charpoly = candidate.charpoly()
        factors = charpoly.factor()
        if len(factors) != 2 or factors[0][1] != 1 or factors[1][1] != 1:
            #print(factors)
            candidate = None
            timeout -= 1
            if (timeout <= 0):
                return
            continue
    print(candidate)
    print(candidate.charpoly())
    print(candidate.charpoly().factor())
    factors = candidate.charpoly().factor()
    poly1 = factors[0][0]
    poly2 = factors[1][0]
    print(poly1(candidate).kernel())
    print(poly2(candidate).kernel())
    

def forge_sign(public_key,message):
    [forged_A,forged_F] = forge_key(public_key)
    sign(message,A,F)
    