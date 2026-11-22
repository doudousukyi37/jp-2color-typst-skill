#!/usr/bin/env python3
"""Search and download free transparent PNG illustrations from irasutoya.com
via its public Blogger JSON feed (pure Python stdlib, Windows/macOS/Linux).

Usage:
    python fetch_irasutoya.py find "猫 パソコン" 5
    python fetch_irasutoya.py get "電球" --out ./assets/irasutoya --name idea.png
    python fetch_irasutoya.py get "コーヒー" --size 800 --out ./assets/irasutoya --name coffee.png
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import urllib.parse
import urllib.request
from pathlib import Path

FEED_URL = "https://www.irasutoya.com/feeds/posts/summary"
USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"


def http_get(url: str, timeout: int = 15) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return resp.read()


def rewrite_blogger_size(url: str, size: str) -> str:
    """Replace Blogger thumbnail size (/s72-c/, /s400/, etc.) with target size (e.g. s800 or s0)."""
    size_seg = size if size.startswith("s") else f"s{size}"
    updated = re.sub(r"/(?:s\d+(?:-c)?|w\d+-h\d+(?:-c)?)/", f"/{size_seg}/", url, count=1)
    if updated == url and "=s" in url:
        updated = re.sub(r"=s\d+(?:-[a-z]+)?$", f"={size_seg}", url)
    return updated


def extract_page_url(entry: dict) -> str:
    for link in entry.get("link", []):
        if link.get("rel") == "alternate":
            return link.get("href", "")
    return ""


def fetch_feed(query: str | None, label: str | None = None, max_results: int = 20, size: str = "800") -> list[dict]:
    base = FEED_URL + ("/-/" + urllib.parse.quote(label) if label else "")
    params: dict[str, str] = {"alt": "json", "max-results": str(max(max_results, 10))}
    if query:
        params["q"] = query
    url = f"{base}?{urllib.parse.urlencode(params)}"
    raw = http_get(url)
    entries = json.loads(raw.decode("utf-8")).get("feed", {}).get("entry", [])

    results = []
    for entry in entries:
        title = entry.get("title", {}).get("$t", "").strip()
        html = entry.get("content", {}).get("$t", "") or entry.get("summary", {}).get("$t", "")
        m = re.search(r'src="(https://(?:blogger\.googleusercontent\.com|\d+\.bp\.blogspot\.com)/[^"]+?\.(?:png|jpg|jpeg|gif))"', html)
        src = m.group(1) if m else entry.get("media$thumbnail", {}).get("url", "")
        if not src:
            continue
        img_url = rewrite_blogger_size(src, size)
        page_url = extract_page_url(entry)
        labels = [c.get("term", "") for c in entry.get("category", []) if c.get("term")]
        fname = os.path.basename(urllib.parse.urlparse(img_url).path) or f"irasutoya_{len(results) + 1}.png"
        fname = re.sub(r"[^a-zA-Z0-9._-]+", "_", fname)
        if not fname.lower().endswith((".png", ".jpg", ".jpeg", ".gif")):
            fname += ".png"
        results.append(
            {
                "title": title,
                "file": fname,
                "img_url": img_url,
                "page_url": page_url,
                "labels": labels,
            }
        )
    return results


def search_irasutoya(query: str, max_results: int = 10, label: str | None = None, size: str = "800") -> tuple[list[dict], list[str]]:
    tokens = [t for t in query.strip().split() if t]
    tried: list[str] = []
    candidates = [query.strip()]
    if len(tokens) > 1:
        candidates.extend(tokens)

    seen_urls: set[str] = set()
    merged: list[dict] = []
    for cand in candidates:
        if not cand or cand in tried:
            continue
        tried.append(cand)
        hits = fetch_feed(cand, label=label, max_results=20, size=size)
        for item in hits:
            key = item["page_url"] or item["img_url"]
            if key not in seen_urls:
                seen_urls.add(key)
                merged.append(item)
        if len(merged) >= max_results and cand == query.strip():
            break

    # Rank: prefer title containing more query tokens
    def rank_key(item: dict) -> tuple[int, int]:
        title = item["title"]
        matches = sum(1 for t in tokens if t in title)
        return (-matches, len(title))

    merged.sort(key=rank_key)
    return merged[:max_results], tried


def png_dims(data: bytes) -> tuple[int, int]:
    if data[:8] == b"\x89PNG\r\n\x1a\n" and len(data) >= 24:
        return int.from_bytes(data[16:20], "big"), int.from_bytes(data[20:24], "big")
    return 0, 0


def download_image(url: str, dst: Path) -> tuple[int, int, int]:
    blob = http_get(url, timeout=25)
    if not (blob[:8] == b"\x89PNG\r\n\x1a\n" or blob[:3] == b"\xff\xd8\xff"):
        raise RuntimeError(f"Downloaded content is not a valid PNG/JPEG: {url}")
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_bytes(blob)
    w, h = png_dims(blob)
    return len(blob), w, h


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Search and download free transparent PNGs from irasutoya.com")
    p.add_argument("cmd", choices=["find", "get"], help="find (list only) or get (search + download)")
    p.add_argument("query", help="Japanese search query, e.g. 'ひらめき' or '猫 パソコン'")
    p.add_argument("count", nargs="?", type=int, default=None, help="Number of items (default: 8 for find, 1 for get)")
    p.add_argument("--label", default=None, help="Optional irasutoya category label filter")
    p.add_argument("--size", default="800", help="Image max dimension: 400, 800, or 0 for original (default: 800)")
    p.add_argument("--out", type=Path, default=Path("assets/irasutoya"), help="Output directory (default: assets/irasutoya)")
    p.add_argument("--name", default=None, help="Custom output filename when downloading 1 item (e.g. mascot.png)")
    p.add_argument("--json", action="store_true", help="Print JSON output")
    return p.parse_args()


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    args = parse_args()
    count = args.count if args.count is not None else (1 if args.cmd == "get" else 8)
    try:
        items, tried = search_irasutoya(args.query, max_results=count, label=args.label, size=args.size)
    except Exception as exc:
        print(f"Error querying irasutoya.com: {exc}", file=sys.stderr)
        return 1

    if not items:
        print(f"No hits for {tried}. Try a simpler Japanese noun (e.g. 電球, コーヒー, パソコン).", file=sys.stderr)
        return 1

    if args.cmd == "get":
        for idx, item in enumerate(items[:count]):
            fname = args.name if (args.name and count == 1 and idx == 0) else item["file"]
            dst = args.out / fname
            nbytes, w, h = download_image(item["img_url"], dst)
            item["saved_path"] = str(dst)
            item["bytes"] = nbytes
            item["width"] = w
            item["height"] = h

    if args.json:
        print(json.dumps(items, ensure_ascii=False, indent=2))
    else:
        print(f"tried: {' | '.join(tried)}  ({len(items)} hits)")
        for i, item in enumerate(items, 1):
            mark = "*" if "saved_path" in item else " "
            lbl = ",".join(item["labels"][:3])
            print(f"{i:2d}{mark} {item['title']} | {item['file']} | {lbl}")
            if "saved_path" in item:
                dim_s = f"{item['width']}x{item['height']}" if item.get("width") else "image"
                print(f"     saved: {item['saved_path']} ({item['bytes'] // 1024} KB, {dim_s})")
                print(f"     src:   {item['page_url']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
