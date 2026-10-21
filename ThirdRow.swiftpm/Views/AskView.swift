import SwiftUI

/// The moment after squinting has failed: you have to ask a person.
///
/// Three doors, one corridor. The choice matters to the player and not at all to
/// the outcome, which is exactly the thing this scene is about.
struct AskView: View {
    let onChoose: (AnswerSource) -> Void

    @State private var visible = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("You can't read it. So you ask.")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(AppTheme.ink)
                .multilineTextAlignment(.center)
                .opacity(visible ? 1 : 0)

            Text("Anyone will do.")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.inkSoft)
                .opacity(visible ? 1 : 0)
                .padding(.top, 8)

            VStack(spacing: 12) {
                ForEach(AnswerSource.allCases) { source in
                    Button {
                        SoundPlayer.shared.thud()
                        onChoose(source)
                    } label: {
                        Text(source.button)
                            .font(.system(size: 16, weight: .medium))
                            .frame(maxWidth: 360)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.paper)
                            .foregroundColor(AppTheme.ink)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(AppTheme.ink.opacity(0.16), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 34)
            .opacity(visible ? 1 : 0)

            Spacer()
        }
        .padding(.horizontal, 40)
        .onAppear {
            SoundPlayer.shared.stopStrain()
            withAnimation(.easeIn(duration: 0.5)) { visible = true }
        }
    }
}
