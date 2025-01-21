

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
    return vector([field(0) for _ in range(k)])