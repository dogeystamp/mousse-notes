#let INDENT = 1.4em

/// Manual override for indent (because Typst paragraphs suck)
#let indent = h(INDENT)

#let title_page(
  title: none,
  subtitle: none,
  subsubtitle: none,
  subsubsubtitle: none,
  author: none,
) = {
  place(horizon + center, dy: -15%, {
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
  })

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
  set text(font: "New Computer Modern")
  set par(first-line-indent: (amount: INDENT, all: false), justify: true, spacing: 0.5em + 1pt, leading: 0.5em + 1pt)
  set enum(indent: INDENT, numbering: "1.")
  set terms(hanging-indent: INDENT)

  // break block equations; don't break inline eqs
  show math.equation: set block(breakable: true)
  show math.equation.where(block: false): it => box(it)

  set document(author: if author != none { author } else { () }, title: title)

  set page(
    margin: (left: 16.3%, right: 16.3%),
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
      let sec_right_after = query(selector(heading.where(level: 2)).after(here())).at(0, default: none)
      let sec_right_before = query(selector(heading.where(level: 2)).before(here())).at(-1, default: none)

      let current_chapter = query(selector(heading.where(level: 1)).before(here())).at(-1, default: none)
      let current_sec = if sec_right_after != none and sec_right_after.location().page() == here().page() {
        sec_right_after
      } else {
        sec_right_before
      }

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
      link(el.location(), numbering(el.numbering, ..counter(eq).at(el.location())))
    } else {
      it
    }
  }
  show math.qed: "▮"

  show link: it => {
    if type(it.dest) != str {
      // local link
      it
    } else if (it.body == [#it.dest]) {
      // URL (no custom text)
      set text(fill: blue)
      set text(font: "DejaVu Sans Mono", size: 0.8em)
      box(it)
    } else {
      // URL (custom text)
      set text(fill: blue)
      show text: underline
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

  set heading(numbering: "1.1.1a")

  let heading-func = (body-fmt: strong, it) => {
    block(
      sticky: true,
      (
        counter(heading).display() + h(0.8em) + body-fmt(it.body)
      ),
    )
  }

  show heading.where(level: 2): heading-func.with(body-fmt: smallcaps)
  show heading.where(level: 2): set text(size: 1.1em)
  show heading.where(level: 2): it => {
    set block(above: 0em, below: 0em)
    v(1.5em, weak: true) + it + v(0.75em, weak: true)
  }

  show heading.where(level: 3): heading-func
  show heading.where(level: 3): it => {
    set block(above: 0em, below: 0em)
    v(1.25em, weak: true) + it + v(0.75em, weak: true)
  }

  show heading.where(level: 4): heading-func

  show heading.where(level: 1): set heading(supplement: [Chapter])
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set text(weight: "regular", hyphenate: false)
    set par(first-line-indent: 0.0em)
    counter(footnote).update(0)
    counter(math.equation).update(0)
    block(
      inset: (left: -0.2em),
      height: 15% - 1em,
      {
        set text(size: 2em)
        (smallcaps(it.body))
      }
        + if it.outlined {
          smallcaps[
            #linebreak()
            #h(0.125em)Chapter #counter(heading).display()
          ]
        },
    )
  }
  show enum: it => { v(0.9em, weak: true) + it + v(0.9em, weak: true) }

  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(gap: 1em)
  show figure.where(kind: table): it => { v(1.5em, weak: true) + it + v(2em, weak: true) }

  pagebreak()
  body
}

/// Theorem environment. Optionally can have a name, like "Rolle's" theorem.
#let thmenv(kind, fmt: it => it, body_fmt: it => it, numbered: true) = {
  return (body, name: none, id: none, breakable: true) => [
    #let ctr = counter("moussethm" + kind)
    #ctr.step()
    #show figure: set align(start)
    #show figure: it => it.body
    #v(weak: true, 1.5em)
    #block(width: 100%, breakable: breakable, above: 0em, below: 0em, [
      #figure(
        kind: kind,
        supplement: kind,
        numbering: (..levels) => [#(counter(heading).get().at(0)).#levels.at(0)],
        {
          let number = context [ #counter(heading).get().at(0).#ctr.display()]
          (
            fmt[#kind#if numbered { number }] + if name != none [ *(#name)*] + fmt[.] + h(0.1em) + body_fmt(body)
          )
        },
      )#if id != none { label(id) }
    ])
    #v(weak: true, 1.5em)
  ]
}

#let smallcaps-strong = it => smallcaps(strong(it))

#let theorem = thmenv("Theorem", fmt: smallcaps-strong, body_fmt: emph)
#let lemma = thmenv("Lemma", fmt: smallcaps-strong, body_fmt: emph)
#let corollary = thmenv("Corollary", fmt: smallcaps-strong, body_fmt: emph)
#let definition = thmenv("Definition", fmt: smallcaps-strong, body_fmt: emph)
#let example = thmenv("Example", fmt: smallcaps)
#let solution = thmenv("Solution", fmt: emph, numbered: false)
#let proof = thmenv("Proof", fmt: emph, numbered: false)
#let remark = thmenv("Remark", fmt: it => strong(emph(it)), numbered: false)

/// Quick macro to "glue" text to the next element.
//
// Use this on text before a math block so that the text doesn't get separated from it.
// Set `indent: false` when this is the first element after a heading.
#let glue(indent: true, body) = {
  block(sticky: true, (if indent { h(INDENT) }) + body)
}

/// Custom table function.
#let tablef(..args) = {
  set table.hline(stroke: 0.5pt)
  table(
    align: left,
    stroke: (x, y) => {
      if (y == 0) {
        (
          top: 1pt,
          bottom: 0.5pt,
        )
      }
    },
    ..args.named(),
    ..(args.pos() + (table.hline(stroke: 1pt),)),
  )
}
