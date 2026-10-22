"""Render previews of the proposed board sound so the change can be judged by ear.

This mirrors the DSP that will go into SoundSynth.swift exactly: same noise
generator, same stroke schedule, same one-pole filters. If it sounds wrong
here, it will sound wrong on the phone.

Outputs, into dist/sound-preview/:
  old-chalk.wav   the current continuous hiss, for comparison
  new-near.wav    proposed sound, Row 3 (close to the board)
  new-mid.wav     proposed sound, Row 5
  new-far.wav     proposed sound, Row 7
"""
import math
import os
import struct
import wave

SR = 44100.0
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "dist", "sound-preview")


class Noise:
    """Same xorshift as the Swift version, so previews are representative."""

    def __init__(self):
        self.state = 0x9E3779B97F4A7C15

    def next(self):
        m = (1 << 64) - 1
        s = self.state
        s ^= (s << 13) & m
        s ^= s >> 7
        s ^= (s << 17) & m
        self.state = s
        return (s % 20000) / 10000.0 - 1.0


def write_wav(path, samples):
    peak = max(abs(s) for s in samples) or 1.0
    norm = [s / peak * 0.45 for s in samples]
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(int(SR))
        w.writeframes(b"".join(
            struct.pack("<h", max(-32767, min(32767, int(s * 30000))))
            for s in norm))
    return peak


def old_chalk(seconds=2.4):
    """The current implementation: continuous modulated band noise."""
    n = int(SR * seconds)
    noise = Noise()
    low = high = 0.0
    out = []
    for i in range(n):
        t = i / SR
        raw = noise.next()
        low += (raw - low) * 0.28
        high += (raw - high) * 0.02
        grit = low - high
        stroke = max(0.0, math.sin(2 * math.pi * 1.35 * t + 0.7))
        drift = 0.60 + 0.40 * math.sin(2 * math.pi * 0.41 * t)
        out.append(grit * 0.26 * (0.30 + 0.70 * stroke) * drift)
    return out


def board_writing(distance=0.0, seconds=2.2):
    """Discrete chalk strokes, degraded by distance.

    distance 0 = standing at the board, 1 = the last row.
    """
    n = int(SR * seconds)
    buf = [0.0] * n
    rng = Noise()

    # Irregular stroke schedule. A hand does not keep time.
    t = 0.04
    while t < seconds - 0.18:
        dur = 0.055 + 0.075 * abs(rng.next())
        gain = 0.42 + 0.53 * abs(rng.next())
        start = int(t * SR)
        length = int(dur * SR)
        low = high = 0.0
        for j in range(length):
            if start + j >= n:
                break
            tr = j / SR
            attack = min(1.0, tr / 0.003)
            env = attack * math.exp(-tr * 24.0)
            raw = rng.next()
            low += (raw - low) * 0.42      # keep everything below ~6 kHz
            high += (raw - high) * 0.08    # drop everything below ~1.1 kHz
            buf[start + j] += (low - high) * env * gain
        t += dur + 0.018 + 0.075 * abs(rng.next())

    # Distance: a duller, quieter board. Same filters the Swift side will use.
    alpha = 0.42 - 0.28 * distance
    gain = 1.0 - 0.68 * distance
    lp = 0.0
    out = []
    for s in buf:
        lp += (s - lp) * alpha
        out.append(lp * gain)

    # Fade the very edges so the player cannot click on start or stop.
    f = int(SR * 0.05)
    for i in range(min(f, len(out))):
        g = i / f
        out[i] *= g
        out[-1 - i] *= g
    return out


def main():
    os.makedirs(OUT, exist_ok=True)
    jobs = [
        ("old-chalk.wav", old_chalk()),
        ("new-near.wav", board_writing(0.0)),
        ("new-mid.wav", board_writing(0.42)),
        ("new-far.wav", board_writing(0.85)),
    ]
    for name, samples in jobs:
        path = os.path.join(OUT, name)
        peak = write_wav(path, samples)
        # crude brightness metric: zero crossings per second
        zc = sum(1 for i in range(1, len(samples))
                 if (samples[i - 1] < 0) != (samples[i] < 0))
        dur = len(samples) / SR
        print(f"{name:16s} {dur:4.2f}s  peak={peak:5.3f}  "
              f"zero crossings/s={zc / dur:6.0f}")


if __name__ == "__main__":
    main()
