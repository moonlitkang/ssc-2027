import Foundation

/// Every sound in this piece is generated from a few lines of maths at launch.
///
/// No audio files, no downloads, nothing bundled: the submission stays fully
/// offline and the package stays tiny. Each function returns a complete mono
/// 16-bit WAV in memory, ready to hand to AVAudioPlayer.
enum SoundSynth {

    static let sampleRate = 44_100.0

    // MARK: - Chalk on a board

    /// The board being written on, once, in a handful of strokes.
    ///
    /// The first version of this was a continuous hiss: band noise gated by a
    /// 1.35 Hz sine, looped forever underneath every scene. Measured, it sat at
    /// twelve thousand zero crossings a second and read as tape hiss, not
    /// chalk, because real chalk is a series of dry, separate scratches with
    /// silence in between. A loop also fills the silences this piece depends on,
    /// so it is now an event with an end rather than a bed.
    ///
    /// `distance` goes 0 at the board to 1 in the last row. It dulls the
    /// spectrum and drops the level, so the board is heard the way it is seen:
    /// less of it, the further back you sit.
    static func board(distance: Double, seconds: Double = 2.2) -> Data {
        let n = Int(sampleRate * seconds)
        var buffer = [Double](repeating: 0, count: n)
        var noise = Noise()

        // A hand does not keep time, so the strokes are placed on an irregular
        // grid: short scrapes, uneven gaps, uneven pressure.
        var t = 0.04
        while t < seconds - 0.26 {
            let dur = 0.055 + 0.075 * abs(noise.next())
            let gain = 0.42 + 0.53 * abs(noise.next())
            let start = Int(t * sampleRate)
            let length = Int(dur * sampleRate)
            var low = 0.0
            var high = 0.0

            for j in 0..<length {
                let index = start + j
                if index >= n { break }
                let tr = Double(j) / sampleRate
                let attack = min(1.0, tr / 0.003)
                let envelope = attack * exp(-tr * 24.0)
                let raw = noise.next()
                low += (raw - low) * 0.42    // keep everything below ~6 kHz
                high += (raw - high) * 0.08  // throw away everything below ~1.1 kHz
                buffer[index] += (low - high) * envelope * gain
            }

            t += dur + 0.018 + 0.075 * abs(noise.next())
        }

        // The chalk being put back on the tray: one last, lower, shorter scrape.
        // Without it the sound stops in mid-air.
        let tapStart = Int((seconds - 0.17) * sampleRate)
        if tapStart > 0 && tapStart < n {
            var dull = 0.0
            let tapLength = Int(0.12 * sampleRate)
            for j in 0..<tapLength {
                let index = tapStart + j
                if index >= n { break }
                let tr = Double(j) / sampleRate
                let raw = noise.next()
                dull += (raw - dull) * 0.18
                buffer[index] += dull * exp(-tr * 42.0) * 0.85
            }
        }

        // Distance: a duller, quieter board.
        let alpha = 0.42 - 0.28 * distance
        let distanceGain = 1.0 - 0.68 * distance
        var lowpass = 0.0
        var samples = [Double]()
        samples.reserveCapacity(n)
        for sample in buffer {
            lowpass += (sample - lowpass) * alpha
            samples.append(lowpass * distanceGain * 1.05)
        }

        return wav(from: fadeEdges(samples, fade: 0.05))
    }

    // MARK: - Breathing

    /// A breath in, and a breath out, as two separate events.
    ///
    /// This is not ambience. People hold their breath when they try to see
    /// something, and let it go when they give up, so the sound is tied to the
    /// press and the release rather than looped underneath. That makes the
    /// gesture audible without ever competing with the silence between tries.
    static func breath(inhaling: Bool) -> Data {
        let seconds = inhaling ? 0.75 : 0.95
        let n = Int(sampleRate * seconds)
        var noise = Noise()
        var low = 0.0
        var high = 0.0
        var samples = [Double]()
        samples.reserveCapacity(n)

        for i in 0..<n {
            let t = Double(i) / sampleRate
            let p = min(1.0, t / seconds)
            let envelope: Double
            if inhaling {
                // Air pulled in: builds quickly, then stops rather than fades.
                let rise = pow(min(1.0, p / 0.55), 1.6)
                let cutoff = p > 0.86 ? max(0.0, 1.0 - (p - 0.86) / 0.14) : 1.0
                envelope = rise * cutoff
            } else {
                // Let go: starts at full and falls away.
                envelope = pow(1.0 - p, 1.3) * min(1.0, p / 0.08)
            }

            let raw = noise.next()
            low += (raw - low) * (inhaling ? 0.30 : 0.22)
            high += (raw - high) * 0.05
            samples.append((low - high) * envelope * (inhaling ? 0.22 : 0.17))
        }

        return wav(from: fadeEdges(samples, fade: 0.03))
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

        // withUnsafeBytes takes a value, not an inout pointer: passing `&le`
        // here does not compile.
        func append32(_ value: UInt32) {
            let le = value.littleEndian
            withUnsafeBytes(of: le) { data.append(contentsOf: $0) }
        }
        func append16(_ value: UInt16) {
            let le = value.littleEndian
            withUnsafeBytes(of: le) { data.append(contentsOf: $0) }
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
