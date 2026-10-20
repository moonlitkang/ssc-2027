import SwiftUI

struct StrainBar: View {
    let value: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.ink.opacity(0.13))
                Capsule()
                    .fill(AppTheme.strain)
                    .frame(width: proxy.size.width * CGFloat(min(1.0, max(0.0, value))))
                Capsule()
                    .strokeBorder(AppTheme.ink.opacity(0.10), lineWidth: 0.5)
            }
        }
    }
}
