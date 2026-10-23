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

/// Two shoulders rising from the bottom edge to the neck.
struct ShoulderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let shoulderY = rect.minY + rect.height * 0.16
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: shoulderY),
            control: CGPoint(x: rect.minX + rect.width * 0.20, y: rect.minY + rect.height * 0.02)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.maxX - rect.width * 0.20, y: rect.minY + rect.height * 0.02)
        )
        path.closeSubpath()
        return path
    }
}

/// Back of a seated student: head, neck, and the slope of two shoulders.
///
/// The first version was a head floating over a rounded rectangle. Real
/// shoulders slope and a real neck is narrower than the head, and without those
/// two facts the silhouette reads as a stone.
struct StudentSilhouette: View {
    var width: CGFloat

    var body: some View {
        ZStack {
            ShoulderShape()
                .fill(AppTheme.head)
                .frame(width: width, height: width * 0.44)
                .offset(y: width * 0.30)

            Rectangle()
                .fill(AppTheme.head)
                .frame(width: width * 0.15, height: width * 0.14)
                .offset(y: width * 0.12)

            Ellipse()
                .fill(AppTheme.head)
                .frame(width: width * 0.44, height: width * 0.50)
                .offset(y: -width * 0.04)
        }
        .frame(width: width, height: width * 0.80)
    }
}

/// First-person view from your seat.
///
/// Three rules:
/// 1. How many rows sit between you and the board grows with the act. Row 3 →
///    one row of heads in front. Row 7 → three. The seat change is shown, not
///    narrated.
/// 2. Every surface is blurred by how far away it is, and by nothing else. That
///    includes the heads in front of you and your own desk, which means at row
///    seven the front of the room goes soft while the page under your hand stays
///    readable. An earlier version of this comment claimed the heads stayed
///    sharp; the code never did that, and the comment was the thing that was
///    wrong.
/// 3. Nothing floats. The floor line, the skirting board and the teacher's
///    desk legs all agree on where the ground is.
struct ClassroomScene: View {
    let act: Act

    /// A single number used to be handed in here — a blur radius — and every
    /// far surface got the same one. Now the eye is handed in, and each surface
    /// is blurred by how far away it actually is. See `Optics`.
    let defocus: Defocus

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
                room(w: w, h: h)
                board(w: w, h: h)
                eyeChart(w: w, h: h)
                timetable(w: w, h: h)
                teacherDesk(w: w, h: h)
                    .blur(radius: defocus.radius(at: Defocus.Distance.teacherDesk, width: w))

                ForEach(slots, id: \.self) { slot in
                    deskRow(slot: slot, w: w, h: h)
                        .blur(radius: defocus.radius(at: Defocus.Distance.headsAhead, width: w))
                }

                yourDesk(w: w, h: h)
                    .blur(radius: defocus.radius(at: Defocus.Distance.yourDesk, width: w))
            }
            .clipped()
        }
    }

    // MARK: - The room itself

    private func room(w: CGFloat, h: CGFloat) -> some View {
        let wallBottom = h * 0.585

        return ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [AppTheme.wallTop, AppTheme.wall],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: w, height: wallBottom)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [AppTheme.floorDeep, AppTheme.floor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: w, height: h - wallBottom)
                .offset(y: wallBottom)

            // A skirting board: without it the wall colour stops dead against
            // the floor and the room reads as two stacked swatches.
            Rectangle()
                .fill(AppTheme.skirting)
                .frame(width: w, height: h * 0.013)
                .offset(y: wallBottom - h * 0.004)

            ceiling(w: w, h: h)
        }
    }

    private func ceiling(w: CGFloat, h: CGFloat) -> some View {
        Rectangle()
            .fill(AppTheme.ceiling)
            .frame(width: w, height: h * 0.056)
            .overlay(
                HStack(spacing: w * 0.26) {
                    Capsule()
                        .fill(AppTheme.chalk.opacity(0.80))
                        .frame(width: w * 0.20, height: 3.5)
                    Capsule()
                        .fill(AppTheme.chalk.opacity(0.52))
                        .frame(width: w * 0.11, height: 3.5)
                }
                .blur(radius: 1.5)
                .offset(y: h * 0.010)
            )
    }

    // MARK: - The wall

    private func board(w: CGFloat, h: CGFloat) -> some View {
        let boardW = w * 0.56
        let boardH = h * 0.32
        let totalH = boardH + 18

        return VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.board)

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Rectangle()
                        .fill(AppTheme.chalk.opacity(0.05))
                        .frame(height: boardH * 0.18)
                }
                .clipShape(RoundedRectangle(cornerRadius: 4))

                boardText(w: w)
                    .padding(.horizontal, boardW * 0.07)
                    .blur(radius: defocus.radius(at: act.boardDistance, width: w))
            }
            .frame(width: boardW, height: boardH)
            .padding(4)
            .background(AppTheme.wood)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            chalkTray(width: boardW)
        }
        .frame(width: boardW + 8, height: totalH, alignment: .top)
        .position(x: w * 0.05 + (boardW + 8) / 2, y: h * 0.115 + totalH / 2)
    }

    private func boardText(w: CGFloat) -> some View {
        // Everything chalked scales with the drawing. The blur radius already
        // does — it is derived from the width — but the letter sizes used to be
        // absolute points, so the same act was sharp on a phone and fog on an
        // iPad, and the only number that decides whether a word can be read
        // (radius over glyph size) changed with the device. Scaling the type by
        // the same factor pins that ratio, and makes `referenceWidth` mean what
        // its name says.
        //
        // The note is chalked at roughly a third of the problem's size, so the
        // same blur radius swallows it a full row before it swallows the
        // problem. That difference is the argument of the second act.
        let scale = w / Optics.referenceWidth
        return VStack(alignment: .leading, spacing: act.fontSize * 0.26 * scale) {
            ChalkText(text: act.heading, size: act.fontSize * 0.44 * scale, seed: 3)
            ChalkText(text: act.problem, size: act.fontSize * scale, seed: 11, weight: .medium)
            ChalkText(text: act.note, size: act.fontSize * 0.32 * scale, seed: 23)
                .opacity(0.78)
        }
        .rotationEffect(.degrees(-0.5))
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
        let cw = w * 0.23
        let rows: [(String, CGFloat)] = [
            ("E", 0.30),
            ("E E", 0.185),
            ("E E E", 0.125),
            ("E E E E", 0.085),
            ("E E E E E", 0.056)
        ]

        return VStack(spacing: cw * 0.030) {
            ForEach(0..<5, id: \.self) { index in
                Text(rows[index].0)
                    .font(.system(size: cw * rows[index].1, weight: .bold, design: .monospaced))
            }
        }
        .foregroundColor(AppTheme.ink.opacity(0.70))
        .frame(width: cw)
        .padding(.vertical, cw * 0.09)
        .background(AppTheme.chalk.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .strokeBorder(AppTheme.ink.opacity(0.12), lineWidth: 0.6)
        )
        .blur(radius: defocus.radius(at: Defocus.Distance.wallChart, width: w))
        .position(x: w * 0.805, y: h * 0.215)
    }

    /// The wall timetable. It gives the empty wall a second thing to be.
    private func timetable(w: CGFloat, h: CGFloat) -> some View {
        let tw = w * 0.112
        let th = h * 0.088

        return VStack(alignment: .leading, spacing: th * 0.13) {
            ForEach(0..<5, id: \.self) { index in
                HStack(spacing: tw * 0.07) {
                    Rectangle()
                        .fill(AppTheme.ink.opacity(0.26))
                        .frame(width: tw * (0.38 - CGFloat(index) * 0.030), height: 1.6)
                    Rectangle()
                        .fill(AppTheme.ink.opacity(0.13))
                        .frame(width: tw * 0.20, height: 1.6)
                }
            }
        }
        .padding(.horizontal, tw * 0.12)
        .padding(.top, th * 0.14)
        .frame(width: tw, height: th, alignment: .topLeading)
        .background(AppTheme.paper)
        .overlay(
            Rectangle()
                .strokeBorder(AppTheme.ink.opacity(0.10), lineWidth: 0.6)
        )
        .blur(radius: defocus.radius(at: Defocus.Distance.wallChart, width: w))
        // Right-aligned with the eye chart above it, and low enough that the two
        // cards no longer touch. They used to overlap by a few points, which at
        // row 7's blur turned into one white smear with two centres.
        .position(x: w * 0.862, y: h * 0.405)
    }

    // MARK: - Front of the room

    private func teacherDesk(w: CGFloat, h: CGFloat) -> some View {
        let deskW = w * 0.24
        let topH = h * 0.020
        let bodyH = h * 0.052
        let legH = h * 0.030
        let legW = w * 0.013
        let totalH = topH + bodyH + legH
        let floorY = h * 0.585

        return ZStack(alignment: .top) {
            // Legs run from under the top down to the floor, and a cross bar
            // keeps the whole thing from reading as a floating slab.
            ZStack(alignment: .top) {
                HStack {
                    Rectangle()
                        .fill(AppTheme.wood)
                        .frame(width: legW, height: bodyH + legH)
                    Spacer()
                    Rectangle()
                        .fill(AppTheme.wood)
                        .frame(width: legW, height: bodyH + legH)
                }
                .frame(width: deskW * 0.78)
                .offset(y: topH)

                Rectangle()
                    .fill(AppTheme.wood.opacity(0.72))
                    .frame(width: deskW * 0.78, height: 2.5)
                    .offset(y: topH + (bodyH + legH) * 0.70)
            }

            VStack(spacing: 0) {
                Rectangle()
                    .fill(AppTheme.woodLight)
                    .frame(height: topH)

                ZStack(alignment: .top) {
                    Rectangle()
                        .fill(AppTheme.desk)
                    VStack(spacing: bodyH * 0.20) {
                        Rectangle()
                            .fill(AppTheme.wood.opacity(0.20))
                            .frame(height: 1)
                        Rectangle()
                            .fill(AppTheme.wood.opacity(0.20))
                            .frame(height: 1)
                    }
                    .padding(.top, bodyH * 0.26)
                }
                .frame(height: bodyH)
            }
            .frame(width: deskW)

            // a stack of exercise books on the desk
            HStack(spacing: 3) {
                Rectangle()
                    .fill(AppTheme.notebook)
                    .frame(width: deskW * 0.16, height: 4)
                Rectangle()
                    .fill(AppTheme.notebook.opacity(0.85))
                    .frame(width: deskW * 0.16, height: 4)
                Rectangle()
                    .fill(AppTheme.chalk.opacity(0.65))
                    .frame(width: deskW * 0.09, height: 3)
            }
            .offset(y: -4)
        }
        .frame(width: deskW, height: totalH)
        .position(x: w * 0.34, y: floorY - totalH / 2)
    }

    private func deskRow(slot: Int, w: CGFloat, h: CGFloat) -> some View {
        let widths: [CGFloat] = [0.42, 0.58, 0.76]
        let centres: [CGFloat] = [0.700, 0.800, 0.888]
        let bw = w * widths[slot]
        let deskH = h * 0.028
        let studentW = bw * 0.23

        return ZStack(alignment: .bottom) {
            HStack(spacing: bw * 0.24) {
                StudentSilhouette(width: studentW)
                    .offset(y: -deskH * 0.45)
                StudentSilhouette(width: studentW * 0.96)
                    .offset(y: -deskH * 0.45)
            }

            ZStack(alignment: .top) {
                DeskShape(inset: bw * 0.045)
                    .fill(AppTheme.desk)
                Rectangle()
                    .fill(AppTheme.woodLight)
                    .frame(height: 2.5)
                Rectangle()
                    .fill(AppTheme.wood.opacity(0.16))
                    .frame(height: 2)
                    .offset(y: 2.5)
            }
            .frame(width: bw, height: deskH)
        }
        .frame(width: bw)
        .position(x: w * 0.5, y: h * centres[slot])
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

            // An open notebook, already waiting. It pays off one scene later.
            RoundedRectangle(cornerRadius: 3)
                .fill(AppTheme.paper)
                .frame(width: w * 0.26, height: h * 0.042)
                .overlay(
                    VStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { _ in
                            Rectangle()
                                .fill(AppTheme.ink.opacity(0.09))
                                .frame(height: 1)
                        }
                    }
                    .padding(.horizontal, 12)
                )
                .rotationEffect(.degrees(-1.2))
                .offset(x: w * 0.12, y: h * 0.012)

            // a pencil, sharp because it is close
            HStack(spacing: 0) {
                Rectangle()
                    .fill(AppTheme.notebook)
                    .frame(width: w * 0.13, height: 5)
                PencilTip()
                    .fill(AppTheme.inkSoft)
                    .frame(width: 9, height: 5)
            }
            .rotationEffect(.degrees(-4))
            .offset(x: -w * 0.22, y: h * 0.028)
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
