import SwiftUI

enum AppTheme {
    static let paper = Color(red: 0.97, green: 0.96, blue: 0.94)
    static let ink = Color(red: 0.12, green: 0.12, blue: 0.13)
    static let inkSoft = Color(red: 0.42, green: 0.42, blue: 0.44)
    static let board = Color(red: 0.13, green: 0.19, blue: 0.17)
    static let chalk = Color(red: 0.93, green: 0.93, blue: 0.90)
    static let strain = Color(red: 0.85, green: 0.42, blue: 0.20)

    // Classroom. The wall is lit from above, so the top is a shade darker than
    // the part near the boards: a flat fill reads as a colour swatch, not a room.
    static let ceiling = Color(red: 0.84, green: 0.82, blue: 0.78)
    static let wallTop = Color(red: 0.90, green: 0.88, blue: 0.83)
    static let wall = Color(red: 0.94, green: 0.92, blue: 0.87)
    static let wallShade = Color(red: 0.86, green: 0.83, blue: 0.77)
    static let skirting = Color(red: 0.62, green: 0.55, blue: 0.46)
    static let floor = Color(red: 0.84, green: 0.80, blue: 0.74)
    static let floorDeep = Color(red: 0.73, green: 0.68, blue: 0.61)

    static let desk = Color(red: 0.72, green: 0.66, blue: 0.57)
    static let wood = Color(red: 0.55, green: 0.46, blue: 0.36)
    static let woodLight = Color(red: 0.68, green: 0.59, blue: 0.47)
    static let head = Color(red: 0.31, green: 0.28, blue: 0.25)
    static let notebook = Color(red: 0.72, green: 0.36, blue: 0.30)
}
