  // --- Getting something that looks like LateX
#set page(margin: 1.53in, numbering: "1")
#set math.mat(delim: "[")
#set par(leading: 0.55em, spacing: 0.55em, first-line-indent: 1.8em, justify: true)
#set text(
  lang: "en"
)
#set text(font: "New Computer Modern")
#show raw: set text(font: "New Computer Modern Mono")
#show heading: set block(above: 1.4em, below: 1em)
// ---

// --- Alternating page numbers

// ---

// --- Theorems
#import "@preview/ctheorems:1.1.3": *
#show: thmrules.with(qed-symbol: $square$)

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
// ---

// --- Pseudo code 
#import "@preview/lovelace:0.3.0": *

#let takernd = math.attach(
  math.arrow.l, // Élément de base (la flèche gauche)
  t: text(scale(150%, sym.die.three)) // Élément à attacher au-dessus (t: pour top)
)
#let comment(input) = text(rgb("#555"))[#h(1fr) _/\/ #input _ #h(5pt)]
#let algo-counter = counter("algo-counter")
#let algo(title, code) = {
  align(center)[
    #algo-counter.step()
    #box(
      stroke: black + 0.5pt,
      inset:2pt,
      pseudocode-list([- *Algorithm #context algo-counter.display() :* #title] + code)
    )
  ]
}
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
#let header-title = "Perturbed Oil and Vinegar Signature Schemes - Bell & Bidault"

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

// --- link and ref
#show ref: this => {
  let content = this
  let color = blue
  if this.element != none { // not a ref to biblio
    content = "[" + content + "]"
    color = red
  }
  text(color)[#content]
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

#let table_style(body) = style(styles => {
  let T = table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center, center, center),
    stroke: 0.4pt,
    inset: 5pt,
    body
  )
  T
})

#let create_results_table(..cells) = {
  table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr), // First column width by content, rest share space
    align: (left, center, center, center, center, center), // Align first column left, others center
    stroke: 0.4pt, // Light gray border for cells
    inset: 5pt,    // Padding within cells
    ..cells        // Spread the provided cell contents here
  )
}




// -----------------------------------------------

// ----------------- Title page ------------------




#set page(numbering: none)
#align(center + horizon)[
  #v(-7cm)
  
  #image("sorbonne-logo.svg")

  #v(1cm)
  #big[PCCA]

  #line(length: 100%)
  
  #large[*Perturbed Oil and Vinegar Signature Schemes*]

  #line(length: 100%)

  #big[Master's research project - CCA]
  
  #datetime.today().display("[day] [month repr:long] [year]")

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
#set page(numbering: "1")
#counter(page).update(1)

#outline(title:"Contents", depth:3)
#pagebreak()

// ----------------- Begin document --------------

= Introduction

With the anticipated arrival of quantum computers powerful enough to break many modern cryptographic schemes in the decades to come, there is much interest in the development of "post-quantum" schemes, i.e. cryptographic methods that remain resistant to attacks by quantum computers. One such family of signature schemes, named Oil and Vinegar (OV), is a promising candidate @Pat97. While classic OV is well-known to be classically insecure @kipnis-shamir-1998cryptanalysis, many variations exist which are believed to be quantum-resistant.

This report examines classic OV and several of its variations with a particular focus on OV$hat(+)$, providing an improved classical attack against OV, and analysing the complexity of both OV and OV$hat(+)$, with a comparison against FOX schemes which are more sophisticated @vox, using an unbalanced number of oil and vinegar variables and making use of compression algorithms and structured private keys.

= Notation and context
All signature schemes described in this paper are over an arbitrary finite field $FF_q$ and its associated polynomial ring $FF_q [x]$.

The representation of quadratic polynomials as matrices is used in the description of the scheme. Given a quadratic polynomial over $n$ variables $x_i in FF_q$, 

== Signature scheme

The motivation for a signature scheme is to authenticate that a particular message has come from a particular source with its contents unaltered. This has many applications, one of which is online software distribution, where signatures ensure downloaded code has been untampered with. The author of the code distributes with it a signature that matches the contents of the program, such that if the code is changed in any way, the signature will no longer match, and the receiver will detect that the modified message was not what was sent by the original sender.

In general, signature schemes have $2$ parties: a signer and a verifier. Beforehand, the signer publishes a public key, which tells the verifier how to detect valid message-signature pairs. To this is associated a private key, known only to the sender, which tells the signer how to sign a given message. Whenever the signer wants to send an authenticated message, they use their private key to create a matching signature for the message and send the message-signature pair to the verifier.

The verifier will then apply the public key to the message-signature pair and verify that the pair is valid. If so, they accept that the pair is a legitimate message sent by the signer. If the verifier finds that the pair is invalid, then they have no guarantee that the message has come from the signer -- it may have been altered mid-transmission by a malicious third-party, or may be completely fabricated by an impersonator.

A signature scheme is defined by three algorithms:
- key generation, a randomised algorithm that generates a pair of public/private keys, given security parameters
- signature, an algorithm that computes a valid signature for a message, given a private key
- verification, an algorithm that checks if a signature is valid for a message given a public key

A "good" signature scheme is one that gives certain guarantees, whose precise definitions we will omit. Some of these are the following:

- Given an arbitrary message, a signer can compute a corresponding valid signature "efficiently".
- Given an arbitrary message-signature pair, a verifier can check whether it is valid or not "efficiently".
- A forger with knowledge of only the public key and previous message-signature pairs produced by the signer cannot efficiently produce any valid message-signature with non-negligeable probability.
- The size of the public key and private key are "relatively small".
- The size of a signature is small, even for large messages.

The meaning of "efficiently" is within time polynomial in the size of the input. It has historically been assumed all parties have access only to classic computation. Under this assumption, RSA is a signature scheme whose security relies on the assumed difficulty of factoring large integers, that appears to provide these guarantees. However, it is probable that within the following decades that quantum computers will exist that are powerful enough to "efficiently compute" valid message-signature pairs without knowledge of the public key. For this reason, there is interest in developing signature schemes where "efficiently" implies access to only classical computation for the signer and the verifier, while "efficiently" implies access to quantum computation for the forger. In layman terms, the scheme can be used without access to special equipment, but is secure even against those with access to special equipment.


== Multivariate cryptography

The justification for the security of OV variants is based on the multivariate quadratic problem (MQ) which is known to be NP-hard and believed to require exponential time to solve using quantum computers. @beulens

#box(stroke: 0.5pt,
      inset:(bottom:10pt,left:5pt,right:5pt),[#definition[Multivariate quadratic problem]

Let $q$ be a prime power. Given $n$ quadratic polynomials in $m$ variables ${P_i}_(i=1)^n : FF_q^m --> FF_q$, for $i$ from $1$ to $n$, and a target $y in FF_q^n$, find an $x in FF_q^m$ such that $forall i, 1 <= i <= n, P_i (x) = y_i$.]
)

Multivariate quadratic signature is a family of signature schemes characterised by the following algorithms.
- Key generation selects invertible $S in FF_q^(n times n)$, invertible $T in FF_q^(m times m)$, and $F_i in FF_q^(m times m)$ for $i in {1,dots,n}$ such that systems of the form $X^top F_i X = y_i$ may be solved efficiently. The public key returned is $(P_i)_(i=1)^k$ where $P_i := sum_(j=1)^n s_(i,j) (T^top F_j T)$. The private key is $(S,T)$.
- Signature of $M in FF_q^n$ calculates $S^(-1)M$, finds a solution to $Y^top F_i Y = S^(-1)M$, then outputs $X := T^(-1)Y$.
- Verification of $M,X,(F_i)_(i=1)^n$ verifies the system of equations $X^top F_i X = m_i$ for $i$ from $1$ to $n$

Here $X^top F_i X = y$ is a quadratic form, i.e. a matrix equation equivalent to evaluation of a polynomial represented by $F$ on inputs $X$ having output $y$. This representation is used heavily throughout this report.

OV variants are instances of multivariate quadratic signature, with a particular structure for the $F_i$: the top-left $o times o$ quadrant is $0$. Equivalently, for the first $o$ variables (named "oil" variables) of the corresponding quadratic polynomial to $X^top F_i X$, there is no oil $times$ oil term.

== VOX and FOX

VOX is an OV variant that was submitted as a candidate to the NIST Post-Quantum Cryptography Project in May 2023. It is an unbalanced scheme (UOV), meaning the number of oil variables $o < k/2$, and uses a similar perturbation technique to OV$hat(+)$, as well as two compression techniques to reduce key size: BPB and QR. FOX is a variant of VOX without the QR compression technique, as only BPB is guaranteed to not reduce security.

Following analysis of various attacks against the QR technique, the authors of the VOX specification switched their focus to FOX as their main candidate. @vox

= Oil and Vinegar Signatures
	Our implementations for OV and OV$hat(+)$ can be found at https://github.com/mbido/Perturbed-oil-and-vinegar-signature-scheme.
== Scheme Description
	
The following is a presentation of the classic Oil and Vinegar signature scheme, as described in @kipnis-shamir-1998cryptanalysis. Let $q$ be a prime power and $k in NN$. The message $m$ is encoded as $(m_1,dots,m_k) in FF_q^k$.

=== Key Generation
	
The *private key* $T$ is an invertible matrix in $FF_q^(2k times 2k)$ chosen uniformly at random. The matrix $S$ is not used in classic OV and so $S=I_k$.

For the public key, the signer generates $k$ matrices $F_1, dots, F_k in FF_q^(2k times 2k)$ uniformly at random, with the constraint that the upper-left quadrant of each $F_i$ is the zero matrix of $F_q^(k times k)$, i.e. 

$
F_i = mat(
  0   , B_(i,1);
  B_(i,2) , B_(i,3)
) quad text(", for ") B_(i,j) in FF_q^(k times k) 
$ <def-F>

The *public key* is $G_1, dots, G_k$, with 
$
G_i := T^top F_i T
$

#underline[Space complexity of the keys]

  While algorithms in this project are described using matrices, note for quadratic forms, that the verifier may always store an equivalent upper triangular form. Space of these reduced forms is used in the complexity analysis here.

  The field $FF_q$ containing $q$ elements, one field element can be stored using $cal(O)(log(q))$ bits.\ \
    
  The public key is a collection of $k$ quadratic polynomials, $G_1$ through $G_k$, each with $2k$ variables and $(k(k+1))/(2)$ coefficients in $FF_q$, one for each pair of variables. Therefore, each $G_i$ requires storing $cal(O)(k^2)$ elements of $FF_q$. With $k$ such polynomials, the total *public key size* is $cal(O)(k^3log(q))$ bits.
  
  The private key is the $2k times 2k$ matrix $T$. This matrix holds $(2k)^2 = 4k^2$ elements.  Thus, the *private key size* is $cal(O)(k^2log(p))$. The $F_i$ matrices are not strictly part of the private key since they may be derived using $T$ and the public key.\ \
  
#underline[Time complexity of key generation]

  Generating a key pair has a complexity bounded by computing each $G_i = T^top F_i T$ of the public key. This takes $cal(O)(k^omega)$ operations for each $G_i$. Therefore, *computing the public key* (which has $k$ $G_i$ components) takes $cal(O)(k^(1 + omega))$.\ 

#create_results_table(
  [#strong[q \\ k]], [#strong[8]], [#strong[16]], [#strong[32]], [#strong[64]], [#strong[128]],
  [251],   [0.0205], [0.0027], [0.0129], [0.0884], [0.6979],
  [4093],  [0.0022], [0.0027], [0.0165], [0.1232], [1.0129],
  [65521], [0.0012], [0.0026], [0.0162], [0.1226], [1.0059],
)
#align(center)[Key generation in practice]




=== Signature
	
In the following definition, the matrices $G_i$ are treated as quadratic forms over $FF_q^(2k)$, i.e. $G_i (x_1, dots, x_(2k)) := X^top G_i X$

#definition[Given a message $M in FF_q^k$ and public key $(G_i)_(i=1)^k$, a *valid signature* $X$ is a vector $(x_1, dots, x_(2k)) in  FF_q^(2k)$, such that
$
  cases(
    G_1 (x_1, dots, x_(2k)) = m_1,
    G_2 (x_1, dots, x_(2k)) = m_2,
    dots.v,
    G_k (x_1, dots, x_(2k)) = m_k
  )
$] <signature-def>

for $(m_1, m_2, dots, m_k) := M$. 

The signer constructs a vector of $2k$ elements $Y = (y_1, dots, y_(2k)) in FF_n^(2k)$ to solve this system. The first $k$ elements of $Y$, $(y_1, dots, y_k)$, are referred to as the *oil* part and the latter half $(y_(k+1), dots, y_(2k))$, the *vinegar* part.

#definition[The *oil subspace* of $Y$ is the subspace of $FF_q^(2k)$ where the last $k$ entries are $0$.]

#definition[The *vinegar subspace* of $Y$ is the subspace of $FF_q^(2k)$ where the first $k$ entries are $0$.]

#example[The vector $mat(x_1,dots,x_k,0,dots,0)^top$ is in the oil subspace of $Y$. The vector $mat(0,dots,0,x_1,dots,x_k)^top$ is in the vinegar subspace of $Y$.]

The signer begins by generating the *vinegar* part of $Y$ uniformly at random. The *oil* part is then deduced using the following system of equations:
$
  cases(
    Y^top F_1 Y = m_1,
    dots.v,
    Y^top F_k Y = m_k,
  )
$

If this system has no solution, a new vinegar half is randomly generated. This process is repeated until a unique solution is obtained.

In order to solve this system, it can be rewritten by splitting $Y$ into its oil and vinegar parts, $Y = mat(O, V)$ with $O, V in FF_n^k$. Let $F_i$ be one of the generated matrices in @def-F and $m_i in FF_q$, a block of the message. This allows the reformulation of each equation as a linear system with $O$ as the sole unknown.
$
  &&Y^top F_i Y                                           &= m_i\
  &<=> &mat(O^top, V^top) mat(0, B_1 ; B_2, B_3) mat(O ; V)       &= m_i\
  &<=> &mat(V^top B_2, (O^top B_1 + V^top B_3)) mat(O; V) &= m_i\
  &<=> &V^top B_2 O + (O^top B_1 + V^top B_3) V           &= m_i\
  &<=> &V^top B_2 O + O^top B_1 V + V^top B_3 V       &= m_i\
  &<=> &V^top B_2 O + V^top B_1^top O + V^top B_3 V       &= m_i quad (O^top B_1 V #[is a scalar])\ 
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

This is a linear system in terms of $O$ which may be solved using Gaussian elimination. With $Y$ constructed, a signature $X$ for $M$ is now computed.
$
  X := T^(-1) Y in FF_q^(2k)
$ <signature-equation>
  
#underline[Complexity of signing a message]

  The time complexity of signing a message is bounded by the complexity of solving the linear system in $O$ which is of complexity $cal(O)(k^omega)$.

#create_results_table(
  [#strong[q \\ k]], [#strong[8]], [#strong[16]], [#strong[32]], [#strong[64]], [#strong[128]],
  [251],   [0.2222], [0.0012], [0.0022], [0.0300], [0.0321],
  [4093],  [0.0020], [0.0012], [0.0027], [0.0088], [0.0421],
  [65521], [0.0011], [0.0012], [0.0033], [0.0094], [0.0421],
)
#align(center)[Signing a message in practice]

=== Verification

#proposition[The result $X in FF_n^(2k)$ produced by @signature-equation is a valid signature.]

#proof[
Given a message $M in FF_q^k$, a signature to this message $X in FF_q^(2k)$ created with @signature-equation, it follows for all $i in [|1; k|]$ that
$
  X^top G_i X &= X^top (T^top F_i T) X\
              &= (T^(-1) Y)^top T^top F_i T T^(-1) Y\
              &= Y^top (T^(-1))^top T^top F_i Y\
              &= Y^top F_i Y = m_i
$

Therefore, $X$ is a signature of $M$, i.e. $
forall i in [|1; k|] quad X^top G_i X = m_i
$.
]

#underline[Complexity of the verification]

  Verifying a signature can be done in $cal(O)(k^3)$ as it consists of $2k$ matrix vector multiplications which are in $cal(O)(k^2)$.

#create_results_table(
  [#strong[q \\ k]], [#strong[8]], [#strong[16]], [#strong[32]], [#strong[64]], [#strong[128]],
  [251],   [0.0006], [0.0002], [0.0003], [0.0007], [0.0035],
  [4093],  [0.0002], [0.0002], [0.0005], [0.0008], [0.0069],
  [65521], [0.0002], [0.0002], [0.0003], [0.0008], [0.0081],
)
#align(center)[Verifying a signature in practice]


== Attack on OV

An attack is provided by Kipnis & Shamir in their original paper @kipnis-shamir-1998cryptanalysis which allows an adversary to construct an equivalent private key $T'$, i.e. a key which when passed to the signing algorithm, produces signatures that are valid for $T$. In our original implementation of Kipnis & Shamir's attack, we noticed that $T$ had the We provide an improvement on this attack, examining the matrices $F_i + F_i^top$ instead of $F_i$, which leads to a more likely successful generation of an equivalent private key.

#definition[Given a matrix $F_i$, $F_i^*$ is defined as $F_i + F_i^top$.]<def-F-star>

#proposition[If $F_i^*$ is invertible, then it maps the oil subspace of $Y$ to the vinegar space of $Y$.]

#proof[
  First analyse the form of $F^*$.
$
  F^* = F + F^T &= mat(
    0, B_1 + B_2^top;
    B_1^top + B_2,  B_3 + B_3^top
  )\
    &= mat(
      0, C_1;
      C_1^top, C_3
    )
$

  Now consider any arbitrary vector $mat(X;0)$ in the oil subspace of $Y$.

$
mat(
    0, C_1;
    C_1^top, C_3
  )mat(X; 0) = mat(0; C_1^top X)
$

  $mat(0; C_1^top X)$ is in the vinegar subspace of $Y$.
]

#definition[
  The matrix $F_(i,j)$ is defined for convenience as $(F_i^*)^(-1) F_j^*$.
]<def-F-bar>

#proposition[@kipnis-shamir-1998cryptanalysis
  If $F_(i,j)$ is invertible, which is the case with overwhelming probability as $FF_q$ or $k$ grows, then it is an automorphism on the oil subspace of $Y$.
]

#proof[
  Given an invertible $F_(i,j) = (F_i^*)^(-1) F_j^*$, it is necessarily the case that $F_i$ and $F_j$ are invertible. Being square matrices, each is a isomorphism from the $k$-dimension oil subspace of $Y$ to the $k$-dimension vinegar subspace of $Y$.
]

#proposition[
The inverse of $F^*$ has the form :
$
(F^*)^(-1) = mat(
    D, (C_1^top)^(-1);
    C_1^(-1), 0
  )
$
]
#proof[
Examine the form of the inverse of $F^*$ as follows.
$
mat(0, C_1; C_1^T, C_3) &mat(D_1 D_2; D_3 D_4) = mat(I, 0; 0, I)\
==> &cases(C_1 D_3 = I \
    C_1 D_4 = 0 \
    C_1^T D_1 + C_3 D_3 = 0 \
    C_1^T D_2 + C_3 D_4 = I) \
==> &cases(D_3 = C_1^(-1) \
    D_4 = 0 \ 
    D_2 = (C_1^T)^(-1))
$

The inverse of $F^*$ thus has the form
$
(F^*)^(-1) = mat(
    D_1, (C_1^top)^(-1);
    C_1^(-1), 0
  )
$, with $D_1 in FF_q^k$ a matrix that need not be computed.
]

#proposition[
$F_(i,j)$ has the form 
$
mat(
  hat(A), hat(B);
  0, hat(D)
  )
$
with $hat(A), hat(B), hat(D) in FF_q^k$.
]
#proof[

As before, one may examine the form of $F_(i,j)$:
$
F_(i, j) = (F_i^*)^(-1) F_j^* 

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
$<compute-F-bar>

The matrices $hat(A), hat(B), hat(D) in FF_q^k$ are implicitly defined as those above.
]

#lemma[
The characteristic polynomial of $F_(i, j)$ is a square.
]<lemma-poly-char-square>

// We will show that the characteristic polynomial of $F_(i, j)$ is a square, this will help us later.
#proof[
By definition of the characteristic polynomial
$
chi_F (X) = det(F_(i, j) - X I_(2k))
$
Explicitly shown,
$
F_(i, j) - I_(2k) = mat(
  hat(A) - X I_k, hat(B);
  0, hat(D) - X I_k
)
$

The determinant of an upper triangular matrix by block is the product of the determinants of its diagonal blocks. Therefore
$
chi_F (X) =& det(hat(A) - X I_k) dot det(hat(D) - X I_k)\
          =& chi_hat(A) (X) dot chi_hat(D) (X)
$

In addition, observe that $hat(A)$ and $hat(D)$ are related
$
&hat(A) = (C_1^top)^(-1) B_1^top &<=>& B_1^top = C_1^top hat(A)\
&hat(D) = C_1^(-1) B_1 &<=>& B_1^top = hat(D)^top C_1^top\
$
Thus
$ 
&hat(A) = (C_1^top)^(-1) hat(D)^top C_1^top
$ <link-A-to-D>

This shows that $hat(A)$ is similar to $hat(D)^top$. Consequently, they share the same characteristic polynomial. Using the fact that a matrix and its transpose have the same characteristic polynomial

$
chi_hat(A)(X) = chi_(hat(D)^top)(X) = chi_hat(D)(X)
$

Finally, the desired result is obtained

$
chi_F (X) =& chi_hat(A) (X) dot chi_hat(D) (X) \
          =& [chi_hat(A) (X)]^2
$
]

// Ce paragraphe me semble pas précis, il faut revoir le théorème, on fait plus tard
This property allows the identification of the oil subspace. Specifically, as a forger can find a matrix whose characteristic polynomial factors into two irreducible polynomials of degree $k$, the kernels of these polynomial factors (evaluated on the matrix) will correspond to the oil subspace. This follows from Theorem 9 of @kipnis-shamir-1998cryptanalysis (section 4.2) concerning eigenspaces and characteristic polynomials. Allowing to identify a polynomial of degree $k$ whose kernel has dimension $k$.

The *public* matrices $G_i$ can be now used for the attack.  Recall that $G_i = T^top F_i T$, the goal is to find a linear transformation that effectively "undoes" the mixing introduced by the secret matrix $T$, allowing the separation of the oil and vinegar variables.

The $F_(i,j)$ matrices cannot be directly computed, as they depend on the secret $F_i$. However, matrices from the public key that have a similar relationship to the oil subspace can be constructed.

The results shown for $F_(i,j)$ can be translated into similar results for the matrices in the public key.

#definition[The *oil subspace* of $X$ is the pre-image of the oil subspace of $Y$ under multiplication by $T$.]

#definition[The *vinegar subspace* of $X$ is the pre-image of the vinegar subspace of $Y$ under multiplication by $T$.]

#definition[The matrix $G_(i,j)$ is defined in the same manner as before, as $ (G_i + G_i^top)^(-1) (G_j + G_j^top) $.]

#lemma[
  The characteristic polynomial $chi_G_(i,j)(X)$ of $G_(i,j)$ is square and is equal to $chi_F_(i,j)(X)$.
]

#proof[
By definition:
$ G_(i,j) := (G_i + G_i^top)^(-1) (G_j + G_j^top) $

Substituting $G_i = T^top F_i T$, the similarity is shown with $F_(i,j)$.

$ G_(i,j) &= (T^top F_i T + T^top F_i^top T)^(-1) (T^top F_j T + T^top F_j^top T) \
          &= (T^top (F_i + F_i^top) T)^(-1) (T^top (F_j + F_j^top) T) \
          &= (T^top F_i^* T)^(-1) (T^top F_j^* T) \
          &= T^(-1) (F_i^*)^(-1) (T^top)^(-1) T^top F_j^* T \
          &= T^(-1) (F_i^*)^(-1) F_j^* T \
          &= T^(-1) F_(i,j) T $

As $F_(i,j)$ and $G_(i,j)$ are similar, they have the same characteristic polynomial. By @lemma-poly-char-square, it is square.
]

\ Similar matrices have the same characteristic polynomial, and their eigenspaces are related by the similarity transformation (in this case, $T$).  Therefore, finding the eigenspaces of $G_(i,j)$ will recover the oil subspace, up to the unknown transformation $T$.\ \

#theorem[An alternative private key $T' in FF_q^(2k times 2k)$ that can produce valid signatures can be forged using the following `ForgeSecretKey` algorithm.]

#algo("ForgeSecretKey")[
  - *Input:* A public key $G in (FF_q^(2k times 2k))^k$.
  - *Output:* An alternative private key $T' in FF_q^(2k times 2k)$ that can sign messages for the public key $G$.
  + $G_(i,j) :=$ *None*
  // - *While* $G_(i,j)$ *is None do* 
  + *Do* 
    + $(i, j) #takernd [|0, k-1|]^2$ #comment[taken at random]
    + *If* $(G_i+G_i^top)^(-1)$ *and* $(G_j+G_j^top)^(-1)$ *exist do*
      + $G_(i,j) <- (G_i + G_i^top)^(-1) (G_j + G_j^top) in FF_q^(2k times 2k)$
      + $Q(X) := chi_(G_(i,j)) (X) in FF_q [X]$ #comment[the characteristic polynomial]
      + $P(X) := sqrt(Q(X)) in FF_q [X]$ #comment[it exists as Q(X) is a perfect square]
      + $K := ker(P(G_(i,j))) subset.eq FF_q^(2k times 2k)$
    + *Else goto 3*
  + *While* $dim(K) != k$
      // - *If* $dim(K) != k$ *do Return* ForgeSecretKey(G)
  - *Return* $T' := text("basis")(K) in FF_q^(2k times 2k)$
]

#underline[Complexity of the improved Kipnis-Shamir attack]

In general, the vast majority of the $G_i$ matrices are invertible -- $G_i$ is invertible iff $F_i$ is as well. This is the case if (but not only if) each $B_i$ is invertible, which is increasingly likely as $k$ increases. Computing the characteristic polynomial takes $cal(O)(k^omega)$ operations in $FF_q$ using the algorithm presented in @fast-poly-calc. The characteristic polynomial being of degree $2k$, computing its square root takes $cal(O)((k+log q)k log^2(k)log log(k))$ operations in $FF_q$, using the algorithm by @Shoup1993. Using Horner's scheme, the forger can compute $P(G_(i,j))$ in $cal(O)(k^(omega + 1))$. Computing the kernel takes $cal(O)(k^omega)$ operations. Therefore, the time complexity of *the attack on OV* is bounded by $cal(O)(k^(omega + 1))$.

#create_results_table(
  [#strong[q \\ k]], [#strong[8]], [#strong[16]], [#strong[32]], [#strong[64]], [#strong[128]],
  [251],   [0.0273], [0.0068], [0.0277], [0.1557], [1.2029],
  [4093],  [0.0040], [0.0099], [0.0537], [0.3967], [3.3763],
  [65521], [0.0036], [0.0102], [0.0566], [0.4246], [3.3319],
)
#align(center)[Forging a secret key in practice]


= OV$hat(+)$ signature scheme
== Scheme description

The following is a more general case of OV, based on the definitions given in @vox and @faugere2022newperturbation. The general idea is to perturb the $F_i$ matrices with a small number of quadratic polynomials chosen uniformly at random, and therefore containing oil $times$ oil monomials, unlike classic OV.

=== Key generation

Let $t < k$ be a positive integer. In order to sign a message, the signer must solve a quadratic system of $t$ equations in $t$ variables. Thus, $t$ is typically chosen to be less than 10.

Define $T in FF_q^(2k times 2k)$ to be an invertible matrix chosen uniformly at random, as in classic OV.

Define $F_i in FF_q^(2k times 2k)$ similarly to in OV. When $1 <= i <= t$ however, $F_i$ is chosen uniformly at random with no constraints, i.e. the upper-left quadrant is no longer restricted to 0. $ F_i := cases(
  B_i "if" 1 <= i <= t,
  mat(0,B_(i,1);B_(i,2),B_(i,3)) "if" t < i <= k
) quad text(", for ") B_(i, j) in FF_q^(k times k), B_i in FF_q^(2k times 2k) $

Define $S in FF_q^(k times k)$ to be a random invertible matrix. This will serve to "mix" the fully random matrices and the structured ones.

The quadratic map $(F_i)_(i=1)^n$ is now composed with the linear map $T$ to give $ G_i := T^top F_i T $ as in classic OV. The linear map $S$ is now composed with this further to give the *public key* $(P_i)_(i=1)^k$, defined as follows: $ P_i := sum_(j=1)^k s_(i,j) G_j $.

The *private key* is $(S,T)$. As with classic OV, the signer may recover $(F_i)_(i=1)^k$ from the public key.\ \

The *public key size*, $cal(O)(k^3log(q))$ bits, is identical to that of OV, as the key has the same structure. For a precise number of bits, we have $k$ upper triangular matrices of dimension $2k times 2k$, giving a total size of $k((2k(2k+1))/2)ceil(log_2(q)) = (2k^3 + k^2)ceil(log_2(q))$ bits.

The *private key size* is $cal(O)(k^2log(p))$ bits. The key is composed of $S$, a $k times k$ matrix taking $k^2$ elements in $FF_q$, and $T$, a $2k times 2k$ matrix taking $4k^2$ elements in $FF_q$. The precise number of bits for $S$ and $T$ together is $5k^2ceil(log_2(q))$.\ \

The final step in key generation is the application of $S$ to obtain $(P_i)_(i=1)^k$. For each $P_i$, $k-1$ matrix additions for matrices of dimension $2k times 2k$ are performed. Given $k$ matrices in the public key to calculate, the *total time complexity* is $cal(O)(k^4)$.

Here are some timing of our implementation in sagemath but with $t=5$ showing a good scaling over $k$:

// Average Key Generation Time (seconds)
#create_results_table(
  [#strong[q \\ k]], [#strong[28]], [#strong[32]], [#strong[36]], [#strong[40]], [#strong[44]],
  [251], [0.1463], [0.1765], [0.2823], [0.4070], [0.5811],
  [4093], [0.1377], [0.2220], [0.3481], [0.5186], [0.7747],
  [65521], [0.1592], [0.2630], [0.4354], [0.6148], [0.8848],
)
#align(center)[Average Key Generation Time (seconds)]





=== Signature

It is first useful to note the application of $P_i$ to a given signature block $x$:
$ 
   (x^top P_i x)_(i=1)^k &= (x^top sum_(j=1)^k s_(i,j) G_j x)_(i=1)^k\
   &= (sum_(j=1)^k s_(i,j) x^top G_j x)_(i=1)^k\
   &= S (x^top G_i x)_(i=1)^k
$.

To recover a quadratic system from a desired message $m$, it is sufficient to define
$
(x^top G_i x)_(i=1)^k &= S^(-1)m\
$.

Given the structure of $F_(t+1),dots,F_k$, as with OV a random vinegar part of $T x$ is chosen. The $k-t$ equations $ (T x)^top F_i (T x) = (S^(-1)m)_i quad "for" i "from" t+1 "to" k $<ovp-linear-equation> over the remaining $k$ oil variables are then linear, and with high probability define a coset of dimension $t$, which may be easily expressed as $y_0 + K z$ for $y_0 in FF_q^(2k), K in FF_q^(k times t), z in FF_q^t$.

The remaining $t$ equations define a quadratic system over $t$ variables $ mat(y_0^top+z^top K^top, V^top) F_i mat(y_0+K z; V) = (S^(-1)m)_i "for" i "from" 1 "to" t $<ovp-quadratic-equation>, which is solvable with probability approaching $1 - 1/e$ for large $q$ and $t$ @multivar-fusco. If the system is not solvable, the signer selects another random vinegar part until a solvable system is obtained.

To compute a solution, the signer calculates a Gröbner basis for the $t$ polynomials, then calculates the variety of the ideal it defines, which is expected to be of dimension $0$. We have not studied this in depth and have taken SageMath implementations of these calculations for granted.

Once a solution $mat(y_0+K z;V)$ is found, a signature of $m$ is $ x = T^(-1) mat(y_0+K z; V) $ which is valid by construction.

The *signature size* is $cal(O)(k log(p))$ bits as it consists of $2k$ elements in $FF_q$. The exact size is $2k ceil(log_2(p))$ bits.

The algorithm requires the following sub-procedures in the average case:
- $cal(O)(k)$ arithmetic matrix operations over $FF_q$, costing $cal(O)(k^(1+omega))$
- $cal(O)(1)$ solutions to a linear system over $FF_q$, costing $cal(O)(k^omega)$
- $cal(O)(t)$ matrix-vector multiplications over $FF_q [x]$, costing $cal(O)(t M(k)^2)$
- $cal(O)(1)$ solutions to a quadratic system of $t$ polynomials of degree $2$ over $t$ variables using a Gröbner basis calculation, costing $cal(O)(binom(2t,t+1​)^omega)=cal(O)(4^(t omega))$ @F5-complexity.
The total complexity is therefore $cal(O)(4^(t omega) + k^(1+omega))$.

Here are the results of timing our implementation in SageMath with $t=5$ showing a good scaling over $k$:
// Average Signing Time (seconds)
#create_results_table(
  [#strong[q \\ k]], [#strong[28]], [#strong[32]], [#strong[36]], [#strong[40]], [#strong[44]],
  [251], [1.3323], [0.6797], [0.6752], [3.4435], [0.7363],
  [4093], [2.6586], [0.6808], [0.6974], [2.1291], [0.7298],
  [65521], [2.2344], [1.1899], [1.1433], [3.5828], [2.4047],
)
#align(center)[Average Signing Time (seconds)]



=== Verification

The verification is identical to that of OV. A signature $x in FF_q^(2k)$ is valid for a message $m in FF_q^(2k)$ and public key quadratic map $(P_i)_(i=1)^k: FF_q^(2k) --> FF_q^k$ iff $forall i, 1 <= i <= k, x^top P_i x = m_i$.

As verification is identical to OV, it costs $cal(O)(k^3)$, the cost of $k$ matrix-vector multiplications of dimension $2k times 2k$.

Here are some timing of our implementation in sagemath with $t=5$ showing a good scaling over $k$:
// Average Certification Time (seconds)
#create_results_table(
  [#strong[q \\ k]], [#strong[28]], [#strong[32]], [#strong[36]], [#strong[40]], [#strong[44]],
  [251], [0.0004], [0.0004], [0.0006], [0.0006], [0.0006],
  [4093], [0.0004], [0.0005], [0.0006], [0.0008], [0.0008],
  [65521], [0.0004], [0.0005], [0.0006], [0.0007], [0.0007],
)
#align(center)[Average Verification Time  (seconds)]




// === Correctness

// #proposition[Let $m in FF_q^(2k)$ be a message, $(P_i)_(i=1)^k: FF_q^(2k) --> FF_q^k$ be a quadratic map, and $x$ be a signature found via the signature generation above. Then $x$ is a valid signature.]

// #proof[Consider any member of the quadratic map $P_i$. The following reduction suffices.
// $
// x^top P_i x &= x^top (sum_(j=1)^k s_(i,j) T^top F_j T) x\
// &= sum_(j=1)^t s_(i,j) mat(y_0^top+z^top K^top, V^top) F_j mat(y_0+K z; V) + sum_(j=t+1)^k s_(i,j) (T x)^top F_j T x\
// &= sum_(j=1)^k s_(i,j) (S^(-1)     m)_j quad#text[by @ovp-quadratic-equation and @ovp-linear-equation]\
// &= (S S^(-1)m)_i = m_i 
// $
// ]


== Security parameters
The security parameters for security level $gamma$ (e.g. 128, 192, or 256) are values of $(q, k, t)$ such that breaking the security of the scheme requires at least as many logic-gate operations as are needed to break AES-$gamma$. For security levels 128, 192, and 256, the respective numbers $2^lambda$ of logic-gate operations required are $2^143$, $2^207$, and $2^272$. The definition of bit complexity can be found in @NIST:2022:DSproposals.

On OV$hat(+)$, there are two main attacks:
- Attacking directly the scheme to forge a signature.
- Inverting S to recover the OV structure and using the improved Kipnis-Shamir attack to recover a secret key.

=== Direct forgery attack
As described in @vox, the direct attack consists of inverting the public key for a message. This correspond to solving a quadratic system of $k$ equations in $2k$ variables. The best known attack is HybridF5 (@BettaleFaugerePerret2009) which attempts to solve the quadratic system by repeatedly guessing a correct subset of variables to eliminate, and solving the resulting quadratic subsystem of fewer variables with Gröbner bases (@Buchberger1965 & @Buchberger1970) as for the OV$hat(+)$ signature, which is successful when the correct variables have been selected.

For our analysis of OV$hat(+)$, the values of $q$ are the same used in @vox and from which the parameters $k$ and $t$ are derived. To deduce the value of $k$, the python tool `MQEstimator` from the library `cryptographic_estimators` (@cryptoeprint:2023-589) has been used. 

=== OV structure recovery
To recover the OV structure, the forger must recover two distinct linear combinations of the ${P_i}_(i=1)^k$ whose quadratic (the random chosen part) parts vanish and execute the Kipnis-Shamir @kipnis1-Patarin-Goubin-999unbalanced attack to see if it works. If the linear combinations' quadratic parts do not vanish, the oil subspace is not recovered. For a linear combination chosen at random,the quadratic part fully vanishes with probability $1/(q^t)$ @vox. Each time two linear combinations are tested on the KS @kipnis-shamir-1998cryptanalysis attack adding its number of operations.

Therefore, to prevent this attack, the parameters $t$ and $q$ must satisfy $q^(2t)p(q)a(q) > 2^lambda$ with $a(q)$ being the number of arithmetic operations needed for the Kipnis-Shamir attack ($k^(omega + 1) + 6k^omega + k^2$) and $p$ the number of logic-gate operations needed for one arithmetic operation in $FF_q$ (estimated to be $log_2^2(q))$.

The security parameters for the OV$hat(+)$ signature are as follows:

#align(center)[
  #grid(columns: (auto, auto, auto, auto, auto, auto), stroke: 0.5pt, inset:5pt,
    "Security Level", "q", "t", "k", "HybridF5 attack", "KS attack",
    "128", "251", "8", "39", "143.02", "153.86",
    "192", "4093", "8", "53", "207.74", "221.11",
    "256", "65521", "8", "69", "272.99", "287.37",
  )
]

Similarly in @vox, the minimum bits needed to represent an element of $FF_q$ appears to have been used. Therefore, a comparison can be drawn with the FOX scheme:
#v(1cm)

#figure()[
  #align(center)[
    #grid(columns: (auto, auto, auto, auto, auto, auto, auto, auto), stroke: 0.5pt, inset:5pt,
      "Security Level", "q"     , "o", "v", "|1 elt|" , "|sig|", "|cpk|"     , "|csk|",
      "128"           , "251"   , "48", "72", "8 bits"  , "120 B", "47,056 B" , "64 B",
      "192"           , "4093"  , "68", "106", "12 bits" , "261 B", "211,156 B", "64 B",
      "256"           , "65521" , "91", "140", "16 bits" , "462 B", "694,892 B", "64 B",
    )
    FOX sizes
  ]
  
  #line(length:100%, stroke: 0.5pt)
  
  #align(center)[
    #grid(columns: (auto, auto, auto, auto,auto, auto, auto), stroke: 0.5pt, inset:5pt,
      "Security Level", "q"     , "k", "|1 elt|" , "|sig|" , "|pk|"      , "|sk|",
      "128"           , "251"   , "39", "8 bits"  , "82 B"   , "120,159 B" , "7,605 B",
      "192"           , "4093"  , "53", "12 bits" , "183 B"   , "450,844 B" , "210,67 B",
      "256"           , "65521" , "69", "16 bits" , "324 B"   , "1,323,558 B", "47,610 B",
    )
    OV$hat(+)$ sizes
  ]
]

#v(1cm)

#pagebreak()
#bibliography("biblio.bib", style:"din-1505-2-alphanumeric.csl")