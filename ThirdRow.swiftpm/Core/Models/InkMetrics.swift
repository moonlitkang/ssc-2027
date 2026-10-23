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

        // PencilKit measures in points, and there are 72 to the inch.
        let centimetres = Double(totalPoints) * 2.54 / 72.0

        self.init(
            strokes: drawing.strokes.count,
            // A single dot is still a mark; never report zero centimetres.
            lengthCM: max(1, Int(centimetres.rounded()))
        )
    }

    var isEmpty: Bool { strokes == 0 }
}
