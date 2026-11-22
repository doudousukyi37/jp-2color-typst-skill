---
name: jp-2color-typst
description: >-
  Typeset Markdown notes, technical specs, architecture proposals, or Feishu docs into
  Japanese 2-Color Print (2色刷り, 《图解 HTTP》 / Gihyo / Shoeisha style) Typst documents
  with Sumi Black (#1C1C1C) and a single Spot Ink (default Cobalt #005BAC), wide right
  margin notes, pure 2-color vector diagrams, and Obsidian Typst Mate live-preview support.
  Use whenever the user asks to typeset or convert a document into Typst, PDF, or
  Japanese 2-color print illustrated handbook style.
---

# Japanese 2-Color Print Typst (`jp-2color-typst`)

Transform plain Markdown, technical specifications, diff comparisons, or Feishu docs into publication-grade **Japanese 2-Color Print (`2色刷り`)** Typst documents inspired by *《图解 HTTP》* and Japanese technical books (Gihyo / Shoeisha).

## Core Aesthetic Principles (Non-Negotiable)

1. **Strictly Two Inks**:
   - **Ink 1 — Sumi Black (`K`)**: `#1C1C1C` (primary text/rules), `#595959` (secondary/margin notes), `#8C8C8C` (captions/footers), `#C4C4C4` / `#E8E8E8` (hairlines), `#F4F4F4` (code/muted tint).
   - **Ink 2 — Single Spot Ink** (default **Print Cobalt `#005BAC`**): `spot-100` (`#005BAC`), `spot-40` (`#6FA3D2`), `spot-10` (`#EBF3FA`).
   - **Never** introduce a third accent color, gradients, drop shadows, glassmorphism, or rounded SaaS cards.
2. **Card-Free Editorial Airiness**:
   - Separate sections with crisp horizontal print rules (`1.35pt` spot + `0.4pt` gray double rules for chapters; `0.4pt` hairlines between items).
   - Use an asymmetric **main column (`1fr`) + right margin column (`43mm–44mm`)** for source paths, implementation caveats, and diagram notes.
3. **Pure 2-Color Vector Diagrams**:
   - Replace dense paragraphs with native Typst vector diagrams (`jp2-diagram`, `d-box`, `d-arrow`, `seq-step`) using only the 4 tonal modes (`muted`, `outline`, `tint`, `solid`).
4. **Zero Content Loss**:
   - Preserve every technical detail, table, field, API contract, code block, and edge case from the source document; elevate visual hierarchy rather than summarizing away facts.

## Workflow

### Step 1: Read Source & Template
1. Read the source document (local `.md`, code diff, or Feishu doc via `lark-cli`).
2. Read [template-jp-2color.typ](./resources/template-jp-2color.typ) for the canonical component library.
3. If building complex diagrams or tables, consult [components-and-diagrams.md](./references/components-and-diagrams.md).

### Step 2: Plan Document Structure
- **Front Header (`jp2-title-header`)**: Double top rule (`2.2pt` spot + `0.45pt` black), kicker, bold title, subtitle, metadata bar, and compact TOC (`toc-layout: "side"` for <= 5 chapters, `"strip"` for 6+ chapters).
- **Chapters (`jp2-chapter`)**: Numbered `01`, `02`, ... with optional English uppercase subtitle and compact right-aligned badge. Automatically updates running page headers.
- **Content Blocks**:
  - **Diff / Comparison docs**: Use `jp2-lead` + `jp2-diagram` + `jp2-entry` + `jp2-point-box`.
  - **General Tech Specs / PRDs / Notes**: Use `jp2-lead` + `jp2-sub` + `jp2-item` / `jp2-row` + `jp2-diagram` + `jp2-table` + `jp2-codeblock` + `jp2-point-box`.
- **Pagination Rhythm**: Keep atomic blocks `breakable: false` so headings/diagrams/rows never orphan across pages; avoid giant multi-page unbreakable wrappers.

### Step 3: Choose Output Mode (Obsidian vs CLI)
- **Obsidian `Typst Mate` Live Preview (Default for Obsidian Vaults)**:
  - **Inline the template directly at the top of the `.typ` file** (single-file self-contained). Obsidian `Typst Mate` resolves `#import` relative to its configured `importPath` (often `.typst`), so relative sibling `#import "template-jp-2color.typ": *` causes a blank preview.
  - If the user encounters Chinese tofu boxes or washed-out thin strokes in Obsidian, follow [obsidian-typst-mate-guide.md](./references/obsidian-typst-mate-guide.md) and run [slice_obsidian_fonts.py](./scripts/slice_obsidian_fonts.py).
- **CLI / Multi-File Project**:
  - May `#import "template-jp-2color.typ": *` when compiling solely via `typst compile`.

### Step 4: Typst Syntax Guardrails
- Never leave Markdown bold `**text**` inside Typst content blocks — use `*text*` or `#strong[text]` or `#spot[text]`.
- Never pass `leading:` to `text(...)` — `leading` belongs to `set par(leading: ...)`.
- Escape literal `$`, `#`, `@`, `<`, `>` inside prose (or wrap code identifiers in backticks `` `...` ``).
- Use `raw(code-str, block: true)` inside `jp2-codeblock` rather than nested triple backticks when passing string arguments.

### Step 5: Compile & Visually Verify (Mandatory)
1. Compile with Typst CLI and confirm **0 errors and 0 warnings**:
   ```powershell
   typst compile "<output>.typ" "<output>.pdf"
   ```
2. Export pages to PNG for visual inspection (check margins, Chinese font weight, table wrapping, diagram alignment, and balanced page fill):
   ```powershell
   typst compile --format png --ppi 144 "<output>.typ" "preview-page-{p}.png"
   ```
3. Inspect the rendered PNGs. Fix any overflow, awkward orphan page, or cramped diagram before finishing, and clean up temporary preview PNGs.

## Quick Reference
- Canonical template: [template-jp-2color.typ](./resources/template-jp-2color.typ)
- Component & diagram cookbook: [components-and-diagrams.md](./references/components-and-diagrams.md)
- Working example: [sample-tech-spec.typ](./examples/sample-tech-spec.typ)
- Obsidian setup & font slicing: [obsidian-typst-mate-guide.md](./references/obsidian-typst-mate-guide.md)
