import os, glob
from PIL import Image

KEEP = {'assets/images/zeta_icon.png'}  # launcher icon must stay PNG
before = after = 0
converted = kept = 0
fails = []
for ext in ('png', 'jpg', 'jpeg'):
    for path in glob.glob(os.path.join('assets', '**', '*.' + ext), recursive=True):
        rel = path.replace(os.sep, '/')
        if rel in KEEP:
            kept += 1
            continue
        sz = os.path.getsize(path)
        out = os.path.splitext(path)[0] + '.webp'
        try:
            im = Image.open(path)
            # Lossy q90 — visually indistinguishable for this photographic/AI
            # art, ~73% smaller (lossless was +19% on this content). method=6 =
            # best compression effort. RGBA preserves PNG transparency.
            im = im.convert('RGBA' if path.lower().endswith('.png') else 'RGB')
            im.save(out, 'WEBP', quality=90, method=6)
            after += os.path.getsize(out)
            before += sz
            os.remove(path)
            converted += 1
        except Exception as e:
            fails.append((path, str(e)))
print('converted %d files, kept %d (launcher)' % (converted, kept))
if before:
    print('before: %.1f MB  ->  after: %.1f MB  (%.0f%% smaller)'
          % (before / 1e6, after / 1e6, 100 * (1 - after / before)))
for p, e in fails:
    print('FAIL', p, e)
