#!/usr/bin/env python3
"""
Polish raw Zeta Idle screenshots into Play Store marketing images.

Workflow:
  1. Run the game in debug mode.
  2. Navigate to each screen you want to feature.
  3. Tap the camera FAB — it saves exported_screenshots/shot_001.png … shot_007.png
  4. Run:  python make_screenshots.py
  5. Upload files from polished_screenshots/ to Google Play Console > Screenshots.

Expected shot order (rename files if you captured them in a different order):
  shot_001  ->  Home / Modes hub
  shot_002  ->  Campaign battle
  shot_003  ->  Dungeon run (room selection)
  shot_004  ->  Gauntlet or Boss Rush
  shot_005  ->  Hero upgrades / stat screen
  shot_006  ->  Pets / Companions screen
  shot_007  ->  Prestige or Ascension screen
"""

import os
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT      = os.path.dirname(os.path.abspath(__file__))
IN_DIR    = os.path.join(ROOT, 'exported_screenshots')
OUT_DIR   = os.path.join(ROOT, 'polished_screenshots')
ICON_PATH = os.path.join(ROOT, 'assets', 'zeta_icon.png')

# ── Slide definitions ─────────────────────────────────────────────────────────
# (filename, headline, tagline, [chip labels])
SLIDES = [
    ('shot_001.png', 'YOUR ADVENTURE AWAITS',
     'Dungeons · Gauntlet · Boss Rush · PvP and more',
     ['12 HERO CLASSES', '5 GAME MODES', 'IDLE + ACTIVE']),

    ('shot_002.png', 'EPIC COMBAT',
     'Turn-based battles powered by D&D mechanics',
     ['D&D MECHANICS', 'ELEMENTAL DAMAGE', '12 ABILITIES']),

    ('shot_003.png', 'DUNGEON RUNS',
     'Roguelite dungeons — every run is unique',
     ['ROGUELITE ROOMS', 'LOCKED CHESTS', 'UNIQUE BOSSES']),

    ('shot_004.png', 'ULTIMATE CHALLENGES',
     'Gauntlet waves, Boss Rush, daily trials',
     ['BOSS RUSH', 'ENDLESS WAVES', 'DAILY TRIALS']),

    ('shot_005.png', 'DEEP HERO BUILDS',
     'Upgrade 6 D&D stats · Choose your subclass',
     ['6 D&D STATS', 'PASSIVE TREE', 'SUBCLASSES']),

    ('shot_006.png', 'PET COMPANIONS',
     'Collect, evolve, and battle alongside your pets',
     ['12 COMPANIONS', 'EVOLVE TWICE', 'PASSIVE BONUSES']),

    ('shot_007.png', 'ENDLESS PROGRESSION',
     'Prestige, Ascend, and grow your legacy forever',
     ['PRESTIGE SYSTEM', 'ASCENSION', 'ENDLESS UPGRADES']),
]

# ── Output canvas (portrait, Play Store safe) ─────────────────────────────────
OUT_W, OUT_H = 1080, 1920
HEADER_H     = 200   # title + icon area
FOOTER_H     = 130   # tagline area
SHOT_H       = OUT_H - HEADER_H - FOOTER_H   # 1590 px for screenshot

# ── Colours ───────────────────────────────────────────────────────────────────
BG_TOP    = (8,  6,  22)
BG_BOTTOM = (22, 8,  40)
GOLD      = (212, 175, 55, 255)
GOLD_DIM  = (170, 140, 60, 220)
WHITE70   = (220, 210, 190, 200)
SEPARATOR = (60,  48,  28, 160)

# ── Chip overlay constants ────────────────────────────────────────────────────
CHIP_STRIP_H   = 130    # height of the dark fade at the bottom of the screenshot
CHIP_PAD_X     = 20     # horizontal inner padding inside each chip
CHIP_PAD_Y     = 10     # vertical inner padding inside each chip
CHIP_GAP       = 16     # gap between chips
CHIP_RADIUS    = 6      # corner radius
CHIP_BG        = (8, 6, 16, 210)       # near-black, semi-opaque
CHIP_BORDER    = (212, 175, 55)        # gold border
CHIP_TEXT      = (240, 210, 100)       # warm gold text
CHIP_SHADOW    = (0, 0, 0, 160)        # drop shadow colour


# ── Helpers ───────────────────────────────────────────────────────────────────

def gradient_bg(w: int, h: int) -> Image.Image:
    img  = Image.new('RGBA', (w, h))
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / h
        r = int(BG_TOP[0] + (BG_BOTTOM[0] - BG_TOP[0]) * t)
        g = int(BG_TOP[1] + (BG_BOTTOM[1] - BG_TOP[1]) * t)
        b = int(BG_TOP[2] + (BG_BOTTOM[2] - BG_TOP[2]) * t)
        draw.line([(0, y), (w, y)], fill=(r, g, b, 255))
    return img


def best_fonts(sizes: list) -> list:
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


def centered_text(draw: ImageDraw.ImageDraw, text: str, font,
                  cx: int, y: int, fill: tuple, shadow: bool = True) -> None:
    bb = draw.textbbox((0, 0), text, font=font)
    tw = bb[2] - bb[0]
    x  = cx - tw // 2
    if shadow:
        draw.text((x + 2, y + 2), text, font=font, fill=(0, 0, 0, 180))
    draw.text((x, y), text, font=font, fill=fill)


def fit_screenshot(shot: Image.Image, target_w: int, target_h: int) -> Image.Image:
    """Scale screenshot to fill target_w x target_h, centred-crop if needed."""
    sw, sh = shot.size
    scale  = max(target_w / sw, target_h / sh)
    nw, nh = int(sw * scale), int(sh * scale)
    shot   = shot.resize((nw, nh), Image.LANCZOS)
    left = (nw - target_w) // 2
    top  = (nh - target_h) // 2
    return shot.crop((left, top, left + target_w, top + target_h))


def add_vignette(img: Image.Image) -> Image.Image:
    """Darken edges of the screenshot so it blends into the dark frame."""
    vign = Image.new('RGBA', img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(vign)
    w, h = img.size
    steps = 40
    for i in range(steps):
        alpha = int(180 * (1 - i / steps) ** 2)
        draw.rectangle([i, i, w - i - 1, h - i - 1],
                       outline=(0, 0, 0, alpha))
    return Image.alpha_composite(img.convert('RGBA'), vign)


def draw_chip_strip(canvas: Image.Image, chips: list,
                    shot_top: int, shot_h: int, chip_font) -> None:
    """
    Composites a dark gradient fade + a row of labelled chip badges
    at the bottom of the screenshot area.
    """
    w       = canvas.width
    fade_y  = shot_top + shot_h - CHIP_STRIP_H

    # ── Dark gradient fade ────────────────────────────────────────────────────
    fade = Image.new('RGBA', (w, CHIP_STRIP_H), (0, 0, 0, 0))
    fd   = ImageDraw.Draw(fade)
    for i in range(CHIP_STRIP_H):
        t     = i / CHIP_STRIP_H
        alpha = int(220 * (t ** 0.5))   # square-root easing: fast-then-slow
        fd.line([(0, i), (w, i)], fill=(0, 0, 0, alpha))
    canvas.alpha_composite(fade, (0, fade_y))

    # ── Measure chip sizes ────────────────────────────────────────────────────
    probe = ImageDraw.Draw(canvas)
    sizes = []
    for label in chips:
        bb = probe.textbbox((0, 0), label, font=chip_font)
        tw, th = bb[2] - bb[0], bb[3] - bb[1]
        sizes.append((tw + CHIP_PAD_X * 2, th + CHIP_PAD_Y * 2, tw, th))

    total_w  = sum(s[0] for s in sizes) + CHIP_GAP * (len(sizes) - 1)
    x        = (w - total_w) // 2
    chip_h   = sizes[0][1]
    # Vertically centre the chips in the lower two-thirds of the strip
    chip_top = fade_y + int(CHIP_STRIP_H * 0.42)

    draw = ImageDraw.Draw(canvas)
    for label, (cw, ch, tw, th) in zip(chips, sizes):
        x1, y1, x2, y2 = x, chip_top, x + cw, chip_top + ch

        # Background pill
        try:
            draw.rounded_rectangle(
                [x1, y1, x2, y2],
                radius=CHIP_RADIUS,
                fill=CHIP_BG,
                outline=CHIP_BORDER,
                width=2,
            )
        except TypeError:
            # Pillow < 8.2: rounded_rectangle doesn't accept outline/width
            draw.rounded_rectangle([x1, y1, x2, y2], radius=CHIP_RADIUS, fill=CHIP_BG)
            draw.rounded_rectangle([x1, y1, x2, y2], radius=CHIP_RADIUS, outline=CHIP_BORDER)

        # Text (shadow then main)
        tx = x1 + (cw - tw) // 2
        ty = y1 + (ch - th) // 2
        draw.text((tx + 1, ty + 1), label, font=chip_font, fill=CHIP_SHADOW)
        draw.text((tx, ty), label, font=chip_font, fill=CHIP_TEXT)

        x += cw + CHIP_GAP


# ── Main ─────────────────────────────────────────────────────────────────────

def process_slide(shot_path: str, headline: str, tagline: str, chips: list,
                  out_path: str, fonts: list, icon: Image.Image) -> None:
    font_title, font_sub, font_tag, font_chip = fonts

    # ── Base canvas ───────────────────────────────────────────────────────────
    canvas = gradient_bg(OUT_W, OUT_H)
    draw   = ImageDraw.Draw(canvas)

    # ── Header (0 ... HEADER_H) ───────────────────────────────────────────────
    cx = OUT_W // 2

    ico = icon.resize((56, 56), Image.LANCZOS)
    canvas.paste(ico, (28, (HEADER_H - 56) // 2), ico)

    centered_text(draw, headline, font_title, cx + 28, 34, GOLD)
    centered_text(draw, 'ZETA IDLE', font_sub, cx + 28, 120, GOLD_DIM, shadow=False)

    draw.line([(0, HEADER_H - 1), (OUT_W, HEADER_H - 1)],
              fill=SEPARATOR[:3] + (SEPARATOR[3],), width=1)

    # ── Screenshot (HEADER_H ... HEADER_H + SHOT_H) ───────────────────────────
    shot = Image.open(shot_path).convert('RGB')
    shot = fit_screenshot(shot, OUT_W, SHOT_H)
    shot = add_vignette(shot)
    canvas.paste(shot, (0, HEADER_H), shot)

    # ── Feature chip overlay ──────────────────────────────────────────────────
    if chips:
        draw_chip_strip(canvas, chips, HEADER_H, SHOT_H, font_chip)

    # ── Separator + footer ────────────────────────────────────────────────────
    sep_y = HEADER_H + SHOT_H
    draw  = ImageDraw.Draw(canvas)   # re-acquire after alpha_composite
    draw.line([(0, sep_y), (OUT_W, sep_y)], fill=SEPARATOR[:3] + (SEPARATOR[3],), width=1)

    tag_cy = sep_y + FOOTER_H // 2 - 10
    centered_text(draw, tagline, font_tag, cx, tag_cy, WHITE70)

    # ── Save ──────────────────────────────────────────────────────────────────
    canvas.convert('RGB').save(out_path, 'PNG', optimize=True)


def main() -> None:
    missing = [s for s, *_ in SLIDES
               if not os.path.exists(os.path.join(IN_DIR, s))]
    if missing:
        print(f'Missing screenshots: {missing}')
        print('Capture them in-game first (dev FAB) then re-run.')
        if len(missing) == len(SLIDES):
            sys.exit(1)
        print('Continuing with available files...\n')

    os.makedirs(OUT_DIR, exist_ok=True)

    print('Loading fonts and icon...')
    fonts = best_fonts([68, 26, 32, 22])   # title / sub / tag / chip
    icon  = Image.open(ICON_PATH).convert('RGBA')

    for i, (filename, headline, tagline, chips) in enumerate(SLIDES, 1):
        src = os.path.join(IN_DIR, filename)
        if not os.path.exists(src):
            print(f'  [{i}/7] SKIP  {filename}  (not found)')
            continue

        out_name = f'screenshot_{i:02d}.png'
        out_path = os.path.join(OUT_DIR, out_name)
        print(f'  [{i}/7] {filename}  ->  {out_name}  |  {headline}')
        process_slide(src, headline, tagline, chips, out_path, fonts, icon)

    count = len([f for f in os.listdir(OUT_DIR) if f.endswith('.png')])
    print(f'\nDone. {count} file(s) in polished_screenshots/')
    print('Upload to: Google Play Console > Store listing > Screenshots')


if __name__ == '__main__':
    main()
