import SwiftUI

/// Chalk lettering, drawn one character at a time.
///
/// A single Text view is what makes a board look printed instead of written:
/// every letter sits on the same baseline, at the same angle, at the same
/// weight. Real chalk does not. Each character here gets its own small
/// rotation, offset and opacity, derived from a fixed hash so the wobble stays
/// identical on every redraw instead of shivering.
struct ChalkText: View {
    let text: String
    let size: CGFloat
    var seed: Int = 1
    var weight: Font.Weight = .regular

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, character in
                let w = wobble(at: index)
                Text(String(character))
                    .font(.system(size: size, weight: weight, design: .serif))
                    .foregroundColor(AppTheme.chalk)
                    .shadow(color: AppTheme.chalk.opacity(0.28), radius: 0.9, x: 0.7, y: 0.4)
                    .rotationEffect(.degrees(w.rotation))
                    .offset(x: w.dx, y: w.dy)
                    .opacity(w.opacity)
            }
        }
    }

    private struct Wobble {
        let rotation: Double
        let dx: CGFloat
        let dy: CGFloat
        let opacity: Double
    }

    private func wobble(at index: Int) -> Wobble {
        var h = UInt64(truncatingIfNeeded: seed &* 2_654_435_761 &+ index &* 40_503)
        h ^= h >> 33
        h = h &* 0x2545_F491_4F6C_DD1D
        h ^= h >> 29
        let a = Double(h % 997) / 997.0
        let b = Double((h >> 10) % 991) / 991.0
        let c = Double((h >> 20) % 983) / 983.0
        return Wobble(
            rotation: (a - 0.5) * 3.4,
            dx: (b - 0.5) * size * 0.05,
            dy: (c - 0.5) * size * 0.08,
            opacity: 0.80 + 0.20 * a
        )
    }
}
