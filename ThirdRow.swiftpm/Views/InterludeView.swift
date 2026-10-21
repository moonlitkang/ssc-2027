import SwiftUI

/// One sentence you did not expect, shown after the pencil has already been put
/// down. It runs on its own so nothing can be tapped away before it lands.
struct InterludeView: View {
    let source: AnswerSource
    let onDone: () -> Void

    @State private var opacity = 0.0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(source.afterword)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AppTheme.ink)
                .multilineTextAlignment(.center)
                .lineSpacing(7)
                .opacity(opacity)

            Spacer()
        }
        .padding(.horizontal, 44)
        .onAppear {
            SoundPlayer.shared.stopChalk()
            SoundPlayer.shared.stopStrain()
            withAnimation(.easeIn(duration: 0.7)) { opacity = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) {
                onDone()
            }
        }
    }
}
