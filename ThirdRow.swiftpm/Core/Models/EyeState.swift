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

    /// The act's refractive error, in dioptres, positive for myopia. It grows
    /// over the term: about half a dioptre in September, nearly three by
    /// December. That growth, not the seat, is what takes the board away.
    @Published var sphericalError: Double = 1.0

    /// Fires a few times a second while squinting, so audio can follow strain
    /// without the model having to know that audio exists.
    var onStrainChange: ((Double) -> Void)?

    private var timer: Timer?
    private var tickCount = 0

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
            strain = min(1.0, strain + dt * 0.055)
            squintedSeconds += dt
            tickCount += 1
            if tickCount % 6 == 0 {
                onStrainChange?(strain)
            }
        } else {
            squint = max(0.0, squint - dt * 3.0)
            strain = max(0.0, strain - dt * 0.012)
        }
    }

    /// 0 = eyes wide open, 1 = lids narrowed to a slit.
    var pupilMM: Double {
        Optics.dilatedPupilMM
            - (Optics.dilatedPupilMM - Optics.squintingPupilMM) * squint
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
    }
}
