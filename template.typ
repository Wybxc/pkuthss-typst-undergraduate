// font.typ: 字体，字号信息
#import "template/font.typ": *

// title_page.typ: 标题页面
#import "template/title_page.typ": *

// check_sheet.typ: 打分表
#import "template/check_sheet.typ": *

// cliam.typ: 版权声明
#import "template/claim.typ": *

// abstract.typ : 摘要
#import "template/abstract.typ": *

// content.typ: 目录
#import "template/outline.typ": *

// numbering.typ: 计数部分
#import "template/numbering.typ": *


#let lengthceil(len, unit: 字号.小四) = calc.ceil(len / unit) * unit
#let partcounter = counter("part")
#let chaptercounter = counter(heading)
#let appendixcounter = counter("appendix")
#let footnotecounter = counter(footnote)
#let rawcounter = counter(figure.where(kind: raw))
#let imagecounter = counter(figure.where(kind: image))
#let tablecounter = counter(figure.where(kind: table))
#let equationcounter = counter(math.equation)
#let skippedstate = state("skipped", false)
#let thmcounter = counter(figure.where(kind: "theorem"))

// 文档的状态参数
#let doc_mode = state("doc_mode", false)


#let chineseunderline(s, width: 300pt, bold: false) = {
  let chars = s.clusters()
  let n = chars.len()
  context {
    let i = 0
    let now = ""
    let ret = ()

    while i < n {
      let c = chars.at(i)
      let nxt = now + c

      if measure(nxt).width > width or c == "\n" {
        if bold {
          ret.push(strong(now))
        } else {
          ret.push(now)
        }
        ret.push(v(-1em))
        ret.push(line(length: 100%))
        if c == "\n" {
          now = ""
        } else {
          now = c
        }
      } else {
        now = nxt
      }

      i = i + 1
    }

    if now.len() > 0 {
      if bold {
        ret.push(strong(now))
      } else {
        ret.push(now)
      }
      ret.push(v(-0.9em))
      ret.push(line(length: 100%))
    }

    ret.join()
  }
}

#let listoffigures(title: "插图", kind: image) = {
  heading(title, numbering: none, outlined: false)
  context {
    let it = here()
    let elements = query(figure.where(kind: kind).after(it))

    for el in elements {
      let maybe_number = {
        let el_loc = el.location()
        chinesenumbering(
          chaptercounter.at(el_loc).first(),
          counter(figure.where(kind: kind)).at(el_loc).first(),
          location: el_loc,
        )
        h(0.5em)
      }
      let line = {
        context {
          let width = measure(maybe_number, styles).width
          box(
            width: lengthceil(width),
            link(el.location(), maybe_number),
          )
        }

        link(el.location(), el.caption.body)

        // Filler dots
        box(width: 1fr, h(10pt) + box(width: 1fr, repeat[.]) + h(10pt))

        // Page number
        let footers = query(selector(<__footer__>).after(el.location()))
        let page_number = if footers == () {
          0
        } else {
          counter(page).at(footers.first().location()).first()
        }
        link(el.location(), str(page_number))
        linebreak()
        v(-0.2em)
      }

      line
    }
  }
}

#let booktab(columns: (), aligns: (), width: auto, caption: none, ..cells) = {
  let headers = cells.pos().slice(0, columns.len())
  let contents = cells.pos().slice(columns.len(), cells.pos().len())
  set align(center)

  if aligns == () {
    for i in range(0, columns.len()) {
      aligns.push(center)
    }
  }

  let content_aligns = ()
  for i in range(0, contents.len()) {
    content_aligns.push(aligns.at(calc.rem(i, aligns.len())))
  }

  figure(
    block(
      width: width,
      grid(
        columns: auto,
        row-gutter: 1em,
        line(length: 100%),
        [
          #set align(center)
          #box(
            width: 100% - 1em,
            grid(
              columns: columns,
              ..headers
                .zip(aligns)
                .map(it => [
                  #set align(it.last())
                  #strong(it.first())
                ])
            ),
          )
        ],
        line(length: 100%),
        [
          #set align(center)
          #box(
            width: 100% - 1em,
            grid(
              columns: columns,
              row-gutter: 1em,
              ..contents
                .zip(content_aligns)
                .map(it => [
                  #set align(it.last())
                  #it.first()
                ])
            ),
          )
        ],
        line(length: 100%),
      ),
    ),
    caption: caption,
    kind: table,
  )
}

// 标记文档开始的时候的一些状态设置
#let doc_start = () => {
  doc_mode.update(true)
  // 设置文档计数的状态，在numbering.typ文件里
  start_page_counting()
}

// 标记文档结束的时候的一些状态设置
#let doc_end = () => {
  doc_mode.update(false)
  // 设置文档计数的状态，在numbering.typ文件里
  stop_page_counting()
}

#let UndergraduateThesis(
  ctitle: "",
  linespacing: 1em,
  doc,
) = {
  set text(weight: "regular", font: 字体.宋体, size: 字号.小四, lang: "zh")
  show math.equation: set text(font: 字体.数学)

  set heading(numbering: chinesenumbering)
  set list(indent: 2em, marker: move(dy: 2pt)[•])
  set enum(indent: 2em, numbering: it => move(dy: 2pt)[#it.])

  set page(
    "a4",
    margin: (
      top: 2.5cm,
      right: 2cm,
      left: 2cm,
      bottom: 2.5cm,
    ),
    header: context {
      footnotecounter.update(0)
      if not doc_mode.at(here()) {
        return
      }
      set align(center)
      set text(font: 字体.宋体, size: 字号.小五, weight: "regular")
      ctitle
      v(-0.5em)
      line(length: 100%)
    },
    footer: foot_numbering(),
  )

  show <reference>: set heading(numbering: none)
  show <thanks>: set heading(numbering: none)
  show strong: it => text(font: 字体.黑体, weight: "semibold", it.body)
  show emph: it => text(font: 字体.楷体, style: "italic", it.body)
  set par(spacing: linespacing, justify: true)
  show raw: set text(font: 字体.代码)

  show figure.caption: it => {
    set text(font: 字体.宋体, size: 字号.五号)
    v(0.5em)
    it
  }
  show figure: it => context {
    if it.kind == raw {
      show raw: it => block(stroke: 1pt + luma(240), radius: 1pt, inset: 10pt, it)
      it
    } else if it.kind == "theorem" {
      set align(start)
      set par(justify: false)
      set block(breakable: true)
      let nums = thmcounter.at(here())
      strong[#it.supplement #chinesenumbering(chaptercounter.at(here()).first(), ..nums)]
      if it.caption != none {
        strong[（#it.caption.body）]
      } else {
        h(0.5em)
      }
      it.body
    } else if it.kind == "proof" {
      set align(start)
      set block(breakable: true)
      strong[#it.supplement：]
      it.body
    } else {
      it
    }
  }
  show figure.where(kind: image): set math.equation(numbering: none)
  set figure(
    numbering: (..nums) => context {
      chinesenumbering(chaptercounter.at(here()).first(), ..nums)
    },
  )
  set math.equation(
    numbering: (..nums) => context {
      chinesenumbering(brackets: true, chaptercounter.at(here()).first(), ..nums)
    },
  )

  show heading: it => {
    // Cancel indentation for headings
    set par(first-line-indent: 0em)

    let sizedheading(it, size) = [
      #set text(size: size, font: 字体.黑体)
      #v(0.5em)
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
      #v(0.4em)
    ]
    set align(left)
    set text(weight: "regular")
    if it.level == 1 {
      rawcounter.update(0)
      imagecounter.update(0)
      tablecounter.update(0)
      equationcounter.update(0)
      thmcounter.update(0)
      // pagebreak()
      pagebreak(to: "even", weak: true)
      sizedheading(it, 字号.三号)
    } else if it.level == 2 {
      sizedheading(it, 字号.小三)
    } else if it.level == 3 {
      sizedheading(it, 字号.四号)
    } else {
      sizedheading(it, 字号.小四)
    }
  }

  show ref: it => {
    if it.element == none {
      // Keep citations as is
      it
    } else {
      // Remove prefix spacing
      h(0em, weak: true)

      let el = it.element
      let el_loc = el.location()
      if el.func() == math.equation {
        // Handle equations
        link(
          el_loc,
          [
            式
            #chinesenumbering(
              chaptercounter.at(el_loc).first(),
              equationcounter.at(el_loc).first(),
              location: el_loc,
              brackets: true,
            )
          ],
        )
      } else if el.func() == figure {
        // Handle figures
        if el.kind == image {
          link(
            el_loc,
            [
              图
              #chinesenumbering(chaptercounter.at(el_loc).first(), imagecounter.at(el_loc).first(), location: el_loc)
            ],
          )
        } else if el.kind == table {
          link(
            el_loc,
            [
              表
              #chinesenumbering(chaptercounter.at(el_loc).first(), tablecounter.at(el_loc).first(), location: el_loc)
            ],
          )
        } else if el.kind == raw {
          link(
            el_loc,
            [
              代码
              #chinesenumbering(chaptercounter.at(el_loc).first(), rawcounter.at(el_loc).first(), location: el_loc)
            ],
          )
        } else if el.kind == "theorem" {
          link(
            el_loc,
            [
              #el.supplement
              #chinesenumbering(chaptercounter.at(el_loc).first(), thmcounter.at(el_loc).first(), location: el_loc)
            ],
          )
        }
      } else if el.func() == heading {
        // Handle headings
        if el.level == 1 {
          link(el_loc, chinesenumbering(..counter(heading).at(el_loc), location: el_loc))
        } else {
          link(
            el_loc,
            [
              节
              #chinesenumbering(..counter(heading).at(el_loc), location: el_loc)
            ],
          )
        }
      }

      // Remove suffix spacing
      h(0em, weak: true)
    }
  }


  set par(first-line-indent: (amount: 2em, all: true), leading: 1em)
  show par: it => context {
    if doc_mode.at(here()) {
      v(0.1em)
      it
    } else {
      it
    }
  }

  set align(start)

  // 正文显示部分
  doc
}
