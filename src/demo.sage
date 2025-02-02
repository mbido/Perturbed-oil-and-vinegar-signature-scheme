load("sign.sage")
load("utils.sage")
load("certify.sage")

if __name__ == "__main__":
  # setting up the environnement 
  field = GF(7, 'a')
  k = 4

  # Alice's Keys
  A_f = generate_F_matrices(field, k, 0)
  A_private = generate_private_key(field, k, 0)
  A_public = generate_public_key(A_private, A_f, 0)

  # Bob's Keys
  B_f = generate_F_matrices(field, k)
  B_private = generate_private_key(field, k)
  B_public = generate_public_key(B_private, B_f)

  # Messages
  message1 = "First message to sign"
  message2 = "Seconde message to sign"

  # Alice signing the messages
  A_signed_1 = sign(message1, A_private, A_f, 0)
  A_signed_2 = sign(message2, A_private, A_f)

  # Bob signing the messages
  B_signed_1 = sign(message1, B_private, B_f)
  B_signed_2 = sign(message2, B_private, B_f)

  # Validations 
  ## Valid signatures
  print("======== Valid signatures ========")
  print(certify(A_public, message1, A_signed_1))
  print(certify(A_public, message2, A_signed_2))
  print(certify(B_public, message1, B_signed_1))
  print(certify(B_public, message2, B_signed_2))

  ## Invalid signatures -> wrong message tested
  print("======== Wrong message tested ========")
  print(certify(A_public, message2, A_signed_1))
  print(certify(A_public, message1, A_signed_2))
  print(certify(B_public, message2, B_signed_1))
  print(certify(B_public, message1, B_signed_2))

  ## Invalid signatures -> wrong signature tested
  print("======== Wrong signature tested ========")
  print(certify(A_public, message1, A_signed_2))
  print(certify(A_public, message2, A_signed_1))
  print(certify(B_public, message1, B_signed_2))
  print(certify(B_public, message2, B_signed_1))

  ## Invalid signatures -> wrong person tested
  print("======== Wrong person tested ========")
  print(certify(A_public, message1, B_signed_1))
  print(certify(A_public, message2, B_signed_2))
  print(certify(B_public, message1, A_signed_1))
  print(certify(B_public, message2, A_signed_2, 2))