# from certify import *
# load("sign.sage")
load("certify.sage")

if __name__ == "__main__":
  field = GF(7, 'a')
  k = 4
  F = generate_F_matrices(field, k)
  A = generate_private_key(field, k)
  G = generate_public_key(A, F)
  message = "Hello, world!"
  X = sign(message, A, F, field, k)
  #X_V = vector(X)
  valid = certify(G,message,X)
  print(X)
  # print(valid)
  
