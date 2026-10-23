import SwiftUI

/// One sentence you did not expect, shown after the pencil has already been put
/// down. It runs on its own so nothing can be tapped away before it lands.
///
/// The lines arrive one at a time and then the screen holds. This is the place
/// the whole piece is aiming at, so it is deliberately the slowest moment in
/// it: three and a half seconds was long enough to read, not long enough to
/// feel.
struct InterludeView: View {
    let source: AnswerSource

    /// Test-only. With `-hold` on the command line the screen never advances,
    /// so a capture taken whenever the simulator finally paints is still this
    /// beat. Without it, the four seconds it takes this runner to launch can
    /// swallow the whole six-second window and photograph the next screen.
    var hold: Bool = false

    let onDone: () -> Void

    @ObservedObject private var l10n = L10n.shared

    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var visible = 0

    /// Twenty points reads as a caption on an iPad. This is the one sentence the
    /// whole piece exists to deliver, so on a regular-width screen it grows
    /// rather than floating small in the middle of a lot of paper.
    private var lineSize: CGFloat { sizeClass == .regular ? 27 : 20 }
    private var lineGap: CGFloat { sizeClass == .regular ? 9 : 7 }

    /// Translate first, then split: the table keys are the whole two-line
    /// sentence, not its halves.
    private var lines: [String] {
        l10n.t(source.afterword).components(separatedBy: "\n")
    }

    var body: some View {
        VStack(spacing: 11) {
            Spacer()

            ForEach(lines.indices, id: \.self) { index in
                Text(lines[index])
                    .font(.system(size: lineSize, weight: .medium))
                    .foregroundColor(AppTheme.ink)
                    .multilineTextAlignment(.center)
                    .lineSpacing(lineGap)
                    .opacity(index < visible ? 1 : 0)
            }

            Spacer()
        }
        .padding(.horizontal, 44)
        .animation(.easeIn(duration: 0.8), value: visible)
        .onAppear {
            SoundPlayer.shared.stopStrain()

            for index in lines.indices {
                let delay = 0.25 + 1.35 * Double(index)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    visible = index + 1
                }
            }

            // Read every line, then sit on the last one long enough to hurt.
            let dwell = 0.25 + 1.35 * Double(lines.count) + 3.2
            guard !hold else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + dwell) {
                onDone()
            }
        }
    }
}
