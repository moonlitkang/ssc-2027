import CoreGraphics

/// How much a given eye blurs a given distance.
///
/// This replaces the old arrangement, which was a single `blurRadius` fed by a
/// hand-tuned "clarity" number. That produced the right *look* and had nothing
/// behind it: the same blur landed on the board and on the desk, and squinting
/// was a magic multiplier that got smaller in each act because I said so.
///
/// The model here is two lines of textbook optics. A defocused point is no
/// longer a point; it is a disc on the retina whose angular size is
///
///     θ = pupil diameter × defocus,   in radians when the pupil is in metres
///
/// and the defocus is how far past the eye's far point the object sits. The eye
/// can always add power, so near things focus and only far things do not.
/// Everything else in this file is unit conversion, so that θ can be spent as a
/// blur radius in points.
///
/// Two things fall out of it that the old model could not produce:
///
///   * Distance matters. The board at six metres and your own desk at
///     forty-five centimetres blur by wildly different amounts, so at row seven
///     the room goes soft while the page under your hand stays readable. That
///     is the actual experience of myopia, and it is the reason the copy scene
///     works.
///   * Squinting helps by exactly one mechanism — it narrows the aperture. So
///     it relieves every row by the same *fraction*, and it still stops working
///     in row seven, because two-thirds of a large blur is still a large blur.
///     Nothing has to be tuned down per act for the story to hold.
enum Optics {

    /// Half the horizontal field the classroom is drawn as subtending. A framed
    /// view of a blackboard from a seat is roughly 40 degrees across; this is
    /// the only free parameter in the conversion, and it is here rather than
    /// buried in a call site so it can be argued with.
    static let halfFieldRadians = 0.35

    /// A dark classroom, no reading lamp: the pupil is wide, which is precisely
    /// why the board is worse at the back of a dim room than a bright one.
    static let dilatedPupilMM = 5.0

    /// Squinting is a slit, not a smaller circle, and a slit is a worse stop
    /// than its gap suggests: diffraction off both lids, plus a pupil that is
    /// only partly covered, so the *effective* aperture is nearer 2.4 mm than
    /// the 1.8 mm the gap measures. That difference matters here — at 1.8 mm the
    /// relief was so strong that row seven, squinted, came out as legible as
    /// row five is at rest, which quietly destroyed the third act.
    static let squintingPupilMM = 2.4

    /// Points per radian at a given drawing width.
    static func pointsPerRadian(width: CGFloat) -> Double {
        Double(width) / (2 * halfFieldRadians)
    }

    /// The classroom's laid-out width on the iPad it was drawn for. Only needed
    /// by the one view that draws a board without any geometry of its own — the
    /// copying scene, where the board is a small rectangle standing in for the
    /// real one.
    static let referenceWidth: CGFloat = 766

    /// Blur radius in points for an object `distance` metres away.
    ///
    /// `sphericalError` is in dioptres and positive means myopic, which is the
    /// sign convention an optometrist would use on a prescription.
    ///
    /// The defocus is `S − 1/distance`, floored at zero, and the floor is the
    /// important part. A short-sighted eye can always *accommodate* — add power
    /// with the ciliary muscle — so anything nearer than the far point is
    /// brought into focus and is sharp. Myopia only removes the ability to
    /// relax, so only objects beyond the far point blur. Without that floor the
    /// model says a −0.5 D eye cannot read the page in front of it, which is the
    /// opposite of how myopia actually behaves.
    static func blurRadius(
        width: CGFloat,
        distance: Double,
        sphericalError: Double,
        pupilMM: Double
    ) -> CGFloat {
        let objectVergence = 1.0 / max(distance, 0.15)
        let defocus = max(0.0, sphericalError - objectVergence)
        let angle = (pupilMM / 1000.0) * defocus
        // The angle is the diameter of the blur disc; a radius modifier wants
        // half of it.
        let radius = angle * pointsPerRadian(width: width) / 2
        // Past about a fiftieth of the frame the room stops reading as a room
        // and becomes fog, which is a different (and worse) picture.
        return CGFloat(min(radius, Double(width) * 0.019))
    }
}

/// The state of the eye at one instant: how wrong it is, and how wide the hole
/// in front of it is.
struct Defocus: Equatable {
    var sphericalError: Double
    var pupilMM: Double

    func radius(at distance: Double, width: CGFloat) -> CGFloat {
        Optics.blurRadius(
            width: width,
            distance: distance,
            sphericalError: sphericalError,
            pupilMM: pupilMM
        )
    }

    /// Distances used by the drawing, in metres, measured from the player's
    /// seat. Kept together so the room and the model cannot drift apart.
    enum Distance {
        static let board: Double = 6.0
        static let wallChart: Double = 5.4
        static let teacherDesk: Double = 3.0
        static let headsAhead: Double = 1.8
        static let yourDesk: Double = 0.45
    }
}
