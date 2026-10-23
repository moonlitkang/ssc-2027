import SwiftUI

/// One row of the room, and the only mechanic in the piece.
///
/// The way out is withheld until the player has actually looked, and the price
/// is paid in seconds of squinting rather than in taps: 1.5 seconds in the
/// third row, thirteen in the last. Tapping faster changes nothing, which is
/// the point — the last row is supposed to cost you something before it lets
/// you give up and ask a person.
struct StageView: View {
    @ObservedObject var eye: EyeState
    let act: Act
    let onNext: () -> Void

    @ObservedObject private var l10n = L10n.shared

    @State private var captionVisible = false
    @State private var soundOn = true
    @State private var lateLine: String?
    @State private var revealed = 0
    @State private var canLeave = false

    /// squintedSeconds is cumulative across the whole run, so each act measures
    /// from where it started.
    @State private var baseline: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Text(l10n.t(act.caption))
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(AppTheme.inkSoft)
                .multilineTextAlignment(.center)
                .opacity(captionVisible ? 1 : 0)
                .padding(.top, 24)
                .padding(.bottom, 18)

            ClassroomScene(act: act, blurRadius: eye.blurRadius)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            // onChanged fires many times per press; only the
                            // first one is an actual intake of breath.
                            if !eye.isHolding { SoundPlayer.shared.breathe(inhaling: true) }
                            eye.beginSquint()
                        }
                        .onEnded { _ in
                            eye.endSquint()
                            SoundPlayer.shared.breathe(inhaling: false)
                            SoundPlayer.shared.stopStrain()
                            updateProgress()
                        }
                )

            VStack(spacing: 7) {
                StrainBar(value: eye.strain)
                    .frame(height: 12)

                HStack {
                    Text(l10n.t("Eye strain"))
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.inkSoft)

                    Spacer()

                    Button(action: toggleSound) {
                        Image(systemName: soundOn ? "speaker.wave.2" : "speaker.slash")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.inkSoft)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                    }
                    .buttonStyle(.plain)

                    Text(l10n.rowLabel(act.row))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(AppTheme.inkSoft)
                }
            }
            .padding(.top, 20)

            // Fixed height on purpose: the late lines are longer than the hint,
            // and the scene above must not jump when one replaces the other.
            Text(l10n.t(lateLine ?? act.hint))
                .font(.system(size: 13))
                .foregroundColor(AppTheme.inkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(minHeight: 46, alignment: .top)
                .padding(.top, 12)
                .padding(.horizontal, 8)

            // Kept in the layout from the start so nothing shifts when it fades in.
            Button {
                eye.endSquint()
                SoundPlayer.shared.stopStrain()
                SoundPlayer.shared.thud()
                onNext()
            } label: {
                Text(l10n.t(act.advance))
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .frame(maxWidth: 380)
                    .background(AppTheme.ink)
                    .foregroundColor(AppTheme.paper)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .opacity(canLeave ? 1 : 0)
            .disabled(!canLeave)
            .padding(.top, 10)
            .padding(.bottom, 26)
        }
        .padding(.horizontal, 34)
        .onAppear {
            captionVisible = false
            lateLine = nil
            revealed = 0
            canLeave = act.requiredSquint <= 0
            baseline = eye.squintedSeconds
            withAnimation(.easeIn(duration: 0.45)) { captionVisible = true }

            // strain changes five times a second while holding, which is a
            // free heartbeat: no timer needed to watch the clock.
            eye.onStrainChange = { level in
                SoundPlayer.shared.setStrain(level)
                updateProgress()
            }

            // The board is written once, as the scene opens.
            SoundPlayer.shared.board(distance: act.distance)
        }
        .onDisappear {
            SoundPlayer.shared.stopStrain()
        }
    }

    private func updateProgress() {
        let held = eye.squintedSeconds - baseline
        let thresholds = act.lineThresholds

        if revealed < act.lateLines.count, held >= thresholds[revealed] {
            revealed += 1
            withAnimation(.easeInOut(duration: 0.55)) {
                lateLine = act.lateLines[revealed - 1]
            }
        }

        if held >= act.requiredSquint && !canLeave {
            withAnimation(.easeIn(duration: 0.5)) { canLeave = true }
        }
    }

    private func toggleSound() {
        soundOn.toggle()
        SoundPlayer.shared.setEnabled(soundOn)
    }
}
