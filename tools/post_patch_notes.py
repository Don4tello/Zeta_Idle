#!/usr/bin/env python3
"""Post the latest Zeta Idle patch notes to Discord + Reddit.

Reads the newest "## +N — Title" section from CHANGELOG.md and publishes it.

Secrets come from tools/post_config.json (git-ignored) or environment variables:
  DISCORD_WEBHOOK_URL
  REDDIT_CLIENT_ID, REDDIT_CLIENT_SECRET, REDDIT_REFRESH_TOKEN,
  REDDIT_SUBREDDIT   (default: zeta_idle)

Reddit uses a refresh token (no password — works with Google Sign-In). Run
  python tools/get_reddit_token.py
once to authorize in the browser and save REDDIT_REFRESH_TOKEN.

Usage:
  python tools/post_patch_notes.py                # post to both
  python tools/post_patch_notes.py --discord-only
  python tools/post_patch_notes.py --reddit-only
  python tools/post_patch_notes.py --dry-run      # print, don't post
"""
import argparse
import json
import os
import re
import sys
from pathlib import Path

import requests

ROOT = Path(__file__).resolve().parent.parent
CHANGELOG = ROOT / "CHANGELOG.md"
CONFIG = Path(__file__).resolve().parent / "post_config.json"
USER_AGENT = "zeta-idle-patchbot/1.0"
GOLD = 0xC9A35A  # brand accent gold, for the Discord embed


def load_config():
    cfg = {}
    if CONFIG.exists():
        cfg = json.loads(CONFIG.read_text(encoding="utf-8"))
    # Environment variables override the file.
    for key in ("DISCORD_WEBHOOK_URL", "REDDIT_CLIENT_ID", "REDDIT_CLIENT_SECRET",
                "REDDIT_REFRESH_TOKEN", "REDDIT_SUBREDDIT"):
        if os.environ.get(key):
            cfg[key] = os.environ[key]
    cfg.setdefault("REDDIT_SUBREDDIT", "zeta_idle")
    return cfg


def latest_patch():
    """Return (build:int, title:str, bullets:[str]) for the newest changelog entry."""
    text = CHANGELOG.read_text(encoding="utf-8")
    # Find the first "## +N — Title" heading and capture until the next "## " or "---".
    m = re.search(r"^## \+(\d+)\s+—\s+(.+?)\n(.*?)(?=^## |\n---)", text, re.M | re.S)
    if not m:
        sys.exit("Could not find a '## +N — Title' entry in CHANGELOG.md")
    build = int(m.group(1))
    title = m.group(2).strip()
    body = m.group(3)
    # Collapse the markdown bullet lines (which may wrap) into single strings.
    bullets = []
    for raw in re.split(r"\n(?=- )", body.strip()):
        line = raw.strip()
        if not line.startswith("- "):
            continue
        line = re.sub(r"\s*\n\s*", " ", line[2:]).strip()   # unwrap
        line = re.sub(r"\*\*(.+?)\*\*", r"\1", line)          # drop bold markers
        line = re.sub(r"`(.+?)`", r"\1", line)                # drop code ticks
        bullets.append(line)
    return build, title, bullets


def format_body(build, title, bullets):
    lines = [f"**Build {build} — {title}**", ""]
    lines += [f"• {b}" for b in bullets]
    return "\n".join(lines)


def post_discord(cfg, build, title, bullets, dry):
    url = cfg.get("DISCORD_WEBHOOK_URL")
    if not url:
        print("… skipping Discord (no DISCORD_WEBHOOK_URL)")
        return
    embed = {
        "title": f"🛡  Zeta Idle — Build {build}: {title}",
        "description": "\n".join(f"• {b}" for b in bullets),
        "color": GOLD,
    }
    if dry:
        print("[dry-run] Discord embed:\n", json.dumps(embed, indent=2))
        return
    r = requests.post(url, json={"embeds": [embed]}, timeout=20)
    r.raise_for_status()
    print(f"✓ Posted to Discord (HTTP {r.status_code})")


def post_reddit(cfg, build, title, bullets, dry):
    need = ("REDDIT_CLIENT_ID", "REDDIT_CLIENT_SECRET", "REDDIT_REFRESH_TOKEN")
    if not all(cfg.get(k) for k in need):
        print("… skipping Reddit (missing REDDIT_* / refresh token — run get_reddit_token.py)")
        return
    post_title = f"Update — Build {build}: {title}"
    post_text = format_body(build, title, bullets)
    sub = cfg["REDDIT_SUBREDDIT"]
    if dry:
        print(f"[dry-run] Reddit r/{sub} post:\n{post_title}\n\n{post_text}")
        return
    # OAuth (refresh-token grant) → submit self post. No password needed.
    auth = requests.auth.HTTPBasicAuth(cfg["REDDIT_CLIENT_ID"], cfg["REDDIT_CLIENT_SECRET"])
    tok = requests.post(
        "https://www.reddit.com/api/v1/access_token",
        auth=auth,
        data={"grant_type": "refresh_token",
              "refresh_token": cfg["REDDIT_REFRESH_TOKEN"]},
        headers={"User-Agent": USER_AGENT}, timeout=20)
    tok.raise_for_status()
    token = tok.json().get("access_token")
    if not token:
        sys.exit(f"Reddit auth failed: {tok.text}")
    r = requests.post(
        "https://oauth.reddit.com/api/submit",
        headers={"Authorization": f"bearer {token}", "User-Agent": USER_AGENT},
        data={"sr": sub, "kind": "self", "title": post_title, "text": post_text,
              "api_type": "json"}, timeout=20)
    r.raise_for_status()
    errors = r.json().get("json", {}).get("errors")
    if errors:
        sys.exit(f"Reddit submit error: {errors}")
    print(f"✓ Posted to Reddit r/{sub}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--discord-only", action="store_true")
    ap.add_argument("--reddit-only", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    cfg = load_config()
    build, title, bullets = latest_patch()
    print(f"Latest: Build {build} — {title}  ({len(bullets)} changes)")

    if not args.reddit_only:
        post_discord(cfg, build, title, bullets, args.dry_run)
    if not args.discord_only:
        post_reddit(cfg, build, title, bullets, args.dry_run)


if __name__ == "__main__":
    main()
