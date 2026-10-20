import SwiftUI

struct RecapView: View {
    @ObservedObject var eye: EyeState

    var body: some View {
        VStack(spacing: 18) {
            Text("You squinted for \(Int(eye.squintedSeconds)) seconds.")
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(AppTheme.ink)
                .multilineTextAlignment(.center)

            Text("Fifteen pairs of glasses in a class of fifty.")
                .font(.system(size: 17))
                .foregroundColor(AppTheme.inkSoft)

            Text("Mine is one of them.")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(AppTheme.ink)

            Text("I never found out how many of the other thirty-five were squinting.")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding(40)
    }
}
