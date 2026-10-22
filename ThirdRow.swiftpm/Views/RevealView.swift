import SwiftUI

/// The one moment the whole piece is built around: the blur is taken away in
/// under a second.
///
/// Deliberately the same classroom as the last act — same seat, same rows of
/// heads — so only one thing changes on screen. That is the whole point.
///
/// The second beat is the small line under the problem. It is the only thing
/// the glasses actually buy back, and it is deliberately unremarkable: you do
/// not get your eyesight fixed, you get to read the homework range. Whatever
/// that line says is the player's business, so the app does not comment on it.
struct RevealView: View {
    let onDone: () -> Void

    @ObservedObject private var l10n = L10n.shared

    @State private var blur: CGFloat = 11
    @State private var captionOpacity: Double = 0
    @State private var sceneOpacity: Double = 0
    @State private var noteOpacity: Double = 0
    @State private var closingOpacity: Double = 0

    private var lastAct: Act { Act.last }

    var body: some View {
        VStack(spacing: 0) {
            Text(l10n.t("Then someone handed me a pair of glasses."))
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(AppTheme.inkSoft)
                .multilineTextAlignment(.center)
                .opacity(captionOpacity)
                .padding(.top, 24)
                .padding(.bottom, 18)

            ClassroomScene(act: lastAct, blurRadius: blur)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(sceneOpacity)

            // Two lines share one slot, in order, so the layout never moves.
            ZStack(alignment: .top) {
                Text(l10n.t(lastAct.note))
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .foregroundColor(AppTheme.ink)
                    .opacity(noteOpacity)

                Text(l10n.t("It took less than a second."))
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.inkSoft)
                    .opacity(closingOpacity)
            }
            .frame(minHeight: 24, alignment: .top)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 34)
        .onAppear {
            withAnimation(.easeOut(duration: 0.35)) { sceneOpacity = 1 }
            withAnimation(.easeOut(duration: 0.8).delay(0.6)) { blur = 0 }
            withAnimation(.easeIn(duration: 0.5).delay(0.4)) { captionOpacity = 1 }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                SoundPlayer.shared.chime()
            }

            // Long after the blur has gone, the small line finally reads.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                withAnimation(.easeIn(duration: 0.9)) { noteOpacity = 1 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.6) {
                withAnimation(.easeOut(duration: 0.6)) { noteOpacity = 0 }
                withAnimation(.easeIn(duration: 0.6)) { closingOpacity = 1 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.2) {
                onDone()
            }
        }
    }
}
