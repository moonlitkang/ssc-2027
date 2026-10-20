import SwiftUI

/// First-person view of the classroom from your seat.
///
/// Two things matter here:
/// 1. How many rows of desks sit between you and the board. Row 3 → one row in front.
///    Row 7 → three. The seat change is shown, not narrated.
/// 2. Only the board is blurred. Myopia is a distance problem: the desks in front of
///    you stay sharp while the board goes soft. Blurring the whole screen would be a
///    filter; blurring the far layer is what the eye actually does.
struct ClassroomScene: View {
    let act: Act
    let blurRadius: CGFloat

    /// Slots 0 = far, 1 = middle, 2 = near. Closer desks appear as you move back.
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
                        .fill(AppTheme.floor)
                        .frame(height: h * 0.30)
                }

                board(w: w, h: h)
                    .padding(.horizontal, w * 0.055)
                    .padding(.top, h * 0.06)

                teacherDesk(w: w, h: h)

                ForEach(slots, id: \.self) { slot in
                    deskRow(slot: slot, w: w, h: h)
                }

                yourDesk(w: w, h: h)
            }
            .clipped()
        }
    }

    private func board(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(AppTheme.board)

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Rectangle()
                        .fill(AppTheme.chalk.opacity(0.05))
                        .frame(height: 14)
                }
                .clipShape(RoundedRectangle(cornerRadius: 7))

                Text(act.words)
                    .font(.system(size: act.fontSize, weight: .medium, design: .monospaced))
                    .foregroundColor(AppTheme.chalk)
                    .opacity(0.93)
                    .rotationEffect(.degrees(-0.4))
                    .blur(radius: blurRadius)
            }
            .frame(height: h * 0.33)
            .padding(5)
            .background(AppTheme.wood)
            .clipShape(RoundedRectangle(cornerRadius: 9))

            chalkTray(w: w)
        }
    }

    private func chalkTray(w: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(AppTheme.chalk.opacity(0.20))
                .frame(height: 7)

            HStack(spacing: 5) {
                Capsule()
                    .fill(AppTheme.chalk.opacity(0.60))
                    .frame(width: 24, height: 5)
                Capsule()
                    .fill(AppTheme.chalk.opacity(0.35))
                    .frame(width: 15, height: 5)
                Spacer()
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppTheme.chalk.opacity(0.30))
                    .frame(width: 32, height: 10)
            }
            .padding(.horizontal, w * 0.02)
            .offset(y: -5)
        }
        .frame(height: 9)
    }

    private func teacherDesk(w: CGFloat, h: CGFloat) -> some View {
        let deskW = w * 0.30
        return ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(AppTheme.desk)
                .frame(width: deskW, height: h * 0.075)

            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(AppTheme.chalk.opacity(0.35))
                    .frame(width: deskW * 0.22, height: 4)
                RoundedRectangle(cornerRadius: 1)
                    .fill(AppTheme.chalk.opacity(0.28))
                    .frame(width: deskW * 0.16, height: 4)
            }
            .offset(y: -h * 0.040)
        }
        .position(x: w * 0.5, y: h * 0.545)
    }

    private func deskRow(slot: Int, w: CGFloat, h: CGFloat) -> some View {
        let widths: [CGFloat] = [0.34, 0.48, 0.64]
        let ys: [CGFloat] = [0.655, 0.775, 0.895]
        let bw = w * widths[slot]
        let headW = bw * 0.155

        return ZStack {
            HStack(spacing: bw * 0.30) {
                Ellipse()
                    .fill(AppTheme.head)
                    .frame(width: headW, height: headW * 1.12)
                Ellipse()
                    .fill(AppTheme.head.opacity(0.92))
                    .frame(width: headW * 0.94, height: headW * 1.06)
            }
            .offset(y: -bw * 0.052)

            RoundedRectangle(cornerRadius: 3)
                .fill(AppTheme.desk)
                .frame(width: bw, height: h * 0.034)
        }
        .frame(width: bw)
        .position(x: w * 0.5, y: h * ys[slot])
    }

    /// The near edge of the desk you are sitting at. It anchors the point of view.
    private func yourDesk(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(AppTheme.wood)
                .frame(height: 3)
            Rectangle()
                .fill(AppTheme.desk)
        }
        .frame(width: w, height: h * 0.075)
        .position(x: w * 0.5, y: h * 0.965)
    }
}
