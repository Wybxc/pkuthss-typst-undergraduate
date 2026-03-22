#import "font.typ": *
#import "numbering.typ": *
#let lengthceil(len, unit: 字号.小四) = calc.ceil(len / unit) * unit
#let chineseoutline(depth: none, indent: true) = {
  align(top + center)[
    #set text(font: 字体.黑体, size: 字号.小二)
    #strong[目#h(1em)录]
  ]

  set text(font: 字体.黑体, size: 字号.小四)
  set align(top)
  context {
    let it = here()
    let elements = query(heading.where(outlined: true).after(it))

    set par(leading: 1em, first-line-indent: 0em)
    for el in elements {
      let maybe_number = if el.numbering != none {
        if el.numbering == chinesenumbering {
          chinesenumbering(..counter(heading).at(el.location()), location: el.location())
        } else {
          numbering(el.numbering, ..counter(heading).at(el.location()))
        }
      }
      let line = {
        // Indentation
        if indent {
          h(1em * (el.level - 1))
        }

        // Number
        if maybe_number != none {
          context {
            let width = measure(maybe_number).width + 1pt
            box(
              width: lengthceil(width),
              link(
                el.location(),
                if el.level == 1 {
                  strong(maybe_number)
                } else {
                  maybe_number
                },
              ),
            )
          }
        }

        // Title
        link(
          el.location(),
          if el.level == 1 {
            strong(el.body)
          } else {
            set text(font: 字体.宋体, weight: "regular")
            el.body
          },
        )

        // Filler dots
        box(width: 1fr, h(10pt) + box(width: 1fr, repeat[.]) + h(10pt))

        // Page number
        let footer = query(selector(<__footer__>).after(el.location()))
        let page_number = if footer == () {
          0
        } else {
          counter(page).at(footer.first().location()).first()
        }

        link(
          el.location(),
          if el.level == 1 {
            strong(str(page_number))
          } else {
            str(page_number)
          },
        )

        linebreak()
      }

      line
    }

    // 北京大学学位论文原创性声明和使用授权说明
    link(<claim>, strong("北京大学学位论文原创性声明和使用授权说明"))
    box(width: 1fr, h(10pt) + box(width: 1fr, repeat[.]) + h(10pt))
    link(<claim>, strong(str(counter(page).at(<claim>).first())))
  }
}

#let TableOfContent = [
  #pagebreak(weak: true)
  #chineseoutline()
]
