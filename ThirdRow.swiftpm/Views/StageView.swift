import SwiftUI

struct StageView: View {
    @ObservedObject var eye: EyeState
    let act: Act
    let onNext: () -> Void

    @State private var captionVisible = false
    @State private var soundOn = true

    var body: some View {
        VStack(spacing: 0) {
            Text(act.caption)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(AppTheme.inkSoft)
                .multilineTextAlignment(.center)
                .opacity(captionVisible ? 1 : 0)
                .padding(.top, 24)
                .padding(.bottom, 18)

            ClassroomScene(act: act, blurRadius: eye.blurRadius)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            eye.beginSquint()
                        }
                        .onEnded { _ in
                            eye.endSquint()
                            SoundPlayer.shared.stopStrain()
                        }
                )

            VStack(spacing: 7) {
                StrainBar(value: eye.strain)
                    .frame(height: 12)

                HStack {
                    Text("Eye strain")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.inkSoft)

                    Spacer()

                    Button(action: toggleSound) {
                        Image(systemName: soundOn ? "speaker.wave.2" : "speaker.slash")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.inkSoft)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                    }
                    .buttonStyle(.plain)

                    Text("Row \(act.row) of 7")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(AppTheme.inkSoft)
                }
            }
            .padding(.top, 20)

            Text(act.hint)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.top, 14)
                .padding(.horizontal, 8)

            Button {
                eye.endSquint()
                SoundPlayer.shared.stopStrain()
                SoundPlayer.shared.thud()
                onNext()
            } label: {
                Text(act.advance)
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .frame(maxWidth: 380)
                    .background(AppTheme.ink)
                    .foregroundColor(AppTheme.paper)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 12)
            .padding(.bottom, 26)
        }
        .padding(.horizontal, 34)
        .onAppear {
            captionVisible = false
            withAnimation(.easeIn(duration: 0.45)) { captionVisible = true }
            eye.onStrainChange = { level in
                SoundPlayer.shared.setStrain(level)
            }
            SoundPlayer.shared.startChalk()
        }
        .onDisappear {
            SoundPlayer.shared.stopStrain()
        }
    }

    private func toggleSound() {
        soundOn.toggle()
        SoundPlayer.shared.setEnabled(soundOn)
        if soundOn {
            SoundPlayer.shared.startChalk()
        }
    }
}
