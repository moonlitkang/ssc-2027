import AVFoundation

/// Plays the synthesised buffers and owns the audio session.
///
/// A single shared instance, because there are only ever a handful of sounds
/// and the two loops have to survive view rebuilds: if a player were owned by a
/// view, every phase change would restart the chalk mid-stroke.
final class SoundPlayer {

    static let shared = SoundPlayer()

    private var chalkPlayer: AVAudioPlayer?
    private var strainPlayer: AVAudioPlayer?
    private var oneShots: [AVAudioPlayer] = []
    private var prepared = false
    private var enabled = true

    private init() {}

    var isEnabled: Bool { enabled }

    /// Building the buffers costs a few milliseconds. Doing it on first use
    /// keeps app launch clean, and the first use is a scene transition where a
    /// couple of frames are hidden anyway.
    private func prepareIfNeeded() {
        guard !prepared else { return }
        prepared = true
        configureSession()
        chalkPlayer = make(SoundSynth.chalk(), loops: -1, volume: 0)
        strainPlayer = make(SoundSynth.strain(), loops: -1, volume: 0)
    }

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        // playback + mixWithOthers: audible even with the ring switch silenced
        // (people will judge this on a muted iPad), and polite to other audio.
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    private func make(_ data: Data, loops: Int, volume: Float) -> AVAudioPlayer? {
        guard let player = try? AVAudioPlayer(data: data) else { return nil }
        player.numberOfLoops = loops
        player.volume = volume
        player.prepareToPlay()
        return player
    }

    // MARK: - The lesson in progress

    func startChalk(volume: Float = 0.26) {
        prepareIfNeeded()
        guard enabled, let player = chalkPlayer else { return }
        if !player.isPlaying {
            player.volume = 0
            player.play()
        }
        player.setVolume(volume, fadeDuration: 0.9)
    }

    func stopChalk() {
        chalkPlayer?.setVolume(0, fadeDuration: 0.9)
    }

    // MARK: - Squinting

    /// Volume follows strain, so the sound gets louder the longer they hold.
    func setStrain(_ level: Double) {
        prepareIfNeeded()
        guard enabled, let player = strainPlayer else { return }
        if !player.isPlaying {
            player.volume = 0
            player.play()
        }
        let clamped = max(0.0, min(1.0, level))
        let target = clamped < 0.02 ? 0 : Float(0.05 + 0.33 * clamped)
        player.setVolume(target, fadeDuration: 0.15)
    }

    func stopStrain() {
        strainPlayer?.setVolume(0, fadeDuration: 0.7)
    }

    // MARK: - One shots

    func chime() {
        play(SoundSynth.glassesChime(), volume: 0.85)
    }

    func thud() {
        play(SoundSynth.thud(), volume: 0.60)
    }

    private func play(_ data: Data, volume: Float) {
        prepareIfNeeded()
        guard enabled else { return }
        guard let player = try? AVAudioPlayer(data: data) else { return }
        player.volume = volume
        player.prepareToPlay()
        player.play()
        oneShots.removeAll { !$0.isPlaying }
        oneShots.append(player)
        if oneShots.count > 6 {
            oneShots.removeFirst(oneShots.count - 6)
        }
    }

    // MARK: - Mute

    func setEnabled(_ value: Bool) {
        enabled = value
        if value {
            prepareIfNeeded()
        } else {
            chalkPlayer?.stop()
            strainPlayer?.stop()
        }
    }
}
