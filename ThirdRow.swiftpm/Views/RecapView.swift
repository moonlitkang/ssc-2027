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

    /// What the pencil did, counted from the drawing itself. Empty when the
    /// player never wrote anything, in which case the line is not shown at all —
    /// a zero would be a fact about the tester, not about the story.
    var ink: InkMetrics = .empty

    /// Capture only. A screenshot run never squints, so without this the ending
    /// is photographed reading "0 seconds" and "0 hours a year", which is the
    /// one screen where a zero looks like a bug rather than a result.
    var captureSeconds: Double?

    /// Offered only when a door was left unopened — two of three were asked and
    /// one remains. Nil means the room has been exhausted, and the ending is
    /// allowed to end.
    ///
    /// This exists because the argument of the piece is that all three answers
    /// are the same non-answer, and that argument is worth nothing if a judge
    /// only ever sees two of them and cannot tell whether the third was the one
    /// that worked. Thirty seconds of walking through the last door is more
    /// convincing than any sentence claiming it leads nowhere.
    var onAskMissing: (() -> Void)?

    /// How many people were asked, so the ending can state what came of it.
    ///
    /// The three answers never appear on screen together — they are separated by
    /// a copying scene and a minute of play — so "all of them were the same
    /// non-answer" used to be something the piece asserted rather than something
    /// the player could see. Saying the count out loud is the cheapest way to put
    /// them side by side: two doors, two failures.
    var askedCount: Int = 0

    @ObservedObject private var l10n = L10n.shared

    @State private var numberVisible = false

    private var seconds: Double { captureSeconds ?? eye.squintedSeconds }

    /// 1200 lessons a year, divided into the seconds already counted.
    private var hoursPerYear: Int {
        max(0, Int(seconds / 3.0))
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)

            Text("\(Int(seconds))")
                .font(.system(size: 68, weight: .semibold, design: .monospaced))
                .foregroundColor(AppTheme.ink)
                .opacity(numberVisible ? 1 : 0)

            Text(l10n.t("seconds of squinting."))
                .font(.system(size: 15))
                .foregroundColor(AppTheme.inkSoft)
                .opacity(numberVisible ? 1 : 0)

            // The second measured thing, and the only one the player made with
            // their hands. Both of these numbers were counted, neither was
            // written into the app.
            if !ink.isEmpty {
                Text(l10n.inkLine(strokes: ink.strokes, centimetres: ink.lengthCM))
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
                    .opacity(numberVisible ? 1 : 0)

                // The pauses, which are the only part of this that is a
                // measurement rather than a description. A gap in the
                // timestamps longer than a hand movement is a moment the player
                // was not writing, and in this scene there is exactly one other
                // thing to do. It is reported without being explained — the
                // explanation is the scene they just played.
                //
                // Shown even when it is zero: writing straight through means the
                // board was never consulted, and that is worth saying too.
                Text(l10n.pauseLine(pauses: ink.pauses))
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
                    .opacity(numberVisible ? 1 : 0)
            }

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
            .padding(.bottom, 46)

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
            .padding(.bottom, 40)

            // The count, stated flatly. Two doors, two failures — which is the
            // whole argument, and it is better made by arithmetic than by a
            // sentence claiming all three answers were the same.
            if askedCount >= 2 {
                Text(l10n.askedSummary(askedCount))
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 26)
                    .opacity(numberVisible ? 1 : 0)
            }

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

            // The third door, if it is still shut. Quiet and under the ending
            // rather than above it: it is an offer, not a prompt.
            if let onAskMissing {
                Button {
                    SoundPlayer.shared.thud()
                    onAskMissing()
                } label: {
                    Text(l10n.t("There was one more person in the room."))
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.inkSoft)
                        .underline()
                        .multilineTextAlignment(.center)
                }
                .buttonStyle(.plain)
                .padding(.top, 22)
                .opacity(numberVisible ? 1 : 0)
            }

            // Both ends need a flexible spacer. With only the one at the top,
            // the whole ending slid to the bottom of an iPad and left a third of
            // the screen empty above it.
            Spacer(minLength: 12)
        }
        .padding(.horizontal, 34)
        .onAppear {
            SoundPlayer.shared.stopStrain()
            SoundPlayer.shared.thud()
            withAnimation(.easeIn(duration: 0.7).delay(0.2)) { numberVisible = true }
        }
    }
}
