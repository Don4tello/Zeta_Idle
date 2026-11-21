import os, zipfile

web = 'build/web'
out = 'build/zeta_demo_web.zip'
if os.path.exists(out):
    os.remove(out)
n = 0
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as z:
    for d, _, fs in os.walk(web):
        rel_dir = os.path.relpath(d, web).replace(os.sep, '/')
        # CanvasKit loads from the gstatic CDN by default — exclude the bundled
        # copy from the upload so the ZIP fits the 50 MB budget.
        if rel_dir == 'canvaskit' or rel_dir.startswith('canvaskit/'):
            continue
        for f in fs:
            p = os.path.join(d, f)
            z.write(p, os.path.relpath(p, web))
            n += 1
print('zipped %d files (canvaskit excluded -> loads from gstatic CDN)' % n)
print('ZIP size: %.1f MB   (budget 50 MB)' % (os.path.getsize(out) / 1e6))
