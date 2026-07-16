/// Theorem environments

#import "_constants.typ": LEADING
#import "_style.typ": _box-math

/// Theorem environment.
///
/// - `kind`: Name of the kind of environment, e.g. "Theorem".
/// - `fmt`: Formatting function for the heading of this theorem.
/// - `body-fmt`: Formatting function for the body of this theorem.
/// - `numbered`: Whether to number this theorem or not.
/// - `counter-type`: Theorems will use this counter. Use the same counter to
//    share a counter between environments.
#let thm-env(kind, fmt: it => smallcaps(strong(it)), body-fmt: emph, numbered: true, counter-type: "thmlike") = {
  /// `body`: Contents of the theorem.
  /// `name`: Name of the theorem, e.g. "Rolle's" theorem.
  /// `breakable`: Allow breaking the theorem across pages.
  /// `numbering-internal`: Sets the numbering of lists within the environment.
  return (body, name: none, breakable: true, numbering-internal: "(1)") => box({
    // the entire theorem needs to be a single box, because `sequence` objects
    // are very screwed up. as of typst 0.15.0, using a sequence instead of a
    // box will result in a 'label does not exist in document' error, when
    // _box-math is also being used.
    metadata("__mousse_thmenv")
    let theorem-counter = counter("__moussethm-" + counter-type)
    if numbered {
      theorem-counter.step()
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

    let thm-figure = figure(
      kind: kind,
      supplement: kind,
      numbering: (..levels) => [#counter(heading).get().at(0).#theorem-counter.display()],
      {
        let number = context [ #counter(heading).get().at(0).#theorem-counter.display()]
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
        thm-heading + body-fmt-internal(_box-math(body))
      },
    )

    context {
      let index = query(selector(<__mousse_thm_figure_meta>).before(here())).len()
      let fig-label = label("__mousse_thm_figure_" + str(index))

      // smuggle the index out of the context
      [#metadata((label: fig-label))<__mousse_thm_figure_meta>]

      box(width: 100%, [#thm-figure#fig-label])
      v(LEADING)
    }
  })
}

#let _smallcaps-strong = it => smallcaps(strong(it))

#let theorem = thm-env("Theorem")
#let proposition = thm-env("Proposition")
#let lemma = thm-env("Lemma")
#let corollary = thm-env("Corollary")
#let definition = thm-env("Definition")
#let example = thm-env("Example", fmt: it => strong(it), body-fmt: emph, counter-type: "example")
#let solution = thm-env("Solution", fmt: emph, body-fmt: it => it, numbered: false, counter-type: "example")
#let proof = thm-env("Proof", fmt: emph, body-fmt: it => it, numbered: false)
#let remark = thm-env("Remark", body-fmt: it => it, numbered: false)
