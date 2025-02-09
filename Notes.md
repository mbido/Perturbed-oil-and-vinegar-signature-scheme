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


### Lundi 3 Février
#### What have been done : 
Étapes pour l'attaque :
1. **Définir la clôture T :**
    *   Calculer les matrices $G_{ij} = G_i^{-1}G_j$ pour toutes les paires $(i, j)$ où $G_i$ est inversible (les $G_i$ sont les matrices de la clé publique).
    *   Considérer l'ensemble des $G_{ij}$ comme une base (ou une partie d'une base) pour un espace vectoriel T. En pratique, cet ensemble est souvent suffisant pour l'attaque, sans avoir besoin de l'étendre formellement pour inclure toutes les combinaisons linéaires possibles.

2. **Définir un vecteur symbolique R :**
    *   Créer un vecteur `R` de taille $2k$ dont les composantes sont des variables symboliques $r_1, r_2, ..., r_{2k}$ (où $k$ est la moitié du nombre de variables dans le schéma).

3. **Construire la matrice M :**
    *   Pour chaque matrice $T_i$ dans la base de T (ou simplement pour chaque $G_{ij}$), calculer le produit $T_i \cdot R$.
    *   Concaténer les vecteurs résultants $T_i \cdot R$ en colonnes pour former la matrice `M`. `M` aura donc $2k$ lignes et autant de colonnes que de matrices $T_i$ utilisées.

4. **Trouver une relation linéaire :**
    *   Exploiter le fait que le rang de `M` est au plus $k$ (une propriété clé de l'attaque).
    *   Rechercher une relation linéaire non triviale entre les $k+1$ premières lignes de `M`. Les coefficients de cette relation, $s_1, s_2, ..., s_{k+1}$, sont des inconnues que l'on cherche à déterminer.
    *   En pratique, on peut utiliser la forme échelonnée réduite de `M` pour trouver cette relation.

5. **Exprimer la relation comme une équation quadratique :**
    *   Pour chaque colonne de `M`, la relation linéaire trouvée à l'étape précédente (par exemple $\sum_{l=1}^{k+1} s_l \cdot M_{l,i} = 0$ pour la colonne $i$) peut être exprimée comme une équation quadratique. Cette équation fait intervenir les variables symboliques $r_j$ et les coefficients $s_l$ de la relation linéaire.

6. **Linéariser les équations quadratiques :**
    *   Introduire de nouvelles variables symboliques $z_{ij}$ pour remplacer chaque produit $r_i s_j$ (ou $r_j s_i$, l'ordre n'importe pas) dans les équations quadratiques.
    *   Remplacer chaque occurrence de $r_i s_j$ par $z_{ij}$ pour obtenir un système d'équations linéaires en les variables $z_{ij}$.

7. **Ajouter des équations linéaires (pour éliminer les solutions parasites) :**
    *   Générer des équations linéaires aléatoires en les variables $r_i$ et les ajouter au système.
    *   Cela permet de s'assurer que la solution du système correspond bien à un produit de la forme $r_i s_j$ et pas à une combinaison arbitraire de $z_{ij}$.

8. **Résoudre le système linéaire :**
    *   Résoudre le système d'équations linéaires (en les $z_{ij}$ et potentiellement en les $s_j$) pour trouver les valeurs des variables.

9. **Déduire des informations sur l'espace huile :**
    *   Analyser les solutions trouvées pour les $z_{ij}$ et $s_j$ afin d'en déduire des informations sur les valeurs possibles des $r_i$ qui correspondent à des vecteurs de l'espace huile.
    *   Cette étape peut être plus ou moins complexe selon la structure des solutions trouvées.

10. **Retrouver l'espace huile :**
    *   Avec suffisamment d'informations sur les $r_i$, on peut reconstruire l'espace huile, ce qui permet de casser complètement le schéma OV.
11. **Exprimer les formes quadratiques dans une base adaptée à l'espace huile :**
    *   Trouver une base de l'espace vectoriel engendré par les vecteurs solutions $r_i$ trouvés, qui correspond à l'espace huile.
    *   Compléter cette base en une base de l'espace vectoriel total (de dimension $2k$).
    *   Exprimer les formes quadratiques $G_e$ de la clé publique dans cette nouvelle base.
12. **Exploiter la linéarité des formes quadratiques dans la nouvelle base :**
    *   Les formes quadratiques $G_e$, lorsqu'elles sont exprimées dans la base adaptée à l'espace huile, deviennent linéaires dans les variables correspondant à la base de l'espace huile.
    *   Utiliser cette linéarité pour forger des signatures ou retrouver la clé secrète.


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


Polynomial $p$ of degree $d$, matrice $M \in F_q^{n\times n}$

Values of dim ker(p(M)) ?

$\dim(\ker(p(M))) + \dim(\im (p(M))) = \rank(p(M)) = n$

If $p$ is the zero-polynomial, then $\dim \ker(p(M)) = \dim \ker(0) = n$

In all other cases, we can look at only monic polynomials, as we are working over a field.

If $p$ is otherwise constant, then $\dim \ker(p(M)) = \dim \ker(Id) = 0$

If $p$ is linear, then $\dim \ker (p(M)) = \dim \ker(M) = n - \rank(M)$

If $p$ is affine, $p(M) = M + p_0 Id$. For any eigenvalue $\lambda$ of $M$, we can set $p_0 = -\lambda$, and then any associated eigenvector will map to $0$.
So $\dim \ker(p(M))$ can be the dimension of an eigenspace.

We can construct higher degree polynomials by multiplying $(x-\lambda)$ for each eigenvalue of $M$.

If $M$ has no eigenvalues?

If p is the characteristic polynomial, then $\dim \ker(p(M)) = n$



Unique monic annihilating polynomial

Consider a polynomial p of minimal degree such that p(M) = 0. We may force this to be monic by multiplying by the inverse of its most significant coefficient. We show this is unique: assume a and b are two distinct monic polynomials of degree d such that a(M) = 0 = b(M). Then a-b has degree at most d-1 and (a-b)(M) = a(M) - b(M) = 0. This is a contradiction, so there is a unique minimal polynomial p that is monic and such that p(M)=0.