#import "font.typ": *
#let TitlePage(
  chinese_title: "北京大学本科生typst论文模板",
  english_title: "typst template for undergraduate in PKU",
  name : "十一",
  studentid : "20000xxxxx",
  department : "信息科学与技术学院",
  major : "信息与计算科学",
  supervisor_name : "11",
  year_and_month : "二〇二四年五月"
) = {
  let fieldname(name) = [
    #set align(right + top)
    #set text(font : 字体.黑体, size : 字号.小三)
    #strong(name)
  ]

  let fieldvalue(style : 字体.黑体, size : 字号.三号, row_gutter : 0.7em, value) = [
    #set align(center + horizon)
    #set text(font: style, size:size)
    #grid(
      rows: (auto, auto),
      row-gutter: row_gutter,
      [#value],
      line(length: 100%)
    )
  ]
  page(numbering: none, header: none, footer: none)[
    #set align(center)
    #set par(justify: false)

    #v(0.5em)
    #pad(left: 1em)[
      #grid(
        columns: (auto, auto),
        column-gutter: 1.05em,
        image("../asset/pkulogo.svg", height: 68pt, fit: "contain"),
        align(horizon,
          image("../asset/pkuword.svg", height: 47pt, fit: "contain")
        )
      )
      #v(0.4em)
      #block(
        text(
          font: 字体.黑体,
          size: 字号.小初,
          [本科生毕业论文]
        )
      )
    ]

    #v(2.5em)

    #let title = fieldvalue.with(style : 字体.黑体, size : 字号.一号, row_gutter : 0.5em)
    #pad(left: 11.5%, right: 14%)[#grid(
      columns: 2,
      rows: 2,
      column-gutter: 1.5em,
      row-gutter: 1.4em,
      [#align(horizon, text(font: 字体.宋体, size : 字号.二号)[题目：])], [#strong(title(chinese_title))],
      [],[#strong(title(english_title))]
    )]
    #v(6.7em)
    #let term = fieldvalue.with(style : 字体.仿宋, size : 字号.小三, row_gutter : 0.7em)
    #pad(left: 15.5%, right: 19%, grid(
      columns: 2,
      row-gutter: 0.95em,
      column-gutter: 1em,
      fieldname([姓#h(2em)名：]), term(name),
      fieldname([学#h(2em)号：]), term(studentid),
      fieldname([院#h(2em)系：]), term(department),
      fieldname([专#h(2em)业：]), term(major),
      fieldname([导师姓名：]), term(supervisor_name)
    ))

    #v(2.1em)
    #align(horizon)[
      #pad(left: 1.05em)[
        #text(
          font: 字体.黑体,
          size: 字号.三号,
          year_and_month
        )
      ]
    ]
  ]
}