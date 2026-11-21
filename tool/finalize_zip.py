import os, shutil, zipfile

web = 'build/web'
ck = os.path.join(web, 'canvaskit')

# 1) Trim CanvasKit to only what a standard (non-wasm) web build actually loads:
#    the generic canvaskit.wasm (fallback) + the chromium/ variant (Chrome).
#    Drop the skwasm renderer, wimp, experimental paragraph, and all debug
#    .symbols files — none are fetched by this build (server log confirmed Chrome
#    loads chromium/canvaskit.wasm).
removed = 0
def rm(path):
    global removed
    if os.path.isdir(path):
        sz = sum(os.path.getsize(os.path.join(d, f)) for d, _, fs in os.walk(path) for f in fs)
        shutil.rmtree(path); removed_bytes[0] += sz; removed += 1
    elif os.path.isfile(path):
        removed_bytes[0] += os.path.getsize(path); os.remove(path); removed += 1

removed_bytes = [0]
if os.path.isdir(ck):
    rm(os.path.join(ck, 'experimental_webparagraph'))
    for f in os.listdir(ck):
        p = os.path.join(ck, f)
        if f.endswith('.symbols') or f.startswith('skwasm') or f.startswith('wimp'):
            rm(p)

# 2) Drop the launcher-only PNG (used by flutter_launcher_icons at build time,
#    not at web runtime; the in-app logo uses zeta_icon.webp).
launcher = os.path.join(web, 'assets', 'assets', 'images', 'zeta_icon.png')
if os.path.isfile(launcher):
    removed_bytes[0] += os.path.getsize(launcher); os.remove(launcher); removed += 1

print('trimmed %d items, freed %.1f MB' % (removed, removed_bytes[0] / 1e6))

# 3) Zip the whole (trimmed) build/web — CanvasKit is bundled (CDN black-screened).
out = 'build/zeta_demo_web.zip'
if os.path.exists(out):
    os.remove(out)
n = 0
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as z:
    for d, _, fs in os.walk(web):
        for f in fs:
            p = os.path.join(d, f)
            z.write(p, os.path.relpath(p, web)); n += 1
folder = sum(os.path.getsize(os.path.join(d, f)) for d, _, fs in os.walk(web) for f in fs)
print('zipped %d files' % n)
print('unzipped folder: %.1f MB   |   ZIP: %.1f MB   (budget 50 MB)'
      % (folder / 1e6, os.path.getsize(out) / 1e6))
