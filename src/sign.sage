import utils

def generate_private_key(field, k):
  """
  Generate a private key for the given field.

  Parameters
  ----------
  field : Field
    The finite field over which the private key is to be generated.
  k : integer
    The size of the private key.

  Returns
  -------
  matrix
    The generated private key for the specified field.
  """
  A = random_matrix(field, 2*k)
  while not A.is_invertible(): # we loop very rarely
    A = random_matrix(field, 2*k)
  return A

def generate_F_matrices(field, k):
  """
  Generate the list of random matrices F for the given field.

  Parameters
  ----------
  field : Field
    The finite field over which the matrices are to be generated.
  k : integer
    The number of matrices to generate and 1/2 the size of the matrices.

  Returns
  -------
  list of matrices
    The generated list of random matrices for the specified field.
    The matrices are of size 2k*2k and there top left k*k submatrix is 0.
    F_e = [0 , B1]
          [B2, B3]
  """
  F = []
  for _ in range(k):
    F_e = random_matrix(field, 2*k)
    F_e[:k, :k] = matrix(field, k)
    F.append(F_e)
  return F


def generate_public_key(A, F):
  """
  Generate a public key using the private key A and the list of random matrices F.

  Parameters
  ----------
  A : matrix
    The private key, a k*k invertible random matrix.
  F : list of matrices
    The list of matrices used to build the public key. Each matrix is of size 2k*2k.

  Returns
  -------
  list of matrices
    The generated public key, which is a list of k matrices of size 2k*2k.
  """
  G = []
  for i, F_e in enumerate(F):
    G.append(A.transpose() * F_e * A)
  return G



def create_system(M, A, F, V):
  """
  Create the linear system for the UOV scheme.

  Parameters
  ----------
  M : vector
    The encoded message in the field (length k).
  A : matrix
    The private key. (Currently unused in the system construction.)
  F : list of matrices
    The list of random matrices used to build the system (each of size 2k x 2k).
  V : vector
    The partial signature (vinegar part), of dimension k.

  Returns
  -------
  L : matrix
    A k x k matrix used in solving for the oil part.
  r : vector
    A k-dimensional vector (right-hand side) for the system.
  """
  k = len(V)
  r = [0] * k                     # right part of the system for later
  L = [[0] * k for _ in range(k)] # left part of the system for later
  
  for e in range(k):
    # top right part of F[e]
    B_1 = F[e][:k, k:]
    # bottom left part of F[e]
    B_2 = F[e][k:, :k]
    # bottom right part of F[e]
    B_3 = F[e][k:, k:]

    # Compute quadratic form V^T * B_3 * V using dot product
    r[e] = M[e] - V.dot_product(B_3 * V)
    # Compute row vector V * (B_2 + B_1^T) and convert to list
    L[e] = (V * (B_2 + B_1.transpose())).list()

  return matrix(field, L), vector(field, r)


def sign(message, A, F):
  """
  Sign a message using the private key A, the vector of random matrices F
  and the OV scheme. All of that in a field \mathcal{F}_q.

  Parameters
  ----------
  message : string
    The message we want to sign.
  A : matrix
    The private key, a k*k invertible random matrix
  F : vector of matrices
    The vector of matrices used to build the public key.

  Returns
  -------
  vector in \mathcal{F}_q
    The signature for the message being a sage vector

  """
  M = utils.encode_message(message, field, k)
  V = random_vector(field, k)  # Vinegar variables (fixed)
  
  # Regenerate L and r until L is invertible
  L, r = create_system(M, A, F, V)
  while not L.is_invertible():
    V = random_vector(field, k)
    L, r = create_system(M, A, F, V)

  O = L.solve_right(r)  # Solve for oil variables
  Y = vector(field, list(O) + list(V))  # Concatenate O and V (order corrected)
  return A.inverse() * Y  # Compute signature using inverse, not transpose

counter = 0

if __name__ == "__main__":
  print("testing")
  field = GF(7, 'a')
  k = 4
  F = generate_F_matrices(field, k)
  A = generate_private_key(field, k)
  G = generate_public_key(A, F)
  message = "Hello, world!"
  X = sign(message, A, F)
  print(X)