/// Theorem environments

#import "_constants.typ": LEADING

/// Theorem environment. Optionally can have a name, like "Rolle's" theorem.
#let thm-env(kind, fmt: it => it, body-fmt: it => it, numbered: true, counter-type: "thmlike") = {
  return (body, name: none, breakable: true, numbering-internal: "(1)") => {
    let ctr = counter("moussethm-" + counter-type)
    if numbered {
      ctr.step()
    }
    show figure: set align(start)
    show figure: it => it.body

    let body-fmt-internal = it => {
      // un-italicize numbering in theorems
      set enum(numbering: (..nums) => {
        show emph: it => it.body
        body-fmt(std.numbering(numbering-internal, ..nums))
      })
      show text: body-fmt
      it
    }

    // HACK
    let space = [
      a
    ]
      .children
      .at(0)
      .func()

    let body-elems = if body.has("children") {
      // filter out spaces from start of body
      body
        .children
        .enumerate()
        .filter(
          ((i, x)) => {
            not (i == 0 and x.func() == space)
          },
        )
        .map(((i, x)) => x)
    } else {
      (body,)
    }

    linebreak()
    box(width: 100%, figure(
      kind: kind,
      supplement: kind,
      numbering: (..levels) => [#counter(heading).get().at(0).#ctr.display()],
      {
        v(weak: false, LEADING * 2)
        let number = context [ #counter(heading).get().at(0).#ctr.display()]
        let thm-heading-content = fmt[#kind#if numbered { number }] + if name != none [ *(#name)*] + fmt[.]

        let first-elem = body-elems.at(0, default: none)

        let block-funcs = (list.item, enum.item)
        let is-block = first-elem.func() in block-funcs or (first-elem.func() == math.equation and first-elem.block)

        let thm-heading = if is-block {
          // heading, and then thm content on a new line
          // use sticky to prevent heading from being page-broken apart from the content
          block(sticky: true, thm-heading-content)
        } else {
          // heading, and thm content on the same line
          thm-heading-content + h(0.35em, weak: true)
        }
        thm-heading + body-fmt-internal(body)
        v(weak: false, LEADING * 2)
      },
    ))
    linebreak()
  }
}

#let _smallcaps-strong = it => smallcaps(strong(it))

#let theorem = thm-env("Theorem", fmt: _smallcaps-strong, body-fmt: emph)
#let proposition = thm-env("Proposition", fmt: _smallcaps-strong, body-fmt: emph)
#let lemma = thm-env("Lemma", fmt: _smallcaps-strong, body-fmt: emph)
#let corollary = thm-env("Corollary", fmt: _smallcaps-strong, body-fmt: emph)
#let definition = thm-env("Definition", fmt: _smallcaps-strong, body-fmt: emph)
#let example = thm-env("Example", fmt: it => strong(it), counter-type: "example")
#let solution = thm-env("Solution", fmt: emph, numbered: false)
#let proof = thm-env("Proof", fmt: emph, numbered: false)
#let remark = thm-env("Remark", fmt: it => strong(emph(it)), numbered: false)
