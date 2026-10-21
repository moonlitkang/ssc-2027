import SwiftUI
import Combine

/// Core mechanic.
/// Holding the screen means squinting: clarity goes up a little, strain goes up a lot.
/// Letting go drops clarity immediately, but strain recovers very slowly.
/// That asymmetry is the whole story.
final class EyeState: ObservableObject {

    @Published var strain: Double = 0
    @Published var squint: Double = 0
    @Published var isHolding: Bool = false
    @Published var squintedSeconds: Double = 0
    @Published var baseClarity: Double = 0.82

    /// Relief per act. Row 3 gives a full 0.35, Row 7 gives almost nothing.
    private var squintGain: Double = 1.0
    private var maxSquint: Double { 0.35 * squintGain }

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
            squint = min(maxSquint, squint + dt * 2.4)
            strain = min(1.0, strain + dt * 0.055)
            squintedSeconds += dt
            tickCount += 1
            if tickCount % 6 == 0 {
                onStrainChange?(strain)
            }
        } else {
            squint = max(0.0, squint - dt * 2.4)
            strain = max(0.0, strain - dt * 0.012)
        }
    }

    var clarity: Double {
        min(1.0, max(0.0, baseClarity + squint - strain * 0.45))
    }

    /// Capped on purpose: past ~11 the words stop being "hard to read" and just vanish.
    var blurRadius: CGFloat {
        CGFloat(max(0.0, 1.0 - clarity) * 11.0)
    }

    func beginSquint() {
        isHolding = true
    }

    func endSquint() {
        isHolding = false
    }

    func reset(baseClarity value: Double, squintGain gain: Double = 1.0) {
        baseClarity = value
        squintGain = gain
        strain = 0
        squint = 0
    }
}
