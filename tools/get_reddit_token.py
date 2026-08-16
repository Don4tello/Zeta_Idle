#!/usr/bin/env python3
"""One-time Reddit authorization → saves a refresh token to post_config.json.

No password needed, so this works even if your Reddit account uses Google
Sign-In (and it's unaffected by 2FA). Run it once; the refresh token is reused
by post_patch_notes.py forever after.

Setup: create a Reddit app at https://www.reddit.com/prefs/apps
  - Type: **web app**
  - redirect uri: http://localhost:8080
  - Put the client id + secret in tools/post_config.json (or you'll be prompted).

Then:
  python tools/get_reddit_token.py
A browser opens → click **Allow** → done.
"""
import http.server
import json
import secrets
import socketserver
import sys
import urllib.parse
import webbrowser
from pathlib import Path

import requests

CONFIG = Path(__file__).resolve().parent / "post_config.json"
REDIRECT = "http://localhost:8080"
USER_AGENT = "zeta-idle-patchbot/1.0"
SCOPE = "submit identity"


def main():
    cfg = json.loads(CONFIG.read_text(encoding="utf-8")) if CONFIG.exists() else {}
    cid = cfg.get("REDDIT_CLIENT_ID") or input("Reddit client id: ").strip()
    csecret = cfg.get("REDDIT_CLIENT_SECRET") or input("Reddit client secret: ").strip()

    state = secrets.token_urlsafe(16)
    auth_url = (
        "https://www.reddit.com/api/v1/authorize?"
        + urllib.parse.urlencode({
            "client_id": cid,
            "response_type": "code",
            "state": state,
            "redirect_uri": REDIRECT,
            "duration": "permanent",   # required to receive a refresh token
            "scope": SCOPE,
        })
    )

    holder = {}

    class Handler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            params = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
            holder["code"] = params.get("code", [None])[0]
            holder["state"] = params.get("state", [None])[0]
            holder["error"] = params.get("error", [None])[0]
            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.end_headers()
            self.wfile.write(b"<h2>Zeta Idle: authorization received. You can close this tab.</h2>")

        def log_message(self, *_):
            pass

    print("Opening your browser to authorize the app… click 'Allow'.")
    print("If it doesn't open, paste this URL:\n" + auth_url + "\n")
    webbrowser.open(auth_url)
    with socketserver.TCPServer(("localhost", 8080), Handler) as httpd:
        httpd.handle_request()  # serve exactly one request (the redirect)

    if holder.get("error"):
        sys.exit(f"Authorization denied: {holder['error']}")
    if holder.get("state") != state:
        sys.exit("State mismatch — aborting for safety.")
    code = (holder.get("code") or "").rstrip("#_")
    if not code:
        sys.exit("No authorization code returned.")

    tok = requests.post(
        "https://www.reddit.com/api/v1/access_token",
        auth=requests.auth.HTTPBasicAuth(cid, csecret),
        data={"grant_type": "authorization_code", "code": code, "redirect_uri": REDIRECT},
        headers={"User-Agent": USER_AGENT}, timeout=20)
    tok.raise_for_status()
    data = tok.json()
    refresh = data.get("refresh_token")
    if not refresh:
        sys.exit(f"No refresh token returned (check app type = web app, duration=permanent): {data}")

    cfg["REDDIT_CLIENT_ID"] = cid
    cfg["REDDIT_CLIENT_SECRET"] = csecret
    cfg["REDDIT_REFRESH_TOKEN"] = refresh
    cfg.setdefault("REDDIT_SUBREDDIT", "zeta_idle")
    cfg.pop("REDDIT_USERNAME", None)
    cfg.pop("REDDIT_PASSWORD", None)
    CONFIG.write_text(json.dumps(cfg, indent=2), encoding="utf-8")
    print(f"\n✓ Saved REDDIT_REFRESH_TOKEN to {CONFIG.name}. You're set — run post_patch_notes.py.")


if __name__ == "__main__":
    main()
