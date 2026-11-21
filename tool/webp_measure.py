import os, glob, io
from PIL import Image

KEEP = {'assets/images/zeta_icon.png'}
rows = []
tot_src = tot_lossy = tot_lossless = 0
for ext in ('png', 'jpg', 'jpeg'):
    for path in glob.glob(os.path.join('assets', '**', '*.' + ext), recursive=True):
        rel = path.replace(os.sep, '/')
        if rel in KEEP:
            continue
        src = os.path.getsize(path)
        im = Image.open(path).convert('RGBA' if ext == 'png' else 'RGB')
        b1 = io.BytesIO(); im.save(b1, 'WEBP', quality=90, method=6); lossy = b1.tell()
        tot_src += src; tot_lossy += lossy
        rows.append((src, lossy, rel))
rows.sort(reverse=True)
print('TOTAL  src: %.1f MB  ->  lossy q90: %.1f MB  (%.0f%% smaller)'
      % (tot_src/1e6, tot_lossy/1e6, 100*(1-tot_lossy/tot_src)))
print('--- 10 biggest (src KB -> q90 KB) ---')
for src, lossy, rel in rows[:10]:
    print('%6.0f -> %6.0f KB  %s' % (src/1e3, lossy/1e3, rel))
