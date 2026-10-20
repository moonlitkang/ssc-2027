"""Find saturated-blue UI buttons on screen and print their bounding boxes.

Removes the guesswork of eyeballing scaled screenshots.

Usage:
    python tools/findbtn.py              # all blue blobs
    python tools/findbtn.py 1400         # only blobs whose centre x > 1400
"""
import sys
from PIL import ImageGrab

img = ImageGrab.grab().convert("RGB")
W, H = img.size
px = img.load()

step = 2
mask = []
for y in range(0, H, step):
    row = []
    for x in range(0, W, step):
        r, g, b = px[x, y]
        row.append(1 if (b > 190 and r < 90 and 60 < g < 170) else 0)
    mask.append(row)

rows, cols = len(mask), len(mask[0])
seen = [[False] * cols for _ in range(rows)]
blobs = []
for y in range(rows):
    for x in range(cols):
        if not mask[y][x] or seen[y][x]:
            continue
        stack = [(x, y)]
        seen[y][x] = True
        xs, ys = [], []
        while stack:
            cx, cy = stack.pop()
            xs.append(cx)
            ys.append(cy)
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = cx + dx, cy + dy
                if 0 <= nx < cols and 0 <= ny < rows and mask[ny][nx] and not seen[ny][nx]:
                    seen[ny][nx] = True
                    stack.append((nx, ny))
        blobs.append((min(xs) * step, min(ys) * step, max(xs) * step, max(ys) * step))

minx = int(sys.argv[1]) if len(sys.argv) > 1 else 0
out = []
for x0, y0, x1, y1 in blobs:
    w, h = x1 - x0, y1 - y0
    if w > 60 and 20 < h < 90 and (x0 + x1) / 2 >= minx:
        out.append((x0, y0, x1, y1, w, h))

out.sort(key=lambda b: (b[1], b[0]))
print(f"screen {W}x{H}, {len(out)} candidate button(s):")
for x0, y0, x1, y1, w, h in out:
    print(f"  box=({x0},{y0})-({x1},{y1})  size={w}x{h}  centre=({(x0+x1)//2},{(y0+y1)//2})")
