// ------------------- Preamble -------------------

// --- Theorems
#import "@preview/theoretic:0.2.0" as theoretic: theorem, proof, qed
#show ref: theoretic.show-ref
#let corollary = theorem.with(kind: "corollary", supplement: "Corollary")
#let example = theorem.with(kind: "example", supplement: "Example", number: none)
// ---

// --- Code snippets
#import "@preview/codly:1.2.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()
// ---

// --- Getting something that looks like LateX
#set page(margin: 1.75in, numbering: "1")
#set par(leading: 0.55em, spacing: 0.55em, first-line-indent: 1.8em, justify: true)
#set text(font: "New Computer Modern")
#show raw: set text(font: "New Computer Modern Mono")
#show heading: set block(above: 1.4em, below: 1em)
// ---

// --- some shortcuts
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
#set enum(numbering: "a.")
#set heading(numbering: "I.1.a -")
// ---

// -----------------------------------------------

// ----------------- Title page ------------------

#align(center + horizon)[
  #large[*Unbalanced Oil and Vinegar Signature Schemas*]

  #big[Master's degree - CCA]
  
  #datetime.today().display("[day]. [month repr:long] [year]")
]

#align(bottom)[
  #stack(
      dir: ltr,
      align(left + top)[#big[Pierre the boss]],
      h(1fr),
      align(right)[#big[ 
      Nicholas Bell - 0000000

      Matthieu Bidault - 0000000
    ]],
  )
]

// -------------- Table of contents --------------

#pagebreak()
#outline(title:"Contents")
#pagebreak()


// ----------------- Begin document --------------

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
$

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
$

for $m_1||m_2||dots||m_k = M$.

To achive this, we first create $Y = (y_1, dots, y_(2k)) in FF_n^(2k)$. Let us call the first half $(y_1, dots, y_k)$ the *oil* part and the second half $(y_(k+1), dots, y_(2k))$ the *vinegar* part.

The *vinegar* is randomly generated. To get the *oil* part, we need to solve the folowing system of equations :
$
  cases(
    Y^top F_1 Y = m_1,
    dots.v,
    Y^top F_k Y = m_k,
  )
$

If the system has more than one solution, we generate a new *vinegar* and than solve the system again or generate again. This thanksfully happens rarely. 

For that system to be solved, we can first rewrite it another way :

We write $Y = mat(O, V)$ with $O, V in FF_n^k$. Let us take an $F_i$ and an $m_i$, we have :
$
  &&Y^top F_i Y &= m_i\
  &<=> &mat(O, V) mat(0, B_1 ; B_2, B_3) mat(O ; V) &= m_i\
  &<=> &mat(V^top B_2, (O^top B_1 + V^top B_3)) mat(O; V) &= m_i\
  &<=> &V^top B_2 O + (O^top B_1 + V^top B_3) V &= m_i\
  &<=> &V^top B_2 O + V^top B_1^top O + V^top B_3 V &= m_i\
  &<=> &(V^top B_2 + V^top B_1^top) O &= m_i - V^T B_3 V 
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
  X := A^(-1) Y
$

=== Verification
	
A signature $X = (x_1,dots,x_{2k})$ is valid if for all $i$, 
$
x_i^top G_i x_i = m_i
$ 

recall previews equations :
$
  cases(
    G_1 (x_1, dots, x_(2k)) = m_1,
    G_2 (x_1, dots, x_(2k)) = m_2,
    dots.v,
    G_k (x_1, dots, x_(2k)) = m_k
  )
$

	
== Proof of Correctness
	
// 	salle u
	
== Implementation
	
// 	sait khi ?
	
= An Improved Attack