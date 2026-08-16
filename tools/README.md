# Release tools

## Posting patch notes to Discord + Reddit

`post_patch_notes.py` reads the newest `## +N — Title` block from `CHANGELOG.md`
and posts it to your Discord channel and/or the subreddit.

### One-time setup

1. **Copy the config:** `cp tools/post_config.example.json tools/post_config.json`
   (this file is git-ignored — your secrets never get committed).

2. **Discord webhook** (no bot needed):
   Server Settings → Integrations → Webhooks → *New Webhook* → pick the channel →
   *Copy Webhook URL* → paste into `DISCORD_WEBHOOK_URL`.

3. **Reddit app** (Reddit has no webhook, so it needs API access):
   - Go to https://www.reddit.com/prefs/apps → *create another app…*
   - Type: **script**. Redirect URI: `http://localhost:8080` (unused, but required).
   - Copy the **client id** (under the app name) → `REDDIT_CLIENT_ID`, and the
     **secret** → `REDDIT_CLIENT_SECRET`.
   - Put your Reddit **username/password** in `REDDIT_USERNAME` / `REDDIT_PASSWORD`
     (the account must be a moderator/approved poster of r/zeta_idle).
   - Note: password auth requires the account to **not** use 2FA (or use an app
     password). Set `REDDIT_SUBREDDIT` to your sub (default `zeta_idle`).

### Usage

```bash
python tools/post_patch_notes.py --dry-run     # preview, post nothing
python tools/post_patch_notes.py               # post to both
python tools/post_patch_notes.py --discord-only
python tools/post_patch_notes.py --reddit-only
```

Run it right after you update `CHANGELOG.md` for a release — it always posts the
top (newest) entry. You can also supply secrets via environment variables of the
same names instead of the JSON file (handy for CI).
