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

    private var timer: Timer?

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
            squint = min(0.35, squint + dt * 2.4)
            strain = min(1.0, strain + dt * 0.055)
            squintedSeconds += dt
        } else {
            squint = max(0.0, squint - dt * 2.4)
            strain = max(0.0, strain - dt * 0.012)
        }
    }

    var clarity: Double {
        min(1.0, max(0.0, baseClarity + squint - strain * 0.45))
    }

    /// Capped at 18 on purpose: past that the words disappear instead of getting hard.
    var blurRadius: CGFloat {
        CGFloat(max(0.0, 1.0 - clarity) * 18.0)
    }

    func beginSquint() {
        isHolding = true
    }

    func endSquint() {
        isHolding = false
    }

    func reset(baseClarity value: Double) {
        baseClarity = value
        strain = 0
        squint = 0
    }
}
