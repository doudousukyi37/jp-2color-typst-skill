# Obsidian `Typst Mate` Live-Preview Setup & Troubleshooting

This guide documents every Windows + Obsidian `Typst Mate` quirk solved during real-world production use so `.typ` files render identically to `typst compile` PDFs directly inside Obsidian.

## 1. Blank Preview (`failed to load file`)

**Cause**: Obsidian `Typst Mate` resolves `#import "..."` relative to its plugin setting `importPath` (commonly `.typst`), **not** relative to the current `.typ` file's folder.

**Fixes** (Option A is strongly recommended for portability):
- **Option A (Recommended)**: Keep each `.typ` document **single-file self-contained** by inlining `template-jp-2color.typ` at the top of the file. Works identically in Obsidian and CLI from any subfolder.
- **Option B**: Copy `template-jp-2color.typ` into `<VaultRoot>/.typst/template-jp-2color.typ` and verify `importPath` in `.obsidian/plugins/typst-mate/data.json`.

## 2. Chinese Tofu Boxes (`□□□`) in Obsidian Preview

**Cause**: `Typst Mate` runs a sandboxed WASM Typst compiler that **cannot read OS system fonts** automatically. It only loads fonts placed inside:
```text
<VaultRoot>/.obsidian/plugins/typst-mate/fonts/
```

## 3. Chinese Text Looks Washed Out / Ultra-Thin Compared to PDF

**Cause**: Windows ships variable fonts (`NotoSansSC-VF.ttf`, `NotoSerifSC-VF.ttf`). `Typst Mate`'s WASM SVG renderer collapses variable-font weights to Thin (`wght=100`), making body text look pale and unreadable.

**Fix**: Remove any `-VF.ttf` files from `.obsidian/plugins/typst-mate/fonts/`, and instantiate static Regular (`400`) and Bold (`700`) fonts using the bundled script:

```powershell
uv run --with fonttools skills/jp-2color-typst/scripts/slice_obsidian_fonts.py --vault "E:\path\to\your\ObsidianVault"
```

This generates static fonts directly into `<VaultRoot>/.obsidian/plugins/typst-mate/fonts/`:
- `NotoSansSC-Regular.ttf` (`wght=400`)
- `NotoSansSC-Bold.ttf` (`wght=700`)
- `NotoSerifSC-Regular.ttf` (`wght=400`)
- `NotoSerifSC-Bold.ttf` (`wght=700`)
- `consola.ttf` & `consolab.ttf` (copied from `C:\Windows\Fonts\` if present)

Reload Obsidian (`Ctrl+P` → **Reload app without saving**) after placing the static fonts.

## 4. Installing Typst & Tinymist on Windows (Optional CLI + LSP)

```powershell
winget install --id Typst.Typst -e
winget install --id Myriad-Dreamin.Tinymist -e
```

Find the installed binary paths:
```powershell
(Get-Command typst).Source
(Get-Command tinymist).Source
```
