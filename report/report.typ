// ------------------- Preamble -------------------

// --- Theorems
#import "@preview/theoretic:0.2.0" as theoretic: theorem, proof, qed
#show ref: theoretic.show-ref
#let corollary = theorem.with(kind: "corollary", supplement: "Corollary")
#let example = theorem.with(kind: "example", supplement: "Example", number: none)
// ---

// --- Code snippets
// #import "@preview/codly:1.2.0": *
// #import "@preview/codly-languages:0.1.1": *
// #show: codly-init.with()
// ---

// --- Getting something that looks like LateX
#set page(margin: 1.75in, numbering: "1")
#set math.mat(delim: "[")
#set par(leading: 0.55em, spacing: 0.55em, first-line-indent: 1.8em, justify: true)
#set text(
  lang: "en"
)
#set text(font: "New Computer Modern")
#show raw: set text(font: "New Computer Modern Mono")
#show heading: set block(above: 1.4em, below: 1em)
// ---

// --- some shortcuts
#let normal(input) =  text(12pt)[#input]
#let big(input) = text(14pt)[#input]
#let Big(input) = text(18pt)[#input]
#let large(input) = text(22pt)[#input]
#let Large(input) = text(26pt)[#input]
#let HUGE(input) = text(30pt)[#input]
// ---

// --- header
#let header-title = "UOV study - Bell & Bidault"

#let first-page-header = 3

#let header-content = context {
    let current = counter(page).get().first()

    if current < first-page-header {
      return
    }
    
    let side = right
    if calc.rem(current,2) == 0{
      side = left
    }

    context {
      align(side + horizon)[
        #header-title
        #v(-2pt)
        #line(length:100%, stroke: 0.9pt)
      ]
    }
  }
#set page(header: header-content)
// ---

// --- small modifs
#set enum(numbering: "1.")
#set heading(numbering: "I.1.a -")
#set math.equation(numbering: "(1)")
// ---

// -----------------------------------------------

// ----------------- Title page ------------------

#align(center + horizon)[
  #large[*Unbalanced Oil and Vinegar Signature Schemas*]

  #big[Master's project - CCA]
  
  #datetime.today().display("[day]. [month repr:long] [year]")
]

#align(bottom)[
  #stack(
      dir: ltr,
      align(left + top)[#normal[Supervisor: Pierre Pébereau]],
      h(1fr),
      align(right)[#normal[ 
      Nicholas Bell - 21400099

      Matthieu Bidault - 21401573
    ]],
  )
]

// -------------- Table of contents --------------

#pagebreak()
#outline(title:"Contents", depth:3)
#pagebreak()

// ----------------- Begin document --------------

= Notations and context
We work in a finite field $FF_q$ with $q$ elements and we deal with the ring of polynomials in $n$ variables $x_1, dots, x_n$ over $FF_q$.

= Oil and Vinegar Signatures
	
== Schema Description
	
We begin by briefly presenting Kipnis and Shamir's variant of the Oil and Vinegar signature schema. Let $(m_1,dots,m_k) in FF_q$ be our message.
	
=== Key Generation
	
Our *private key* $A$ is a randomly chosen invertible matrix in $FF_q^(2k times 2k)$.
	
For our public key we first generate $k$ random matrices $F_1, dots, F_k in FF_q^(2k times 2k)$, such that the upper-left quadrant of each $F_i$ is zero, i.e.

$
F_i = mat(
  0   , B_1;
  B_2 , B_3
) text(", for ") B_i in FF_q^(k times k) 
$ <def-F>

Our *public key* is $G_1, dots, G_k$, with 
$
G_i := A^T F_i A
$
	
=== Signature
	
Given a message $M in FF_q^k$, we want to create a *signature* $X = (x_1, dots, x_(2k)) in  FF_n^(2k)$, i.e.
$
  cases(
    G_1 (x_1, dots, x_(2k)) = m_1,
    G_2 (x_1, dots, x_(2k)) = m_2,
    dots.v,
    G_k (x_1, dots, x_(2k)) = m_k
  )
$ <signature-def>

for $m_1 m_2 dots m_k := M$.

To achieve this, we first create $Y = (y_1, dots, y_(2k)) in FF_n^(2k)$ a vector of $2k$ elements. Let us call the first half of that vector $(y_1, dots, y_k)$ the *oil* part and the second half $(y_(k+1), dots, y_(2k))$ the *vinegar* part.

To create this Y, the *vinegar* is randomly generated. To get the *oil* part, we need to solve the following system of equations :
$
  cases(
    Y^top F_1 Y = m_1,
    dots.v,
    Y^top F_k Y = m_k,
  )
$

If the system has more than one solution, we generate a new *vinegar* and than solve the system again until we have a non singular system to solve. Having multiple solutions thankfully happens rarely. 

For that system to be solved, we can first rewrite it :

We write $Y = mat(O, V)$ with $O, V in FF_n^k$. Let us take an $F_i$ and an $m_i$, we have :
$
  &&Y^top F_i Y                                           &= m_i\
  &<=> &mat(O, V) mat(0, B_1 ; B_2, B_3) mat(O ; V)       &= m_i\
  &<=> &mat(V^top B_2, (O^top B_1 + V^top B_3)) mat(O; V) &= m_i\
  &<=> &V^top B_2 O + (O^top B_1 + V^top B_3) V           &= m_i\
  &<=> &V^top B_2 O + V^top B_1^top O + V^top B_3 V       &= m_i\
  &<=> &(V^top B_2 + V^top B_1^top) O                     &= m_i - V^T B_3 V 
$

And finally :
$
  cases(
    Y^top F_1 Y = m_1 \
		dots.v \
		Y^top F_k Y = m_k
  ) <=> mat(
    V^top B_(1, 2) + V^top B_(1, 1)^top;
    dots.v;
    V^top B_(k, 2) + V^top B_(k, 1)^top;
  ) O = mat(
    m_i - V^T B_(1, 3) V;
    dots.v;
    m_i - V^T B_(k, 3) V
  )
$

This is a simple $A x = b$ system to solve.
	
Now that we have our $Y$ generated, we can obtain a signature $X$ for $M$ as :
$
  X := A^(-1) Y in FF_q^(2k)
$

=== Verification

Given a message $M in FF_q^k$ and a potential signature $X in FF_q^(2k)$, let us take a fixed $i in [|1; n|]$

Suppose that $X$ is indeed a signature of $M$. We have : 
$
  X^top G_i X &= X^top (A^top F_i A) X\
              &= (A^(-1) Y)^top A^top F_i A A^(-1) Y\
              &= Y^top (A^(-1))^top A^top F_i Y\
              &= Y^top F_i Y = m_i
$

Therefore, ($X$ is a signature of $M) => X^top G_i X = m_i, forall i in [|1; n|]$ 

The other way around is implied by the definition of what a signature is. Therefore : 
$ (X #text("is a signature of") M) <=> X^top G_i X = m_i, forall i in [|1; n|] $ 

== Attack on OV

We base our attack on the one described by Kipnis & Shamir in the original paper. *ADD REF*.

We start by considering that we have access to the $F$ matrices used in the key generation, similarly to Kipnis & Shamir. We exclude non-invertible matrices, which be increasingly rare as the size of our base field and $k$ grow.

While the original paper considers raw matrices $F_i$, we will instead focus on the modified forms given as follows.


With our previous $F$ (see @def-F), we denote $F^*$ as:
$
F^* = F + F^T &= mat(
  0, B_1 + B_2^top;
  B_1^top + B_2,  B_3 + B_3^top
)\
  &= mat(
    0, C_1;
    C_1^top, C_3
  )
$<def-F-star>
With $C_i in FF_q^k$ being just a notation. 

We notice similarly to the $F$ matrices used by Kipnis and Shamir, that if $F^*$ is invertible (which is probable), then it maps the oil subspace of $Y$ to the vinegar subspace of $Y$.

$
mat(
    0, C_1;
    C_1^top, C_3
  )mat(X; 0) = mat(0; C_1^T X)
  $

We continue by denoting $overline(F_(i,j))$ the following, which has the important property of being an automorphism on the oil subspace of $Y$:
$
overline(F_(i, j)) = (F_i^*)^(-1) F_j^*
$<def-F-bar>

We now examine the form of the inverse of $F^*$.

$
mat(0, C_1; C_1^T, C_3) mat(D_1 D_2; D_3 D_4) = mat(I, 0; 0, I)\
==> C_1 D_3 = I and C_1 D_4 = 0 and C_1^T D_1 + C_3 D_3 = 0\ and C_1^T D_2 + C_3 D_4 = I\
==> D_3 = C_1^(-1) and D_4 = 0 and D_2 = (C_1^T)^(-1)
$

The inverse of $F^*$ thus has the form :
$
(F^*)^(-1) = mat(
    D_1, (C_1^top)^(-1);
    C_1^(-1), 0
  )
$
With $D_1 in FF_q^k$ being just a matrix that we wont compute. 

We can compute that $overline(F_(i,j))$ :
$
overline(F_(i, j)) = (F_i^*)^(-1) F_j^* 

  &= mat(
    D_i, (C_(i, 1)^top)^(-1);
    C_(i, 1)^(-1), 0
  ) mat(
    0, C_(j, 1);
    C_(j, 1)^top, C_(j, 3)
  )\
  
  &= mat(
    (C_1^top)^(-1) B_1^top, D B_1 + (C^top)^(-1) B_3;
    0, C_1^(-1) B_1
  )\
  
  &= mat(
  hat(A), hat(B);
  0, hat(D)
  )
$ <compute-F-bar>

With again new notations with $hat(A), hat(B), hat(C) in FF_q^k$.

We will show that the characteristic polynomial of $overline(F_(i, j))$ is a square, this will help us later.

We have : 
$
chi_F (X) = det(overline(F_(i, j)) - I_(2k))
$
And 
$
overline(F_(i, j)) - I_(2k) = mat(
  hat(A) - X I_k, hat(B);
  0, hat(D) - X I_k
)
$

The determinant of a upper triangular matrix by block is the product of the determinants of its diagonal blocks. Therefore :
$
chi_F (X) =& det(hat(A) - X I_k) dot det(hat(D) - X I_k)\
          =& chi_hat(A) (X) dot chi_hat(D) (X)
$

And we know that $hat(A)$ and $hat(D)$ are linked :
$
&hat(A) = (C_1^top)^(-1) B_1^top &<=>& B_1^top = C_1^top hat(A)\
&hat(D) = C_1^(-1) B_1 &<=>& B_1^top = hat(D)^top C_1^top\

text("And so :")\ 
&hat(A) = (C_1^top)^(-1) hat(D)^top C_1^top
$ <link-A-to-D>

That means that $hat(A)$ similar to $hat(D)^top$ meaning they share the same characteristic polynomial. Also a matrix and its transpose share the same characteristic polynomial. Therefore : 

$
chi_F (X) =& chi_hat(A) (X) dot chi_hat(D) (X) \
          =& [chi_hat(A) (X)]^2
$

This result demonstrates that the characteristic polynomial of $overline(F_(i, j))$ is a perfect square. This is a crucial property that allows us to identify the oil subspace. Specifically, if we can find a matrix whose characteristic polynomial factors into two distinct irreducible polynomials of degree $k$, then the kernels of these polynomial factors (evaluated at the matrix) will correspond to the oil and vinegar subspaces. This follows from Theorem [*REF TO KIPNIS SHAMIR*] concerning eigenspaces and characteristic polynomials. In practice, we may encounter characteristic polynomials that are not perfect squares due to numerical approximations or slight variations in the scheme. However, we expect them to be close to a perfect square, allowing us to identify a polynomial of degree $k$ whose kernel has dimension $k$.

We will now utilise the *public* matrices $G_i$ for the practical attack.  Recall that $G_i = A^T F_i A$.  Our goal is to find a linear transformation that effectively "undoes" the mixing introduced by the secret matrix $A$, allowing us to separate the oil and vinegar variables.

We cannot directly compute the $overline(F_(i,j))$ matrices, as they depend on the secret $F_i$. However, we can construct matrices from the public key that have a similar relationship to the oil subspace.  We define:

$ G_(i,j) := (G_i + G_i^T)^(-1) (G_j + G_j^T) $

Substituting $G_i = A^T F_i A$, we get:

$ G_(i,j) &= (A^T F_i A + A^T F_i^T A)^(-1) (A^T F_j A + A^T F_j^T A) \
          &= (A^T (F_i + F_i^T) A)^(-1) (A^T (F_j + F_j^T) A) \
          &= (A^T F_i^* A)^(-1) (A^T F_j^* A) \
          &= A^(-1) (F_i^*)^(-1) (A^T)^(-1) A^T F_j^* A \
          &= A^(-1) (F_i^*)^(-1) F_j^* A \
          &= A^(-1) overline(F_(i,j)) A $

This crucial result shows that $G_(i,j)$ is *similar* to $overline(F_(i,j))$.  Similar matrices have the same characteristic polynomial, and their eigenspaces are related by the similarity transformation (in this case, $A$).  Therefore, finding the eigenspaces of $G_(i,j)$ will allow us to recover the oil subspace, up to the unknown transformation $A$.

To find the oil subspace, we employ the characteristic polynomial method.  The process is as follows:

+  #underline[Construct  $G_(i,j)$ Matrices:]
  We begin by selecting pairs of indices $(i, j) in [|1; k|]^2$.  For each pair, we compute  $G_(i,j) = (G_i + G_i^top)^(-1) (G_j + G_j^top)$, using the publicly available  $G_i$ matrices.  We filter out any  $G_i$ for which  $(G_i + G_i^top)$ is not invertible.  In practice, we expect a significant proportion of the  $G_i$ to satisfy this invertibility condition.

+  #underline[Compute Characteristic Polynomial:]  For each constructed  $G_(i,j)$ matrix, we compute its characteristic polynomial, denoted as  $chi_(G_(i,j)) (X)$.  Since  $G_(i,j)$ is similar to  $overline(F_(i,j))$,  $chi_(G_(i,j)) (X)$ is identical to  $chi_F (X)$, which we have shown to be (ideally) a perfect square of a polynomial of degree  $k$.

+  #underline[Factor and Extract "Square Root":] We factor the characteristic polynomial  $chi_(G_(i,j))(x)$. Due to numerical imprecision or slight variations, we might not get a perfect square. However, we will look for two factors that is the result of rounding errors, having two similar polynomials. In the ideal case, we have  $chi_(G_(i,j)) (X) = [P(X)]^2$, where  $P(x)$ is a polynomial of degree  $k$.  We extract this  $P(X)$ polynomial.  If the factorization yields multiple factors, we select the factor (or product of factors) that results in a polynomial of degree  $k$.

+  #underline[Compute Kernel:] We now evaluate the polynomial  $P(X)$ at the matrix  $G_(i,j)$, obtaining  $P(G_(i,j))$. The kernel of this matrix,  $ker(P(G_(i,j)))$, is our target.  By the theory of eigenspaces and characteristic polynomials [*REF KIPNIS SHAMIR*], this kernel will be either the oil subspace or the vinegar subspace (both of dimension  $k$).

+  #underline[Iterate and Verify:]  We repeat steps 1-4 with different pairs of indices  $(i, j)$ until we find a  $G_(i,j)$ matrix that yields a kernel of dimension  $k$.  The dimension of the kernel is easily checked.  Once a kernel of the correct dimension is found, we have successfully identified (up to the transformation  $A$) either the oil or vinegar subspace.  Since the oil and vinegar subspaces are complements of each other, finding one effectively reveals the other.

+ #underline[Construct Forged Key] Once the kernel is found, its basis matrix (transposed) serves as our fake $A$. This matrix allows to create valid signatures.



Once we have identified the oil subspace (represented by the kernel of  $P(G_(i,j))$), we have effectively broken the security of the scheme. The kernel's basis vectors form the columns of a matrix that we can use as a substitute for the secret key  $A$  in the signing process. Let  $K$  be the matrix whose columns are the basis vectors of the recovered kernel.  We can then use  $K$  to generate valid signatures for arbitrary messages, following the same procedure as the legitimate signer (but using  $K$  instead of  $A$). The resulting signatures will be valid because the signing algorithm depends only on the *relationship* between the oil and vinegar variables, which is preserved by our transformation  $K$

== Implementation
	
For the implementation, we used sagemath for its simplicity and how powerful it is.


=== Complexities and sizes
+ *Key Generation*

  #underline[Space Complexity of the Keys]
  
  The public key is a collection of $k$ quadratic polynomials, $G_1$ through $G_k$.  Each of these polynomials, involves $2k$ variables. Because they are quadratic, each $G_i$ can have roughly $2k^2$ terms (each a pair of variables), along with coefficients from our finite field $FF_q$.  Therefore, each $G_i$ requires storing approximately $O(k^2)$ elements. With $k$ such polynomials, the total public key size is $O(k^3)$ elements of $FF_q$.
  
  The private key is primarily the $2k times 2k$ matrix $A$.  This matrix holds $(2k)^2 = 4k^2$ elements.  Thus, the private key's size is $O(k^2)$ elements. The $F_i$ matrices are not strictly part of the secret key since they are derivable with $A$.

  #underline[Time Complexity of Key Generation] // Useful ?? not sure
  
+ *Signing a message*
+ *Verification*
+ *Forging a signature*

= VOX signature scheme