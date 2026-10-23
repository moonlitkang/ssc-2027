import SwiftUI
import Foundation
import PencilKit

private enum Phase {
    case intro
    case stage(Int)
    case ask
    case copy(AnswerSource)
    case interlude(AnswerSource)
    case reveal
    case recap
}

struct RootView: View {
    @StateObject private var eye = EyeState()
    @ObservedObject private var l10n = L10n.shared
    @State private var phase: Phase

    /// How many people you end up asking. Two is the honest number: the first
    /// answer turns out to be second-hand, so you try once more, and the second
    /// answer is no better. Raising this lengthens the middle of the piece by
    /// roughly half a minute per extra person.
    private let askRounds = 2

    /// Who has already been asked, so the same door is not offered twice.
    @State private var asked: Set<AnswerSource> = []

    /// The page the player actually wrote on. Shown again, sharp, at the end.
    @State private var written: PKDrawing?

    /// Counted off the drawing the moment it is handed over, so the ending can
    /// report something the player actually did.
    @State private var ink = InkMetrics.empty

    /// Lets CI jump straight to a beat so each screen can be captured without tapping.
    /// Usage: launch with `-startAt stage1|stage2|stage3|ask|ask2|copy|interlude|reveal|recap`.
    /// Add `-hold` alongside it to keep a self-advancing beat on screen.
    /// Add `-squintFor <seconds>` to open the act already squinting for that
    /// long, which is the only way to photograph the state the mechanic lives
    /// in — and the only way to see what the relief looks like once it is gone.
    init() {
        var initial: Phase = .intro
        let args = ProcessInfo.processInfo.arguments
        freezeForCapture = args.contains("-hold")
        var squintFromStart: Double?
        if let i = args.firstIndex(of: "-startAt"), i + 1 < args.count {
            switch args[i + 1] {
            case "stage1": initial = .stage(0)
            case "stage2": initial = .stage(1)
            case "stage3": initial = .stage(2)
            // The state the whole mechanic lives in, and the only one a finger
            // was ever needed for. Captured holding, so it can be looked at.
            case "stage3squint": initial = .stage(2); squintFromStart = 0.3
            // Thirteen seconds in: the relief has bottomed out. Without this
            // beat the act was signed off on the strength of its clearest frame.
            case "stage3fog": initial = .stage(2); squintFromStart = 13.0
            case "ask", "ask2": initial = .ask
            case "copy": initial = .copy(.classmate)
            case "interlude": initial = .interlude(.classmate)
            case "reveal": initial = .reveal
            case "recap": initial = .recap
            default: break
            }
        }
        if let j = args.firstIndex(of: "-squintFor"),
           j + 1 < args.count,
           let seconds = Double(args[j + 1]) {
            squintFromStart = seconds
        }
        // Capture only. The ending has three measured lines and two of them
        // come from a drawing, which a screenshot run cannot make — so without
        // this the only way to see them is to play the piece by hand and
        // screenshot the last screen yourself. The numbers are deliberately
        // plausible rather than round, so a layout that only fits a two-digit
        // count does not pass.
        captureInk = args.contains("-ink")
            ? InkMetrics(strokes: 7, lengthCM: 24, pauses: 5, pauseSeconds: 9.4)
            : nil
        startsSquinting = squintFromStart
        _phase = State(initialValue: initial)
    }

    /// Set by `-hold`. Only the two beats that advance themselves look at it.
    private var freezeForCapture: Bool

    /// Set by the `stage3squint` / `stage3fog` beats, or by `-squintFor`.
    private var startsSquinting: Double?

    /// Set by `-ink`. Stands in for a drawing the screenshot run cannot make.
    private var captureInk: InkMetrics?

    var body: some View {
        ZStack {
            AppTheme.paper.ignoresSafeArea()

            switch phase {
            case .intro:
                IntroView {
                    SoundPlayer.shared.thud()
                    asked = []
                    phase = .stage(0)
                }
                .pageWidth()

            case .stage(let index):
                StageView(
                    eye: eye,
                    act: Act.all[index],
                    startsSquinting: startsSquinting
                ) {
                    if index + 1 < Act.all.count {
                        phase = .stage(index + 1)
                    } else {
                        phase = .ask
                    }
                }
                // The eye is reset by StageView itself, before it applies any
                // capture beat — see the comment on its onAppear.

            case .ask:
                AskView(excluding: asked, round: asked.isEmpty ? 1 : 2) { source in
                    asked.insert(source)
                    phase = .copy(source)
                }
                .pageWidth()

            case .copy(let source):
                CopyView(source: source, isLast: asked.count >= askRounds) { page in
                    // Keep the *first* page, not the last one. You ask twice,
                    // and the point of the second ask is that the first answer
                    // was already second-hand — so the page the ending hands
                    // back has to be the copy of a copy, not the copy of a
                    // second opinion. Overwriting it quietly swapped the most
                    // damning piece of evidence in the piece for the least.
                    if written == nil {
                        written = page
                        ink = InkMetrics(drawing: page)
                    }
                    phase = .interlude(source)
                }

            case .interlude(let source):
                InterludeView(source: source, hold: freezeForCapture) {
                    if asked.count < askRounds {
                        phase = .ask
                    } else {
                        phase = .reveal
                    }
                }
                .pageWidth()

            case .reveal:
                // Deliberately not page-capped: this beat is the room coming
                // back into focus, and the room is a picture.
                RevealView(page: written, hold: freezeForCapture) {
                    phase = .recap
                }

            case .recap:
                RecapView(eye: eye, ink: captureInk ?? ink)
                    .pageWidth()
            }
        }
        // The language switch lives above every screen, in one place, so no
        // scene has to know it exists. English stays the default; this only
        // ever moves if the person holding the phone asks it to.
        .overlay(alignment: .topTrailing) {
            Button {
                l10n.toggle()
            } label: {
                Text(l10n.toggleLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppTheme.inkSoft)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.paper.opacity(0.85))
                    .overlay(
                        Capsule().strokeBorder(AppTheme.ink.opacity(0.14), lineWidth: 1)
                    )
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 10)
            .padding(.trailing, 14)
        }
    }
}

/// Keeps the written screens to a column.
///
/// On a phone this does nothing. On an iPad it is the difference between a page
/// and a noticeboard: 17-point type spread across 834 points of paper reads as
/// an unfinished settings screen, and the three-way question at the end turned
/// into a row of full-width list buttons. The room and the notebook stay
/// full-bleed — they are pictures, and pictures want the width.
private struct PageWidth: ViewModifier {
    func body(content: Content) -> some View {
        content.frame(maxWidth: 560)
    }
}

private extension View {
    func pageWidth() -> some View { modifier(PageWidth()) }
}
