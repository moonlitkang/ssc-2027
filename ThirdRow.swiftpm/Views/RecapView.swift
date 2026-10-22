import SwiftUI

/// The ending is deliberately two facts and a question, in that order.
///
/// The numbers are the author's own class, not a national statistic: fifty
/// students, fifteen pairs of glasses. The last two lines have to hold for
/// every route the player could have taken — classmate, front row, teacher, in
/// either order — so they say the one thing that was true in all of them:
/// nobody in that room got it off the board.
struct RecapView: View {
    @ObservedObject var eye: EyeState

    @State private var numberVisible = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)

            Text("\(Int(eye.squintedSeconds))")
                .font(.system(size: 78, weight: .semibold, design: .monospaced))
                .foregroundColor(AppTheme.ink)
                .opacity(numberVisible ? 1 : 0)

            Text("seconds of squinting.")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.inkSoft)
                .opacity(numberVisible ? 1 : 0)
                .padding(.bottom, 40)

            Text("Fifteen pairs of glasses\nin a class of fifty.")
                .font(.system(size: 23, weight: .medium))
                .foregroundColor(AppTheme.ink)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)

            Text("Mine is one of them.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.inkSoft)

            Spacer(minLength: 20)

            VStack(spacing: 6) {
                Text("Nobody read it off the board.")
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.ink)
                    .multilineTextAlignment(.center)

                Text("We all read it off each other.")
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.inkSoft)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 44)
        }
        .padding(.horizontal, 40)
        .onAppear {
            SoundPlayer.shared.stopStrain()
            SoundPlayer.shared.thud()
            withAnimation(.easeIn(duration: 0.7).delay(0.2)) { numberVisible = true }
        }
    }
}
