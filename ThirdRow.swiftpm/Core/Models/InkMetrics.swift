import PencilKit
import Foundation

/// What the pencil actually did.
///
/// This exists so the copying scene stops being a gesture and becomes
/// evidence. Up to now the drawing was only replayed at the end as a picture,
/// which meant the player's own hand contributed nothing measurable to the
/// piece and every number it reports was one I typed in.
///
/// Three things are read off the `PKDrawing` the player made: how many strokes
/// they laid down, how much pencil that is, and — the one that matters — how
/// often the pencil stopped.
///
/// The pauses are the point. A stroke carries timestamps, so the gap between
/// the end of one stroke and the start of the next is measurable, and a gap
/// longer than a breath is a moment when the player was not writing. In this
/// scene there is only one thing to do while not writing, and it is the thing
/// the whole piece is about. Counting it turns "you couldn't see the board"
/// from a claim the app makes into a fact the player produced.
struct InkMetrics: Equatable {

    let strokes: Int
    let lengthCM: Int

    /// Gaps longer than this are counted as stops rather than as the natural
    /// lift between letters. Lifting the pencil to start the next character
    /// takes a third of a second at most; looking up takes one to three.
    static let pauseThreshold: TimeInterval = 0.8

    /// How many times the pencil came off the page for longer than a breath.
    let pauses: Int

    /// How long those stops added up to, in seconds.
    let pauseSeconds: Double

    static let empty = InkMetrics(strokes: 0, lengthCM: 0, pauses: 0, pauseSeconds: 0)

    init(strokes: Int, lengthCM: Int, pauses: Int = 0, pauseSeconds: Double = 0) {
        self.strokes = strokes
        self.lengthCM = lengthCM
        self.pauses = pauses
        self.pauseSeconds = pauseSeconds
    }

    init(drawing: PKDrawing?) {
        guard let drawing, !drawing.strokes.isEmpty else {
            self = .empty
            return
        }

        var totalPoints: CGFloat = 0
        var pauses = 0
        var pauseSeconds: TimeInterval = 0

        for stroke in drawing.strokes {
            let points = stroke.path

            // Sum the segment lengths rather than counting points: a slow,
            // careful line and a fast flick have the same number of points but
            // very different amounts of pencil.
            guard points.count > 1 else { continue }
            for index in 1..<points.count {
                let a = points[index - 1].location
                let b = points[index].location
                let dx = b.x - a.x
                let dy = b.y - a.y
                totalPoints += (dx * dx + dy * dy).squareRoot()
            }
        }

        // The gap has to be measured from the end of the previous stroke, not
        // from when it started: a long careful stroke and a short one followed
        // by the same pause should count the same, and subtracting the stroke's
        // own duration is what makes that true.
        for index in 1..<drawing.strokes.count {
            let previous = drawing.strokes[index - 1].path
            let current = drawing.strokes[index].path
            guard previous.count > 0 else { continue }

            let previousEnd = previous.creationDate
                .addingTimeInterval(previous[previous.count - 1].timeOffset)
            // Clamped: if a stroke path reports a creation date at its end
            // rather than its start, the subtraction goes negative, and a
            // negative pause is not a thing that should ever be counted.
            let gap = max(0, current.creationDate.timeIntervalSince(previousEnd))

            if gap > Self.pauseThreshold {
                pauses += 1
                pauseSeconds += gap
            }
        }

        // PencilKit measures in points, and a point is not a printer's point:
        // on the iPad this was drawn for, the screen is 264 pixels to the inch
        // at @2x, so there are 132 of these to the inch, not 72. Using 72
        // overstated every measurement by a factor of 1.8 — and this is the one
        // number in the piece that claims to be measured rather than written,
        // so being wrong by 83% is worse than not reporting it.
        //
        // 132 is the iPad figure. A phone ranges from 134 to 163 depending on
        // the model, and there is no public API for it, so this is an estimate
        // on those — but it is the right estimate for the device the piece is
        // built for.
        let centimetres = Double(totalPoints) * 2.54 / 132.0

        self.init(
            strokes: drawing.strokes.count,
            // A single dot is still a mark; never report zero centimetres.
            lengthCM: max(1, Int(centimetres.rounded())),
            pauses: pauses,
            pauseSeconds: pauseSeconds
        )
    }

    var isEmpty: Bool { strokes == 0 }
}
