import os, re

# Update Dart asset references from .png/.jpg to .webp after the lossless WebP
# conversion. Line-scoped and guarded: only lines that reference an `assets/`
# image are touched, the launcher icon (zeta_icon.png) is left as PNG, and audio
# refs (.mp3/.ogg/.wav) are never matched.
changed_files = 0
changed_lines = 0
for root, _, files in os.walk('lib'):
    for fn in files:
        if not fn.endswith('.dart'):
            continue
        p = os.path.join(root, fn)
        with open(p, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        dirty = False
        for i, line in enumerate(lines):
            if 'assets/' not in line:
                continue
            if 'zeta_icon' in line:
                continue
            if '.png' not in line and '.jpg' not in line and '.jpeg' not in line:
                continue
            new = line.replace('.png', '.webp').replace('.jpeg', '.webp').replace('.jpg', '.webp')
            if new != line:
                lines[i] = new
                dirty = True
                changed_lines += 1
        if dirty:
            with open(p, 'w', encoding='utf-8') as f:
                f.writelines(lines)
            changed_files += 1
print('updated %d lines across %d files' % (changed_lines, changed_files))
