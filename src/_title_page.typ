/// Title page of the document.
///
/// The subtitle options are descriptions under the title on the front page.
/// The epigraph is intended to be a `#quote` element to decorate the page.
#let title-page(
  subtitle: none,
  subsubtitle: none,
  subsubsubtitle: none,
  epigraph: none,
) = {
  place(horizon + center, dy: -15%, {
    set par(spacing: 0.7em, leading: 0.3em, justify: false)
    smallcaps(context { text(size: 4em, weight: "regular", hyphenate: false, document.title) })
    v(2.5%, weak: true)
    if subtitle != none {
      text(size: 2em, smallcaps(subtitle))
      v(2.5%, weak: true)
    }
    v(3.5%, weak: true)
    emph(text(size: 1.5em, subsubtitle))
    v(1.25%, weak: true)
    emph(subsubsubtitle)
  })

  {
    set par(justify: false, linebreaks: "optimized", spacing: 1em)
    set text(costs: (runt: 400%))
    set quote(block: true)
    show quote: it => [
      #emph(it.body)

      #align(right, box(text(size: 0.7em)[--- #it.attribution]))
    ]

    if epigraph != none {
      place(bottom + center, dy: -17.5%, block(
        stroke: (top: black, bottom: black),
        inset: (top: 12pt, bottom: 12pt, left: 6pt, right: 6pt),
        width: 80%,
        align(left, text(size: 1.4em, epigraph, hyphenate: false)),
      ))
    }
  }

  context for author in document.author {
    align(bottom + center, text(size: 1.5em, smallcaps(author)))
  }

  [#v(0em) <mousse-title-page>]

  pagebreak()
}
