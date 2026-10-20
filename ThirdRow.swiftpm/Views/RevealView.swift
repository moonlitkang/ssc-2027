import SwiftUI

/// The one moment the whole piece is built around: the blur is taken away in under a second.
///
/// Deliberately the same classroom as the last act — same seat, same rows of heads —
/// so only one thing changes on screen. That is the whole point.
struct RevealView: View {
    let onDone: () -> Void

    @State private var blur: CGFloat = 11
    @State private var captionOpacity: Double = 0
    @State private var sceneOpacity: Double = 0

    private var lastAct: Act {
        Act.all[Act.all.count - 1]
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Then someone handed me a pair of glasses.")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(AppTheme.inkSoft)
                .multilineTextAlignment(.center)
                .opacity(captionOpacity)
                .padding(.top, 26)
                .padding(.bottom, 22)

            ClassroomScene(act: lastAct, blurRadius: blur)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(sceneOpacity)

            Text("It took less than a second.")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.inkSoft)
                .opacity(captionOpacity)
                .padding(.top, 22)
                .padding(.bottom, 34)
        }
        .padding(.horizontal, 34)
        .onAppear {
            withAnimation(.easeOut(duration: 0.35)) { sceneOpacity = 1 }
            withAnimation(.easeOut(duration: 0.8).delay(0.6)) { blur = 0 }
            withAnimation(.easeIn(duration: 0.5).delay(0.4)) { captionOpacity = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                onDone()
            }
        }
    }
}
