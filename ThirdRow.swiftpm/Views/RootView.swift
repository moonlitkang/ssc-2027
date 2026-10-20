import SwiftUI

private enum Phase {
    case intro
    case stage(Int)
    case reveal
    case recap
}

struct RootView: View {
    @StateObject private var eye = EyeState()
    @State private var phase: Phase = .intro

    var body: some View {
        ZStack {
            AppTheme.paper.ignoresSafeArea()

            switch phase {
            case .intro:
                IntroView {
                    phase = .stage(0)
                }

            case .stage(let index):
                StageView(
                    eye: eye,
                    act: Act.all[index],
                    isLast: index == Act.all.count - 1
                ) {
                    if index + 1 < Act.all.count {
                        phase = .stage(index + 1)
                    } else {
                        phase = .reveal
                    }
                }
                .onAppear {
                    eye.reset(baseClarity: Act.all[index].baseClarity)
                }

            case .reveal:
                RevealView {
                    phase = .recap
                }

            case .recap:
                RecapView(eye: eye)
            }
        }
    }
}
