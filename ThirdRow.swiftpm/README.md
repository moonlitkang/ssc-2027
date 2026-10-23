# Third Row

An app playground for the Swift Student Challenge 2027.

## The idea

My classroom has seven rows. I sit in the last one.

In September, in row 3, I could read the board. By October, from row 5, the same
equation took the whole lesson to decipher. By December, from row 7, I was
squinting as hard as I could and it had stopped helping, so I asked the boy next
to me to read it out loud, and I copied down an answer I had no way to check.

That is the piece: not the blur itself, but the workaround. Squinting works for a
while, and it costs more than it gives.

## Interaction

About three minutes, in four movements:

1. **Row 3, September** — hold the board and nothing happens, because at half a
   dioptre there is nothing to press away. This act teaches the gesture, not the
   relief; the line above the button is the only thing that has to change, and
   it says so. Honest, and it is why the next act lands.
2. **Row 5, October** — the problem comes back into focus, the line under it does
   not. The note is chalked smaller, so the same blur swallows it first. That is
   the real first loss in myopia: detail goes before subject.
3. **Row 7, December** — squinting gives back about half of a blur that is now
   nearly three dioptres wide, and it gives it back for a second and a half
   before the muscle and the tear film give up. The question is a different one
   this month, so the answer cannot be remembered off the board. The way out
   appears only after thirteen seconds of actually looking.
4. **Ask** — you ask someone, twice, because the first answer turns out to be a
   copy of a copy.
5. **Copy** — they read it out loud and you write it down with a pencil. The board
   stays out of focus, so there is nothing to check your copying against.
6. **Glasses** — the prescription is taken away in under a second, and the small
   line you never read finally arrives. So does your own page, rendered from the
   strokes you actually drew.
7. **Recap** — the seconds you spent squinting, converted into a school year, and
   three lines that move the blame off your eyes and onto the room.

## The mechanic is optics, not a blur slider

`Core/Models/Optics.swift` computes how much each surface is out of focus. It is
two lines of textbook optics:

```
θ = pupil diameter × defocus        (radians, pupil in metres)
defocus = max(0, S − 1/distance)    (dioptres)
```

`S` is the act's refractive error: +0.50 D in September, +1.50 D in October,
+2.75 D in December. Those are ordinary childhood myopia values, and they are the
only per-act numbers that were chosen. Everything else is derived.

Two consequences the old hand-tuned version could not produce:

- **Distance matters.** The board is six metres away, the teacher's desk three,
  the heads in front of you one and eight, your own desk forty-five centimetres.
  Every one gets its own blur radius in the same frame. At row 7 the whole front
  of the room goes soft while the page under your hand stays readable.
- **Only things past the far point blur.** A short-sighted eye can always add
  power to focus on something near; what it cannot do is relax. The `max(0, …)`
  is that fact, and without it the model would claim a −0.5 D eye cannot read the
  paper in front of it, which is backwards.

Squinting narrows the pupil from 5.0 mm to 2.4 mm. Not 1.8: a slit is a worse
stop than its gap suggests — diffraction off both lids, and a pupil only partly
covered — and at 1.8 the relief was strong enough that row seven, squinted, came
out as legible as row five is at rest. That number is the difference between the
last act working and quietly contradicting itself.

So squinting relieves *every* row by the same fraction, about 52% of the blur,
everywhere. It stops working at row 7 not because it becomes weaker but because
half of 7 points is still 3.4 points of blur against 20-point chalk. No
difficulty curve was written; the geometry does it.

Two more things the model needed, both discovered by testing it rather than by
reasoning about it:

- **Relief runs out.** A slit is held by a muscle. `Act.reliefSeconds` is how
  long the press actually does anything, and it is short exactly where the
  defocus is large: September's is `.infinity` because half a dioptre needs no
  press at all, October's lasts six seconds, December's is over in one and a
  half. Without this, holding longer only ever made the board clearer, and the
  line "they don't get sharper" was describing a screen that did not exist.
- **It is the accumulated time that tires an eye**, not the length of any one
  press. The first version decayed against the current press and refilled on
  release, which made tapping strictly better than holding: 0.4 s down and 0.3 s
  up kept the relief pinned at full for thirteen seconds. The decay now counts
  the seconds squinted in the act — the same number the progress bar counts — so
  a duty cycle buys nothing.

Strain adds a small amount of defocus on top, and decays far more slowly than it
accumulates, which is why letting go leaves you worse off than not having tried.

## Sound

Every sound is synthesised at launch from maths in `SoundSynth.swift`: chalk on a
board, the intake and release of a breath tied to the gesture, low pressure while
squinting, a metal chime when the glasses arrive, a soft hit when a month passes.
Nothing is bundled, nothing is downloaded, and the package grows by zero bytes.

The speaker icon in the strain row mutes it.

## Language

English is the default and stays the default — the judges are not reading Chinese.
A capsule in the top-right corner switches to Chinese for anyone here who wants it;
the choice is remembered. Every string lives in `Core/Models/L10n.swift`, and
`tools/check_l10n.py` fails the build checks if a key is missing, because a missing
key falls back to English silently.

## Screens

Captured automatically on every build by `.github/workflows/build.yml`, which jumps
straight to a beat with `-startAt` and freezes the self-advancing ones with `-hold`.

## Structure

```
ThirdRow.swiftpm/
  Package.swift            Swift Playgrounds app manifest
  ThirdRowApp.swift        entry point
  Core/Models/             Optics (defocus), EyeState (pupil and strain),
                           Act (per-month config), AnswerSource, L10n
  Views/                   RootView, IntroView, StageView, AskView, CopyView,
                           PencilCanvas, InterludeView, ClassroomScene,
                           RevealView, RecapView, StrainBar
  Utilities/               AppTheme, ChalkText, SoundSynth, SoundPlayer
```

## Two rules in the classroom

`ClassroomScene` is a first-person view from the seat. Two things must stay true
when editing it:

- **The number of desk rows between you and the board grows with the act** (row 3
  → one row of heads in front, row 7 → three). The seat change is shown, never
  narrated.
- **Nothing is blurred by eye.** Every blur radius in the file comes from
  `Optics`. If a surface is sharp, it is because it is nearer than the far point,
  not because it looked better that way.

A third rule, added after the first version: nothing floats. The floor line, the
skirting board and the teacher's desk legs all agree on where the ground is.

## Running it

Open `ThirdRow.swiftpm` in Swift Playgrounds 4.6 (iPad) or Xcode 26. No network
access is required and there are no external dependencies. iOS 16 or later; it is
built and screenshotted on a simulator on every push.

## Credits

All visuals are drawn in code. Every sound is generated in code. No third-party
assets, no third-party packages.

## AI disclosure

See `AI_USAGE.md`.
