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
    let onDone: () -> Void

    @State private var visible = 0

    private var lines: [String] {
        source.afterword.components(separatedBy: "\n")
    }

    var body: some View {
        VStack(spacing: 11) {
            Spacer()

            ForEach(lines.indices, id: \.self) { index in
                Text(lines[index])
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppTheme.ink)
                    .multilineTextAlignment(.center)
                    .lineSpacing(7)
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

            let hold = 0.25 + 1.35 * Double(lines.count) + 3.2
            DispatchQueue.main.asyncAfter(deadline: .now() + hold) {
                onDone()
            }
        }
    }
}
