# UOV-study
This repository is a study of the multivariate signature schema OV, UOV and OV$\widehat{+}$


## Structure of the project
The structure can change but will change here first before updating the 
physical structure.
```sh
.
├── data
│   ├── messages
│   │   ├── m1.txt
│   │   ├── m2.txt
│   │   ...
│   ...
├── src
│   ├── OV
│   │   ├── sign.sage
│   │   ├── certif.sage
│   │   ├── forge.sage
│   │   ├── utils.sage
│   ...
├── tests
│   ├── OV
│   │   ├── <test-name>.sage
│   │   ...
│   ...
├── prep_scripts.sh
...
```
### Remarks
The `forge.sage` file will contain all the forging methods we will implement.
The `prep_script.sh` converts the .sage modules in basics .py moduls that we can import.

## Implementation
### Encoding a message
To sign a message we will need to encode the message first:
1) Fix $k$, the number of polynomes in the public key.
2) Fix $q$, a prime number power to define our field $\mathcal{F}_q$.
3) Parse the message in $k$ equal parts (the last one has the remainder).
4) Hash those blocs with a hash function in $\mathcal{F}_q$ to get the $m_e$.


## Documentation
To document our code, we will use the **numpydoc** format.
Here is an example of such a doc : 
```py 
def add(a, b):
  """
  Additionne deux nombres.

  Parameters
  ----------
  a : int or float
      Le premier nombre.
  b : int or float
      Le deuxième nombre.

  Returns
  -------
  int or float
      La somme de a et b.

  Examples
  --------
  >>> add(2, 3)
  5
  >>> add(1.5, 2.5)
  4.0
  """
  return a + b
```
