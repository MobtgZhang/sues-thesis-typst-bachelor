#import "thesis.typ" as thesis

#show: doc => thesis.sues_thesis_bachelor(
  blind: false,
  doc
)
// 封面
#include "chapters/cover.typ"
// 插入目录
#locate(loc => {
    thesis.chineseoutline(
      title: "目录",
      depth: 3,
      indent: true,
    )
})
#pagebreak()
// 文章章节内容
#include "chapters/ch01.typ"
#include "chapters/ch02.typ"
#include "chapters/ch03.typ"
#include "chapters/ch04.typ"
#include "chapters/ch05.typ"
// 附录部分
#include "chapters/appendix.typ"
// 致谢部分
#include "chapters/thanks.typ"
