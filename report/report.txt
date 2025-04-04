// --- Theorems
// #import "@preview/theoretic:0.2.0" as theoretic: theorem, proof, qed
// #show ref: theoretic.show-ref
// #let corollary = theorem.with(kind: "corollary", supplement: "Corollary")
// #let lemma = theorem.with(kind: "lemma", supplement: "Lemma")
// #let proposition = theorem.with(kind: "proposition", supplement: "Proposition")
// #let example = theorem.with(kind: "example", supplement: "Example", number: none)
// 
// 
// ---

// --- Code snippets
// #import "@preview/codly:1.2.0": *
// #import "@preview/codly-languages:0.1.1": *
// #show: codly-init.with()
// ---

#import "@preview/ctheorems:1.1.3": *
#show: thmrules.with(qed-symbol: $square$)

// #set page(width: 16cm, height: auto, margin: 1.5cm)
// #set heading(numbering: "a.a")

#let theorem = thmbox("theorem", "Theorem", base_level: 0)
#let lemma = thmbox("lemma", "Lemma", base_level: 0)
#let proposition = thmbox("proposition", "Proposition", base_level: 0)
#let corollary = thmplain(
  "corollary",
  "Corollary",
  base: "theorem",
  titlefmt: strong
)
#let definition = thmbox("definition", "Definition", inset: (x: 1.2em, top: 1em), base_level: 0)

#let example = thmplain("example", "Example").with(numbering: none)
#let proof = thmproof("proof", "Proof", base_level:0, base: "heading")

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


#show ref: this => {
  let content = this
  let color = green
  if this.element != none { // not a ref to biblio
    content = "[" + content + "]"
    color = red
  }
  underline()[_#text(color)[#content]_]
}

#show link: it => {
  if type(it.dest) != label { // not an internal link
    set text(fill: blue)
    it
  } else {
    it
  }
}

// ---


// -----------------------------------------------

// ----------------- Title page ------------------

#align(center + horizon)[
  #large[*Perturbed Oil and Vinegar Signature Schemes*]

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

= Notation and context
All signature schemes described in this paper are over
an arbitrary finite field $FF_q$ and its associated polynomial ring $FF_q [x]$.

The representation of quadratic polynomials as matrices is used in the description of the scheme. Given a quadratic polynomial over $n$ variables $x_i in FF_q$, 

= Oil and Vinegar Signatures
	
== Scheme Description
	
The following is a brief presentation of Kipnis and Shamir's variant of the Oil and Vinegar signature scheme. The message $m$ is encoded as $(m_1,dots,m_k) in FF_q$.
	
=== Key Generation
	
The *private key* $A$ is a randomly chosen invertible matrix in $FF_q^(2k times 2k)$.

For the public key, $k$ random matrices $F_1, dots, F_k in FF_q^(2k times 2k)$ are first generated, such that the upper-left quadrant of each $F_i$ is the zero matrix of $F_q^(K times k)$, i.e.

$
F_i = mat(
  0   , B_1;
  B_2 , B_3
) quad text(", for ") B_i in FF_q^(k times k) 
$ <def-F>

The *public key* is $G_1, dots, G_k$, with 
$
G_i := A^top F_i A
$
	
=== Signature
	
In the following definition, the matrices $G_i$ are treated as quadratic polynomials over $FF_q^(2k)$, i.e. $G_i (x_1, dots, x_(2k)) := X^top G_i X$

#definition[Given a message $M in FF_q^k$, a *signature* $X$ is a vector $(x_1, dots, x_(2k)) in  FF_n^(2k)$, such that
$
  cases(
    G_1 (x_1, dots, x_(2k)) = m_1,
    G_2 (x_1, dots, x_(2k)) = m_2,
    dots.v,
    G_k (x_1, dots, x_(2k)) = m_k
  )
$] <signature-def>

for $(m_1, m_2, dots, m_k) := M$. 

To achieve this, a vector of $2k$ elements $Y = (y_1, dots, y_(2k)) in FF_n^(2k)$ is constructed. The first $k$ elements of $Y$, $(y_1, dots, y_k)$, are referred to as the *oil* part and the latter half, $(y_(k+1), dots, y_(2k))$, the *vinegar* part.

#definition[The *oil subspace* of $Y$ is the subspace of $FF_q^(2k)$ where the last $k$ entries are $0$.]

#definition[The *vinegar subspace* of $Y$ is the subspace of $FF_q^(2k)$ where the first $k$ entries are $0$.]

To construct this $Y$, the *vinegar* part of $Y$ is first randomly generated. The *oil* part is generated using the following system of equations:
$
  cases(
    Y^top F_1 Y = m_1,
    dots.v,
    Y^top F_k Y = m_k,
  )
$

If this system has more than one solution, a new *vinegar* half is generated again at random, repeating until the resulting system has a unique solution. In practice, the need to regenerate a vinegar half is rare.

In order to solve this system, it can be rewritten by splitting $Y$ into its oil and vinegar parts, $Y = mat(O, V)$ with $O, V in FF_n^k$. Let $F_i$ be one of the generated matrices in @def-F and $m_i in FF_q$, a block of the message. This allows the reformulation of each equation as a linear system with $O$ as the sole unknown.
$
  &&Y^top F_i Y                                           &= m_i\
  &<=> &mat(O^top, V^top) mat(0, B_1 ; B_2, B_3) mat(O ; V)       &= m_i\
  &<=> &mat(V^top B_2, (O^top B_1 + V^top B_3)) mat(O; V) &= m_i\
  &<=> &V^top B_2 O + (O^top B_1 + V^top B_3) V           &= m_i\
  &<=> &V^top B_2 O + O^top B_1 V + V^top B_3 V       &= m_i\
  &<=> &V^top B_2 O + V^top B_1^top O + V^top B_3 V       &= m_i (O^top B_1 V #[is a scalar])\ 
  &<=> &(V^top B_2 + V^top B_1^top) O                     &= m_i - V^top B_3 V 
$

The system of equations is thus expressed as follows.
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
    m_i - V^top B_(1, 3) V;
    dots.v;
    m_i - V^top B_(k, 3) V
  )
$

This is a linear system in terms of $O$ which may be solved using known methods. With $Y$ constructed, a signature $X$ for $M$ is now computed.
$
  X := A^(-1) Y in FF_q^(2k)
$ <signature-equation>

=== Verification

#proposition[If a vector $X in FF_n^(2k)$ is a signature created with @signature-equation, then the @signature-def is verified.]

#proof[
Given a message $M in FF_q^k$, a signature to this message $X in FF_q^(2k)$ created with @signature-equation, it follows for all $i in [|1; k|]$ that
$
  X^top G_i X &= X^top (A^top F_i A) X\
              &= (A^(-1) Y)^top A^top F_i A A^(-1) Y\
              &= Y^top (A^(-1))^top A^top F_i Y\
              &= Y^top F_i Y = m_i
$

Therefore, $X$ is a signature of $M$, i.e. $
forall i in {1,dots, k} quad X^top G_i X = m_i
$.
]

== Attack on OV

This attack is based on the one described by Kipnis & Shamir in their original paper @kipnis-shamir-1998cryptanalysis.

#definition[Given a matrix $F_i$, $F_i^*$ is defined as $F_i + F_i^top$.]

#lemma[If $F_i^*$ is invertible, then it is an automorphism on the oil subspace of $Y$.]

One can consider that there is access to the $F$ matrices used in the key generation, similarly to Kipnis & Shamir. This is possible as it will be shown later that those matrices are not used to implement the attack. Non-invertible matrices are excluded, which be increasingly rare as the size of our base field and $k$ grow.

While the original paper considers raw matrices $F_i$, this attack will instead focus on the modified forms given as follows.


With the previous $F$ (see @def-F), $F^*$ is defined as:
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

#lemma[
Similarly to the $F$ matrices used by Kipnis and Shamir, it can be notice that if $F^*$ is invertible (which is probable), then it maps the oil subspace of $Y$ to the vinegar subspace of $Y$.
]
#proof[
$
mat(
    0, C_1;
    C_1^top, C_3
  )mat(X; 0) = mat(0; C_1^T X)
$
]

$overline(F_(i,j))$ is now introduce as follow :
$
overline(F_(i, j)) = (F_i^*)^(-1) F_j^*
$<def-F-bar>

#lemma[
  $overline(F_(i,j))$ is an automorphism on the oil subspace of $Y$.
]

#lemma[
The inverse of $F^*$ has the form :
$
(F^*)^(-1) = mat(
    D_1, (C_1^top)^(-1);
    C_1^(-1), 0
  )
$
]
#proof[
One can examine the form of the inverse of $F^*$ as follows.

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

With $D_1 in FF_q^k$ being just a matrix that wont be compute.
]

#lemma[
$overline(F_(i,j))$ has the form : 
$
mat(
  hat(A), hat(B);
  0, hat(D)
  )
$
With $hat(A), hat(B), hat(C) in FF_q^k$.
]
#proof[

As before, one can examine the form of $overline(F_(i,j))$ :
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
]

#lemma[
The characteristic polynomial of $overline(F_(i, j))$ is a perfect square.
]<lemma-poly-char-square>



// We will show that the characteristic polynomial of $overline(F_(i, j))$ is a square, this will help us later.
#proof[
By definition of the characteristic polynomial: 
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

The determinant of an upper triangular matrix by block is the product of the determinants of its diagonal blocks. Therefore :
$
chi_F (X) =& det(hat(A) - X I_k) dot det(hat(D) - X I_k)\
          =& chi_hat(A) (X) dot chi_hat(D) (X)
$

And it is known that $hat(A)$ and $hat(D)$ are linked :
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
]

This is property allows to identify the oil subspace. Specifically, if one can find a matrix whose characteristic polynomial factors into two distinct irreducible polynomials of degree $k$, then the kernels of these polynomial factors (evaluated at the matrix) will correspond to the oil subspace. This follows from Theorem [*REF TO KIPNIS SHAMIR*] concerning eigenspaces and characteristic polynomials. Allowing to identify a polynomial of degree $k$ whose kernel has dimension $k$.

The *public* matrices $G_i$ will be now utilised for the practical attack.  Recall that $G_i = A^top F_i A$, the goal is to find a linear transformation that effectively "undoes" the mixing introduced by the secret matrix $A$, allowing to separate the oil and vinegar variables.

The $overline(F_(i,j))$ matrices cannot be directly computed, as they depend on the secret $F_i$. However, matrices from the public key that have a similar relationship to the oil subspace can be constructed. 

In that extend $G_(i,j)$ is defined as follow :
$ G_(i,j) := (G_i + G_i^T)^(-1) (G_j + G_j^T) $

#lemma[
  $G_(i,j)$ is similar to $overline(F_(i,j))$
]

#proof[
By definition :
$ G_(i,j) := (G_i + G_i^T)^(-1) (G_j + G_j^T) $

Substituting $G_i = A^T F_i A$ :

$ G_(i,j) &= (A^T F_i A + A^T F_i^T A)^(-1) (A^T F_j A + A^T F_j^T A) \
          &= (A^T (F_i + F_i^T) A)^(-1) (A^T (F_j + F_j^T) A) \
          &= (A^T F_i^* A)^(-1) (A^T F_j^* A) \
          &= A^(-1) (F_i^*)^(-1) (A^T)^(-1) A^T F_j^* A \
          &= A^(-1) (F_i^*)^(-1) F_j^* A \
          &= A^(-1) overline(F_(i,j)) A $

Therefore, $G_(i,j)$ is similar to $overline(F_(i,j))$.
]

Similar matrices have the same characteristic polynomial, and their eigenspaces are related by the similarity transformation (in this case, $A$).  Therefore, finding the eigenspaces of $G_(i,j)$ will allow to recover the oil subspace, up to the unknown transformation $A$.

The process of finding the oil subspace using the characteristic polynomial method is as follows :

+  #underline[Construct  $G_(i,j)$ Matrices:]
  Pairs of indices $(i, j) in [|1; k|]^2$ are first selected. For each pair, $G_(i,j) = (G_i + G_i^top)^(-1) (G_j + G_j^top)$ is computed using the publicly available $G_i$ matrices. Any $G_i$ for which $(G_i + G_i^top)$ is not invertible is filtered out. In practice, a significant proportion of the $G_i$ is expected to satisfy this invertibility condition.

+  #underline[Characteristic Polynomial Computation:]  For each constructed  $G_(i,j)$ matrix, its characteristic polynomial, denoted as  $chi_(G_(i,j)) (X)$, is computed.  Since  $G_(i,j)$ is similar to  $overline(F_(i,j))$,  $chi_(G_(i,j)) (X)$ is identical to  $chi_F (X)$, which has been shown to be a perfect square of a polynomial of degree  $k$.

+  #underline[Factor and Extract "Square Root":] The characteristic polynomial $chi_(G_(i,j))(x)$ is factored. It is known that $chi_(G_(i,j)) (X) = [P(X)]^2$, where $P(x)$ is a polynomial of degree $k$. The $P(X)$ polynomial is then extracted. If multiple factors are obtained in the factorization, the factor that results in a polynomial of degree $k$ is selected.

+  #underline[Compute Kernel:] The polynomial  $P(X)$ is then evaluated at the matrix  $G_(i,j)$, resulting in  $P(G_(i,j))$. The kernel of this matrix,  $ker(P(G_(i,j)))$, is computed. By the theory of eigenspaces and characteristic polynomials @kipnis-shamir-1998cryptanalysis (section 4.2), this kernel will be either the oil subspace (of dimension  $k$).

+  #underline[Iterate and Verify:]  Steps 1-4 are repeated with different pairs of indices $(i, j)$ until a $G_(i,j)$ matrix that yields a kernel of dimension $k$ is found. The dimension of the kernel can be easily checked. Once a kernel of the correct dimension has been found, the oil subspace will have been successfully identified (up to the transformation $A$). Since the oil and vinegar subspaces are complements of each other, when the oil is found, the vinegar is effectively revealed.

+ #underline[Construct Forged Key] Once the kernel is found, its basis matrix (transposed) serves as a fake $A$. This matrix allows to create valid signatures.

Once the oil subspace (represented by the kernel of $P(G_(i,j))$) has been identified, the security of the scheme can be considered broken. The kernel's basis vectors can be arranged into columns of a matrix that can be used as a substitute for the secret key $A$ in the signing process. Let $K$ be the matrix whose columns are formed by the basis vectors of the recovered kernel. Valid signatures for arbitrary messages can then be generated using $K$, following the same procedure as the legitimate signer (but with $K$ used instead of $A$). The signatures generated in this way will be valid because the signing algorithm depends only on the relationship between the oil and vinegar variables, which is preserved by the transformation $K$

== Implementation
	
The implementation as been done using sagemath.

=== Complexities and sizes
+ *Key Generation*

  #underline[Space Complexity of the Keys]
  
  The public key is a collection of $k$ quadratic polynomials, $G_1$ through $G_k$.  Each of these polynomials, involves $2k$ variables. Because they are quadratic, each $G_i$ can have roughly $2k^2$ terms (each a pair of variables), along with coefficients from our finite field $FF_q$.  Therefore, each $G_i$ requires storing approximately $O(k^2)$ elements. With $k$ such polynomials, the total public key size is $O(k^3)$ elements of $FF_q$.
  
  The private key is primarily the $2k times 2k$ matrix $A$.  This matrix holds $(2k)^2 = 4k^2$ elements.  Thus, the private key's size is $O(k^2)$ elements. The $F_i$ matrices are not strictly part of the secret key since they are derivable with $A$.

  #underline[Time Complexity of Key Generation]
  
+ *Signing a message*
+ *Verification*
+ *Forging a signature*

= VOX signature scheme




#pagebreak()
#bibliography(full:true, "biblio.bib")