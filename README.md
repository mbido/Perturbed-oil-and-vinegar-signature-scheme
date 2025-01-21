# UOV-study
This repository is a study of the multivariate signature schema OV, UOV and OV+^


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
...
```
### Remarks
The `forge.sage` file will contain all the forging methods we will implement.

## Implementation
### Encoding a message
To sign a message we will need to encode the message first:
1) Fix $k$, the number of polynomes in the public key.
2) Fix $q$, a prime number power to define our field $\mathcal{F}_q$.
3) Parse the message in $k$ equal parts (the last one can be smaller).
4) Hash those blocs with a hash function in $\mathcal{F}_q$ to get the $m_e$.