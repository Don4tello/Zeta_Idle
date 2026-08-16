# Release tools

## Posting patch notes to Discord + Reddit

`post_patch_notes.py` reads the newest `## +N — Title` block from `CHANGELOG.md`
and posts it to your Discord channel and/or the subreddit.

### One-time setup

1. **Copy the config:** `cp tools/post_config.example.json tools/post_config.json`
   (this file is git-ignored — your secrets never get committed).

2. **Discord webhook** (no bot needed):
   Server Settings → Integrations → Webhooks → *New Webhook* → pick the channel →
   *Copy Webhook URL* → paste into `https://discord.com/api/webhooks/1538498804746293329/s7vvsz5R3uszUXkBl4o2Y-_cvgCJM3te3mGq6kp1tEskaOuW7Wh0ySS5rjzxFtg9epXw`.

3. **Reddit app** (no webhook, so it needs API access — uses a **refresh token**,
   so no password is stored; works with Google Sign-In and 2FA):
   - Go to https://www.reddit.com/prefs/apps → *create another app…*
   - Type: **web app**. redirect uri: `http://localhost:8080`
   - Copy the **client id** (under the app name) → `REDDIT_CLIENT_ID`, and the
     **secret** → `REDDIT_CLIENT_SECRET`. Set `REDDIT_SUBREDDIT` (default `zeta_idle`).
   - Then run the one-time authorizer:
     ```bash
     python tools/get_reddit_token.py
     ```
     A browser opens → click **Allow**. It saves `REDDIT_REFRESH_TOKEN` into your
     config automatically. (The Reddit account must be able to post to the sub.)

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
