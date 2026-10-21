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
    let onNext: () -> Void

    @State private var drawing = PKDrawing()
    @State private var captionVisible = false

    private var act: Act { Act.last }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 5) {
                Text(source.arrival)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(AppTheme.inkSoft)
                Text("You write it down.")
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.inkSoft.opacity(0.85))
            }
            .multilineTextAlignment(.center)
            .opacity(captionVisible ? 1 : 0)
            .padding(.top, 24)
            .padding(.bottom, 16)

            board
                .frame(height: 146)
                .padding(.bottom, 18)

            notebook
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Text("You can't check it against the board.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.inkSoft)
                .padding(.top, 14)

            Button {
                SoundPlayer.shared.stopStrain()
                onNext()
            } label: {
                Text("Put on your glasses")
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
            SoundPlayer.shared.stopChalk()
            SoundPlayer.shared.setStrain(0.42)
            withAnimation(.easeIn(duration: 0.45)) { captionVisible = true }
        }
        .onDisappear {
            SoundPlayer.shared.stopStrain()
        }
    }

    /// The board as it looks from the last row: legible as a shape, useless as
    /// information. Deliberately not tied to the squint state.
    private var board: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(AppTheme.board)

            VStack(alignment: .leading, spacing: 10) {
                ChalkText(text: act.heading, size: 16, seed: 3)
                ChalkText(text: act.problem, size: 30, seed: 11, weight: .medium)
            }
            .blur(radius: 5.5)
        }
        .padding(4)
        .background(AppTheme.wood)
        .clipShape(RoundedRectangle(cornerRadius: 7))
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
