import SwiftUI

/// A desk top seen from behind: wider at the bottom edge, narrower at the far edge.
struct DeskShape: Shape {
    var inset: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + inset, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

/// Back of a seated student: head plus the slope of two shoulders.
struct StudentSilhouette: View {
    var width: CGFloat
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: width * 0.18)
                .fill(AppTheme.head)
                .frame(width: width, height: width * 0.34)
                .offset(y: width * 0.14)
            Ellipse()
                .fill(AppTheme.head)
                .frame(width: width * 0.40, height: width * 0.44)
                .offset(y: -width * 0.06)
        }
        .frame(width: width)
    }
}

/// First-person view from your seat.
///
/// Two rules:
/// 1. How many rows sit between you and the board grows with the act. Row 3 → one row
///    of heads in front. Row 7 → three. The seat change is shown, not narrated.
/// 2. Only the board and the eye chart are blurred. Myopia is a distance problem: the
///    desks in front of you stay sharp. Blurring everything would just be a filter.
struct ClassroomScene: View {
    let act: Act
    let blurRadius: CGFloat

    /// 0 = far, 1 = middle, 2 = near.
    private var slots: [Int] {
        switch act.id {
        case 0: return [2]
        case 1: return [1, 2]
        default: return [0, 1, 2]
        }
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack(alignment: .topLeading) {
                AppTheme.wall

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Rectangle()
                        .fill(AppTheme.wallShade)
                        .frame(height: 5)
                    Rectangle()
                        .fill(AppTheme.floor)
                        .frame(height: h * 0.42)
                }

                board(w: w, h: h)
                eyeChart(w: w, h: h)
                teacherDesk(w: w, h: h)

                ForEach(slots, id: \.self) { slot in
                    deskRow(slot: slot, w: w, h: h)
                }

                yourDesk(w: w, h: h)
            }
            .clipped()
        }
    }

    // MARK: - Wall

    private func board(w: CGFloat, h: CGFloat) -> some View {
        let boardW = w * 0.62
        return VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(AppTheme.board)

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Rectangle()
                        .fill(AppTheme.chalk.opacity(0.05))
                        .frame(height: 14)
                }
                .clipShape(RoundedRectangle(cornerRadius: 6))

                Text(act.words)
                    .font(.system(size: act.fontSize, weight: .medium, design: .monospaced))
                    .foregroundColor(AppTheme.chalk)
                    .opacity(0.93)
                    .rotationEffect(.degrees(-0.4))
                    .blur(radius: blurRadius)
            }
            .frame(height: h * 0.32)
            .padding(4)
            .background(AppTheme.wood)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            chalkTray(width: boardW)
        }
        .frame(width: boardW)
        .position(x: w * 0.06 + boardW / 2, y: h * 0.24)
    }

    private func chalkTray(width: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(AppTheme.chalk.opacity(0.22))
                .frame(height: 6)

            HStack(spacing: 4) {
                Capsule()
                    .fill(AppTheme.chalk.opacity(0.62))
                    .frame(width: 20, height: 4)
                Capsule()
                    .fill(AppTheme.chalk.opacity(0.36))
                    .frame(width: 13, height: 4)
                Spacer()
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppTheme.chalk.opacity(0.30))
                    .frame(width: 26, height: 9)
            }
            .padding(.horizontal, 8)
            .offset(y: -4)
        }
        .frame(height: 8)
        .padding(.horizontal, 6)
    }

    /// The eye chart on the side wall. It belongs to the subject, and it goes soft too.
    private func eyeChart(w: CGFloat, h: CGFloat) -> some View {
        let cw = w * 0.19
        return VStack(spacing: 2) {
            Text("E")
                .font(.system(size: cw * 0.26, weight: .bold, design: .monospaced))
            Text("E E")
                .font(.system(size: cw * 0.17, weight: .bold, design: .monospaced))
            Text("E E E")
                .font(.system(size: cw * 0.115, weight: .bold, design: .monospaced))
            Text("E E E E")
                .font(.system(size: cw * 0.078, weight: .bold, design: .monospaced))
        }
        .foregroundColor(AppTheme.ink.opacity(0.72))
        .frame(width: cw)
        .padding(.vertical, cw * 0.09)
        .background(AppTheme.chalk.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .blur(radius: blurRadius * 0.75)
        .position(x: w * 0.845, y: h * 0.235)
    }

    // MARK: - Front of the room

    private func teacherDesk(w: CGFloat, h: CGFloat) -> some View {
        let deskW = w * 0.26
        let totalH = h * 0.105
        let topH = h * 0.020
        let legH = h * 0.030
        let bodyH = totalH - topH - legH
        let floorY = h * 0.58

        return ZStack(alignment: .top) {
            HStack {
                Rectangle().fill(AppTheme.wood).frame(width: 5, height: legH)
                Spacer()
                Rectangle().fill(AppTheme.wood).frame(width: 5, height: legH)
            }
            .frame(width: deskW * 0.78)
            .offset(y: topH + bodyH)

            VStack(spacing: 0) {
                Rectangle()
                    .fill(AppTheme.woodLight)
                    .frame(height: topH)
                Rectangle()
                    .fill(AppTheme.desk)
                    .frame(height: bodyH)
                    .overlay(
                        Rectangle()
                            .fill(AppTheme.wood.opacity(0.30))
                            .frame(height: 1)
                            .offset(y: bodyH * 0.15),
                        alignment: .top
                    )
            }
            .frame(width: deskW)

            // a stack of notebooks on the desk
            HStack(spacing: 3) {
                Rectangle().fill(AppTheme.notebook).frame(width: deskW * 0.17, height: 3)
                Rectangle().fill(AppTheme.notebook).frame(width: deskW * 0.17, height: 3)
            }
            .offset(y: -3)
        }
        .frame(width: deskW, height: totalH)
        .position(x: w * 0.38, y: floorY - totalH / 2)
    }

    private func deskRow(slot: Int, w: CGFloat, h: CGFloat) -> some View {
        let widths: [CGFloat] = [0.40, 0.56, 0.74]
        let ys: [CGFloat] = [0.700, 0.800, 0.888]
        let bw = w * widths[slot]
        let deskH = h * 0.030
        let studentW = bw * 0.22

        return ZStack(alignment: .bottom) {
            HStack(spacing: bw * 0.30) {
                StudentSilhouette(width: studentW)
                    .offset(y: -deskH * 0.55)
                StudentSilhouette(width: studentW * 0.95)
                    .offset(y: -deskH * 0.55)
            }

            ZStack(alignment: .top) {
                DeskShape(inset: bw * 0.04)
                    .fill(AppTheme.desk)
                Rectangle()
                    .fill(AppTheme.woodLight)
                    .frame(height: 3)
            }
            .frame(width: bw, height: deskH)
        }
        .frame(width: bw)
        .position(x: w * 0.5, y: h * ys[slot])
    }

    // MARK: - Your desk

    private func yourDesk(w: CGFloat, h: CGFloat) -> some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(AppTheme.woodLight)
                .frame(height: 4)
            Rectangle()
                .fill(AppTheme.desk)
                .offset(y: 4)

            // a pencil, sharp because it is close
            HStack(spacing: 0) {
                Rectangle()
                    .fill(AppTheme.notebook)
                    .frame(width: w * 0.16, height: 5)
                PencilTip()
                    .fill(AppTheme.inkSoft)
                    .frame(width: 9, height: 5)
            }
            .rotationEffect(.degrees(-4))
            .offset(x: -w * 0.16, y: h * 0.026)
        }
        .frame(width: w, height: h * 0.075)
        .position(x: w * 0.5, y: h * 0.972)
    }
}

struct PencilTip: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
