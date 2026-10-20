"""Grab the desktop (or a region of it) to a PNG. Companion to mouse_ctl.py.

Usage:
    python tools/screen.py out.png
    python tools/screen.py out.png 0 0 1280 800      # crop: x y w h
"""
import sys
from PIL import ImageGrab

out = sys.argv[1] if len(sys.argv) > 1 else "screen.png"
img = ImageGrab.grab()

if len(sys.argv) >= 6:
    x, y, w, h = (int(v) for v in sys.argv[2:6])
    img = img.crop((x, y, x + w, y + h))

if img.width > 1800:
    ratio = 1800 / img.width
    img = img.resize((1800, int(img.height * ratio)))

img.save(out)
print(f"{out}: {img.width}x{img.height}")
