import Foundation

/// Every sound in this piece is generated from a few lines of maths at launch.
///
/// No audio files, no downloads, nothing bundled: the submission stays fully
/// offline and the package stays tiny. Each function returns a complete mono
/// 16-bit WAV in memory, ready to hand to AVAudioPlayer.
enum SoundSynth {

    static let sampleRate = 44_100.0

    // MARK: - Chalk on a board

    /// Filtered noise with pressure that comes and goes in strokes.
    /// Looping this under a scene is enough to suggest a lesson already in progress.
    static func chalk(seconds: Double = 2.4) -> Data {
        let n = Int(sampleRate * seconds)
        var noise = Noise()
        var low = 0.0
        var high = 0.0
        var samples = [Double]()
        samples.reserveCapacity(n)

        for i in 0..<n {
            let t = Double(i) / sampleRate
            let raw = noise.next()
            low += (raw - low) * 0.28
            high += (raw - high) * 0.02
            let grit = low - high

            let stroke = max(0.0, sin(2 * .pi * 1.35 * t + 0.7))
            let drift = 0.60 + 0.40 * sin(2 * .pi * 0.41 * t)
            samples.append(grit * 0.26 * (0.30 + 0.70 * stroke) * drift)
        }
        return wav(from: fadeEdges(samples, fade: 0.08))
    }

    // MARK: - Pressure behind the eyes

    /// Three low tones. Both frequencies complete a whole number of cycles in
    /// three seconds, so the loop has no seam and no click.
    static func strain(seconds: Double = 3.0) -> Data {
        let n = Int(sampleRate * seconds)
        var samples = [Double]()
        samples.reserveCapacity(n)

        for i in 0..<n {
            let t = Double(i) / sampleRate
            let a = sin(2 * .pi * 48 * t)
            let b = sin(2 * .pi * 97 * t) * 0.45
            let c = sin(2 * .pi * 146 * t) * 0.16
            let swell = 0.86 + 0.14 * sin(2 * .pi * (1.0 / 3.0) * t)
            samples.append((a + b + c) * 0.17 * swell)
        }
        return wav(from: samples)
    }

    // MARK: - Glasses

    /// A bright, dry chime: two metal partials with a short noise transient.
    static func glassesChime() -> Data {
        let seconds = 1.05
        let n = Int(sampleRate * seconds)
        var noise = Noise()
        var samples = [Double]()
        samples.reserveCapacity(n)

        for i in 0..<n {
            let t = Double(i) / sampleRate
            let attack = min(1.0, t / 0.004)
            let tail = exp(-t * 6.2)
            let a = sin(2 * .pi * 2_093 * t) * 0.48
            let b = sin(2 * .pi * 3_136 * t) * 0.26
            let c = sin(2 * .pi * 5_274 * t) * 0.10
            let click = noise.next() * 0.16 * exp(-t * 130)
            samples.append((a + b + c) * attack * tail + click)
        }
        return wav(from: samples)
    }

    // MARK: - Weeks passing

    /// A soft low hit for the jump between rows. The pitch falls as it decays,
    /// which is what makes it read as "time moved" rather than "a drum played".
    static func thud() -> Data {
        let seconds = 0.55
        let n = Int(sampleRate * seconds)
        var samples = [Double]()
        samples.reserveCapacity(n)

        for i in 0..<n {
            let t = Double(i) / sampleRate
            let frequency = 42.0 + 96.0 * exp(-t * 5.0)
            let attack = min(1.0, t / 0.006)
            let tail = exp(-t * 9.0)
            samples.append(sin(2 * .pi * frequency * t) * attack * tail * 0.55)
        }
        return wav(from: samples)
    }

    // MARK: - Plumbing

    /// A deterministic white-noise source. No dependency on the system RNG, so
    /// a given sound is bit-identical on every launch.
    private struct Noise {
        private var state: UInt64 = 0x9E37_79B9_7F4A_7C15

        mutating func next() -> Double {
            state ^= state << 13
            state ^= state >> 7
            state ^= state << 17
            return Double(state % 20_000) / 10_000.0 - 1.0
        }
    }

    private static func fadeEdges(_ samples: [Double], fade: Double) -> [Double] {
        let f = Int(sampleRate * fade)
        guard f > 1, f * 2 < samples.count else { return samples }
        var out = samples
        for i in 0..<f {
            let gain = Double(i) / Double(f)
            out[i] *= gain
            out[out.count - 1 - i] *= gain
        }
        return out
    }

    /// Wraps floating point samples in a canonical 44-byte WAV header.
    private static func wav(from samples: [Double]) -> Data {
        var data = Data()
        let count = samples.count
        let byteRate = Int(sampleRate) * 2

        func append32(_ value: UInt32) {
            var le = value.littleEndian
            withUnsafeBytes(of: &le) { data.append(contentsOf: $0) }
        }
        func append16(_ value: UInt16) {
            var le = value.littleEndian
            withUnsafeBytes(of: &le) { data.append(contentsOf: $0) }
        }

        data.append(contentsOf: Array("RIFF".utf8))
        append32(UInt32(36 + count * 2))
        data.append(contentsOf: Array("WAVE".utf8))
        data.append(contentsOf: Array("fmt ".utf8))
        append32(16)
        append16(1)
        append16(1)
        append32(UInt32(sampleRate))
        append32(UInt32(byteRate))
        append16(2)
        append16(16)
        data.append(contentsOf: Array("data".utf8))
        append32(UInt32(count * 2))

        for sample in samples {
            let clamped = max(-1.0, min(1.0, sample))
            append16(UInt16(bitPattern: Int16(clamped * 30_000)))
        }
        return data
    }
}
