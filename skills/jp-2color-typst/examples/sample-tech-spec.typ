// ============================================================================
// Sample Document: Japanese 2-Color Print (2色刷り) Technical Handbook
// Self-contained example — works directly in Obsidian Typst Mate & Typst CLI
// Compile: typst compile sample-tech-spec.typ sample-tech-spec.pdf
// ============================================================================

#let f-sans = ("Noto Sans SC", "Microsoft YaHei", "SimHei")
#let f-serif = ("Noto Serif SC", "Noto Sans SC", "SimSun")
#let f-mono = ("Consolas", "Noto Sans SC")

#let ink = (
  k100:     rgb("#1C1C1C"),
  k65:      rgb("#595959"),
  k40:      rgb("#8C8C8C"),
  k25:      rgb("#C4C4C4"),
  k10:      rgb("#E8E8E8"),
  k05:      rgb("#F4F4F4"),
  spot-100: rgb("#005BAC"),
  spot-40:  rgb("#6FA3D2"),
  spot-10:  rgb("#EBF3FA"),
)

#let jp2-active-sec(fallback-title: "Overview") = {
  let pg = here().page()
  let all = query(<jp2-sec>)
  let on-page = all.filter(el => el.location().page() == pg)
  let before = all.filter(el => el.location().page() < pg)
  let top-sec = on-page.filter(el => el.location().position().y < 45mm)
  if top-sec.len() > 0 { top-sec.first().value }
  else if before.len() > 0 { before.last().value }
  else if on-page.len() > 0 { on-page.first().value }
  else { (num: "01", title: fallback-title) }
}

#let jp2-code(s) = box(
  fill: ink.k05,
  inset: (x: 2.6pt, y: 0.9pt),
  outset: (y: 0.3pt),
  radius: 1.5pt,
  text(font: f-mono, size: 7.6pt, fill: ink.k100, s),
)

#let spot(body) = text(font: f-sans, weight: "bold", fill: ink.spot-100, body)

#let jp2-title-header(
  kicker: "TECHNICAL HANDBOOK",
  title: "Document Title",
  subtitle: none,
  meta-line: none,
  toc-title: "CONTENTS · 章节速览",
  toc-items: (),
) = {
  block(width: 100%, {
    line(length: 100%, stroke: 2.2pt + ink.spot-100)
    v(2pt)
    line(length: 100%, stroke: 0.45pt + ink.k100)
    v(11pt)
    grid(
      columns: (1fr, 54mm),
      column-gutter: 9mm,
      align: (top + left, top + left),
      {
        text(font: f-sans, size: 7.7pt, weight: "bold", fill: ink.spot-100, tracking: 1.4pt, kicker)
        v(5pt)
        text(font: f-sans, size: 18.5pt, weight: "bold", fill: ink.k100, title)
        if subtitle != none {
          v(5.5pt)
          set par(leading: 0.72em)
          text(font: f-serif, size: 8.8pt, fill: ink.k65, subtitle)
        }
        if meta-line != none {
          v(6pt)
          box(
            fill: ink.spot-10,
            stroke: (left: 2pt + ink.spot-100),
            inset: (x: 7pt, y: 4pt),
            text(font: f-sans, size: 7.5pt, fill: ink.k100, meta-line),
          )
        }
      },
      block(
        width: 100%,
        inset: (left: 8pt, y: 1pt),
        stroke: (left: 0.8pt + ink.k25),
        {
          text(font: f-sans, size: 7.1pt, weight: "bold", fill: ink.spot-100, tracking: 1.2pt, toc-title)
          v(5pt)
          for item in toc-items {
            grid(
              columns: (14pt, 1fr, auto),
              column-gutter: 3pt,
              align: horizon,
              text(font: f-sans, size: 7.3pt, weight: "bold", fill: ink.spot-100, item.num),
              text(font: f-sans, size: 7.4pt, fill: ink.k100, item.title),
              if "count" in item { text(font: f-sans, size: 6.8pt, fill: ink.k65, item.count) } else { [] },
            )
            v(3pt)
          }
        },
      ),
    )
    v(10pt)
    line(length: 100%, stroke: 0.5pt + ink.k25)
  })
  v(10pt)
}

#let jp2-chapter(num, title, subtitle: none, badge: none) = {
  v(10pt, weak: true)
  block(breakable: false, sticky: true, width: 100%, {
    [#metadata((num: num, title: title)) <jp2-sec>]
    grid(
      columns: (1fr, auto),
      column-gutter: 8mm,
      align: bottom,
      {
        text(
          font: f-sans,
          size: 7.5pt,
          weight: "bold",
          fill: ink.spot-100,
          tracking: 1.4pt,
          "CHAPTER " + num + if subtitle != none { "  ·  " + upper(subtitle) } else { "" },
        )
        v(3.8pt)
        text(font: f-sans, size: 14.8pt, weight: "bold", fill: ink.k100, title)
      },
      if badge != none {
        box(
          fill: ink.spot-10,
          stroke: (paint: ink.spot-100, thickness: 0.7pt),
          inset: (x: 6.5pt, y: 2.6pt),
          text(font: f-sans, size: 7.2pt, weight: "bold", fill: ink.spot-100, badge),
        )
      } else { [] },
    )
    v(4.8pt)
    line(length: 100%, stroke: 1.35pt + ink.spot-100)
    v(1.6pt)
    line(length: 100%, stroke: 0.4pt + ink.k25)
    v(8.5pt)
  })
}

#let jp2-lead(lead-body, memo-title: "MEMO · 关键上下文", memo-body: none) = {
  block(breakable: false, width: 100%, below: 10pt, grid(
    columns: (1fr, 44mm),
    column-gutter: 8mm,
    align: (top + left, top + left),
    {
      set par(leading: 0.80em)
      text(size: 8.85pt, fill: ink.k100, lead-body)
    },
    if memo-body != none {
      block(
        width: 100%,
        inset: (left: 7pt, y: 1.5pt),
        stroke: (left: 1.4pt + ink.spot-100),
        {
          text(font: f-sans, size: 7.1pt, weight: "bold", fill: ink.spot-100, memo-title)
          v(3pt)
          set par(leading: 0.68em)
          text(font: f-sans, size: 7.2pt, fill: ink.k65, memo-body)
        },
      )
    } else { [] },
  ))
}

#let jp2-row(main-body, side-title: none, side-body: none, side-rule: true) = {
  block(breakable: false, width: 100%, below: 8.5pt, grid(
    columns: (1fr, 44mm),
    column-gutter: 8mm,
    align: (top + left, top + left),
    main-body,
    if side-body != none {
      block(
        width: 100%,
        inset: (left: if side-rule { 7pt } else { 0pt }, y: 1.5pt),
        stroke: if side-rule { (left: 1.3pt + ink.spot-40) } else { none },
        {
          if side-title != none {
            text(font: f-sans, size: 7pt, weight: "bold", fill: ink.spot-100, "▸ " + side-title)
            v(2.5pt)
          }
          set par(leading: 0.72em)
          text(font: f-sans, size: 7.2pt, fill: ink.k65, side-body)
        },
      )
    } else { [] },
  ))
}

#let jp2-diagram(fig-id, caption, diagram-body, note-title: "图解要点", note-body: none) = {
  let box-content = block(
    width: 100%,
    inset: (x: 10pt, y: 9pt),
    stroke: 0.65pt + ink.k100,
    fill: white,
    {
      grid(
        columns: (auto, 1fr),
        column-gutter: 6pt,
        align: horizon,
        box(fill: ink.k100, inset: (x: 5pt, y: 1.4pt),
          text(font: f-sans, size: 6.6pt, weight: "bold", fill: white, fig-id)),
        text(font: f-sans, size: 8.1pt, weight: "bold", fill: ink.k100, caption),
      )
      v(8pt)
      diagram-body
    },
  )
  jp2-row(box-content, side-title: note-title, side-body: note-body)
}

#let d-box(title, sub: none, mode: "outline") = {
  let (bg, bd, bd-w, tc, sc) = if mode == "muted" {
    (ink.k05, ink.k25, 0.6pt, ink.k65, ink.k65)
  } else if mode == "tint" {
    (ink.spot-10, ink.spot-100, 0.85pt, ink.k100, ink.k65)
  } else if mode == "solid" {
    (ink.spot-100, ink.spot-100, 0.85pt, white, ink.spot-10)
  } else {
    (white, ink.spot-100, 0.85pt, ink.k100, ink.spot-100)
  }
  box(
    width: 100%,
    fill: bg,
    stroke: bd-w + bd,
    inset: (x: 4.5pt, y: 4.6pt),
    align(center + horizon, {
      text(font: f-sans, size: 7.3pt, weight: "bold", fill: tc, title)
      if sub != none {
        v(1.4pt)
        text(font: f-sans, size: 6.1pt, fill: sc, sub)
      }
    }),
  )
}

#let d-arrow(label: none, muted: false) = {
  let c = if muted { ink.k25 } else { ink.spot-100 }
  align(center + horizon, {
    if label != none {
      text(font: f-sans, size: 5.8pt, weight: "bold", fill: c, label)
      v(-1.8pt)
    }
    text(font: f-sans, size: 8.6pt, weight: if muted { "regular" } else { "bold" }, fill: c, "→")
  })
}

#let seq-step(num, from-to, desc, highlight-step: false) = grid(
  columns: (14pt, 30mm, 1fr),
  column-gutter: 5pt,
  align: (center + horizon, left + horizon, left + horizon),
  box(
    width: 12.5pt,
    height: 12.5pt,
    fill: if highlight-step { ink.spot-100 } else { ink.k100 },
    align(center + horizon, text(font: f-sans, size: 6.4pt, weight: "bold", fill: white, str(num))),
  ),
  text(font: f-sans, size: 7pt, weight: "bold", fill: if highlight-step { ink.spot-100 } else { ink.k65 }, from-to),
  text(font: f-sans, size: 7.3pt, fill: ink.k100, desc),
)

#let jp2-entry(num, dim, old-body, new-body, old-label: "旧架构", new-label: "新实现", side-title: none, side-body: none) = {
  block(breakable: false, width: 100%, below: 9.5pt, grid(
    columns: (1fr, 44mm),
    column-gutter: 8mm,
    align: (top + left, top + left),
    {
      stack(
        dir: ltr,
        spacing: 6pt,
        box(fill: ink.spot-100, inset: (x: 4.5pt, y: 1.4pt),
          text(font: f-sans, size: 6.9pt, weight: "bold", fill: white, num)),
        text(font: f-sans, size: 9.4pt, weight: "bold", fill: ink.k100, dim),
      )
      v(5.5pt)
      grid(
        columns: (14.5mm, 1fr),
        column-gutter: 6pt,
        row-gutter: 5pt,
        align: (left + top, left + top),
        text(font: f-sans, size: 7.5pt, weight: "bold", fill: ink.k65, old-label),
        { set par(leading: 0.76em); text(size: 8.55pt, fill: ink.k65, old-body) },
        text(font: f-sans, size: 7.5pt, weight: "bold", fill: ink.spot-100, new-label),
        { set par(leading: 0.80em); text(size: 8.8pt, fill: ink.k100, new-body) },
      )
      v(7.5pt)
      line(length: 100%, stroke: 0.45pt + ink.k25)
    },
    if side-body != none {
      block(width: 100%, inset: (top: 2pt), {
        if side-title != none {
          text(font: f-sans, size: 7.1pt, weight: "bold", fill: ink.spot-100, "▸ " + side-title)
          v(2.5pt)
        }
        set par(leading: 0.72em)
        text(font: f-sans, size: 7.3pt, fill: ink.k65, side-body)
      })
    } else { [] },
  ))
}

#let jp2-codeblock(caption, lang, code-str, side-title: none, side-body: none) = {
  let code-box = block(
    breakable: false,
    width: 100%,
    fill: ink.k05,
    stroke: (left: 2pt + ink.spot-100, top: 0.45pt + ink.k25, right: 0.45pt + ink.k25, bottom: 0.45pt + ink.k25),
    inset: (x: 9pt, y: 7pt),
    {
      grid(
        columns: (1fr, auto),
        align: horizon,
        text(font: f-sans, size: 7.3pt, weight: "bold", fill: ink.k100, caption),
        box(fill: ink.spot-10, stroke: 0.45pt + ink.spot-40, inset: (x: 4.5pt, y: 1pt),
          text(font: f-mono, size: 6.3pt, weight: "bold", fill: ink.spot-100, upper(lang))),
      )
      v(3.5pt)
      line(length: 100%, stroke: 0.4pt + ink.k25)
      v(2pt)
      set par(leading: 0.56em)
      text(font: f-mono, size: 7.1pt, fill: ink.k100, raw(code-str, block: true))
    },
  )
  if side-body != none { jp2-row(code-box, side-title: side-title, side-body: side-body) }
  else { block(breakable: false, width: 100%, below: 9pt, code-box) }
}

#let jp2-table(cols, headers, rows) = {
  set par(leading: 0.66em, justify: false)
  block(width: 100%, below: 9pt, table(
    columns: cols,
    inset: (x: 5.5pt, y: 5pt),
    align: left + top,
    stroke: (x, y) => (
      top: if y == 0 { 1.25pt + ink.k100 } else if y == 1 { 0.85pt + ink.spot-100 } else { 0.4pt + ink.k10 },
      bottom: 0.4pt + ink.k10,
      left: none,
      right: none,
    ),
    fill: (x, y) => if y == 0 { ink.spot-10 } else { white },
    table.header(repeat: true, ..headers.map(h => text(font: f-sans, size: 7.7pt, weight: "bold", fill: ink.k100, h))),
    ..rows.map(r => r.map(cell => block(breakable: false, text(size: 8pt, fill: ink.k100, cell)))).flatten(),
    table.hline(stroke: 1.1pt + ink.k100),
  ))
}

#let jp2-margin-mascot(img-path, caption: none, width: 24mm) = {
  block(
    breakable: false,
    width: 100%,
    inset: (top: 4pt, bottom: 2pt),
    align(center, {
      image(img-path, width: width)
      if caption != none {
        v(3pt)
        set par(leading: 0.65em)
        text(font: f-sans, size: 6.7pt, fill: ink.k65, caption)
      }
    }),
  )
}

#let jp2-point-box(tag: "POINT!", title: none, body, mascot: none, mascot-caption: none) = {
  let content-box = block(
    breakable: false,
    width: 100%,
    fill: ink.spot-10,
    stroke: (paint: ink.spot-100, thickness: 0.8pt, dash: "dashed"),
    inset: (top: 12pt, bottom: 8.5pt, x: 10.5pt),
    {
      place(
        top + left,
        dx: -2pt,
        dy: -18.5pt,
        box(
          fill: ink.spot-100,
          inset: (x: 7.5pt, y: 2.3pt),
          text(
            font: f-sans,
            size: 7pt,
            weight: "bold",
            fill: white,
            tracking: 0.8pt,
            tag + if title != none { "  ·  " + title } else { "" },
          ),
        ),
      )
      set par(leading: 0.76em)
      text(size: 8.3pt, fill: ink.k100, body)
    },
  )
  v(8pt)
  if mascot != none {
    block(breakable: false, width: 100%, below: 9pt, grid(
      columns: (1fr, 44mm),
      column-gutter: 8mm,
      align: (top + left, bottom + center),
      content-box,
      block(width: 100%, align(center, {
        mascot
        if mascot-caption != none {
          v(2pt)
          text(font: f-sans, size: 6.6pt, fill: ink.k65, mascot-caption)
        }
      })),
    ))
  } else {
    jp2-row(content-box)
  }
}

#let jp2-doc(book-title: "Technical Handbook", footer-left: "", footer-right: "", body) = {
  set document(title: book-title)
  set text(font: f-serif, size: 8.75pt, fill: ink.k100, lang: "zh", region: "cn")
  set par(leading: 0.78em, spacing: 0.70em)
  show raw.where(block: false): it => jp2-code(it.text)
  show strong: it => text(font: f-sans, weight: "bold", fill: ink.k100, it.body)
  set page(
    paper: "a4",
    fill: white,
    margin: (top: 19mm, bottom: 19mm, left: 18.5mm, right: 17.5mm),
    header-ascent: 7.2mm,
    footer-descent: 7.2mm,
    header: context {
      let pg = counter(page).get().first()
      if pg > 1 {
        let sec = jp2-active-sec(fallback-title: book-title)
        block(width: 100%, {
          grid(
            columns: (1fr, auto),
            align: bottom,
            text(font: f-sans, size: 7.1pt, fill: ink.k65, book-title),
            {
              text(font: f-sans, size: 7.1pt, weight: "bold", fill: ink.spot-100, "CHAPTER " + sec.num)
              text(font: f-sans, size: 7.1pt, fill: ink.k40, "  |  ")
              text(font: f-sans, size: 7.1pt, weight: "bold", fill: ink.k100, sec.title)
            },
          )
          v(3.2pt)
          line(length: 100%, stroke: 0.5pt + ink.k25)
        })
      }
    },
    footer: context {
      let pg = counter(page).get().first()
      let total = counter(page).final().first()
      let pg-s = if pg < 10 { "0" + str(pg) } else { str(pg) }
      let tot-s = if total < 10 { "0" + str(total) } else { str(total) }
      grid(
        columns: (1fr, auto, 1fr),
        align: (left + horizon, center + horizon, right + horizon),
        text(font: f-sans, size: 6.9pt, fill: ink.k40, footer-left),
        text(font: f-sans, size: 7.8pt, weight: "bold", fill: ink.k100, "— " + pg-s + " / " + tot-s + " —"),
        text(font: f-sans, size: 6.9pt, fill: ink.k40, footer-right),
      )
    },
  )
  body
}

// ============================================================================
// Sample Document Body
// ============================================================================

#show: jp2-doc.with(
  book-title: "高并发多级缓存与熔断降级设计手册",
  footer-left: "JP-2COLOR-TYPST SAMPLE",
  footer-right: "2色刷り · COBALT #005BAC",
)

#jp2-title-header(
  kicker: "JAPANESE 2-COLOR PRINT · TECHNICAL HANDBOOK SAMPLE",
  title: "高并发多级缓存与熔断降级设计",
  subtitle: "严格双色印刷风（墨黑 #1C1C1C × 钴蓝 #005BAC）技术方案排版示例",
  meta-line: "无冗余卡片 · 右侧留白边注 · 纯双色矢量图解 · 原生适配 Obsidian Typst Mate",
  toc-items: (
    (num: "01", title: "多级缓存与防击穿演进", count: "2 项"),
    (num: "02", title: "熔断状态机与配置规范", count: "表 + 码"),
  ),
)

#jp2-chapter("01", "多级缓存与防击穿演进", subtitle: "Multi-Level Cache & SingleFlight", badge: "核心架构")

#jp2-lead(
  [面对热点 Key 突发流量，传统直连 Redis 的单层缓存容易在节点抖动或缓存失效瞬间击穿数据库。新方案采用 #spot[L1 本地 LRU + L2 Redis 集群] 双层结构，并在回源路径强制启用 #spot[SingleFlight 请求合并]，将瞬时千级并发压缩为单次数据库查询。],
  memo-title: "MEMO · 关键模块",
  memo-body: [
    `pkg/cache/tier.go` \
    `pkg/guard/singleflight.go` \
    `config/breaker.yaml`
  ],
)

#jp2-diagram(
  "图 1-1",
  "热点失效路径对照（旧单层直连 vs 新多级合并保护）",
  {
    grid(
      columns: (12mm, 1fr, 10mm, 1fr, 10mm, 1fr),
      column-gutter: 2pt,
      row-gutter: 7pt,
      align: horizon,
      text(font: f-sans, size: 6.8pt, weight: "bold", fill: ink.k65, "旧架构"),
      d-box("热点 Key 过期", sub: "1000+ 并发穿透", mode: "muted"),
      d-arrow(muted: true),
      d-box("直接回源 DB", sub: "连接池迅速耗尽", mode: "muted"),
      d-arrow(muted: true),
      d-box("级联超时", sub: "504 / 雪崩扩散", mode: "muted"),

      text(font: f-sans, size: 6.8pt, weight: "bold", fill: ink.spot-100, "新实现"),
      d-box("L1/L2 多级命中", sub: "99.4% 拦截率", mode: "outline"),
      d-arrow(label: "miss"),
      d-box("SingleFlight 合并", sub: "同 Key 单次回源", mode: "tint"),
      d-arrow(label: "超时"),
      d-box("Stale 兜底返回", sub: "核心 SLA ≥ 99.95%", mode: "solid"),
    )
  },
  note-title: "图解要点",
  note-body: [实心钴蓝块标记最终可用性防线；灰色行表示已淘汰的直连穿透链路。],
)

#jp2-entry(
  "1.1",
  "缓存失效与回源并发控制",
  [热点 Key 到期后，所有并发请求直接穿透至主库执行同一条 SQL，极易触发慢查询堆积与主库 CPU 打满。],
  [引入进程内 `SingleFlight` 合并相同 Key 的回源请求，并搭配 #spot[随机 TTL 抖动（±15%）] 与短周期 `Stale-While-Revalidate`，平滑释放回源压力。],
  side-title: "防雪崩关键",
  side-body: [单次合并回源设置独立 `1.5s` 超时上下文，避免首个调用方取消导致整组等待失败。],
)

#jp2-entry(
  "1.2",
  "空值缓存与布隆过滤器",
  [恶意构造不存在的 ID 直接穿透缓存，反复触发全表或索引空查。],
  [针对非法或不存在主键写入 `30s` 短周期空对象占位符，入口层前置轻量级布隆过滤器拦截非法主键。],
  side-title: "内存防膨胀",
  side-body: [空值占位独立使用小容量 LRU 分区，避免污染热数据淘汰队列。],
)

#jp2-point-box(
  tag: "POINT!",
  title: "为什么坚持严格双色印刷？",
  mascot: image("assets/irasutoya/cat_pc.png", width: 22mm),
  mascot-caption: [（顺手塞一只摸鱼排查缓存的小猫）],
  [在技术文档中，色彩的作用是*建立信息层级*而非装饰。全篇只用墨黑承载事实、钴蓝标记变化与决策焦点；右侧留白处偶尔点缀一只 Irasutoya 随性小插图，既有日系技术书的人情味，又完全不破坏主栏阅读节奏。],
)

#pagebreak()

#jp2-chapter("02", "熔断状态机与配置规范", subtitle: "Circuit Breaker & Configuration", badge: "稳定性基线")

#jp2-diagram(
  "图 2-1",
  "网关层请求流转与熔断降级时序",
  {
    stack(
      dir: ttb,
      spacing: 4.5pt,
      seq-step(1, "Client → Gateway", [携带 `X-Request-Id` 与业务路由标签进入统一入口]),
      seq-step(2, "Gateway → L1/L2", [优先读取本地 LRU，未命中则并发探查 Redis 只读副本]),
      seq-step(3, "Service → Breaker", [滑动窗口统计最近 60 秒错误率，超过阈值即切为 `Open`], highlight-step: true),
      seq-step(4, "Breaker → Fallback", [半开探测恢复前直接返回只读快照，保障核心页面秒开], highlight-step: true),
    )
  },
  note-title: "探测策略",
  note-body: [熔断打开 `15s` 后自动进入 `Half-Open`，放行 5% 探针流量验证下游健康度。],
)

#jp2-table(
  (28mm, 24mm, 24mm, 1fr),
  ("参数名", "默认值", "生效层级", "工程说明"),
  (
    (`L1_MAX_ENTRIES`, `50,000`, `应用进程`, [单实例本地 LRU 最大条目上限，约占用 64MB 堆内存]),
    (`L2_TTL_JITTER`, `±15%`, `Redis 集群`, [写入过期时间时叠加随机偏移，打散集中失效尖峰]),
    (`CB_ERROR_RATIO`, `0.25`, `熔断器`, [60 秒滑动窗口内错误率达到 25% 且最小样本 ≥ 50 时触发熔断]),
    (`CB_HALF_OPEN_S`, `15s`, `熔断器`, [熔断冷却时长，到期后切换半开状态并放行少量探针请求]),
  ),
)

#jp2-codeblock(
  "熔断器核心配置示例（config/breaker.yaml）",
  "yaml",
  "circuit_breaker:\n  window_seconds: 60\n  min_requests: 50\n  error_ratio_threshold: 0.25\n  open_cooldown_seconds: 15\n  fallback_mode: \"serve_stale_snapshot\"",
  side-title: "热更新支持",
  side-body: [
    配置变更通过配置中心下发，无需重启实例即可动态调整阈值。
    #v(6pt)
    #jp2-margin-mascot("assets/irasutoya/coffee-cobalt.png", caption: [（duotone 双色油墨版 · 喝杯咖啡等熔断恢复）], width: 20mm)
  ],
)
