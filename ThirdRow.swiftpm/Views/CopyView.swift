import SwiftUI
import PencilKit

/// The scene the whole piece was missing.
///
/// In Row 7 squinting stops working, so the player asks the boy next to them.
/// He reads the answer out loud and the player writes it down, which is the
/// most ordinary thing in the world and also the whole problem: the board stays
/// blurred the entire time, so there is no way to check what was copied.
///
/// That is why this scene has no squint gesture. The player has already learned
/// that it does not help.
struct CopyView: View {
    let source: AnswerSource
    /// The glasses only arrive after the last person you asked. Until then the
    /// way forward is a third door, not a fix.
    let isLast: Bool
    /// The page is handed back up on purpose: the last scene shows it again,
    /// sharp, next to the board that is finally sharp too. Without that, the
    /// writing would be decoration.
    let onNext: (PKDrawing) -> Void

    @ObservedObject private var l10n = L10n.shared

    @State private var drawing = PKDrawing()
    @State private var captionVisible = false

    private var act: Act { Act.last }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 5) {
                Text(l10n.t(source.arrival))
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(AppTheme.inkSoft)
                Text(l10n.t("You write it down."))
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.inkSoft.opacity(0.85))
            }
            .multilineTextAlignment(.center)
            .opacity(captionVisible ? 1 : 0)
            .padding(.top, 24)
            .padding(.bottom, 16)

            board
                // Shorter than it was, because the lettering on it is now the
                // size the last act used. The same board, seen from the same
                // seat, has the same amount of white space around the writing.
                .frame(height: 112)
                .padding(.bottom, 18)

            notebook
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Asking the teacher does not produce something you can read off
            // the board — it produces a page number. Same dead end, different
            // shape, so the line has to change with the route.
            Text(l10n.t(source == .teacher
                        ? "A page number is not an answer."
                        : "You can't check it against the board."))
                .font(.system(size: 13))
                .foregroundColor(AppTheme.inkSoft)
                .padding(.top, 14)

            Button {
                SoundPlayer.shared.stopStrain()
                onNext(drawing)
            } label: {
                Text(isLast
                     ? l10n.t("Put on your glasses")
                     : l10n.t("Put the pencil down"))
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.ink)
                    .foregroundColor(AppTheme.paper)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 12)
            .padding(.bottom, 26)
        }
        .padding(.horizontal, 34)
        .onAppear {
            SoundPlayer.shared.setStrain(0.42)
            withAnimation(.easeIn(duration: 0.45)) { captionVisible = true }
        }
        .onDisappear {
            SoundPlayer.shared.stopStrain()
        }
    }

    /// The board as it looks from the last row: legible as a shape, useless as
    /// information.
    ///
    /// This used to draw the problem at thirty points while the act before it
    /// drew the same problem at twenty, and the blur radius was identical in
    /// both — so the ratio of blur to letter size was *lower* here than on the
    /// screen where you had just given up. Past about eight seconds of squinting
    /// the last act's board was the foggier of the two, and the caption saying
    /// you cannot check your work against it was describing the opposite of
    /// what was on screen.
    ///
    /// Now both boards scale their lettering by the same factor, so "same
    /// prescription, same six metres" is finally true of the thing you can
    /// actually see: the same fraction of a letter is missing in both.
    private var board: some View {
        GeometryReader { geo in
            let scale = geo.size.width / Optics.referenceWidth
            let blur = Defocus(
                sphericalError: act.sphericalError,
                pupilMM: Optics.dilatedPupilMM
            )
            .radius(at: Defocus.Distance.board, width: geo.size.width)

            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.board)

                VStack(alignment: .leading, spacing: act.fontSize * 0.26 * scale) {
                    ChalkText(text: act.heading, size: act.fontSize * 0.44 * scale, seed: 3)
                    ChalkText(text: act.problem, size: act.fontSize * scale, seed: 11, weight: .medium)
                }
                .blur(radius: blur)
            }
            .padding(4)
            .background(AppTheme.wood)
            .clipShape(RoundedRectangle(cornerRadius: 7))
        }
    }

    private var notebook: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 6)
                .fill(AppTheme.paper)

            VStack(spacing: 0) {
                ForEach(0..<9, id: \.self) { _ in
                    Spacer(minLength: 0)
                    Rectangle()
                        .fill(AppTheme.ink.opacity(0.07))
                        .frame(height: 1)
                }
            }
            .padding(.vertical, 20)

            PencilCanvas(drawing: $drawing)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(AppTheme.ink.opacity(0.10), lineWidth: 1)
        )
    }
}
