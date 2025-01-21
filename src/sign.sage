
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
  return matrix(field, k)

def generate_F_matrices(field, k):
  """
  Generate the vector of random matrices F for the given field.

  Parameters
  ----------
  field : Field
    The finite field over which the matrices are to be generated.
  k : integer
    The number of matrices to generate and 1/2 the size of the matrices.

  Returns
  -------
  vector of matrices
    The generated vector of random matrices for the specified field.
    The matrices are of size 2k*2k and there top left k*k submatrix is 0.
  """
  return vector([matrix(field, k) for _ in range(k)])


def generate_public_key(A, F):
"""
Generate the public key for the UOV signature scheme.

Parameters
----------
A : list of numpy.ndarray
  A list of k matrices, where each matrix is of size (n, n).
F : list of numpy.ndarray
  A list of k matrices, where each matrix is of size (n, n).

Returns
-------
numpy.ndarray
  A vector of k matrices representing the public key.
"""

def sign(M, A, F):
  """
  Sign a message M using the private key A, the vector of random matrices F
  and the OV scheme. All of that in a field \mathcal{F}_q.

  Parameters
  ----------
  M : string
    The message we want to sign.
  A : matrix
    The private key, a k*k invertible random matrix
  F : vector of matrices
    The vector of matrices used to build the public key.

  Returns
  -------
  vector in \mathcal{F}_q
    The signature for the message being a sage vector

  Examples
  --------
  TODO
  """
  return vector(GF(2), [0])

if __name__ == "__main__":
  print(sign(0, 0, 0))