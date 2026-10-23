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
                // Sized from the same ratio the board is drawn at, so the strip
                // is exactly as tall as the board needs and no taller — on a
                // phone as well as on the iPad.
                .aspectRatio(1 / (Self.boardWidthFraction * Self.boardAspect), contentMode: .fit)
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
    /// This is the same board as the act before it, and that has to be true in
    /// the geometry as well as in the prescription. Two earlier versions got
    /// this wrong in opposite directions: the first drew the problem at thirty
    /// points while the act drew it at twenty, so the copy scene was *clearer*
    /// than the screen you had just given up on; the second scaled the type by
    /// the full canvas width and left the board stretched into a 7:1 strip that
    /// no classroom has.
    ///
    /// Now the board is drawn at the width and proportion `ClassroomScene` uses,
    /// so the lettering comes out at the same size and the blur at the same
    /// radius. Same prescription, same six metres, same board.
    private var board: some View {
        GeometryReader { geo in
            // Both of these mirror ClassroomScene.board(w:h:). They are repeated
            // rather than shared because that view takes a size, not a ratio —
            // and a board whose proportions are off is not the same board.
            let canvas = geo.size.width
            let perspective = CGFloat(Act.referenceBoardDistance / act.boardDistance)
            let boardW = canvas * Self.boardWidthFraction * perspective
            let boardH = boardW * Self.boardAspect
            let scale = canvas / Optics.referenceWidth * perspective
            let blur = Defocus(
                sphericalError: act.sphericalError,
                pupilMM: Optics.dilatedPupilMM
            )
            .radius(at: act.boardDistance, width: canvas)

            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.board)

                VStack(alignment: .leading, spacing: act.fontSize * 0.26 * scale) {
                    ChalkText(text: act.heading, size: act.fontSize * 0.44 * scale, seed: 3)
                    ChalkText(text: act.problem, size: act.fontSize * scale, seed: 11, weight: .medium)
                }
                .blur(radius: blur)
            }
            .frame(width: boardW, height: boardH)
            .padding(4)
            .background(AppTheme.wood)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .frame(width: canvas, height: geo.size.height)
        }
    }

    /// The board's share of the room, copied from `ClassroomScene`.
    private static let boardWidthFraction: CGFloat = 0.56
    private static let boardAspect: CGFloat = 0.67

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
