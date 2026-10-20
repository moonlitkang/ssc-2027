"""Grab the screen and overlay a labelled coordinate grid, so click targets can be
read off directly in real pixel coordinates (the displayed image may be downscaled).

Usage:
    python tools/grid.py out.png            # grid every 100 px
    python tools/grid.py out.png 200        # grid every 200 px
    python tools/grid.py out.png 200 0 0 1920 400   # crop region first
"""
import sys
from PIL import ImageGrab, ImageDraw, ImageFont

out = sys.argv[1] if len(sys.argv) > 1 else "grid.png"
step = int(sys.argv[2]) if len(sys.argv) > 2 else 100

img = ImageGrab.grab()
ox, oy = 0, 0
if len(sys.argv) >= 7:
    ox, oy, w, h = (int(v) for v in sys.argv[3:7])
    img = img.crop((ox, oy, ox + w, oy + h))

d = ImageDraw.Draw(img)
try:
    font = ImageFont.truetype("arial.ttf", 14)
except Exception:
    font = ImageFont.load_default()

W, H = img.size
for x in range(0, W, step):
    real = ox + x
    major = real % 500 == 0
    d.line([(x, 0), (x, H)], fill=(255, 0, 0) if major else (255, 160, 160), width=2 if major else 1)
    d.text((x + 3, 2), str(real), fill=(200, 0, 0), font=font)
for y in range(0, H, step):
    real = oy + y
    major = real % 500 == 0
    d.line([(0, y), (W, y)], fill=(255, 0, 0) if major else (255, 160, 160), width=2 if major else 1)
    d.text((2, y + 1), str(real), fill=(200, 0, 0), font=font)

if img.width > 1800:
    ratio = 1800 / img.width
    img = img.resize((1800, int(img.height * ratio)))

img.save(out)
print(f"{out}: {img.size}")
