import SwiftUI

struct RootView: View {
    @StateObject private var eye = EyeState()
    @State private var index: Int = 0

    private var isRecap: Bool {
        index >= Act.all.count
    }

    private var act: Act {
        Act.all[min(index, Act.all.count - 1)]
    }

    var body: some View {
        ZStack {
            AppTheme.paper.ignoresSafeArea()

            if isRecap {
                RecapView(eye: eye)
            } else {
                stage
            }
        }
        .onChange(of: index) { _ in
            if index < Act.all.count {
                eye.reset(baseClarity: act.baseClarity)
            }
        }
    }

    private var stage: some View {
        VStack(spacing: 26) {
            Text(act.caption)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(AppTheme.inkSoft)
                .multilineTextAlignment(.center)

            BlackboardView(act: act, blurRadius: eye.blurRadius)
                .frame(height: 240)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in eye.beginSquint() }
                        .onEnded { _ in eye.endSquint() }
                )

            StrainBar(value: eye.strain)
                .frame(height: 8)

            Text("Hold the board to squint.")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.inkSoft)

            Button {
                eye.endSquint()
                index += 1
            } label: {
                Text(index == Act.all.count - 1 ? "Look away" : "Next seat")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.ink)
                    .foregroundColor(AppTheme.paper)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(32)
    }
}
