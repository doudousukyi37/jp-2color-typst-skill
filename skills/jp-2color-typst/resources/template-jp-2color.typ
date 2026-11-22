// ============================================================================
// Japanese 2-Color Print (2色刷り) Technical Illustrated Book Template
// Authentic 《图解 HTTP》 / Gihyo / Shoeisha Editorial Style
// Strictly 2 Inks: Sumi Black (K100/65/40/25/10/05) + Single Spot Ink
// Compatible with Typst 0.13–0.15+ CLI & Obsidian Typst Mate
// ============================================================================

#let f-sans = ("Noto Sans SC", "Microsoft YaHei", "SimHei")
#let f-serif = ("Noto Serif SC", "Noto Sans SC", "SimSun")
#let f-mono = ("Consolas", "Noto Sans SC")

// --- Centralized 2-Color Ink Palette ---
// Default Spot Ink: 《图解 HTTP》 Print Cobalt (#005BAC · DIC 184)
// Optional single-ink alternatives (swap spot-100 / spot-40 / spot-10):
//   - Vermilion (朱红):  #C83E2B / #E08A7E / #FBECE9
//   - Pine Green (松绿): #1F6B4E / #78AD98 / #EBF4F0
//   - Slate Indigo (蓝黑): #1E3A5F / #7A95B5 / #EDF2F7
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

// --- Active Section Query for Running Header ---
#let jp2-active-sec(fallback-title: "Overview") = {
  let pg = here().page()
  let all = query(<jp2-sec>)
  let on-page = all.filter(el => el.location().page() == pg)
  let before = all.filter(el => el.location().page() < pg)
  let top-sec = on-page.filter(el => el.location().position().y < 45mm)
  if top-sec.len() > 0 {
    top-sec.first().value
  } else if before.len() > 0 {
    before.last().value
  } else if on-page.len() > 0 {
    on-page.first().value
  } else {
    (num: "01", title: fallback-title)
  }
}

// --- Inline Code (Clean Monochrome K05 Tint) ---
#let jp2-code(s) = {
  box(
    fill: ink.k05,
    inset: (x: 2.6pt, y: 0.9pt),
    outset: (y: 0.3pt),
    radius: 1.5pt,
    text(font: f-mono, size: 7.6pt, fill: ink.k100, s),
  )
}

// --- Spot-Ink Emphasis Span ---
#let spot(body) = text(font: f-sans, weight: "bold", fill: ink.spot-100, body)

// --- Book-Style Front Opening Header ---
// toc-layout:
//   "side"  -> right-hand vertical index (ideal for 3–5 chapters; items: (num, title, count))
//   "strip" -> full-width 2-column strip below header (ideal for 6+ chapters; items: (num, title))
//   "none"  -> no TOC block
#let jp2-title-header(
  kicker: "TECHNICAL HANDBOOK",
  title: "Document Title",
  subtitle: none,
  meta-line: none,
  toc-title: "CONTENTS · 章节速览",
  toc-items: (),
  toc-layout: "side",
) = {
  block(
    width: 100%,
    {
      // Top heavy print double rule
      line(length: 100%, stroke: 2.2pt + ink.spot-100)
      v(2pt)
      line(length: 100%, stroke: 0.45pt + ink.k100)
      v(11pt)

      if toc-layout == "side" and toc-items.len() > 0 {
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
                  if "count" in item {
                    text(font: f-sans, size: 6.8pt, fill: ink.k65, item.count)
                  } else {
                    []
                  },
                )
                v(3pt)
              }
            },
          ),
        )
        v(10pt)
        line(length: 100%, stroke: 0.5pt + ink.k25)
      } else {
        text(font: f-sans, size: 7.6pt, weight: "bold", fill: ink.spot-100, tracking: 1.4pt, kicker)
        v(4.5pt)
        text(font: f-sans, size: 18pt, weight: "bold", fill: ink.k100, title)
        if subtitle != none {
          v(5pt)
          set par(leading: 0.72em)
          text(font: f-serif, size: 8.7pt, fill: ink.k65, subtitle)
        }
        if meta-line != none {
          v(6pt)
          box(
            width: 100%,
            fill: ink.spot-10,
            stroke: (left: 2pt + ink.spot-100),
            inset: (x: 8pt, y: 5pt),
            text(font: f-sans, size: 7.5pt, fill: ink.k100, meta-line),
          )
        }
        if toc-layout == "strip" and toc-items.len() > 0 {
          let mid = calc.ceil(toc-items.len() / 2)
          let left-items = toc-items.slice(0, mid)
          let right-items = toc-items.slice(mid)
          v(9pt)
          block(
            width: 100%,
            stroke: (top: 0.5pt + ink.k25, bottom: 0.5pt + ink.k25),
            inset: (y: 7pt),
            {
              text(font: f-sans, size: 6.9pt, weight: "bold", fill: ink.spot-100, tracking: 1.2pt, toc-title)
              v(5pt)
              grid(
                columns: (1fr, 1fr),
                column-gutter: 12mm,
                {
                  for item in left-items {
                    grid(
                      columns: (15pt, 1fr, auto),
                      column-gutter: 3pt,
                      text(font: f-sans, size: 7.4pt, weight: "bold", fill: ink.spot-100, item.num),
                      text(font: f-sans, size: 7.5pt, fill: ink.k100, item.title),
                      if "count" in item { text(font: f-sans, size: 6.8pt, fill: ink.k65, item.count) } else { [] },
                    )
                    v(2.8pt)
                  }
                },
                {
                  for item in right-items {
                    grid(
                      columns: (15pt, 1fr, auto),
                      column-gutter: 3pt,
                      text(font: f-sans, size: 7.4pt, weight: "bold", fill: ink.spot-100, item.num),
                      text(font: f-sans, size: 7.5pt, fill: ink.k100, item.title),
                      if "count" in item { text(font: f-sans, size: 6.8pt, fill: ink.k65, item.count) } else { [] },
                    )
                    v(2.8pt)
                  }
                },
              )
            },
          )
        } else {
          v(9pt)
          line(length: 100%, stroke: 0.5pt + ink.k25)
        }
      }
    },
  )
  v(10pt)
}

// --- Chapter Opening Heading ---
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
      } else {
        []
      },
    )
    v(4.8pt)
    line(length: 100%, stroke: 1.35pt + ink.spot-100)
    v(1.6pt)
    line(length: 100%, stroke: 0.4pt + ink.k25)
    v(8.5pt)
  })
}

// --- Numbered Subheading (1.1 / 2.3 style with Spot Square Badge) ---
#let jp2-sub(num, title) = {
  v(7pt, weak: true)
  block(breakable: false, sticky: true, width: 100%, below: 6pt, {
    stack(
      dir: ltr,
      spacing: 6pt,
      box(
        fill: ink.spot-100,
        inset: (x: 4.5pt, y: 1.4pt),
        text(font: f-sans, size: 7pt, weight: "bold", fill: white, num),
      ),
      text(font: f-sans, size: 9.8pt, weight: "bold", fill: ink.k100, title),
    )
  })
}

// --- Chapter Lead Paragraph + Right Margin Memo ---
#let jp2-lead(lead-body, memo-title: "MEMO · 关键上下文", memo-body: none) = {
  block(
    breakable: false,
    width: 100%,
    below: 10pt,
    grid(
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
      } else {
        []
      },
    ),
  )
}

// --- General Main Column + Right Margin Note Row ---
#let jp2-row(main-body, side-title: none, side-body: none, side-rule: true) = {
  block(
    breakable: false,
    width: 100%,
    below: 8.5pt,
    grid(
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
      } else {
        []
      },
    ),
  )
}

// --- Rule / Spec Item Row with Hairline Divider ---
#let jp2-item(label, body, side-title: none, side-body: none) = {
  block(
    breakable: false,
    width: 100%,
    below: 6.5pt,
    grid(
      columns: (1fr, 44mm),
      column-gutter: 8mm,
      align: (top + left, top + left),
      {
        grid(
          columns: (6pt, 1fr),
          column-gutter: 5pt,
          align: (left + top, left + top),
          box(width: 4pt, height: 4pt, fill: ink.spot-100, baseline: -1.6pt),
          {
            set par(leading: 0.78em)
            text(font: f-sans, weight: "bold", size: 8.65pt, fill: ink.k100, label)
            text(size: 8.65pt, fill: ink.k100, [：] + body)
          },
        )
        v(5.5pt)
        line(length: 100%, stroke: 0.4pt + ink.k10)
      },
      if side-body != none {
        block(
          width: 100%,
          inset: (top: 1pt),
          {
            if side-title != none {
              text(font: f-sans, size: 6.9pt, weight: "bold", fill: ink.spot-100, "▸ " + side-title)
              v(2pt)
            }
            set par(leading: 0.70em)
            text(font: f-sans, size: 7.15pt, fill: ink.k65, side-body)
          },
        )
      } else {
        []
      },
    ),
  )
}

// --- Card-Free Comparison Entry (Old vs New / Before vs After) ---
#let jp2-entry(
  num,
  dim,
  old-body,
  new-body,
  old-label: "最初方案",
  new-label: "最新实现",
  side-title: none,
  side-body: none,
) = {
  block(
    breakable: false,
    width: 100%,
    below: 9.5pt,
    grid(
      columns: (1fr, 44mm),
      column-gutter: 8mm,
      align: (top + left, top + left),
      {
        stack(
          dir: ltr,
          spacing: 6pt,
          box(
            fill: ink.spot-100,
            inset: (x: 4.5pt, y: 1.4pt),
            text(font: f-sans, size: 6.9pt, weight: "bold", fill: white, num),
          ),
          text(font: f-sans, size: 9.4pt, weight: "bold", fill: ink.k100, dim),
        )
        v(5.5pt)
        grid(
          columns: (14.5mm, 1fr),
          column-gutter: 6pt,
          row-gutter: 5pt,
          align: (left + top, left + top),
          text(font: f-sans, size: 7.5pt, weight: "bold", fill: ink.k65, old-label),
          {
            set par(leading: 0.76em)
            text(size: 8.55pt, fill: ink.k65, old-body)
          },
          text(font: f-sans, size: 7.5pt, weight: "bold", fill: ink.spot-100, new-label),
          {
            set par(leading: 0.80em)
            text(size: 8.8pt, fill: ink.k100, new-body)
          },
        )
        v(7.5pt)
        line(length: 100%, stroke: 0.45pt + ink.k25)
      },
      if side-body != none {
        block(
          width: 100%,
          inset: (top: 2pt),
          {
            if side-title != none {
              text(font: f-sans, size: 7.1pt, weight: "bold", fill: ink.spot-100, "▸ " + side-title)
              v(2.5pt)
            }
            set par(leading: 0.72em)
            text(font: f-sans, size: 7.3pt, fill: ink.k65, side-body)
          },
        )
      } else {
        []
      },
    ),
  )
}

// --- Pure 2-Color Print Diagram Container ---
#let jp2-diagram(fig-id, caption, diagram-body, note-title: "图解要点", note-body: none, full-width: false) = {
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
        box(
          fill: ink.k100,
          inset: (x: 5pt, y: 1.4pt),
          text(font: f-sans, size: 6.6pt, weight: "bold", fill: white, fig-id),
        ),
        text(font: f-sans, size: 8.1pt, weight: "bold", fill: ink.k100, caption),
      )
      v(8pt)
      diagram-body
    },
  )

  if full-width {
    block(breakable: false, width: 100%, below: 10pt, box-content)
  } else {
    jp2-row(box-content, side-title: note-title, side-body: note-body)
  }
}

// --- 2-Color Diagram Node, Arrow & Sequence Helpers ---
// mode: "muted" | "outline" | "tint" | "solid"
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

#let seq-step(num, from-to, desc, highlight-step: false) = {
  grid(
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
}

// --- Print-Grade Code Block (Left Spot Accent + K05 Surface) ---
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
        box(
          fill: ink.spot-10,
          stroke: 0.45pt + ink.spot-40,
          inset: (x: 4.5pt, y: 1pt),
          text(font: f-mono, size: 6.3pt, weight: "bold", fill: ink.spot-100, upper(lang)),
        ),
      )
      v(3.5pt)
      line(length: 100%, stroke: 0.4pt + ink.k25)
      v(2pt)
      set par(leading: 0.56em)
      text(font: f-mono, size: 7.1pt, fill: ink.k100, raw(code-str, block: true))
    },
  )
  if side-body != none {
    jp2-row(code-box, side-title: side-title, side-body: side-body)
  } else {
    block(breakable: false, width: 100%, below: 9pt, code-box)
  }
}

// --- Classic 2-Color Print Three-Line Table ---
#let jp2-table(cols, headers, rows) = {
  set par(leading: 0.66em, justify: false)
  block(
    width: 100%,
    below: 9pt,
    table(
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
      table.header(
        repeat: true,
        ..headers.map(h => text(font: f-sans, size: 7.7pt, weight: "bold", fill: ink.k100, h)),
      ),
      ..rows.map(r => r.map(cell => block(breakable: false, text(size: 8pt, fill: ink.k100, cell)))).flatten(),
      table.hline(stroke: 1.1pt + ink.k100),
    ),
  )
}

// --- Classic Japanese Reference Book Floating-Tab Dashed Box (POINT! / COLUMN) ---
#let jp2-point-box(tag: "POINT!", title: none, body, full-width: false) = {
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
  v(10pt)
  if full-width {
    block(breakable: false, width: 100%, below: 9pt, content-box)
  } else {
    jp2-row(content-box)
  }
}

// --- Master Document Wrapper ---
#let jp2-doc(
  book-title: "Technical Specification",
  footer-left: "",
  footer-right: "",
  body,
) = {
  set document(title: book-title)

  set text(
    font: f-serif,
    size: 8.75pt,
    fill: ink.k100,
    lang: "zh",
    region: "cn",
  )

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
