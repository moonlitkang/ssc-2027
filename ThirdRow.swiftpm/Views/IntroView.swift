import SwiftUI

struct IntroView: View {
    let onStart: () -> Void

    @ObservedObject private var l10n = L10n.shared

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text(l10n.t("Third Row"))
                .font(.system(size: 44, weight: .semibold))
                .foregroundColor(AppTheme.ink)

            Text(l10n.t("Row 7 of 7."))
                .font(.system(size: 17, design: .monospaced))
                .foregroundColor(AppTheme.inkSoft)

            Spacer()

            Text(l10n.t("Hold the board to squint.\nLet go and it gets worse."))
                .font(.system(size: 15))
                .foregroundColor(AppTheme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.bottom, 6)

            Text(l10n.t("About three minutes. Sound on."))
                .font(.system(size: 12))
                .foregroundColor(AppTheme.inkSoft.opacity(0.8))
                .padding(.bottom, 22)

            Button(action: onStart) {
                Text(l10n.t("Sit down"))
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: 360)
                    .padding(.vertical, 14)
                    .background(AppTheme.ink)
                    .foregroundColor(AppTheme.paper)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 52)
    }
}
