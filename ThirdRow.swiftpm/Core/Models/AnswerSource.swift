/// Who you ask when the board stops being readable.
///
/// The point of giving three answers is not variety. All three routes lead to
/// the same notebook and the same unverifiable copy, because the problem is not
/// that you asked the wrong person. It is that nobody in the room can see it.
enum AnswerSource: String, CaseIterable, Identifiable {
    case classmate
    case frontRow
    case teacher

    var id: String { rawValue }

    var button: String {
        switch self {
        case .classmate: return "The boy next to you"
        case .frontRow: return "The girl in front of you"
        case .teacher: return "The teacher"
        }
    }

    /// What you get, in the moment.
    var arrival: String {
        switch self {
        case .classmate: return "He reads it out loud."
        case .frontRow: return "She pushes her notebook over."
        case .teacher: return "The teacher says: page 42."
        }
    }

    /// What you find out after you have already written it down.
    ///
    /// Each of the three is a *different* way of not seeing, not three phrasings
    /// of the same one. That distinction is what makes asking a third person
    /// worth thirty seconds: the second answer does not repeat the first, it
    /// widens the room.
    ///
    ///   classmate — someone else is in the same position, and has been for
    ///               longer than you have noticed;
    ///   frontRow  — her small handwriting is not thrift, it is fear: she
    ///               writes down everything because she cannot check any of it;
    ///   teacher   — even the person who is supposed to be able to see the
    ///               board squints at it, and says nothing about it.
    ///
    /// The teacher's squint has to be aimed at the *board*, not at the page.
    /// Squinting at something held close is presbyopia — a far-sighted eye that
    /// cannot accommodate — and the model this piece runs on says the opposite
    /// about myopia: near things are always in focus, because `max(0, S − 1/d)`
    /// is zero for them. Aimed at the page it would have been a physics error;
    /// aimed at the board it is the same failure the player has been having for
    /// three minutes, in the hands of the one person nobody would ask.
    var afterword: String {
        switch self {
        case .classmate:
            return "Then he says he can't see it either.\nHe has been copying from her since September."
        case .frontRow:
            return "Her handwriting is smaller than the board.\nShe writes everything down. She is afraid of missing it."
        case .teacher:
            return "She reads the page out. Before she does, she turns and squints at the board.\nShe doesn't mention it."
        }
    }
}
