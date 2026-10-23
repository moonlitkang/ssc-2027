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
    /// stare. This is why the last act can say "you try again, your eyes water,
    /// you stop" and be describing the actual screen — without it, holding
    /// longer only ever made the board clearer.
    @Published var sustain: Double = 1

    /// The act's refractive error, in dioptres, positive for myopia. It grows
    /// over the term: about half a dioptre in September, nearly three by
    /// December. That growth, not the seat, is what takes the board away.
    @Published var sphericalError: Double = 1.0

    /// Fires a few times a second while squinting, so audio can follow strain
    /// without the model having to know that audio exists.
    var onStrainChange: ((Double) -> Void)?

    private var timer: Timer?
    private var tickCount = 0
    private var heldFor: Double = 0

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.tick(1.0 / 30.0)
        }
    }

    deinit {
        timer?.invalidate()
    }

    private func tick(_ dt: Double) {
        if isHolding {
            squint = min(1.0, squint + dt * 3.0)
            heldFor += dt
            // Four seconds of real relief, then it starts slipping away.
            sustain = max(0.55, 1.0 - max(0.0, heldFor - 4.0) * 0.09)
            strain = min(1.0, strain + dt * 0.055)
            squintedSeconds += dt
            tickCount += 1
            if tickCount % 6 == 0 {
                onStrainChange?(strain)
            }
        } else {
            squint = max(0.0, squint - dt * 3.0)
            heldFor = 0
            sustain = min(1.0, sustain + dt * 1.5)
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

    func reset(sphericalError value: Double) {
        sphericalError = value
        strain = 0
        squint = 0
        sustain = 1
        heldFor = 0
    }

    /// Test-only, for the capture build: start an act already holding, so the
    /// squinted state can be photographed. It is the one state the core
    /// mechanic lives in and the only one CI could never reach, because the
    /// gesture has to come from a finger.
    func beginSquintForCapture() {
        beginSquint()
        squint = 1
        heldFor = 0
        sustain = 1
    }
}
