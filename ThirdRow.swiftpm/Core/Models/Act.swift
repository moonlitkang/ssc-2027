import CoreGraphics

struct Act: Identifiable {
    let id: Int
    let row: Int
    let caption: String
    let words: String
    let fontSize: CGFloat
    let baseClarity: Double
}

extension Act {
    static let all: [Act] = [
        Act(
            id: 0,
            row: 3,
            caption: "Row 3. You can still read it.",
            words: "SOLVE FOR X",
            fontSize: 46,
            baseClarity: 0.90
        ),
        Act(
            id: 1,
            row: 5,
            caption: "Two weeks later. Row 5.",
            words: "SOLVE FOR X",
            fontSize: 34,
            baseClarity: 0.64
        ),
        Act(
            id: 2,
            row: 7,
            caption: "Two weeks later. Row 7.",
            words: "SOLVE FOR X",
            fontSize: 24,
            baseClarity: 0.38
        )
    ]
}
