from pympler import asizeof
import sys

def print_element_size(order):
    field = GF(order)
    element = field.random_element()
    elt_size = asizeof.asizeof(element)

    print(field, element)
    print(f"for a field with {order} elements, the size is:\t{elt_size}")
    return elt_size
"""
print_element_size(251)
print_element_size(4093)
print_element_size(65521)
"""

def temp(k, size):
    return float((2*k**3 + k**2) * size) / 8, float(5*k**2 * size) / 8

print(temp(39, 8))
print(temp(53, 12))
print(temp(69, 16))


