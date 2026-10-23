import SwiftUI

/// The ending is two numbers, a country, and three lines, in that order.
///
/// The first number is the player's own: seconds spent squinting, measured, not
/// written. The second is that same number multiplied by a school year — six
/// lessons a day, five days a week, forty weeks — which turns a private moment
/// into a quantity that belongs to a system rather than to a person.
///
/// The national figure is the only statistic in the piece and the only claim
/// that is not the author's own; it is here because one classroom is an
/// anecdote and fifty million classrooms are a design problem. The last line is
/// the argument: the eyes were never the thing that was built wrong.
struct RecapView: View {
    @ObservedObject var eye: EyeState

    @ObservedObject private var l10n = L10n.shared

    @State private var numberVisible = false

    /// 1200 lessons a year, divided into the seconds already counted.
    private var hoursPerYear: Int {
        max(0, Int(eye.squintedSeconds / 3.0))
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)

            Text("\(Int(eye.squintedSeconds))")
                .font(.system(size: 68, weight: .semibold, design: .monospaced))
                .foregroundColor(AppTheme.ink)
                .opacity(numberVisible ? 1 : 0)

            Text(l10n.t("seconds of squinting."))
                .font(.system(size: 15))
                .foregroundColor(AppTheme.inkSoft)
                .opacity(numberVisible ? 1 : 0)

            VStack(spacing: 3) {
                Text(l10n.t("Six lessons a day, five days a week, forty weeks."))
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.inkSoft)

                Text(l10n.hoursPerYear(hoursPerYear))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.ink)
            }
            .multilineTextAlignment(.center)
            .padding(.top, 14)
            .opacity(numberVisible ? 1 : 0)

            Spacer(minLength: 14)

            VStack(spacing: 5) {
                Text(l10n.t("Fifteen pairs of glasses\nin a class of fifty."))
                    .font(.system(size: 21, weight: .medium))
                    .foregroundColor(AppTheme.ink)
                    .multilineTextAlignment(.center)

                Text(l10n.t("Mine is one of them."))
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.inkSoft)
            }

            VStack(spacing: 2) {
                Text(l10n.t("Seventy-one percent of junior high students in China are short-sighted."))
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.ink)
                    .multilineTextAlignment(.center)

                Text(l10n.t("Source: National Health Commission, 2024."))
                    .font(.system(size: 9))
                    .foregroundColor(AppTheme.inkSoft.opacity(0.75))
            }
            .padding(.top, 16)
            .padding(.horizontal, 6)

            Spacer(minLength: 16)

            VStack(spacing: 7) {
                Text(l10n.t("Nobody read it off the board."))
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.ink)
                    .multilineTextAlignment(.center)

                Text(l10n.t("We all read it off each other."))
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.ink)
                    .multilineTextAlignment(.center)

                Text(l10n.t("Nobody in that room thought the room was the problem."))
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .padding(.bottom, 34)
        }
        .padding(.horizontal, 34)
        .onAppear {
            SoundPlayer.shared.stopStrain()
            SoundPlayer.shared.thud()
            withAnimation(.easeIn(duration: 0.7).delay(0.2)) { numberVisible = true }
        }
    }
}
