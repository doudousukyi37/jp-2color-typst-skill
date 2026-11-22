# Illustrations, Diagrams & Irasutoya Playbook

Four complementary visual tracks — inspired by `chesley-veko/book_skill` (diagram/infographic pipeline & chroma-key/whiten guardrails) and classic Japanese illustrated technical books (*《图解 HTTP》*, Gihyo, Shoeisha) featuring casual **Irasutoya (`いらすとや`)** spot illustrations.

---

## Choosing the Right Visual Track

| Track | Best For | Output Format | Typst Component |
| :--- | :--- | :--- | :--- |
| **1. Native Typst Vector** | 3–6 node flow comparisons, sequence steps, compact architecture boxes | Pure Typst code | `#jp2-diagram` + `d-box` / `d-arrow` / `seq-step` |
| **2. AI Hand-Drawn Infographic / Concept Art** | Metaphorical diagrams (iceberg, funnel, checkpoint, layered sandbox) or bespoke editorial spot art | Pure-white or transparent PNG | `#jp2-figure-img` |
| **3. Mermaid Diagram (`mmdc`)** | Complex state machines, branching topologies, multi-subgraph architecture | High-DPI **PNG** (never SVG!) | `#jp2-figure-img` |
| **4. Casual Irasutoya Spot Art (`いらすとや`)** | Charming "non-essential" margin companions, `POINT!` mascots, chapter breather vignettes | Transparent PNG (original color or 2-color `duotone`) | `#jp2-margin-mascot` / `#jp2-point-box(mascot: ...)` |

---

## Track 2: AI Infographic & Concept Spot Art (Adapted from `book_skill`)

### Two-Color Print Infographic Prompt Prefix (Zero AI-Slop Look)
Copy this prefix before describing your scene metaphor and exact labels:

```text
Draw a clean horizontal editorial technical infographic in Japanese 2-color print (2色刷り) pen-and-ink style, inspired by Japanese technical reference books (Gihyo / Shoeisha / 《图解 HTTP》).
Strict palette: Pure white background (#FFFFFF), Sumi black crisp ink linework (#1C1C1C), and ONLY ONE spot color: Print Cobalt Blue (#005BAC) plus light cobalt tint (#EBF3FA) for key highlights and emphasis zones.
Style: Clean technical pen drawing with subtle hand-drawn warmth, generous whitespace, flat print fills. NO gradients, NO 3D, NO glassmorphism, NO drop shadows, NO paper texture, NO beige/off-white background.
Text rule: Render ONLY the exact Chinese/English labels listed below, sharp and typo-free. Do not invent extra decorative words.
```

### Concept Spot Illustration Prompt Prefix (Text-Free, Minimalist)
For small decorative vignettes or chapter-opener metaphors:

```text
Draw a minimal Japanese 2-color editorial spot illustration on a pure solid white background (#FFFFFF).
Visual language: Crisp Sumi black ink line art (#1C1C1C) with sparse flat Print Cobalt Blue (#005BAC) accents and small solid dots as connectors. Playful yet refined Japanese technical book aesthetic, plenty of whitespace, centered subject with clean silhouette.
NO text, NO gradients, NO 3D, NO photorealism, NO background texture.
```

### Mandatory Post-Processing Guardrails (Lessons from `book_skill`)
1. **Eliminate Grey Box Edges (`whiten` / `chroma-key`)**:
   AI models frequently output `#FAFAFA` or P3-tinted backgrounds that show up as ugly faint grey rectangles on pure white Typst pages. Always run:
   ```powershell
   # For infographics framed inside #jp2-figure-img (bleaches near-white to #FFFFFF)
   uv run --with pillow --with numpy scripts/process_illustration.py whiten raw.png assets/fig-01.png

   # For borderless spot art / transparent overlay
   uv run --with pillow --with numpy scripts/process_illustration.py chroma-key raw.png assets/spot-01.png
   ```
2. **No Silent Degradation**:
   If image generation fails or produces garbled Chinese labels, **never** silently substitute an old image or ugly placeholder shapes. Either regenerate with simpler labels or explicitly fall back to native Typst vector diagrams (`d-box` / `d-arrow`).
3. **Inspect Every Generated Image**:
   Always view each generated PNG with `read_file` to verify zero typos in Chinese labels and clean margins before compiling final PDF.

---

## Track 3: Mermaid Diagrams (When Topology Gets Complex)

- **Always export PNG, NEVER SVG**: Mermaid SVGs embed labels inside `<foreignObject>`, which Typst drops (rendering empty boxes without text).
- **Prefer `flowchart LR`** (landscape aspect ratio `>= 1.5`) so diagrams stay legible and compact inside A4 pages.
- **Match the 2-Color Print Theme** via Mermaid `init` directive:
  ```mermaid
  %%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#EBF3FA', 'primaryBorderColor': '#005BAC', 'primaryTextColor': '#1C1C1C', 'lineColor': '#005BAC', 'secondaryColor': '#F4F4F4', 'tertiaryColor': '#FFFFFF' }}}%%
  ```

---

## Track 4: Casual Irasutoya (`いらすとや`) Spot Illustrations

One of the signature charms of Japanese technical books is placing small, lighthearted, slightly whimsical illustrations in the right margin, next to `POINT!` boxes, or at section breaks — giving dense engineering specs human warmth without hurting structural clarity.

### 1. Search & Download in One Command
Use `scripts/fetch_irasutoya.py` (pure Python stdlib, downloads authentic transparent PNGs directly from `irasutoya.com`):

```powershell
# Preview candidates first
python scripts/fetch_irasutoya.py find "ひらめき" 5

# Download top match into your document's assets/irasutoya/ folder
python scripts/fetch_irasutoya.py get "ひらめき" --out ./assets/irasutoya --name idea.png
```

### 2. Optional: Full-Color Contrast vs. 2-Color Cobalt Duotone
- **Original Color (Recommended for "可爱反差萌" margin mascots)**: Keep Irasutoya's soft watercolor palette at small scale (`18mm–28mm`) in the right margin or beside a `POINT!` box — it creates charming Japanese textbook warmth while the main layout remains strictly 2-color.
- **Strict 2-Color Duotone Mode**: If you want ultra-unified 2-color print cohesion (even for mascots), run:
  ```powershell
  uv run --with pillow --with numpy scripts/process_illustration.py duotone assets/irasutoya/idea.png assets/irasutoya/idea-cobalt.png --spot "#005BAC"
  ```

### 3. Curated Japanese Query Cheat Sheet (Tech Handbook Scenarios)

| Document Moment / Mood | Japanese Query (`fetch_irasutoya.py`) | Typical Placement |
| :--- | :--- | :--- |
| 灵光一闪 / `POINT!` 提示 | `ひらめき` / `電球` | `#jp2-point-box(mascot: ...)` |
| 敲代码 / 认真研发 | `パソコン エンジニア` / `プログラミング` | Chapter 01 margin |
| 纠结踩坑 / 警告注意 | `パソコン 悩む` / `注意 看板` | Caution / pitfall margin |
| 服务器 / 云端架构 | `サーバー` / `クラウド` | Architecture chapter margin |
| 排查 Bug / 放大镜检查 | `虫眼鏡` / `バグ` | Debugging / QA section |
| 咖啡歇口气 / 随性卖萌 | `コーヒー` / `猫 パソコン` / `休憩` | End of long chapter / colophon |
| 对比选择 / 天平权衡 | `天秤` / `迷う` | Trade-off / comparison entry |
| 上线庆祝 / 顺利完成 | `ガッツポーズ` / `クラッカー` | Final summary / wrap-up |

### 4. Typst Placement & Obsidian Compatibility
- Always save illustrations inside an `assets/` folder **next to your `.typ` file** (e.g., `assets/irasutoya/idea.png`), and reference via relative path:
  ```typst
  #jp2-margin-mascot("assets/irasutoya/cat.png", caption: [（摸鱼检查缓存中…）], width: 24mm)

  #jp2-point-box(
    tag: "POINT!",
    title: "设计备忘",
    mascot: image("assets/irasutoya/idea.png", width: 23mm),
    [正文内容...],
  )
  ```
- **Restraint Rule**: Keep casual Irasutoya mascots sparse — **1 per 1–2 pages max**, sized `18mm–28mm`, strictly in the right margin or `POINT!` side slot so they never interrupt the left main reading column.
- **License Note**: [irasutoya.com](https://www.irasutoya.com/p/terms.html) permits free personal and commercial use (up to 20 illustrations per commercial publication/project); always check their terms for large commercial print runs.
