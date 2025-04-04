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

If p is the minimal polynomial (or a product, such as the characteristic polynomial), then $\dim \ker(p(M)) = n$



Unique monic annihilating polynomial


Consider a polynomial p of minimal degree such that p(M) = 0. We may force this to be monic by multiplying by the inverse of its most significant coefficient. We show this is unique: assume a and b are two distinct monic polynomials of degree d such that a(M) = 0 = b(M). Then a-b has degree at most d-1 and (a-b)(M) = a(M) - b(M) = 0. This is a contradiction, so there is a unique minimal polynomial p that is monic and such that p(M)=0.


## Le Schéma de Signature OV+ (Notation Matricielle KS)

OV+ est une modification du schéma Oil and Vinegar (OV) original (équilibré, $v=n$) conçue pour contrecarrer l'attaque de Kipnis-Shamir. Elle introduit des termes "huile $\times$ huile" dans certaines équations secrètes.

### 1. Contexte : Rappel sur OV Équilibré (Notation KS)

*   **Variables Secrètes ($Y$) :** Un vecteur de $2n$ variables $Y = (y_1, \dots, y_n, y_{n+1}, \dots, y_{2n})^T \in \mathbb{F}_q^{2n}$.
    *   $Y_O = (y_1, \dots, y_n)^T$ : Vecteur des $n$ variables "huile".
    *   $Y_V = (y_{n+1}, \dots, y_{2n})^T$ : Vecteur des $n$ variables "vinaigre".
*   **Variables Publiques ($X$) :** Un vecteur de $2n$ variables $X \in \mathbb{F}_q^{2n}$.
*   **Transformation Secrète ($A$) :** Une matrice **secrète** $A \in GL_{2n}(\mathbb{F}_q)$ (matrice $2n \times 2n$ inversible) reliant les variables : $Y = AX$. $A$ mélange les variables huile et vinaigre.
*   **Équations Secrètes (Quadratiques) :** $n$ équations $Y^T F_i Y = m_i$ pour $i = 1, \dots, n$, où $m = (m_1, \dots, m_n)^T$ est le hash du message. Les $F_i$ sont des matrices secrètes $2n \times 2n$.
*   **Structure OV des $F_i$ :** La propriété clé d'OV est que les matrices $F_i$ ont une structure par blocs spécifique par rapport à la partition Huile/Vinaigre :
    $$ F_i = \begin{pmatrix} 0_{n \times n} & A_i \\ B_i & C_i \end{pmatrix} $$
    où $0_{n \times n}$ est la matrice nulle $n \times n$, et $A_i, B_i, C_i$ sont des matrices $n \times n$ secrètes. (Souvent $B_i = A_i^T$). Le bloc nul $0_{n \times n}$ signifie qu'il n'y a pas de termes $y_j y_k$ avec $j, k \le n$ (huile $\times$ huile) dans $Y^T F_i Y$.
*   **Clé Publique (Matrices $P_i$) :** Les $n$ équations publiques sont $X^T P_i X = m_i$, où les matrices publiques $P_i$ sont données par :
    $$ P_i = A^T F_i A $$
    La clé publique est l'ensemble $\{P_1, \dots, P_n\}$.
*   **Attaque KS :** Exploite la structure des $F_i$ et le fait que $n=v$ pour trouver l'espace "huile" public $\mathcal{O}_{pub} = A^{-1}(\text{span}\{e_1, \dots, e_n\})$ en analysant les produits $P_i P_j^{-1}$.

### 2. Introduction d'OV+ (Notation KS)

OV+ modifie la structure des matrices secrètes $F_i$.

### 3. Paramètres d'OV+

*   $q$ : Ordre du corps fini $\mathbb{F}_q$.
*   $n$ : Nombre de variables huile *et* de variables vinaigre. Dimension totale $2n$. Nombre d'équations $n$.
*   $t$ : Entier $0 \le t \le n$, nombre d'équations secrètes perturbées.

### 4. Génération des Clés OV+

*   **Clé Secrète :**
    1.  Choisir une matrice secrète inversible $A \in GL_{2n}(\mathbb{F}_q)$.
    2.  Choisir $n$ matrices secrètes $F_1, \dots, F_n$ de taille $2n \times 2n$ avec la structure suivante :
        *   **Pour $i = 1, \dots, t$ (Matrices Perturbées) :**
            $$ F_i = \begin{pmatrix} Q_i & A_i \\ B_i & C_i \end{pmatrix} \quad \text{avec } Q_i \neq 0_{n \times n} $$
            $Q_i$ est une matrice $n \times n$ **non nulle** (souvent symétrique et aléatoire) représentant les termes huile $\times$ huile aléatoires. $A_i, B_i, C_i$ sont des matrices $n \times n$ secrètes aléatoires (avec $B_i = A_i^T$ si on travaille avec des formes bilinéaires symétriques).
        *   **Pour $i = t+1, \dots, n$ (Matrices OV Standard) :**
            $$ F_i = \begin{pmatrix} 0_{n \times n} & A_i \\ B_i & C_i \end{pmatrix} $$
            Ces matrices ont la structure OV classique sans termes huile $\times$ huile.
    La clé secrète est $(A, \{F_1, \dots, F_n\})$.

*   **Clé Publique :**
    1.  Calculer les $n$ matrices publiques $P_i = A^T F_i A$.
    2.  La clé publique est l'ensemble $\{P_1, \dots, P_n\}$.

### 5. Génération de Signature OV+

Pour signer un message $M$ (avec hash $m = H(M) \in \mathbb{F}_q^n$) :
1.  **Objectif :** Trouver $X$ tel que $X^T P_i X = m_i$ pour $i=1, \dots, n$. Ceci est équivalent à trouver $Y$ tel que $Y^T F_i Y = m_i$ puis calculer $X=A^{-1}Y$.
2.  **Choisir le Vinaigre :** Fixer aléatoirement le vecteur des variables vinaigre $Y_V \in \mathbb{F}_q^n$.
3.  **Formuler le Système en Huile $Y_O$ :** Le système $Y^T F_i Y = m_i$ s'écrit, en décomposant $Y = \begin{pmatrix} Y_O \\ Y_V \end{pmatrix}$ :
    *   Pour $i=1, \dots, t$ :
        $$ \begin{pmatrix} Y_O \\ Y_V \end{pmatrix}^T \begin{pmatrix} Q_i & A_i \\ B_i & C_i \end{pmatrix} \begin{pmatrix} Y_O \\ Y_V \end{pmatrix} = Y_O^T Q_i Y_O + Y_O^T A_i Y_V + Y_V^T B_i Y_O + Y_V^T C_i Y_V = m_i $$
        C'est une équation **quadratique** en les $n$ inconnues de $Y_O$.
    *   Pour $i=t+1, \dots, n$ :
        $$ \begin{pmatrix} Y_O \\ Y_V \end{pmatrix}^T \begin{pmatrix} 0 & A_i \\ B_i & C_i \end{pmatrix} \begin{pmatrix} Y_O \\ Y_V \end{pmatrix} = Y_O^T A_i Y_V + Y_V^T B_i Y_O + Y_V^T C_i Y_V = m_i $$
        C'est une équation **linéaire** en les $n$ inconnues de $Y_O$ (puisque $Y_V$ est fixé).
4.  **Résoudre le Système Mixte :**
    *   On a $n-t$ équations linéaires et $t$ équations quadratiques pour les $n$ variables de $Y_O$.
    *   Résoudre le système linéaire (les $n-t$ dernières équations) pour exprimer $n-t$ variables de $Y_O$ en fonction des $t$ autres (si rang $n-t$).
    *   Substituer dans les $t$ équations quadratiques pour obtenir un système de $t$ équations quadratiques en $t$ variables.
    *   Résoudre ce système $t \times t$ quadratique.
    *   Si une solution $Y_O$ est trouvée, former $Y = \begin{pmatrix} Y_O \\ Y_V \end{pmatrix}$.
    *   Sinon (pas de solution linéaire ou quadratique), retourner à l'étape 2 avec un nouveau $Y_V$.
5.  **Calculer la Signature Publique :** $X = A^{-1}Y$.

### 6. Vérification de Signature OV+

Identique à OV :
1.  Calculer $m = H(M)$.
2.  Calculer $m'_{i} = X^T P_i X$ pour $i=1, \dots, n$ en utilisant la clé publique $\{P_i\}$ et la signature $X$.
3.  Vérifier si $m' = m$.

### 7. Considérations de Sécurité (Notation KS)

*   **Attaque KS directe :** L'attaque originale calculait l'espace invariant $\mathcal{O}_{pub} = A^{-1}(\text{span}\{e_1, \dots, e_n\})$ commun aux opérateurs $P_i P_j^{-1}$. Cette attaque échoue si $P_i$ ou $P_j$ provient d'une matrice $F_k$ perturbée ($k \le t$), car la structure $F_k O \subseteq V$ n'est plus garantie à cause du bloc $Q_k$. L'opérateur $P_i P_j^{-1}$ ne laisse plus nécessairement $\mathcal{O}_{pub}$ invariant.
*   **Nécessité d'isoler les équations non perturbées :** Un attaquant pourrait essayer de trouver des combinaisons linéaires des $P_i$ qui correspondent uniquement aux $F_j$ non perturbées ($j > t$) pour ensuite appliquer l'attaque KS. La difficulté réside dans le fait de trouver ces combinaisons spécifiques (c'est l'idée derrière la condition $q^{2t}$ ou $q^{3t}$ dans les analyses d'attaques sur les variantes "+").
*   **Rôle de $t$ :** Le paramètre $t$ contrôle le compromis entre la complexité de la signature (résolution $t \times t$ quadratique) et la résistance présumée aux attaques structurelles comme KS.

En utilisant la notation matricielle de KS, on voit clairement comment la perturbation "+" (l'introduction des blocs $Q_i \neq 0$ pour $i \le t$) modifie la structure algébrique fondamentale des matrices secrètes $F_i$, rendant l'analyse par espace invariant de l'attaque KS inapplicable directement.
