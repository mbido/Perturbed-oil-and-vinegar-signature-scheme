load("sign.sage")
load("utils.sage")
load("certify.sage")

if __name__ == "__main__":
  # setting up the environment 
  field = GF(7, 'a')
  k = 8
  t = 3

  # Alice's Keys
  A_f = generate_F_matrices(field, k, t, 1)
  A_S = generate_S_mixer(field, k, t, 1)
  A_T = generate_T_mixer(field, k, 1)
  A_public = generate_public_key(A_S, A_T, A_f, 1)

  # Bob's Keys
  B_f = generate_F_matrices(field, k, t)
  B_S = generate_S_mixer(field, k, t)
  B_T = generate_T_mixer(field, k)
  B_public = generate_public_key(B_S, B_T, B_f)

  # Messages
  message1 = "First message to sign"
  message2 = "Second message to sign"

  # Alice signing the messages
  A_signed_1 = sign(message1, A_S, A_T, A_f, t, 1)
  A_signed_2 = sign(message2, A_S, A_T, A_f, t)

  # Bob signing the messages
  B_signed_1 = sign(message1, B_S, B_T, B_f, t)
  B_signed_2 = sign(message2, B_S, B_T, B_f, t)

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
  
  ## Invalid signatures -> inconsistent length
  print("======= Inconsistent length =======")
  print(certify(A_public[:-1], message1, A_signed_1,2))
  print(certify(A_public+[A_public[0]], message1, A_signed_1,2))
  
  # Setting up different fields
  other_field = GF(5, 'a')
  
  # Charlie's keys
  C_f = generate_F_matrices(other_field, k, t)
  C_S = generate_S_mixer(other_field, k, t)
  C_T = generate_T_mixer(other_field, k)
  C_public = generate_public_key(C_S, C_T, C_f)
  
  # Charlie signing the messages
  C_signed_1 = sign(message1, C_S, C_T, C_f, t)
  C_signed_2 = sign(message2, C_S, C_T, C_f, t)
  
  #More validations
  ## Valid signatures
  print("======== Valid signatures ========")
  print(certify(C_public, message1, C_signed_1))
  print(certify(C_public, message2, C_signed_2))
  
  ## Invalid 
  print("======= Inconsistent base field =======")
  print(certify(C_public, message1, A_signed_1))
  print(certify(A_public, message1, C_signed_1))
  print(certify(C_public, message2, A_signed_2,2))
  print(certify(A_public, message2, C_signed_2,2))