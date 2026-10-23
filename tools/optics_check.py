#!/usr/bin/env python3
"""Reproduce the Swift optics model in Python so a parameter change can be
checked against the legibility thresholds before it costs a CI run.

Everything here mirrors ThirdRow.swiftpm/Core/Models/Optics.swift and
EyeState.swift line for line. If those files change, this has to change too.
"""
import sys

PPRAD = 766 / (2 * 0.35)
DILATED = 5.0
SQUINT = 2.4
BOARD = 6.0


def radius(pupil_mm, s):
    defocus = max(0.0, s - 1.0 / BOARD)
    return (pupil_mm / 1000.0) * defocus * PPRAD / 2


def pupil(relief):
    return DILATED - (DILATED - SQUINT) * relief


def sim(hold_seconds, start, rate, floor, s_error, strain_rate=0.055):
    """Integrate the same tick() the app runs, at 30 Hz."""
    dt = 1.0 / 30.0
    spent = 0.0
    sustain = 1.0
    strain = 0.0
    t = 0.0
    out = []
    marks = [0.3, 1.5, 2.0, 3.25, 5.0, 6.5, 7.0, 9.0, 13.0]
    mi = 0
    while t < hold_seconds:
        spent += dt
        sustain = max(floor, 1.0 - max(0.0, spent - start) * rate)
        strain = min(1.0, strain + dt * strain_rate)
        t += dt
        if mi < len(marks) and t >= marks[mi]:
            out.append((marks[mi], sustain, strain, pupil(sustain),
                        radius(pupil(sustain), s_error + strain * 0.35)))
            mi += 1
    return out


def table(title, start, rate, floor, s_error, font, note_scale=0.32, label=""):
    print(f"\n{title}  (relief for {start}s, then {rate}/s down to {floor}, S={s_error})")
    print(f"{'t':>6} {'sustain':>8} {'strain':>7} {'pupil':>6} {'r':>6} {'r/problem':>10} {'r/note':>8}")
    for t, sus, st, p, r in sim(13.0, start, rate, floor, s_error):
        print(f"{t:6.2f} {sus:8.3f} {st:7.3f} {p:6.3f} {r:6.3f} {r/font:10.3f} {r/(font*note_scale):8.3f}")
    print(f"  {label}")


def rest(act_s, font, note_scale=0.32):
    r = radius(DILATED, act_s)
    return r, r / font, r / (font * note_scale)


if __name__ == "__main__":
    print("=== resting states (no squint) ===")
    print(f"{'act':>6} {'S':>5} {'r':>6} {'r/font':>8} {'r/note':>8}")
    for name, s, font in [("row3", 0.50, 40), ("row5", 1.50, 31), ("row7", 2.75, 20)]:
        r, a, b = rest(s, font)
        print(f"{name:>6} {s:5.2f} {r:6.3f} {a:8.3f} {b:8.3f}")

    print("\n=== legibility bands ===")
    print("  < 0.13  sharp      0.13-0.22  the boundary      0.22-0.35  gone      >0.35 fog")
    print("  remembered strings read at ~0.25 because memory fills the gaps")

    table("OLD sustain (4s relief, 0.09/s, floor .55)", 4.0, 0.09, 0.55, 2.75, 20,
          label="row7 at rest is 0.353; row5 at rest is 0.118 (the legibility anchor)")
    table("NEW sustain (1.5s relief, 0.16/s, floor .42)", 1.5, 0.16, 0.42, 2.75, 20,
          label="row7 at rest is 0.353; row5 at rest is 0.118")

    print("\n=== act 2 must stay readable while squinting ===")
    table("act 2 (relief for 6s, floor .72, S=1.50)", 6.0, 0.16, 0.72, 1.50, 31,
          label="its line says the problem is still there and the small line is not")

    print("\n=== tapping instead of holding (0.4s down / 0.3s up) ===")
    # OLD decayed against `heldFor`, the length of the *current* press, and
    # refilled at 1.5/s on release. A 0.4 s press never reached the 4 s delay,
    # so tapping kept sustain pinned at 1.0 forever — the board stayed at its
    # clearest state while the progress counter ran to thirteen.
    sustain, held, t = 1.0, 0.0, 0.0
    dt, cycle = 1.0 / 30.0, 0.0
    while t < 13.0:
        cycle += dt
        t += dt
        if cycle < 0.4:
            held += dt
            sustain = max(0.55, 1.0 - max(0.0, held - 4.0) * 0.09)
        else:
            held = 0.0
            sustain = min(1.0, sustain + dt * 1.5)
            if cycle > 0.7:
                cycle = 0.0
    r = radius(pupil(sustain), 2.75 + min(1.0, 5.2 * 0.055) * 0.35)
    print(f"  OLD: after 13 s of tapping, sustain={sustain:.3f} r/font={r/20:.3f} "
          f"(honest hold gives 0.277)")

    # NEW decays against the accumulated seconds and refills at 0.15/s, so the
    # duty cycle no longer buys anything: 0.4 s on / 0.3 s off reaches the same
    # floor as holding straight through.
    sustain, spent, t = 1.0, 0.0, 0.0
    cycle = 0.0
    while t < 13.0:
        cycle += dt
        t += dt
        if cycle < 0.4:
            spent += dt
            sustain = max(0.42, 1.0 - max(0.0, spent - 1.5) * 0.16)
        else:
            sustain = min(1.0, sustain + dt * 0.15)
            if cycle > 0.7:
                cycle = 0.0
    r = radius(pupil(sustain), 2.75 + min(1.0, 5.2 * 0.055) * 0.35)
    print(f"  NEW: after 13 s of tapping, sustain={sustain:.3f} r/font={r/20:.3f} "
          f"(honest hold gives 0.303)")
