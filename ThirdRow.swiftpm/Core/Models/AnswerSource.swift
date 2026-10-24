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
    ///   frontRow  — the workaround is already built into how she writes;
    ///   teacher   — even the person who is supposed to be able to see it
    ///               squints, and says nothing about it.
    var afterword: String {
        switch self {
        case .classmate:
            return "Then he says he can't see it either.\nHe has been copying from her since September."
        case .frontRow:
            return "Her handwriting is smaller than the board.\nShe fits two subjects into one notebook."
        case .teacher:
            return "She reads the page out. Before she does, she squints at it.\nShe doesn't mention it."
        }
    }
}
