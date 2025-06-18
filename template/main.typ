#import "@local/mousse-notes:0.1.0": *
#set page(paper: "us-letter")
#show: book.with(
  title: [Course Name],
  subtitle: [123-456AB],
  subsubtitle: [
    Lecture notes, Fall 2023
  ],
  subsubsubtitle: [
    Professor #smallcaps[Jonathan Bingus], University of Wunkus.
  ],
  author: "John S. Student",
)

= Chapter Name

== Section Name

=== Subsection
Content goes here.
#lorem(50)

====
One thing.
#lorem(20)

====
Second thing.
#lorem(15)

===
This section is unnamed.
#lorem(90)
This brings us to the following

#theorem(name: "Epsom's", id: "thm_epsom")[
  #lorem(20)
  $
  (c,h,i) in upright(bold(S)) -> K(c, h, i) = mat(
    K_i (c, h, i);
    K_e (c, h, i);
  )
  $
]
#proof[
  I said so, therefore it is true. $qed$
]

===
By @thm_epsom,
chicken, chicken chicken, chicken chicken chicken named equation:
$
C(K) = sum_(i=1)^(n)  Delta^2 (K_i) = sum_(i=1)^(n) norm(E_i - K(H_i))^2
$ <eq_chicken>

#lorem(30)

====
#example[
  #lorem(10) See @eq_chicken.
]

#solution[
  $
  1 + 2 = 3.
  $
]
