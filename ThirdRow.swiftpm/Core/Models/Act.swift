import CoreGraphics

struct Act: Identifiable {
    let id: Int
    let row: Int
    let caption: String

    /// The heading is chalked smaller, the way it would be written on a board.
    let heading: String
    let problem: String
    let fontSize: CGFloat

    let baseClarity: Double

    /// How much relief squinting still gives. It shrinks with every row,
    /// because squinting is a workaround, not a fix.
    let squintGain: Double

    let hint: String
    let advance: String
}

extension Act {
    static let all: [Act] = [
        Act(
            id: 0,
            row: 3,
            caption: "Row 3. You can still read it.",
            heading: "Solve for x:",
            problem: "3x + 7 = 22",
            fontSize: 40,
            baseClarity: 0.90,
            squintGain: 1.00,
            hint: "Hold the board to squint.",
            advance: "Two weeks later"
        ),
        Act(
            id: 1,
            row: 5,
            caption: "Two weeks later. Row 5.",
            heading: "Solve for x:",
            problem: "3x + 7 = 22",
            fontSize: 31,
            baseClarity: 0.62,
            squintGain: 0.72,
            hint: "Hold the board to squint.",
            advance: "Two weeks later"
        ),
        Act(
            id: 2,
            row: 7,
            caption: "Two weeks later. Row 7.",
            heading: "Solve for x:",
            problem: "3x + 7 = 22",
            fontSize: 22,
            baseClarity: 0.28,
            squintGain: 0.38,
            hint: "You squint as hard as you can. It stops helping.",
            advance: "Ask someone"
        )
    ]

    /// The last row is the one the copy scene reuses.
    static var last: Act { all[all.count - 1] }
}
