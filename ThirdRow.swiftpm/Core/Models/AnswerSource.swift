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
    var afterword: String {
        switch self {
        case .classmate:
            return "Then he says: I can't see it either.\nHe copied it from her."
        case .frontRow:
            return "Her handwriting is smaller than the board."
        case .teacher:
            return "You open the book.\nThe print is the same size as the board."
        }
    }
}
