// 定义一些常见的变量
// 定义行距
#let linespacing = 1.5em
// 定义字体的大小
#let fontsizedict = (
  初号: 42pt,
  小初: 36pt,
  一号: 26pt,
  小一: 24pt,
  二号: 22pt,
  小二: 18pt,
  三号: 16pt,
  小三: 15pt,
  四号: 14pt,
  中四: 13pt,
  小四: 12pt,
  五号: 10.5pt,
  小五: 9pt,
  六号: 7.5pt,
  小六: 6.5pt,
  七号: 5.5pt,
  小七: 5pt,
)
// 定义文章中使用到的字体信息
#let fontstypedict = (
  仿宋: ("Times New Roman", "FangSong"),
  宋体: ("Times New Roman", "SimSun"),
  黑体: ("Times New Roman", "SimHei"),
  楷体: ("Times New Roman", "KaiTi"),
  代码: ("New Computer Modern Mono", "Times New Roman", "SimSun"),
)
// 章节定义
#let chaptercounter = counter("chapter")
// 附录定义
#let appendixcounter = counter("appendix")
// 脚注定义
#let footnotecounter = counter(footnote)
// 代码计数器定义
#let rawcounter = counter(figure.where(kind: "code"))
// 图片计数器定义
#let imagecounter = counter(figure.where(kind: image))
// 表格计数器定义
#let tablecounter = counter(figure.where(kind: table))
// 方程计数器定义
#let equationcounter = counter(math.equation)
// 附录定义
#let appendix() = {
  appendixcounter.update(10)
  chaptercounter.update(0)
  counter(heading).update(0)
}
// -----------------------------------------
// 定义一些常见的函数
#let chineseunderline(s, width: 300pt, bold: false) = {
  let chars = s.clusters()
  let n = chars.len()
  style(styles => {
    let i = 0
    let now = ""
    let ret = ()

    while i < n {
      let c = chars.at(i)
      let nxt = now + c

      if measure(nxt, styles).width > width or c == "\n" {
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
  })
}
// 定义目录函数
#let chineseoutline(title: "目录", depth: none, indent: false) = {
  heading(title, numbering: none, outlined: false)
  locate(it => {
    let elements = query(heading.where(outlined: true).after(it), it)

    for el in elements {
      // Skip headings that are too deep
      if depth != none and el.level > depth { continue }

      let maybe_number = if el.numbering != none {
        if el.numbering == chinesenumbering {
          chinesenumbering(..counter(heading).at(el.location()), location: el.location())
        } else {
          numbering(el.numbering, ..counter(heading).at(el.location()))
        }
        h(0.5em)
      }

      let line = {
        if indent {
          h(1em * (el.level - 1 ))
        }

        if el.level == 1 {
          v(0.5em, weak: true)
        }

        if maybe_number != none {
          style(styles => {
            let width = measure(maybe_number, styles).width
            box(
              width: lengthceil(width),
              link(el.location(), if el.level == 1 {
                strong(maybe_number)
              } else {
                maybe_number
              }
            ))
          })
        }

        if el.level == 1 {
          strong(el.body)
        } else {
          el.body
        }

        // Filler dots
        if el.level == 1 {
          box(width: 1fr, h(10pt) + box(width: 1fr) + h(10pt))
        } else {
          box(width: 1fr, h(10pt) + box(width: 1fr, repeat[.]) + h(10pt))
        }

        // Page number
        let footer = query(selector(<__footer__>).after(el.location()), el.location())
        let page_number = if footer == () {
          0
        } else {
          counter(page).at(footer.first().location()).first()
        }
        link(el.location(), if el.level == 1 {
          strong(str(page_number))
        } else {
          str(page_number)
        })

        linebreak()
        v(-0.2em)
      }

      line
    }
  })
}

// ----------------------------------------
// 定义学士学位论文模板
#let sues_thesis_bachelor(
    blind: false,
    doc
) = {
    // 定义纸张类型和页眉页脚
    set page("a4")
    // 定义插入列表的格式
    set list(indent: 2em)
    set enum(indent: 2em)
    // 定义字体格式
    show strong: it => text(font: fontstypedict.黑体,weight: "semibold" ,it.body)
    show emph: it => text(font: fontstypedict.楷体, style: "italic" ,it.body)
    show par: set block(spacing: linespacing)
    show raw: set text(font: fontstypedict.代码)
    // 论文字体大小
    set text(fontsizedict.小四, font: fontstypedict.宋体, lang: "zh")
    // 设置标题的格式和样式
    // 定义三级标题格式
    show heading: it => [
        // 对于二级或二级标题以上的，取消空格
        #set par(first-line-indent: 0em)

        #let sizedheading(it,size) = [
            #set text(size)
            #v(2em)
            #if it.numbering != none {
                strong(counter(heading).display())
                h(0.5em)
            }
            #strong(it.body)
            #v(1em)
        ]
        // 一级标题
        #if it.level == 1 {
            if not it.body.text in ("ABSTRACT","学位论文使用授权说明") {
                pagebreak(weak: true)
            }
            locate(loc => {
                if it.body.text == "摘要" {
                    counter(page).update(1)
                }
            })
            if it.numbering != none {
                chaptercounter.step()
            }
            footnotecounter.update(())
            imagecounter.update(())
            tablecounter.update(())
            rawcounter.update(())
            equationcounter.update(())

            set align(center)
            sizedheading(it,fontsizedict.三号)
        } else {
            if it.level == 2 {
                // 二级标题
                sizedheading(it,fontsizedict.四号)
            } else if it.level == 3 {
                // 三级标题
                sizedheading(it,fontsizedict.中四)
            } else {
                // 三级标题以下
                sizedheading(it,fontsizedict.小四)
            }
        }
    ]
    // 插入正文
    set align(left + top)
    par(justify: true, first-line-indent: 2em, leading: linespacing)[
        #doc
    ]
}