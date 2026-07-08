/// Title page of the document.
///
/// The subtitle options are descriptions under the title on the front page.
/// The epigraph is intended to be a `#quote` element to decorate the page.
#let title-page(
  subtitle: none,
  subsubtitle: none,
  footer: none,
  epigraph: none,
) = {
  place(horizon + center, dy: -15%, {
    set par(spacing: 1em, leading: 0.25em, justify: false)

    align(center, line(length: 90%))
    v(5%, weak: true)
    upper(context { text(size: 5em, hyphenate: false, document.title) })
    v(5%, weak: true)
    if subtitle != none {
      text(size: 2.5em, upper(subtitle))
    }
    v(5%, weak: true)
    align(center, line(length: 90%))
    v(5%, weak: true)

    set par(spacing: 1em, leading: 0.75em, justify: false)
    upper(text(size: 1.75em, subsubtitle))
  })

  place(bottom + center, {
    {
      set text(size: 1.75em)
      upper(footer)
    }
    v(4em, weak: true)
    context for author in document.author {
      align(bottom + center, smallcaps(text(size: 1.75em, author)))
    }
  })

  [#v(0em) <mousse-title-page>]

  pagebreak()
}
