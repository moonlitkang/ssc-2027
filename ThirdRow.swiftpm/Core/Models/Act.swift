import CoreGraphics

struct Act: Identifiable {
    let id: Int
    let row: Int

    /// The month, not the row. The row number already sits in the corner, and
    /// printing it twice made the top of every act read like a bug. This line
    /// carries the only thing the corner does not: how much of the term is gone.
    let caption: String

    /// The heading is chalked smaller, the way it would be written on a board.
    let heading: String
    let problem: String

    /// A smaller line under the problem. Because it is smaller, the same blur
    /// eats it before it eats the problem itself — which is exactly how myopia
    /// works. You lose the details first, the subject last.
    let note: String

    let fontSize: CGFloat

    /// The prescription this act is seen through, in dioptres. Positive means
    /// myopic. It is the only thing that decides how much the room blurs — see
    /// `Optics`. September is mild enough to read a board from the middle of the
    /// room; December is not, from anywhere.
    let sphericalError: Double

    let hint: String

    /// One line per threshold, shown in order as the player keeps looking.
    /// The lines are paced by time actually spent squinting, not by taps, so
    /// nobody can tap their way through the failure.
    let lateLines: [String]

    /// Seconds of squinting before the way out appears. This is the act's
    /// length in the only currency that matters here: how long you try.
    let requiredSquint: Double

    /// 0 = standing at the board, 1 = the last row. Drives how dull and quiet
    /// the board sounds, so hearing degrades with sight.
    let distance: Double

    let advance: String

    /// Late lines land at evenly spaced points across the required squint.
    var lineThresholds: [Double] {
        guard !lateLines.isEmpty else { return [] }
        let step = requiredSquint / Double(lateLines.count + 1)
        return (1...lateLines.count).map { step * Double($0) }
    }
}

extension Act {
    static let all: [Act] = [
        Act(
            id: 0,
            row: 3,
            caption: "September.",
            heading: "Solve for x:",
            problem: "3x + 7 = 22",
            note: "Ex. 1-8, odd only",
            fontSize: 40,
            sphericalError: 0.50,
            hint: "Hold the board to squint.",
            lateLines: ["You don't have to. Not yet."],
            requiredSquint: 1.5,
            distance: 0.0,
            advance: "Two weeks later"
        ),
        Act(
            id: 1,
            row: 5,
            caption: "October.",
            heading: "Solve for x:",
            problem: "3x + 7 = 22",
            note: "Ex. 1-8, odd only",
            fontSize: 31,
            sphericalError: 1.50,
            hint: "Hold the board to squint.",
            lateLines: [
                "The problem comes back. The line under it doesn't.",
                "You lean forward until your chair lifts off the floor. You sit back."
            ],
            requiredSquint: 7.0,
            distance: 0.42,
            advance: "Two months later"
        ),
        Act(
            id: 2,
            row: 7,
            caption: "December.",
            heading: "Solve for x:",
            problem: "3x + 7 = 22",
            note: "Ex. 1-8, odd only",
            fontSize: 22,
            sphericalError: 2.75,
            hint: "Hold the board to squint.",
            lateLines: [
                "The shapes get bigger. They don't get sharper.",
                "You try again. Your eyes water.",
                "You stop trying."
            ],
            requiredSquint: 13.0,
            distance: 0.85,
            advance: "Ask someone"
        )
    ]

    /// The last row is the one the copy scene reuses.
    static var last: Act { all[all.count - 1] }
}
