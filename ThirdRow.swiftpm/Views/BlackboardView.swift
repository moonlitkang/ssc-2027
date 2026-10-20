import SwiftUI

struct BlackboardView: View {
    let act: Act
    let blurRadius: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(AppTheme.board)

            VStack(spacing: 0) {
                Spacer(minLength: 0)
                Rectangle()
                    .fill(AppTheme.chalk.opacity(0.06))
                    .frame(height: 16)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(act.words)
                .font(.system(size: act.fontSize, weight: .medium, design: .monospaced))
                .foregroundColor(AppTheme.chalk)
                .blur(radius: blurRadius)
        }
    }
}
