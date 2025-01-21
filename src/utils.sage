def simple_hash(string, field):
  """
  Convert a string into an element of the given field using a simple hash function.

  Parameters
  ----------
  string : string
    The string to be hashed.
  field : Field
    The finite field over which the hash is to be computed.

  Returns
  -------
  element of field
    The hashed value of the string as an element of the specified field.
  """
  int_representation = int.from_bytes(string.encode('utf-8'), 'big')
  return field.from_integer(int_representation % field.order())**13

def encode_message(message, field, k):
  """
  Encode a message into a vector of k elements in the given field.

  Parameters
  ----------
  message : string
    The message to be encoded.
  field : Field
    The finite field over which the message is to be encoded.
  k : integer
    The size of the encoded message.

  Returns
  -------
  vector
    The encoded message as a vector of k elements in the specified field.
  """
  block_size = len(message) // k + 1
  split_message = [message[i*block_size:(i+1)*block_size] for i in range(k)]
  return vector([simple_hash(m, field) for m in split_message])


if __name__ == "__main__":
  field = GF(2**8, 'a')
  k = 4
  message = "Hello, world!"
  print(simple_hash(message, field))
  print(encode_message(message, field, k))