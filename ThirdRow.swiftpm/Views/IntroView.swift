import SwiftUI

struct IntroView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            Text("Third Row")
                .font(.system(size: 42, weight: .semibold))
                .foregroundColor(AppTheme.ink)

            Text("Row 7 of 7.")
                .font(.system(size: 17, design: .monospaced))
                .foregroundColor(AppTheme.inkSoft)

            Spacer()

            Text("Hold the board to squint.\nLet go and it gets worse.")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.bottom, 24)

            Button(action: onStart) {
                Text("Sit down")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.ink)
                    .foregroundColor(AppTheme.paper)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 56)
    }
}
