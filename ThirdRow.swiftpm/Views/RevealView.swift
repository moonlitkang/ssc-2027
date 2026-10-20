import SwiftUI

/// The one moment the whole piece is built around: the blur is taken away in under a second.
struct RevealView: View {
    let onDone: () -> Void

    @State private var blur: CGFloat = 13
    @State private var captionOpacity: Double = 0
    @State private var boardOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Text("Then someone handed me a pair of glasses.")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(AppTheme.inkSoft)
                .multilineTextAlignment(.center)
                .opacity(captionOpacity)
                .padding(.top, 26)
                .padding(.bottom, 22)

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.board)

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Rectangle()
                        .fill(AppTheme.chalk.opacity(0.06))
                        .frame(height: 18)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))

                Text("SOLVE FOR X")
                    .font(.system(size: 46, weight: .medium, design: .monospaced))
                    .foregroundColor(AppTheme.chalk)
                    .blur(radius: blur)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(boardOpacity)

            Text("It took less than a second.")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.inkSoft)
                .opacity(captionOpacity)
                .padding(.top, 22)
                .padding(.bottom, 34)
        }
        .padding(.horizontal, 36)
        .onAppear {
            withAnimation(.easeOut(duration: 0.35)) { boardOpacity = 1 }
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) { blur = 0 }
            withAnimation(.easeIn(duration: 0.5).delay(0.4)) { captionOpacity = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                onDone()
            }
        }
    }
}
