import SwiftUI

struct RecapView: View {
    @ObservedObject var eye: EyeState

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("\(Int(eye.squintedSeconds))")
                .font(.system(size: 76, weight: .semibold, design: .monospaced))
                .foregroundColor(AppTheme.ink)

            Text("seconds of squinting.")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.inkSoft)
                .padding(.bottom, 44)

            Text("Fifteen pairs of glasses\nin a class of fifty.")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(AppTheme.ink)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)

            Text("Mine is one of them.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.inkSoft)

            Spacer()

            Text("I never found out how many of the other\nthirty-five were squinting.")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.bottom, 48)
        }
        .padding(.horizontal, 40)
    }
}
