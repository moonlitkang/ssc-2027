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

    /// The seat this act's `boardDistance` is measured against, in metres.
    /// Everything on the far wall is a fixed physical size, so how much of the
    /// view it fills is proportional to the reciprocal of the distance — and
    /// `fontSize` is defined at *this* distance. The scene multiplies both by
    /// `referenceBoardDistance / boardDistance`.
    static let referenceBoardDistance: Double = 3.5

    /// The prescription this act is seen through, in dioptres. Positive means
    /// myopic. It is the only thing that decides how much the room blurs — see
    /// `Optics`. September is mild enough to read a board from the middle of the
    /// room; December is not, from anywhere.
    let sphericalError: Double

    /// How far the board is from this act's seat, in metres.
    ///
    /// This used to be a single constant, `Defocus.Distance.board`, and the seat
    /// therefore had no effect on the picture at all — three acts, three rows,
    /// one distance. The room only ever changed by drawing more heads and
    /// shrinking the chalk, which meant the title of the piece was not true of
    /// the model underneath it.
    ///
    /// What the honest number shows is worth knowing: moving from the last row
    /// to the third at −2.75 D changes the blur by about five per cent. The seat
    /// is not the problem, and no amount of moving seats makes it one. December
    /// is the act where that gets said out loud.
    let boardDistance: Double

    let hint: String

    /// One line per threshold, shown in order as the player keeps looking.
    /// The lines are paced by time actually spent squinting, not by taps, so
    /// nobody can tap their way through the failure.
    let lateLines: [String]

    /// Seconds of squinting before the way out appears. This is the act's
    /// length in the only currency that matters here: how long you try.
    let requiredSquint: Double

    /// How long the squint actually relieves anything, and how much of it is
    /// left once the face gives out.
    ///
    /// Both come from the same fact: the more defocus there is to press away,
    /// the shorter the press lasts. Half a dioptre needs no press at all, so
    /// September's is `.infinity` — nothing about that act depends on stamina,
    /// and pretending otherwise would be a difficulty knob rather than a
    /// consequence. December's is over almost as soon as it starts, because a
    /// slit that has to cancel nearly three dioptres has to be held by a
    /// muscle that is already complaining.
    let reliefSeconds: Double
    let reliefFloor: Double

    /// Where the late lines land, in seconds of squinting. Empty means "spread
    /// them evenly", which is what the first two acts want. The last act sets
    /// them by hand: its lines are timed to what the board is doing, and even
    /// spacing would put the first one at 3.25 s — before the blur has begun to
    /// come back, i.e. while the line "they don't get sharper" is still a lie.
    var lineTimes: [Double] = []

    /// 0 = standing at the board, 1 = the last row. Drives how dull and quiet
    /// the board sounds, so hearing degrades with sight.
    let distance: Double

    let advance: String

    /// Late lines land at evenly spaced points across the required squint,
    /// unless the act names its own times.
    var lineThresholds: [Double] {
        guard !lateLines.isEmpty else { return [] }
        if lineTimes.count == lateLines.count { return lineTimes }
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
            // Forty at the reference distance, three and a half metres. The
            // scene scales this down as the seat moves back, so the number here
            // is the same for all three acts: the chalk does not get smaller,
            // you do.
            fontSize: 40,
            sphericalError: 0.50,
            boardDistance: 3.5,
            // Not "to squint". At half a dioptre, squinting moves the blur on
            // a forty-point line by one point and a bit — there is nothing to
            // see, and there is not meant to be. This act teaches the gesture;
            // the line above the button is the only thing that has to change,
            // and it says so.
            hint: "Press and hold the board.",
            lateLines: ["You don't have to. Not yet."],
            requiredSquint: 1.5,
            reliefSeconds: .infinity,
            reliefFloor: 1.0,
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
            fontSize: 40,
            sphericalError: 1.50,
            boardDistance: 5.0,
            hint: "Hold the board to squint.",
            // "The problem comes back" used to carry the whole act, and it
            // stopped being true once the last act changed questions. What is
            // left is the thing the player can actually check on screen.
            lateLines: [
                "You can still make out the problem. The line under it is gone.",
                "You lean forward until your chair lifts off the floor. You sit back."
            ],
            requiredSquint: 7.0,
            reliefSeconds: 6.0,
            reliefFloor: 0.72,
            distance: 0.42,
            advance: "Two months later"
        ),
        Act(
            id: 2,
            row: 7,
            caption: "December.",
            heading: "Solve for x:",
            // A different question on purpose. Every earlier version reused
            // `3x + 7 = 22`, and a string that has been read twice is read the
            // third time from memory: at the blur this act settles on, the
            // remembered answer made the board legible when it was not. This
            // is also just what a term of maths looks like.
            problem: "5x - 3 = 27",
            note: "Ex. 1-8, odd only",
            fontSize: 40,
            // Three rather than two and three quarters. At 2.75 D the board was
            // still reading as "a board with writing on it" at the back of the
            // room, which is not the failure the act is about; at three it is
            // only light and shape.
            sphericalError: 3.0,
            boardDistance: 6.5,
            hint: "Hold the board to squint.",
            lateLines: [
                "The shapes get bigger. They don't get sharper.",
                // The seat, said once, in the act where it has stopped being an
                // answer. The wording matters: the visible movement across the
                // three acts is backwards (row 3 → 5 → 7), so a line claiming
                // you moved *up* would contradict the picture and the corner
                // label at the same time. "Again" is the whole accusation —
                // seats get reassigned, and the last row is where you end up.
                "In November they moved your seat again. In December it was the last row.",
                "You stop trying."
            ],
            requiredSquint: 13.0,
            // The relief lasts a second and a half, and the first line has to
            // land after it has gone — not while it is still working. At 2.0 s
            // the blur is 3.71 against a resting 7.10, i.e. the board is 48%
            // clearer than it was, and "they don't get sharper" is a lie on the
            // screen it appears over. At 3.5 s the radius has climbed back to
            // 0.235 of a glyph, which is past the legible boundary; that is the
            // first honest moment to say it.
            reliefSeconds: 1.5,
            reliefFloor: 0.42,
            lineTimes: [3.5, 6.5, 10.0],
            distance: 0.85,
            advance: "Ask someone"
        )
    ]

    /// The last row is the one the copy scene reuses.
    static var last: Act { all[all.count - 1] }
}
