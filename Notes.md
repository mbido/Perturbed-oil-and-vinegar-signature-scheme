# Notes projet de recherche : Schémas de signature multivarié.

## Réunions
### Lundi 20 Janvier

Difficultés supposés : 
- implantation des shémas faciles
- premières attaques faciles
- partie $8)$ potentiellement très difficile. 

Réunions :
- 1h
- les lundi à 14h
- 26.00.326

### Lundi 27 Janvier
- mqchallenge.org
- préparer démo propre avec option de verbose -> OK
- commencer les attaques (comment les décomposers)
- comment évaluer la sécurité d'un algo

**Pour la semaine prochaine :**
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

Let $Y = \begin{bmatrix} O \\ V \end{bmatrix}$ with $O, V \in \mathcal{F}_n^k$.

Let $F_e = 
\begin{bmatrix}
0 & B_1 \\ 
B_2 & B_3 
\end{bmatrix}$ avec $B_i \in \mathcal{F}_n^{k \times k}$. 

Let $m_e \in \mathcal{F}_n$.

Then:
$$\begin{aligned}
&&Y^\top F_e Y &= m_e \\
&\Leftrightarrow &\begin{bmatrix} O^\top & V^\top \end{bmatrix} \begin{bmatrix}
0 & B_1 \\ 
B_2 & B_3 
\end{bmatrix} \begin{bmatrix} O \\ V \end{bmatrix} &= m_e \\
&\Leftrightarrow &\begin{bmatrix} V^\top B_2 & (O^\top B_1 + V^\top B_3) \end{bmatrix} \begin{bmatrix} O \\ V \end{bmatrix} &= m_e \\
&\Leftrightarrow &V^\top B_2 O + (O^\top B_1 + V^\top B_3) V &= m_e \\
&\Leftrightarrow &V^\top B_2 O + V^\top B_1^\top O + V^\top B_3V &= m_e \\
&\Leftrightarrow &(V^\top B_2 + V^\top B_1^\top) O &= m_e - V^\top B_3 V
\end{aligned}$$

And so :

$$\begin{aligned}
\begin{cases}
Y^\top F_1 Y = m_1 \\
\vdots \\
Y^\top F_k Y = m_k
\end{cases} \\
\Leftrightarrow\begin{bmatrix}
V^\top B_{1, 2} + V^\top B_{1, 3}^\top \\
\vdots \\
V^\top B_{k, 2} + V^\top B_{k, 3}^\top
\end{bmatrix}
O = \begin{bmatrix}
m_1 - V^\top B_{1, 3}V\\
\vdots \\
m_k - V^\top B_{k, 3}V
\end{bmatrix}
\end{aligned}
$$

This is a simple $Ax = b$ system to solve !

We can now get our signature $X$ defined as follow : 

$$X := A^{-1}Y$$


