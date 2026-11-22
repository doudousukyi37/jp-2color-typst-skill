#!/usr/bin/env python3
"""Slice Windows Noto SC variable fonts into static Regular (400) & Bold (700)
TTF files for Obsidian Typst Mate (fixes both Chinese tofu boxes and thin/pale
variable-font rendering in WASM SVG preview).

Usage:
    uv run --with fonttools slice_obsidian_fonts.py --vault "E:\\path\\to\\ObsidianVault"
    uv run --with fonttools slice_obsidian_fonts.py --out-dir "E:\\custom\\fonts\\dir"
"""

from __future__ import annotations

import argparse
import os
import shutil
import sys
from pathlib import Path

from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont


DEFAULT_WIN_FONTS = Path(r"C:\Windows\Fonts")

SLICE_JOBS = [
    ("NotoSansSC-VF.ttf", 400, "NotoSansSC-Regular.ttf"),
    ("NotoSansSC-VF.ttf", 700, "NotoSansSC-Bold.ttf"),
    ("NotoSerifSC-VF.ttf", 400, "NotoSerifSC-Regular.ttf"),
    ("NotoSerifSC-VF.ttf", 700, "NotoSerifSC-Bold.ttf"),
]

STATIC_COPY_FILES = [
    "consola.ttf",
    "consolab.ttf",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate static Noto SC Regular/Bold fonts for Obsidian Typst Mate."
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--vault",
        type=Path,
        help="Path to Obsidian Vault root (writes to .obsidian/plugins/typst-mate/fonts).",
    )
    group.add_argument(
        "--out-dir",
        type=Path,
        help="Explicit destination directory for generated static TTF files.",
    )
    parser.add_argument(
        "--fonts-dir",
        type=Path,
        default=DEFAULT_WIN_FONTS,
        help=f"Source directory containing Noto*-VF.ttf (default: {DEFAULT_WIN_FONTS}).",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    out_dir: Path = (
        args.vault / ".obsidian" / "plugins" / "typst-mate" / "fonts"
        if args.vault is not None
        else args.out_dir
    )
    out_dir.mkdir(parents=True, exist_ok=True)

    # Remove problematic variable fonts if present in destination
    for vf_name in ("NotoSansSC-VF.ttf", "NotoSerifSC-VF.ttf"):
        stale = out_dir / vf_name
        if stale.exists():
            stale.unlink()
            print(f"Removed variable font: {stale}")

    missing = []
    for src_name, wght, out_name in SLICE_JOBS:
        src_path = args.fonts_dir / src_name
        if not src_path.exists():
            missing.append(str(src_path))
            continue
        font = TTFont(str(src_path))
        static_font = instantiateVariableFont(font, {"wght": wght}, inplace=False)
        dst_path = out_dir / out_name
        static_font.save(str(dst_path))
        print(f"Generated: {dst_path} (wght={wght}, {os.path.getsize(dst_path):,} bytes)")

    for mono_name in STATIC_COPY_FILES:
        src_path = args.fonts_dir / mono_name
        if src_path.exists():
            dst_path = out_dir / mono_name
            shutil.copy2(src_path, dst_path)
            print(f"Copied:    {dst_path} ({os.path.getsize(dst_path):,} bytes)")

    if missing:
        print(
            "\nWarning: Some source variable fonts were not found:\n  - "
            + "\n  - ".join(missing),
            file=sys.stderr,
        )
        return 1

    print("\nDone! Reload Obsidian to apply the static fonts.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
