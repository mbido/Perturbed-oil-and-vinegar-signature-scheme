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
            print(factors)
            candidate = None
            timeout -= 1
            if (timeout <= 0):
                return
            continue
    print(candidate)
    print(candidate.charpoly())
    print(candidate.charpoly().factor())

def forge_sign(public_key,message):
    forged_key = forge_key(public_key)
    