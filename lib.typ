#let title_page(
  title: none,
  subtitle: none,
  subsubtitle: none,
  subsubsubtitle: none,
  author: none,
) = {
  place(
    horizon + center,
    dy: -15%,
    {
      set par(spacing: 0.35em, leading: 0.15em, justify: false)
      align(
        center,
        text(size: 4em, smallcaps(title), weight: "black", hyphenate: false)
          + parbreak()
          + text(size: 2em, smallcaps(subtitle)),
      )
      v(1.6em)
      emph(text(size: 1.3em, subsubtitle))
      parbreak()
      emph(subsubsubtitle)
    },
  )

  align(bottom + center, text(size: 1.5em, smallcaps(author)))
}

#let book(
  title: none,
  author: none,
  subtitle: none,
  subsubtitle: none,
  subsubsubtitle: none,
  body,
) = {
  let INDENT = 0em

  set text(font: "New Computer Modern")
  set par(first-line-indent: (amount: INDENT, all: false), justify: true, spacing: 1em, leading: 0.5em + 1pt)
  set enum(indent: INDENT, numbering: "1)")
  set terms(hanging-indent: INDENT)
  show math.equation: set block(breakable: true)
  set document(author: if author != none { author } else { () }, title: title)

  show figure.caption: it => {
    set text(size: 0.85em)
    emph(it)
  }

  set page(
    margin: (left: 100pt, right: 100pt),
    footer: context {
      let current_chapter = query(selector(heading.where(level: 1)).before(here())).at(-1, default: none)
      let is_chapter_heading = current_chapter != none and current_chapter.location().page() == here().page()

      if not is_chapter_heading {
        return
      }

      let page = counter(page).display()
      set text(size: 9pt)
      place(center + horizon, page)
    },
    header: context {
      let page_num = counter(page).get().at(0)
      if page_num == 1 {
        return
      }

      let chapter_right_after = query(selector(heading.where(level: 1)).after(here())).at(0, default: none)

      let current_chapter = query(selector(heading.where(level: 1)).before(here())).at(-1, default: none)
      let current_sec = query(selector(heading.where(level: 2)).before(here())).at(-1, default: none)

      let is_chapter_heading = chapter_right_after != none and chapter_right_after.location().page() == here().page()

      if is_chapter_heading {
        return
      }

      let page = counter(page).display()
      let chap = if current_chapter != none {
        smallcaps(current_chapter.body)
      }
      let chap_num = if current_chapter != none [
        chap. #numbering(current_chapter.numbering, ..counter(heading).at(current_chapter.location()))
      ]

      let sec_num = if current_sec != none [
        sec. #numbering(current_sec.numbering, ..counter(heading).at(current_sec.location()))
      ]

      set text(size: 9pt)

      if calc.even(page_num) {
        place(left + horizon, page)
        place(center + horizon, smallcaps(title))
        if not is_chapter_heading {
          place(right + horizon, smallcaps(chap_num))
        }
      } else {
        if not is_chapter_heading {
          place(left + horizon, smallcaps(sec_num))
          place(center + horizon, chap)
        }
        place(right + horizon, page)
      }
    },
  )

  // offset the numbering by one because single star could be ambiguous in math, maybe
  set footnote(numbering: n => numbering("*", n + 1))

  set math.equation(numbering: "(1)")
  show math.equation: it => {
    // https://forum.typst.app/t/how-to-conditionally-enable-equation-numbering-for-labeled-equations/977
    if it.block and not it.has("label") [
      #counter(math.equation).update(v => v - 1)
      #math.equation(it.body, block: true, numbering: none)#label("")
    ] else {
      it
    }
  }
  // show equation references as (1)
  // https://typst.app/docs/reference/model/ref/
  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      link(
        el.location(),
        numbering(
          el.numbering,
          ..counter(eq).at(el.location()),
        ),
      )
    } else {
      it
    }
  }
  show math.qed: "▮"

  show link: it => {
    if type(it.dest) != str {
      // local link
      it
    } else {
      set text(font: "DejaVu Sans Mono")
      box(it)
    }
  }

  title_page(
    author: author,
    title: title,
    subtitle: subtitle,
    subsubtitle: subsubtitle,
    subsubsubtitle: subsubsubtitle,
  )

  set heading(numbering: "1.11a")

  show heading.where(level: 4): set heading(outlined: false)
  show heading.where(level: 4): it => {
    let levels = counter(heading).get()
    numbering("a.", levels.at(3))
  }

  show heading.where(level: 3): set heading(outlined: false)
  show heading.where(level: 3): it => {
    let levels = counter(heading).get()
    let is_empty = it.body == none or it.body == "" or it.body != []

    (
      [#levels.at(0).#{ levels.at(1) }#{ levels.at(2) }.]
        + if is_empty [
          *#it.body.*
        ]
    )
  }

  show heading.where(level: 2): it => {
    block(
      sticky: true,
      par(
        spacing: 0em,
        {
          numbering("1. ", counter(heading).get().at(1))
          smallcaps(it.body)
        },
      ),
    )
  }

  show heading.where(level: 1): set heading(supplement: [Chapter])
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set text(weight: "regular", hyphenate: false)
    set par(first-line-indent: 0.0em)
    counter(footnote).update(0)
    counter(math.equation).update(0)
    block(
      inset: (left: -0.2em),
      height: 15%,
      {
        set text(size: 2em)
        (smallcaps(it.body))
      }
        + smallcaps[
          #linebreak()
          #h(0.125em)Chapter #numbering("1", counter(heading).get().at(0))
        ],
    )
  }

  pagebreak()
  body
}

/// Theorem environment. Optionally can have a name, like "Rolle's" theorem.
#let thmenv(kind, fmt: it => it, body_fmt: it => it) = {
  return (body, name: none, id: none) => [
    #show figure: set align(start)
    #show figure: it => it.body
    // This is boxed so that the Theorem is inline (not a block element).
    #box([
      #figure(
        kind: kind,
        supplement: kind,
        numbering: (..levels) => {
          // Numbering is just section numbering. This template has lots and lots
          // of subsection options, so only put one theorem per subsection.
          counter(heading).display()
        },
        {
          (if name == none [ #fmt(kind).] else [#fmt(kind) *(#name)*.])
        },
      )#if id != none { label(id) }
    ])
    #body_fmt(body)
  ]
}

#let theorem = thmenv("Theorem", fmt: smallcaps, body_fmt: emph)
#let lemma = thmenv("Lemma", fmt: smallcaps, body_fmt: emph)
#let corollary = thmenv("Corollary", fmt: smallcaps, body_fmt: emph)
#let definition = thmenv("Definition", fmt: smallcaps, body_fmt: emph)
#let example = thmenv("Example", fmt: emph)
#let solution = thmenv("Solution", fmt: emph)
#let proof = thmenv("Proof", fmt: emph)
#let remark = thmenv("Remark", fmt: it => strong(emph(it)))

/// Quick macro to "glue" text to the next element.
//
// Use this on text before a math block so that the text doesn't get separated from it.
#let glue = block.with(sticky: true)
