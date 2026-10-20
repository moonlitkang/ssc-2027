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
| 2026-10-20 | Project structure | `Package.swift`, folder layout, initial SwiftUI view skeletons | Chose Swift Playgrounds app package over a plain Xcode project; chose iOS 17 deployment target |
| 2026-10-20 | Mechanic | `EyeState` counter loop with strain/squint accumulation | Set the tuning values (squint gain, strain rate, recovery rate) so recovery is much slower than damage |
| 2026-10-20 | Copy | English strings for the three rows and the recap | Replaced generic placeholder text with the author's own numbers and phrasing |

## Note for reviewers

The assistant ran on the author's own machine, with the author reviewing every file before it was committed. No part of this project was generated and submitted unreviewed. The repository history shows the author's own commits and edits.
