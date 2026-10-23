# AI Usage Disclosure

Apple's rules for the Swift Student Challenge allow AI-assisted work, but require it to be disclosed in the project documentation. This file is that disclosure. It is written as a running log and updated at every commit that involves AI assistance.

## What "AI assistance" means here

An AI assistant (a large language model used through a coding tool) helped with:

- scaffolding the package structure and boilerplate SwiftUI views
- turning a stated set of mechanic parameters into code
- drafting the English copy and this disclosure file
- reviewing compile errors reported by continuous integration

## What it did not do

- It did not choose the subject. The problem, the classroom, the seven rows, the number of students who wear glasses, and the fact that nobody ever asked, all come from the author's own life.
- It did not design the core interaction. The "hold to squint" mechanic, and the deliberate asymmetry between how fast strain rises and how slowly it recovers, were decided and tuned by the author.
- It did not write the written responses for the submission. Those are written by the author and only reviewed for language.

## Log

| Date | Area | What the AI produced | What the author changed or decided |
|---|---|---|---|
| 2026-10-20 | Project structure | `Package.swift`, folder layout, initial SwiftUI view skeletons | Chose Swift Playgrounds app package over a plain Xcode project. Target later lowered to iOS 16 because the author's own phone runs 16.7 and has to be able to sideload the build |
| 2026-10-20 | Mechanic | `EyeState` counter loop with strain/squint accumulation | Set the tuning values (squint gain, strain rate, recovery rate) so recovery is much slower than damage |
| 2026-10-20 | Copy | English strings for the three rows and the recap | Replaced generic placeholder text with the author's own numbers and phrasing |
| 2026-10-21 | Classroom | Rewrote `ClassroomScene`: skirting board, ceiling tubes, wall timetable, thicker desk legs, shoulders on the silhouettes, `ChalkText` for letter-by-letter chalk wobble | Rejected the first drawn classroom as a wireframe. Wrote the rule that nothing floats and the floor line, skirting and desk legs must agree |
| 2026-10-21 | Sound | `SoundSynth` generates four WAV buffers in code (chalk, strain tone, chime, thud); `SoundPlayer` wraps AVAudioPlayer | Decided against shipping any audio files at all, so the package stays tiny and fully offline. Chose to make strain audible only while squinting |
| 2026-10-21 | Copy scene | `PencilCanvas` (PKCanvasView wrapper) and `CopyView` | Decided this scene must have no squint gesture, because by row 7 squinting has already failed on screen |
| 2026-10-21 | Script | Suggested wording for the row 7 hint and the ending | Supplied the real event the scene is built on: a maths lesson, an equation he could not read, squinting until his eyes hurt, then asking the boy next to him |
| 2026-10-21 | Mechanic | `Act.squintGain` scaling relief per row (1.0 / 0.72 / 0.38) | Decided that squinting should stop working in the last row rather than merely weaken. **This row is superseded on 2026-10-23**: the per-row gain was replaced by an aperture model, after the author rejected a curve that was tuned rather than derived |
| 2026-10-21 | Script | Three routes for "ask someone", a second round of asking, and the two closing lines | Approved the reversal that the first answer was itself copied from someone else, and that no route is allowed to produce a readable board |
| 2026-10-22 | Sound | Two one-shot breath buffers (intake, release) wired to the press and the lift | Asked for breathing, and rejected it as background ambience — it had to be tied to the gesture, not laid under the scene |
| 2026-10-22 | Copy scene | `RevealView` renders the player's own `PKDrawing` as a card at the end | Rejected an earlier version in which writing the answer down changed nothing. Demanded the page come back later, because otherwise the act was decoration |
| 2026-10-22 | Ending | Converted the measured squint seconds into hours per school year (6 lessons × 5 days × 40 weeks), plus the national figure with its source | Supplied the closing argument that the room, not the eyes, was built wrong. Line left in after review, flagged as the only editorial claim in the piece |
| 2026-10-22 | Language | `L10n` table of 50 strings and the corner switch | Set the rule that English stays the default for judges and Chinese is an explicit choice, never a response to device locale |
| 2026-10-23 | Layout | `pageWidth()` capping the text-only screens at 560 points; recap spacing | Found the iPad layout unacceptable after seeing real screenshots: three buttons stretched across the whole screen and an ending spread over 800 points of paper |
| 2026-10-23 | Mechanic | `Optics`: pupil diameter, refractive error in dioptres, per-surface distances, and the `max(0, S − 1/d)` accommodation floor | Requested a technical core that is derived rather than tuned, after the author set the goal of a higher placing. Reviewed and kept the `max(0, …)` after it corrected a first version in which a near-sighted eye could not read its own desk |
| 2026-10-23 | Mechanic | A second pass after an independent review found the first one half-applied: relief now expires on its own (`Act.reliefSeconds`), decays against the seconds squinted in the act rather than the current press, and the slit pupil was widened to 2.4 mm | Kept the finding that tapping beat holding, and the finding that the copy scene's board was clearer than the board it was copied from. Approved changing the last act's equation, which was the single biggest reason it stayed readable — a string read twice is read the third time from memory |
| 2026-10-23 | Script | New wording where the screen no longer matched the sentence: September's hint stops promising a change half a dioptre cannot produce, October's first line no longer depends on the question repeating | Wrote the rule that a line is allowed to be quiet but not to describe a screen nobody is looking at |
| 2026-10-23 | Mechanic | The seat became a real variable: `Act.boardDistance` at 3.5 / 5.0 / 6.5 m, replacing the single constant that made all three acts the same distance | Chose to make the model honest rather than make the title true. The measurement says moving from the last row to the third is worth 5.1% of blur, so the piece now says that instead of implying the seat is the cause — and December's line about the front row going to someone else is the author's, from what actually happens to seats in a class of fifty |
| 2026-10-23 | Copy scene | The first page is kept rather than the last | Found that overwriting it meant the ending handed back the copy of a second opinion, when the whole reason for asking twice is that the first answer was already second-hand |
| 2026-10-23 | Measurement | `InkMetrics` converts points to centimetres at 132 per inch instead of 72 | Corrected a unit error of 83% in the one number the piece claims to have measured rather than written |
| 2026-10-23 | Measurement | Pause detection: the gaps between stroke timestamps longer than 0.8 s, reported on the ending card as "your pencil stopped N times" | Asked for the piece to take a real signal in rather than only render one out. Chose the pause over any other derived quantity because it is the only one the player cannot fake: a length can be scribbled, a stop cannot |

## Note for reviewers

The assistant ran on the author's own machine, with the author reviewing every file before it was committed. No part of this project was generated and submitted unreviewed. The repository history shows the author's own commits and edits.
