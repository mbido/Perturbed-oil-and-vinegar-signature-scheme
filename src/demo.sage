load("sign.sage")
load("utils.sage")
load("certify.sage")

def verif(public_key, message, signature):
  field  = public_key[0].base_ring()
  k = len(public_key)
  message_vector = encode_message(message, field, k)
  for i in range(k):
      if (signature * public_key[i] * signature != message_vector[i]):
        return False
  return True


if __name__ == "__main__":
  field = GF(7, 'a')
  k = 4
  F = generate_F_matrices(field, k)
  A = generate_private_key(field, k)
  G = generate_public_key(A, F)
  message = "Hello, world!"
  X = sign(message, A, F, field, k)
  X_vec = vector(field, X)
  valid = verif(G,message,X_vec)
  print(X)
  print(valid)