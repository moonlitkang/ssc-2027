import SwiftUI

/// The moment after squinting has failed: you have to ask a person.
///
/// Three doors, one corridor. The choice matters to the player and not at all to
/// the outcome, which is exactly the thing this scene is about.
///
/// It comes back a second time, minus whoever you already asked. The first
/// answer turns out to be a copy of a copy, so of course you try one more
/// person — and the second answer is no better. That is the whole argument:
/// asking around is not a way of seeing.
struct AskView: View {
    let excluding: Set<AnswerSource>
    let round: Int
    let onChoose: (AnswerSource) -> Void

    @ObservedObject private var l10n = L10n.shared

    @State private var visible = false

    private var options: [AnswerSource] {
        AnswerSource.allCases.filter { !excluding.contains($0) }
    }

    private var title: String {
        round == 1
            ? l10n.t("You can't read it. So you ask.")
            : l10n.t("He couldn't read it either. So you ask someone else.")
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(AppTheme.ink)
                .multilineTextAlignment(.center)
                .opacity(visible ? 1 : 0)

            Text(l10n.t("Anyone will do."))
                .font(.system(size: 14))
                .foregroundColor(AppTheme.inkSoft)
                .opacity(visible ? 1 : 0)
                .padding(.top, 8)

            VStack(spacing: 12) {
                ForEach(options) { source in
                    Button {
                        SoundPlayer.shared.thud()
                        onChoose(source)
                    } label: {
                        Text(l10n.t(source.button))
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
