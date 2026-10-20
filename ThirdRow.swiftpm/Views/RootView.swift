import SwiftUI
import Foundation

private enum Phase {
    case intro
    case stage(Int)
    case reveal
    case recap
}

struct RootView: View {
    @StateObject private var eye = EyeState()
    @State private var phase: Phase

    /// Lets CI jump straight to a beat so each screen can be captured without tapping.
    /// Usage: launch with `-startAt stage1|stage2|stage3|reveal|recap`.
    init() {
        var initial: Phase = .intro
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-startAt"), i + 1 < args.count {
            switch args[i + 1] {
            case "stage1": initial = .stage(0)
            case "stage2": initial = .stage(1)
            case "stage3": initial = .stage(2)
            case "reveal": initial = .reveal
            case "recap": initial = .recap
            default: break
            }
        }
        _phase = State(initialValue: initial)
    }

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
