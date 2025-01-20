# Notes projet de recherche : Schémas de signature multivarié.

## Réunions
### Lundi 20 Janvier

Difficultés : 
- implantation des shémas faciles
- premières attaques faciles
- partie 8) potentiellement très dure. 

Réunions :
- 1h
- les lundi à 14h
- 26.00.326



**Literature** envoyé par mail.

Pour la semaine prochaine :
- [ ] lire les papiers :
  - [ ] [Kipnis Shamir](articles/[4]-Kipnis-Shamir-1998.pdf)
  - [ ] [Beullens](articles/Beullens20.pdf)
- [ ] Faire l'implementation en sagemath
  - [ ] Implémenter les schémas
  - [ ] Casser les schémas (si possible)
  - [ ] Mesures des perfs du cassage (si vraiment on est chaud)

## Signature Oil & vineger (OV)

Let $A \in \mathcal{F}_n^{2k \times 2k}$ be a randomly generated invertible matrix. $A$ is our **private key**

Let $F = (F_1, \dots, F_k) \in (\mathcal{F}_n^{2k \times 2k})^k$ be a vector of $k$ randomly generated $2k×2k$ square matrices of the form:
$$F_e = \begin{pmatrix}
              0 & B_1 \\
              B_2 & B_3
        \end{pmatrix}$$

We can build our **public key** $G = (G_1, \dots, G_k)$ where each $G_e$ is defined as follow : 

$$G_e = A^\top F_e A$$

Given a message $M \in \mathcal{F}_n^k$ we want to build a **signature** $X = (x_1, \dots, x_{2k}) \in \mathcal{F}_n^{2k}$ ie. : 

$$
\begin{cases}
G_1(x_1,...,x_{2k}) = m_1 \\
G_2(x_1,...,x_{2k}) = m_2 \\
\vdots \\
G_k(x_1,...,x_{2k}) = m_k
\end{cases}
$$

For that, we first create $Y = (y_1, \dots, y_{2k}) \in \mathcal{F}_n^{2k}$. The first part $(y_1, \dots, y_k)$ is called the **Oil** and the second part $(y_{k + 1}, \dots, y_{2k})$ is called the **Vineger**. The vineger is randomly generated. To get the Oil, we have to solve the folowing system : 

$$
\begin{cases}
Y^\top F_1 Y = m_1 \\
\vdots \\
Y^\top F_k Y = m_k
\end{cases}
$$

If the system has not a unique solutions $\rightarrow$ we generate a new vineger and solve the system. Until we find a system with only one solution.

We can now get our signature $X$ defined as follow : 

$$X := A^{-1}Y$$


