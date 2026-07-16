#!/usr/bin/env python3
"""
Compose the 1024×500 Google Play feature graphic for Zeta Idle.
Run from the project root:  python make_feature_graphic.py
Requires: Pillow  (pip install Pillow)
Sprites must already exist in exported_sprites/ (run the in-app Sprite Exporter first).
"""

import os
import random
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT        = os.path.dirname(os.path.abspath(__file__))
SPRITES_DIR = os.path.join(ROOT, 'exported_sprites')
ASSETS_DIR  = os.path.join(ROOT, 'assets')
OUT_PATH    = os.path.join(ROOT, 'feature_graphic.png')

W, H = 1024, 500


# ── Helpers ──────────────────────────────────────────────────────────────────

def load_sprite(name: str, px: int) -> Image.Image:
    path = os.path.join(SPRITES_DIR, f'{name}.png')
    img  = Image.open(path).convert('RGBA')
    # LANCZOS for downscale (smooth), NEAREST would be too jagged at this size
    return img.resize((px, px), Image.LANCZOS)


def load_icon(px: int) -> Image.Image:
    path = os.path.join(ASSETS_DIR, 'zeta_icon.png')
    img  = Image.open(path).convert('RGBA')
    return img.resize((px, px), Image.LANCZOS)


def paste_with_glow(base: Image.Image, sprite: Image.Image,
                    x: int, y: int, glow_rgb: tuple, radius: int = 22) -> None:
    """Paste sprite onto base with a soft colored glow halo behind it."""
    sw, sh = sprite.size
    pad    = radius * 2
    canvas = Image.new('RGBA', (sw + pad, sh + pad), (0, 0, 0, 0))

    # Colorise the sprite's alpha channel → glow silhouette
    alpha     = sprite.split()[3]
    silhouette = Image.new('RGBA', sprite.size, (*glow_rgb, 0))
    silhouette.putalpha(alpha)
    canvas.paste(silhouette, (radius, radius), silhouette)
    canvas = canvas.filter(ImageFilter.GaussianBlur(radius=radius // 2))

    base.paste(canvas, (x - radius, y - radius), canvas)
    base.paste(sprite,  (x, y),                   sprite)


def best_font(sizes: list[int]) -> list[ImageFont.FreeTypeFont | ImageFont.ImageFont]:
    """Return fonts at each size, using Impact → Arial Bold → default fallback."""
    candidates = [
        r'C:\Windows\Fonts\impact.ttf',
        r'C:\Windows\Fonts\arialbd.ttf',
        r'C:\Windows\Fonts\verdanab.ttf',
        r'C:\Windows\Fonts\arial.ttf',
    ]
    for path in candidates:
        if os.path.exists(path):
            try:
                return [ImageFont.truetype(path, s) for s in sizes]
            except Exception:
                continue
    default = ImageFont.load_default()
    return [default] * len(sizes)


def center_text(draw: ImageDraw.ImageDraw, text: str, font, cx: int, y: int,
                fill: tuple) -> None:
    bbox = draw.textbbox((0, 0), text, font=font)
    tw   = bbox[2] - bbox[0]
    draw.text((cx - tw // 2, y), text, font=font, fill=fill)


# ── Background ───────────────────────────────────────────────────────────────

def make_background() -> Image.Image:
    bg   = Image.new('RGBA', (W, H), (0, 0, 0, 255))
    draw = ImageDraw.Draw(bg)

    # Vertical gradient: near-black navy → dark purple
    top    = (8, 6, 22)
    bottom = (22, 8, 40)
    for y in range(H):
        t = y / H
        r = int(top[0] + (bottom[0] - top[0]) * t)
        g = int(top[1] + (bottom[1] - top[1]) * t)
        b = int(top[2] + (bottom[2] - top[2]) * t)
        draw.line([(0, y), (W, y)], fill=(r, g, b, 255))

    # Subtle star field (upper half)
    random.seed(42)
    for _ in range(150):
        sx    = random.randint(0, W - 1)
        sy    = random.randint(0, H // 2)
        sr    = random.choice([0, 0, 0, 1, 1, 2])
        alpha = random.randint(30, 160)
        tint  = random.choice([(200, 180, 255), (180, 220, 255),
                               (255, 230, 180), (220, 255, 220)])
        draw.ellipse([sx - sr, sy - sr, sx + sr, sy + sr],
                     fill=(*tint, alpha))

    return bg


# ── Layout constants ──────────────────────────────────────────────────────────

LOGO_SIZE   = 84
LOGO_X, LOGO_Y = 14, 12

TITLE_X, TITLE_Y = 116, 12          # left-anchor of title text

HEADER_H    = 108                   # separator line y

SPRITE_SIZE = 130                   # each class sprite image pixel square
CELL_W      = W // 6                # 170  (6 per row)
ROW1_Y      = 112                   # top of first sprite row
ROW2_Y      = ROW1_Y + SPRITE_SIZE + 28   # 270

RACE_STRIP_Y = ROW2_Y + SPRITE_SIZE + 22  # 422
RACE_SIZE    = 44
RACE_CELL_W  = W // 10                     # 102

CLASS_GLOW = {
    'hero_barbarian': (220,  70,  20),   # primal fire
    'hero_bard':      ( 60, 160, 220),   # lightning blue
    'hero_cleric':    (220, 160,  50),   # divine gold
    'hero_druid':     ( 60, 190,  70),   # poison green
    'hero_fighter':   (120,  70, 200),   # void purple
    'hero_monk':      ( 60, 160, 220),   # ki lightning
    'hero':           (220, 160,  50),   # paladin radiant gold
    'hero_ranger':    ( 70, 190,  70),   # nature
    'hero_rogue':     (120,  70, 200),   # shadow void
    'hero_sorcerer':  (220,  70,  20),   # wild fire
    'hero_warlock':   ( 90,  40, 200),   # eldritch purple-blue
    'hero_wizard':    ( 50, 130, 230),   # arcane lightning
}

CLASSES = [
    ('hero_barbarian', 'Barbarian'),
    ('hero_bard',      'Bard'),
    ('hero_cleric',    'Cleric'),
    ('hero_druid',     'Druid'),
    ('hero_fighter',   'Fighter'),
    ('hero_monk',      'Monk'),
    ('hero',           'Paladin'),
    ('hero_ranger',    'Ranger'),
    ('hero_rogue',     'Rogue'),
    ('hero_sorcerer',  'Sorcerer'),
    ('hero_warlock',   'Warlock'),
    ('hero_wizard',    'Wizard'),
]

RACES = [
    ('race_human',      'Human'),
    ('race_elf',        'Elf'),
    ('race_dwarf',      'Dwarf'),
    ('race_halfling',   'Halfling'),
    ('race_gnome',      'Gnome'),
    ('race_halfElf',    'Half-Elf'),
    ('race_halfOrc',    'Half-Orc'),
    ('race_tiefling',   'Tiefling'),
    ('race_dragonborn', 'Dragonborn'),
    ('race_aasimar',    'Aasimar'),
]


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    print('Loading fonts...')
    font_title, font_sub, font_label = best_font([62, 22, 13])

    print('Rendering background...')
    bg   = make_background()
    draw = ImageDraw.Draw(bg)

    # ── Logo ─────────────────────────────────────────────────────────────────
    logo = load_icon(LOGO_SIZE)
    bg.paste(logo, (LOGO_X, LOGO_Y), logo)

    # ── Title ─────────────────────────────────────────────────────────────────
    title = 'ZETA IDLE'
    sub   = 'Dungeons  ·  Gauntlet  ·  Boss Rush  ·  Prestige  ·  Pets  ·  PvP  ·  Endless Depth'

    # Drop shadow
    draw.text((TITLE_X + 2, TITLE_Y + 2), title, font=font_title,
              fill=(0, 0, 0, 200))
    # Gold title
    draw.text((TITLE_X, TITLE_Y), title, font=font_title,
              fill=(212, 175, 55, 255))

    draw.text((TITLE_X, TITLE_Y + 68), sub, font=font_sub,
              fill=(170, 148, 90, 230))

    # Header separator
    draw.line([(0, HEADER_H), (W, HEADER_H)], fill=(60, 48, 28, 180), width=1)

    # ── Class sprites ─────────────────────────────────────────────────────────
    print('Compositing class sprites...')
    for i, (sid, label) in enumerate(CLASSES):
        row  = i // 6
        col  = i  % 6
        cy   = ROW1_Y if row == 0 else ROW2_Y
        cx   = col * CELL_W + (CELL_W - SPRITE_SIZE) // 2

        sprite = load_sprite(sid, SPRITE_SIZE)
        glow   = CLASS_GLOW.get(sid, (150, 150, 180))
        paste_with_glow(bg, sprite, cx, cy, glow, radius=20)

        # Class name label
        lbbox = draw.textbbox((0, 0), label, font=font_label)
        lw    = lbbox[2] - lbbox[0]
        lx    = col * CELL_W + CELL_W // 2 - lw // 2
        ly    = cy + SPRITE_SIZE + 3
        draw.text((lx, ly), label, font=font_label, fill=(160, 138, 90, 210))

    # ── Race strip separator ──────────────────────────────────────────────────
    draw.line([(0, RACE_STRIP_Y - 3), (W, RACE_STRIP_Y - 3)],
              fill=(60, 48, 28, 120), width=1)

    # ── Race icons ────────────────────────────────────────────────────────────
    print('Compositing race icons...')
    for i, (rid, rlabel) in enumerate(RACES):
        try:
            race_img = load_sprite(rid, RACE_SIZE)
        except FileNotFoundError:
            print(f'  WARNING: {rid}.png not found, skipping')
            continue

        rx = i * RACE_CELL_W + (RACE_CELL_W - RACE_SIZE) // 2
        ry = RACE_STRIP_Y

        bg.paste(race_img, (rx, ry), race_img)

        # Race label
        lbbox = draw.textbbox((0, 0), rlabel, font=font_label)
        lw    = lbbox[2] - lbbox[0]
        lx    = i * RACE_CELL_W + RACE_CELL_W // 2 - lw // 2
        ly    = ry + RACE_SIZE + 3
        draw.text((lx, ly), rlabel, font=font_label, fill=(140, 120, 80, 190))

    # ── Save ─────────────────────────────────────────────────────────────────
    final = bg.convert('RGB')
    final.save(OUT_PATH, 'PNG', optimize=True)
    size_kb = os.path.getsize(OUT_PATH) // 1024
    print(f'\nSaved: {OUT_PATH}')
    print(f'Size   : {W}×{H} px,  {size_kb} KB')
    print('Upload to: Google Play Console > Store listing > Feature graphic.')


if __name__ == '__main__':
    main()
