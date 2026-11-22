#!/usr/bin/env python3
"""Post-processing utility for Typst illustrations (inspired by book_skill):

1. whiten     — Bleaches near-white / P3-tinted AI infographic backgrounds to pure #FFFFFF
                so they blend seamlessly onto white Typst pages without grey boxes.
2. chroma-key — Converts a solid background color into smooth feathered transparent RGBA.
3. duotone    — Recolors any PNG (AI sketch or Irasutoya) into authentic Japanese 2-Color
                Print inks (Sumi Black #1C1C1C + Spot Ink, default Cobalt #005BAC) while
                preserving alpha transparency.

Usage (no virtualenv needed via uv):
    uv run --with pillow --with numpy process_illustration.py whiten raw.png clean.png
    uv run --with pillow --with numpy process_illustration.py chroma-key raw.png cut.png
    uv run --with pillow --with numpy process_illustration.py duotone raw.png cobalt.png --spot "#005BAC"
"""

from __future__ import annotations

import argparse
import statistics
from pathlib import Path

import numpy as np
from PIL import Image


def parse_hex(hex_str: str) -> np.ndarray:
    h = hex_str.lstrip("#")
    return np.array([int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)], dtype=np.float32)


def cmd_whiten(src: Path, dst: Path, luma_thresh: float = 238.0, sat_thresh: float = 18.0) -> None:
    """Force near-white, low-saturation background pixels to pure #FFFFFF."""
    im = Image.open(src).convert("RGBA")
    arr = np.asarray(im).astype(np.float32)
    rgb = arr[..., :3]
    alpha = arr[..., 3]

    cmax = rgb.max(axis=2)
    cmin = rgb.min(axis=2)
    sat = cmax - cmin
    luma = 0.299 * rgb[..., 0] + 0.587 * rgb[..., 1] + 0.114 * rgb[..., 2]

    mask = (luma >= luma_thresh) & (sat <= sat_thresh)
    rgb[mask] = 255.0
    arr[..., :3] = rgb
    arr[..., 3] = alpha

    dst.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(arr.astype(np.uint8), "RGBA").save(dst)
    print(f"Whitened background -> {dst} (pixels bleached: {int(mask.sum()):,})")


def cmd_chroma_key(src: Path, dst: Path, t1: float = 35.0, t2: float = 85.0) -> None:
    """Key out solid corner background color to transparent RGBA with feathered edges."""
    im = Image.open(src).convert("RGBA")
    arr = np.asarray(im).astype(np.float32)
    h, w, _ = arr.shape
    rgb = arr[..., :3]
    orig_alpha = arr[..., 3]

    corners = [rgb[2, 2], rgb[2, w - 3], rgb[h - 3, 2], rgb[h - 3, w - 3]]
    bg = np.array([statistics.median(float(c[i]) for c in corners) for i in range(3)], dtype=np.float32)
    dist = np.sqrt(((rgb - bg) ** 2).sum(axis=2))
    key_alpha = np.clip((dist - t1) / max(t2 - t1, 1.0), 0.0, 1.0) * 255.0
    final_alpha = np.minimum(orig_alpha, key_alpha)

    rgba = np.dstack([rgb, final_alpha]).astype(np.uint8)
    dst.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(rgba, "RGBA").save(dst)
    bg_hex = "#%02X%02X%02X" % tuple(int(x) for x in bg)
    print(f"Chroma-keyed {bg_hex} -> {dst}")


def cmd_duotone(src: Path, dst: Path, spot_hex: str = "#005BAC", black_hex: str = "#1C1C1C") -> None:
    """Convert an illustration into strict Japanese 2-Color Print duotone (Sumi Black + Spot Ink)
    preserving crisp dark linework, midtone spot ink fills, white highlights, and transparency."""
    im = Image.open(src).convert("RGBA")
    arr = np.asarray(im).astype(np.float32)
    rgb = arr[..., :3]
    alpha = arr[..., 3]

    # Luminance 0.0 (darkest ink) .. 1.0 (paper white)
    luma = (0.299 * rgb[..., 0] + 0.587 * rgb[..., 1] + 0.114 * rgb[..., 2]) / 255.0
    black = parse_hex(black_hex)
    spot = parse_hex(spot_hex)
    white = np.array([255.0, 255.0, 255.0], dtype=np.float32)

    # Map luminance piecewise:
    #   [0.00 .. 0.35]: Sumi Black -> Spot Ink (keeps outlines dark and legible)
    #   [0.35 .. 0.88]: Spot Ink -> Paper White (gives halftone cobalt tint feel)
    #   [0.88 .. 1.00]: Pure Paper White
    out_rgb = np.zeros_like(rgb)
    low = luma <= 0.35
    mid = (luma > 0.35) & (luma <= 0.88)
    high = luma > 0.88

    t_low = np.clip(luma[low] / 0.35, 0.0, 1.0)[:, None]
    out_rgb[low] = black * (1.0 - t_low) + spot * t_low

    t_mid = np.clip((luma[mid] - 0.35) / (0.88 - 0.35), 0.0, 1.0)[:, None]
    out_rgb[mid] = spot * (1.0 - t_mid) + white * t_mid

    out_rgb[high] = white

    rgba = np.dstack([np.clip(out_rgb, 0, 255), alpha]).astype(np.uint8)
    dst.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(rgba, "RGBA").save(dst)
    print(f"Duotone ({black_hex} x {spot_hex}) -> {dst}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Post-process illustrations for jp-2color-typst.")
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_w = sub.add_parser("whiten", help="Bleach near-white AI background to pure #FFFFFF")
    p_w.add_argument("src", type=Path)
    p_w.add_argument("dst", type=Path)
    p_w.add_argument("--luma", type=float, default=238.0)
    p_w.add_argument("--sat", type=float, default=18.0)

    p_c = sub.add_parser("chroma-key", help="Key out solid background into transparent RGBA")
    p_c.add_argument("src", type=Path)
    p_c.add_argument("dst", type=Path)
    p_c.add_argument("--t1", type=float, default=35.0)
    p_c.add_argument("--t2", type=float, default=85.0)

    p_d = sub.add_parser("duotone", help="Recolor illustration into Japanese 2-Color Print duotone")
    p_d.add_argument("src", type=Path)
    p_d.add_argument("dst", type=Path)
    p_d.add_argument("--spot", default="#005BAC")
    p_d.add_argument("--black", default="#1C1C1C")

    args = parser.parse_args()
    if args.cmd == "whiten":
        cmd_whiten(args.src, args.dst, args.luma, args.sat)
    elif args.cmd == "chroma-key":
        cmd_chroma_key(args.src, args.dst, args.t1, args.t2)
    elif args.cmd == "duotone":
        cmd_duotone(args.src, args.dst, args.spot, args.black)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
