import SwiftUI

struct StageView: View {
    @ObservedObject var eye: EyeState
    let act: Act
    let isLast: Bool
    let onNext: () -> Void

    @State private var captionVisible = false

    var body: some View {
        VStack(spacing: 0) {
            Text(act.caption)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(AppTheme.inkSoft)
                .multilineTextAlignment(.center)
                .opacity(captionVisible ? 1 : 0)
                .padding(.top, 22)
                .padding(.bottom, 26)

            BlackboardView(act: act, blurRadius: eye.blurRadius)
                .frame(maxWidth: .infinity)
                .frame(height: 380)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in eye.beginSquint() }
                        .onEnded { _ in eye.endSquint() }
                )

            Spacer(minLength: 16)

            VStack(spacing: 6) {
                StrainBar(value: eye.strain)
                    .frame(height: 12)
                HStack {
                    Text("Eye strain")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.inkSoft)
                    Spacer()
                    Text("Row \(act.row) of 7")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(AppTheme.inkSoft)
                }
            }

            Text("Hold the board to squint.")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.inkSoft)
                .padding(.top, 20)

            Button {
                eye.endSquint()
                onNext()
            } label: {
                Text(isLast ? "Put on your glasses" : "Two weeks later")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(AppTheme.ink)
                    .foregroundColor(AppTheme.paper)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 14)
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 34)
        .onAppear {
            captionVisible = false
            withAnimation(.easeIn(duration: 0.45)) { captionVisible = true }
        }
    }
}
