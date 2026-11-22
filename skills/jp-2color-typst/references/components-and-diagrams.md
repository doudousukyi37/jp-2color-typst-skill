# Component API & 2-Color Vector Diagram Cookbook

Reference for `resources/template-jp-2color.typ`.

## 1. Component Quick Reference

| Component | Purpose | Key Arguments |
| :--- | :--- | :--- |
| `#show: jp2-doc.with(...)` | Page geometry, fonts, running header/footer | `book-title`, `footer-left`, `footer-right` |
| `#jp2-title-header(...)` | Book opening header + TOC | `kicker`, `title`, `subtitle`, `meta-line`, `toc-items`, `toc-layout` (`"side"` / `"strip"` / `"none"`) |
| `#jp2-chapter(...)` | Chapter opener + updates running header | `num`, `title`, `subtitle`, `badge` |
| `#jp2-sub(num, title)` | Numbered subheading (`1.1`, `2.3`) | `num`, `title` |
| `#jp2-lead(...)` | Chapter opening prose + right-margin memo | `lead-body`, `memo-title`, `memo-body` |
| `#jp2-row(...)` | Arbitrary main block + right-margin note | `main-body`, `side-title`, `side-body`, `side-rule` |
| `#jp2-item(...)` | Square-bullet rule/spec row + hairline | `label`, `body`, `side-title`, `side-body` |
| `#jp2-entry(...)` | Card-free Old vs New comparison entry | `num`, `dim`, `old-body`, `new-body`, `old-label`, `new-label`, `side-title`, `side-body` |
| `#jp2-diagram(...)` | Framed 2-color vector diagram + guide | `fig-id`, `caption`, `diagram-body`, `note-title`, `note-body`, `full-width` |
| `#jp2-figure-img(...)` | Framed AI infographic / Mermaid PNG / screenshot | `fig-id`, `caption`, `img-path`, `width`, `note-title`, `note-body`, `full-width` |
| `#jp2-margin-mascot(...)` | Casual Irasutoya / spot illustration for right margin | `img-path`, `caption`, `width` |
| `#jp2-codeblock(...)` | Left-accented monochrome code block | `caption`, `lang`, `code-str`, `side-title`, `side-body` |
| `#jp2-table(...)` | Three-line print table (repeating header) | `cols`, `headers`, `rows` |
| `#jp2-point-box(...)` | Floating-tab dashed highlight box (+ optional mascot) | `tag`, `title`, `body`, `mascot`, `mascot-caption`, `full-width` |
| `#spot[...]` | Bold spot-ink inline emphasis | `body` |

## 2. Diagram Node Tonal Hierarchy (`d-box`)

Strictly stick to the 4 built-in tonal modes so every diagram reads like a two-plate print press:

- `mode: "muted"` — Legacy / deprecated / background component (`K05` fill, `K25` stroke)
- `mode: "outline"` — Standard active step or module (white fill, `spot-100` stroke)
- `mode: "tint"` — Highlighted intermediate state (`spot-10` fill, `spot-100` stroke)
- `mode: "solid"` — Primary decision point / final target / key innovation (`spot-100` fill, white text)

## 3. Proven Vector Diagram Patterns

### Pattern A: Old vs New Flow Comparison
```typst
#jp2-diagram(
  "图 1-1",
  "旧流程与新架构演进对照",
  {
    grid(
      columns: (12mm, 1fr, 10mm, 1fr, 10mm, 1fr),
      column-gutter: 2pt,
      row-gutter: 7pt,
      align: horizon,
      text(font: f-sans, size: 6.8pt, weight: "bold", fill: ink.k65, "旧方案"),
      d-box("同步阻塞请求", sub: "直接击穿 DB", mode: "muted"),
      d-arrow(muted: true),
      d-box("无熔断保护", sub: "雪崩扩散", mode: "muted"),
      d-arrow(muted: true),
      d-box("超时失败", sub: "504 Gateway", mode: "muted"),

      text(font: f-sans, size: 6.8pt, weight: "bold", fill: ink.spot-100, "新方案"),
      d-box("多级缓存命中", sub: "L1 本地 + L2 Redis", mode: "outline"),
      d-arrow(label: "miss"),
      d-box("SingleFlight 合并", sub: "抑制并发回源", mode: "tint"),
      d-arrow(label: "兜底"),
      d-box("熔断降级返回", sub: "核心链路高可用", mode: "solid"),
    )
  },
  note-title: "图解要点",
  note-body: [实心钴蓝块标记核心保护节点，灰色行表示被淘汰的旧路径。],
)
```

### Pattern B: Clean Sequence Flow (`seq-step`)
```typst
#jp2-diagram(
  "图 2-1",
  "请求处理与降级时序",
  {
    stack(
      dir: ttb,
      spacing: 4.5pt,
      seq-step(1, "Client → Gateway", [携带 `X-Request-Id` 与鉴权令牌发起请求]),
      seq-step(2, "Gateway → L1/L2", [优先查询本地 LRU 缓存，未命中则查 Redis 集群]),
      seq-step(3, "Service → Guard", [触发 `SingleFlight` 合并同 Key 并发回源], highlight-step: true),
      seq-step(4, "Guard → Fallback", [下游超时或错误率超阈值时直接返回静态降级数据], highlight-step: true),
    )
  },
  note-title: "时序重点",
  note-body: [编号 3–4 步使用钴蓝方标，强调高并发保护边界。],
)
```

## 4. Common Typst Pitfalls to Avoid

1. **No Markdown `**bold**`**: Typst bold is `*bold*` (or `#strong[bold]`). `**text**` triggers `warning: no text within stars`.
2. **No `text(leading: ...)`**: Always wrap with `set par(leading: 0.78em)` inside a scoped `{ ... }` block.
3. **Avoid Multi-Page Unbreakable Wrappers**: Never wrap an entire chapter or long table inside `block(breakable: false, ...)`. Keep `breakable: false` strictly on individual entries, diagrams, and table cells.
4. **Wide Tables**: Use `jp2-table` directly at full page width (not squeezed inside the left column of `jp2-row`) whenever a table has 4+ columns.
