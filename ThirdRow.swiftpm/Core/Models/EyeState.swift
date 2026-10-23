import SwiftUI
import Combine

/// Core mechanic.
///
/// Holding the screen means squinting. Squinting does exactly one thing: it
/// narrows the pupil. That is not a metaphor — it is the pinhole, and it is why
/// squinting works at all. Narrowing the pupil shrinks the blur disc on the
/// retina in proportion, which sharpens everything, which is also why it hurts
/// after a while.
///
/// Letting go reopens the pupil immediately, but the strain that the squinting
/// caused is still there, and strain makes the eye a little worse while it
/// lasts. That asymmetry — the relief leaves in a fraction of a second, the cost
/// takes minutes — is the whole story.
final class EyeState: ObservableObject {

    @Published var strain: Double = 0
    @Published var squint: Double = 0
    @Published var isHolding: Bool = false
    @Published var squintedSeconds: Double = 0

    /// How much of the squint is still doing anything. It starts at 1 and
    /// decays while the hold continues, because a slit aperture is not a thing
    /// a face can hold: the muscle tires and the tear film breaks up on a
    /// stare. Without it, holding longer only ever made the board clearer, and
    /// the last act's line about the shapes growing without getting sharper
    /// was describing a screen that did not exist.
    @Published var sustain: Double = 1

    /// The act's refractive error, in dioptres, positive for myopia. It grows
    /// over the term: about half a dioptre in September, nearly three by
    /// December. That growth, not the seat, is what takes the board away.
    @Published var sphericalError: Double = 1.0

    /// Fires a few times a second while squinting, so audio can follow strain
    /// without the model having to know that audio exists.
    var onStrainChange: ((Double) -> Void)?

    /// How long this act's squint lasts before it starts slipping, and what is
    /// left when it has finished slipping. Set from the act on `reset`.
    private var reliefSeconds: Double = .infinity
    private var reliefFloor: Double = 1.0

    private var timer: Timer?
    private var tickCount = 0

    /// Capture builds freeze the clock at the second they were asked for.
    /// Without this the timer keeps running after the beat is set up, so a
    /// thirteen-second frame is photographed at twenty-one seconds and the
    /// number in the file name is a lie.
    private var frozen = false

    /// Seconds squinted *in this act*, which is the number the relief decays
    /// against.
    ///
    /// This used to be "seconds held in the current press", reset the moment
    /// the finger came up, and that made the mechanism self-defeating: press
    /// 0.4 s and release for 0.3 s and the decay never got a chance to run, so
    /// tapping out thirteen seconds left the board at its *clearest* state —
    /// strictly better than holding honestly. It is the accumulated time that
    /// tires an eye, not the length of any one press, and it is also the number
    /// the progress bar already counts.
    private var actSquintedSeconds: Double = 0

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.tick(1.0 / 30.0)
        }
    }

    deinit {
        timer?.invalidate()
    }

    private func tick(_ dt: Double) {
        if frozen { return }
        if isHolding {
            squint = min(1.0, squint + dt * 3.0)
            actSquintedSeconds += dt
            let spent = max(0.0, actSquintedSeconds - reliefSeconds)
            sustain = max(reliefFloor, 1.0 - spent * 0.16)
            strain = min(1.0, strain + dt * 0.055)
            squintedSeconds += dt
            tickCount += 1
            if tickCount % 6 == 0 {
                onStrainChange?(strain)
            }
        } else {
            squint = max(0.0, squint - dt * 3.0)
            // Slow, and it was fast: at 1.5 per second, three-tenths of a
            // second between taps handed back almost half the relief. A face
            // does not recover that quickly either — the tear film needs
            // several seconds to lay itself back down.
            sustain = min(1.0, sustain + dt * 0.15)
            strain = max(0.0, strain - dt * 0.012)
        }
    }

    /// 0 = eyes wide open, 1 = lids narrowed to a slit.
    var pupilMM: Double {
        let relief = squint * sustain
        return Optics.dilatedPupilMM
            - (Optics.dilatedPupilMM - Optics.squintingPupilMM) * relief
    }

    /// What the room is seen through right now.
    ///
    /// The strain term is the small, mean part: a tired ciliary muscle holds
    /// focus slightly too close, which adds a fraction of a dioptre and is why
    /// everything is a little worse at the end of a day than at the start.
    var defocus: Defocus {
        Defocus(sphericalError: sphericalError + strain * 0.35, pupilMM: pupilMM)
    }

    func beginSquint() {
        isHolding = true
    }

    func endSquint() {
        isHolding = false
    }

    func reset(act: Act) {
        sphericalError = act.sphericalError
        reliefSeconds = act.reliefSeconds
        reliefFloor = act.reliefFloor
        strain = 0
        squint = 0
        sustain = 1
        actSquintedSeconds = 0
        frozen = false
    }

    /// Test-only, for the capture build: open an act already squinting, as if
    /// the finger had been down for `seconds`. The squinted state is the one
    /// the whole mechanic lives in, and the only one CI can never reach on its
    /// own, because the gesture has to come from a hand.
    ///
    /// `seconds` matters: at zero this photographs the clearest frame the act
    /// ever shows, and at thirteen it photographs the fog the act ends on.
    /// Photographing only the first one was how the last version got signed off
    /// without anyone having seen what it looks like when the relief is gone.
    func beginSquintForCapture(after seconds: Double) {
        beginSquint()
        squint = 1
        actSquintedSeconds = seconds
        // The progress counter too, so the lines that would have arrived during
        // those seconds are already on screen when the frame is taken.
        squintedSeconds += seconds
        strain = min(1.0, seconds * 0.055)
        sustain = max(reliefFloor, 1.0 - max(0.0, seconds - reliefSeconds) * 0.16)
        frozen = true
    }
}
