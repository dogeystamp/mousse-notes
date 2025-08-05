#import "@local/mousse-notes:9999.0.1": *
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
  epigraph: quote(attribution: [Jonathan Bingus])[This is a tremendously inspirational quote that sets the tone of this course; truly, one of the epigraphs of all time.]
)

= Chapter Name

== Section Name

=== Subsection
Content goes here.
#lorem(50)

#lorem(40)
This brings us to the following

#theorem(name: "Pythagorean", id: "thm_pyth")[
  #lorem(20)
  $
  a^2 = b^2 + c^2.
  $
]
#proof[
  I said so, therefore it is true. $qed$
]

=== Another subsection
By @thm_pyth,
chicken, chicken chicken, chicken chicken chicken named equation:
$
x^3 + x^2 + 4x + 9 = 3
$ <eq_chicken>

#lorem(30)

#lorem(50)

#example[
  #lorem(30) See @eq_chicken.
]

#solution[
  $
  1 + 2 = 3.
  $
]
