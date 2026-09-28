import PencilKit
import Foundation

/// What the pencil actually did.
///
/// This exists so the copying scene stops being a gesture and becomes
/// evidence. Up to now the drawing was only replayed at the end as a picture,
/// which meant the player's own hand contributed nothing measurable to the
/// piece and every number it reports was one I typed in.
///
/// These two are read off the `PKDrawing` the player made: how many strokes they
/// laid down and how much pencil that is. Nothing here is invented, and nothing
/// is stored — it is computed from the same object that is handed to the reveal.
struct InkMetrics: Equatable {

    let strokes: Int
    let lengthCM: Int

    static let empty = InkMetrics(strokes: 0, lengthCM: 0)

    init(strokes: Int, lengthCM: Int) {
        self.strokes = strokes
        self.lengthCM = lengthCM
    }

    init(drawing: PKDrawing?) {
        guard let drawing, !drawing.strokes.isEmpty else {
            self = .empty
            return
        }

        var totalPoints: CGFloat = 0

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
            lengthCM: max(1, Int(centimetres.rounded()))
        )
    }

    var isEmpty: Bool { strokes == 0 }
}
