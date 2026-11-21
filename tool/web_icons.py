import os
from PIL import Image

src = Image.open('assets/images/zeta_icon.png').convert('RGBA')
targets = [
    ('web/favicon.png', 32),
    ('web/icons/Icon-192.png', 192),
    ('web/icons/Icon-512.png', 512),
    ('web/icons/Icon-maskable-192.png', 192),
    ('web/icons/Icon-maskable-512.png', 512),
    ('build/web/favicon.png', 32),
    ('build/web/icons/Icon-192.png', 192),
    ('build/web/icons/Icon-512.png', 512),
    ('build/web/icons/Icon-maskable-192.png', 192),
    ('build/web/icons/Icon-maskable-512.png', 512),
]
for path, size in targets:
    d = os.path.dirname(path)
    if d and not os.path.isdir(d):
        continue  # build/web/icons only exists after a build
    img = src.resize((size, size), Image.LANCZOS)
    img.save(path, 'PNG')
    print('wrote', path, size)
