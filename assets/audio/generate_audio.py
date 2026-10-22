"""Rebuild Foxlike's original soundtrack and effects. Requires NumPy and ffmpeg.

All notes, synthesis and arrangements are authored for Foxlike; no sampled assets.
Music is 32-bar seamless stereo Vorbis. Synth tails wrap around the loop.
Run from any directory: python assets/audio/generate_audio.py
"""
from pathlib import Path
import wave
import subprocess
import numpy as np

OUT = Path(__file__).parent
SR = 22050
RNG = np.random.default_rng(4087)


def hz(midi):
    return 440 * 2 ** ((midi - 69) / 12)


def write(name, signal, target=0.86):
    peak = max(1e-6, float(np.max(np.abs(signal))))
    signal = signal * min(target / peak, 1.0)
    pcm = (np.clip(signal, -1, 1) * 32767).astype("<i2")
    with wave.open(str(OUT / name), "wb") as f:
        f.setnchannels(1 if pcm.ndim == 1 else 2)
        f.setsampwidth(2)
        f.setframerate(SR)
        f.writeframes(pcm.tobytes())


def tone(midi, duration, voice="lead"):
    n = max(1, int((duration + 0.12) * SR))
    t = np.arange(n) / SR
    freq = hz(midi)
    phase = 2 * np.pi * freq * t
    attack = np.minimum(t / 0.018, 1)
    release = np.clip((duration + 0.12 - t) / 0.14, 0, 1)
    if voice == "pad":
        wave_ = (np.sin(phase) + 0.30 * np.sin(phase * 2.002)
                 + 0.13 * np.sin(phase * 3.001)) * 0.65
        env = np.minimum(t / 0.19, 1) * np.minimum((duration + 0.12 - t) / 0.25, 1)
    elif voice == "bass":
        wave_ = np.sin(phase) + 0.24 * np.sin(phase * 2) + 0.09 * np.sin(phase * 3)
        env = attack * release * (0.60 + 0.40 * np.exp(-t * 9))
    elif voice == "pluck":
        wave_ = np.sin(phase) + 0.32 * np.sin(phase * 2) + 0.13 * np.sin(phase * 3)
        env = np.minimum(t / 0.006, 1) * np.exp(-t * 9) * release
    elif voice == "bell":
        wave_ = np.sin(phase) + 0.25 * np.sin(phase * 3) + 0.09 * np.sin(phase * 5)
        env = np.minimum(t / 0.008, 1) * np.exp(-t * 4) * release
    else:
        # A soft pulse-like lead with vibrato, never an unfiltered square wave.
        vibrato = 0.010 * np.sin(t * 2 * np.pi * 5.1) * np.minimum(t / 0.2, 1)
        wave_ = (np.sin(phase + vibrato) + 0.21 * np.sin(phase * 3 + vibrato)
                 + 0.065 * np.sin(phase * 5))
        env = attack * release * (0.84 + 0.16 * np.exp(-t * 8))
    return wave_ * env


def kick():
    t = np.arange(int(SR * 0.25)) / SR
    phase = 2 * np.pi * (45 * t + 66 / 22 * (1 - np.exp(-22 * t)))
    return np.sin(phase) * np.exp(-t * 19) * np.minimum(t * 1000, 1)


def snare():
    t = np.arange(int(SR * 0.18)) / SR
    noise = RNG.uniform(-1, 1, len(t))
    # A tiny moving average softens the noisy transient.
    noise = np.convolve(noise, [0.25, 0.5, 0.25], "same")
    return (0.8 * noise + 0.25 * np.sin(2 * np.pi * 172 * t)) * np.exp(-t * 25)


def hat():
    t = np.arange(int(SR * 0.065)) / SR
    noise = RNG.uniform(-1, 1, len(t))
    noise -= np.roll(noise, 1) * 0.85
    return noise * np.exp(-t * 75) * 0.3


def music(stage, boss):
    bpm = [128, 138, 144][stage] + (10 if boss else 0)
    beat = 60 / bpm
    length = int(SR * beat * 128)
    result = np.zeros((length, 2), dtype=np.float64)

    def put(sound, at, amp=1.0, pan=0.0, echo=False):
        offset = int(at * SR)
        idx = (np.arange(len(sound)) + offset) % length
        left, right = np.sqrt((1 - pan) / 2), np.sqrt((1 + pan) / 2)
        np.add.at(result[:, 0], idx, sound * amp * left)
        np.add.at(result[:, 1], idx, sound * amp * right)
        if echo:
            ei = (idx + int(beat * 0.75 * SR)) % length
            np.add.at(result[:, 0], ei, sound * amp * 0.15 * right)
            np.add.at(result[:, 1], ei, sound * amp * 0.15 * left)

    # Distinct harmonic identities, with a dominant in the last bar to return.
    chords = [
        [[45, 48, 52], [41, 45, 48], [48, 52, 55], [43, 47, 50],
         [45, 48, 52], [41, 45, 48], [38, 41, 45], [40, 44, 47]],
        [[38, 41, 45], [46, 50, 53], [41, 45, 48], [36, 40, 43],
         [38, 41, 45], [43, 46, 50], [46, 50, 53], [45, 49, 52]],
        [[40, 43, 47], [36, 40, 43], [43, 47, 50], [38, 42, 45],
         [40, 43, 47], [45, 48, 52], [36, 40, 43], [35, 39, 42]],
    ][stage]
    # Sparse melody has a two-bar question, answer, ascent, then homeward turn.
    melodies = [
        [[76, 0, 79, 81, 0, 79, 76, 74], [72, 0, 69, 72, 76, 0, 74, 72],
         [76, 0, 79, 0, 84, 83, 79, 76], [74, 0, 71, 74, 0, 79, 78, 74],
         [81, 0, 83, 84, 0, 83, 81, 79], [81, 0, 76, 72, 0, 74, 76, 77],
         [77, 0, 74, 72, 69, 0, 72, 74], [76, 0, 75, 0, 71, 0, 68, 0]],
        [[74, 0, 77, 0, 81, 0, 77, 76], [74, 0, 70, 74, 77, 0, 82, 81],
         [81, 0, 77, 76, 72, 0, 77, 0], [79, 0, 76, 0, 72, 74, 76, 79],
         [86, 0, 81, 0, 77, 79, 81, 84], [82, 0, 79, 77, 0, 74, 77, 79],
         [82, 0, 81, 77, 74, 0, 70, 74], [73, 0, 76, 0, 81, 0, 73, 0]],
        [[76, 79, 83, 0, 81, 79, 76, 0], [76, 0, 79, 84, 83, 79, 76, 0],
         [79, 83, 86, 0, 83, 81, 79, 0], [78, 0, 81, 86, 84, 81, 78, 0],
         [88, 0, 86, 83, 81, 79, 76, 0], [81, 0, 84, 88, 86, 84, 81, 0],
         [84, 83, 79, 0, 76, 0, 72, 0], [75, 0, 78, 0, 83, 81, 78, 75]],
    ][stage]
    for bar in range(32):
        notes = chords[bar % 8]
        phrase = bar // 8
        base = bar * 4 * beat
        for i, note in enumerate(notes):
            put(tone(note + 12, beat * 3.9, "pad"), base, .075, (i - 1) * .65)
        pattern = [0, 1, 2, 1, 0, 2, 1, 2]
        for step, chord_index in enumerate(pattern):
            pan = -.45 if step % 2 == 0 else .45
            octave = 24 if step % 4 != 3 else 36
            put(tone(notes[chord_index] + octave, beat * .44, "pluck"),
                base + step * beat * .5, .10 if not boss else .13, pan, True)
        for step in range(8):
            pitch = notes[0] - 12 + (12 if step in [3, 7] else 0)
            put(tone(pitch, beat * .41, "bass"), base + step * beat * .5,
                .24 if step % 2 == 0 else .14)
        for step, note in enumerate(melodies[bar % 8]):
            if note:
                # The second phrase drops into the lower register; the third
                # leaves space for an answering bell voice, then the lead returns.
                if not (phrase == 2 and step in [1, 3, 6]):
                    melody_note = note - (12 if phrase == 1 else 0)
                    put(tone(melody_note, beat * (.72 if step % 2 == 0 else .40), "lead"),
                        base + step * beat * .5, .13 if phrase != 1 else .16, -.10, True)
                if (boss and bar % 8 >= 4) or phrase == 3:
                    put(tone(note - 12, beat * .38, "bell"),
                        base + step * beat * .5, .07, .25, True)
        if phrase in [1, 2]:
            for answer, step in enumerate([1.5, 2.5, 3.5]):
                put(tone(notes[answer % 3] + 36, beat * .72, "bell"),
                    base + step * beat, .09 if phrase == 2 else .045, .45, True)
        for step in range(4):
            if step % 2 == 0 or boss or phrase == 3:
                put(kick(), base + step * beat, .44 if boss else .36)
            if step % 2 == 1:
                put(snare(), base + step * beat, .29 if boss else .22, .04)
        for step in range(8 if not boss else 16):
            put(hat(), base + step * beat * (.5 if not boss else .25), .13, .3)
        if bar % 8 in [3, 7]:
            for step in range(4):
                put(snare(), base + (3 + step * .25) * beat, .10 + step * .025, -.3 + step * .2)
    # Gentle saturation preserves musical dynamics and rounds peaks.
    result = np.tanh(result * 1.5) * .80
    name = ["viridia", "aurora", "terminus"][stage] + ("_boss" if boss else "")
    wav_path = OUT / f"{name}.wav"
    write(wav_path.name, result, .88)
    subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y",
                    "-i", str(wav_path), "-c:a", "libvorbis", "-q:a", "4",
                    str(OUT / f"{name}.ogg")], check=True)
    wav_path.unlink()


def sweep(start, end, duration, decay=6, noise=0):
    t = np.arange(int(SR * duration)) / SR
    freq = start + (end - start) * np.minimum(t / duration, 1)
    phase = 2 * np.pi * np.cumsum(freq) / SR
    env = np.minimum(t * 1000, 1) * np.exp(-t * decay) * np.clip((duration - t) / .02, 0, 1)
    return (np.sin(phase) + RNG.uniform(-noise, noise, len(t))) * env


def effects():
    write("laser.wav", sweep(1500, 360, .14, 21) * .5)
    write("hit.wav", sweep(270, 62, .16, 20, .6) * .65)
    write("explosion.wav", sweep(105, 29, .85, 4.8, 1.2) * .62)
    write("roll.wav", sweep(260, 760, .36, 4.5, .06) * .30)
    write("boost.wav", sweep(70, 240, .6, 2.8, .3) * .30)
    write("missile.wav", sweep(800, 85, .55, 4.3, .35) * .50)
    for name, notes, spacing in [
        ("lock", [81, 88], .07), ("pickup", [76, 79, 83, 88], .09),
        ("warning", [69, 0, 69], .11), ("ui", [76, 83], .04),
        ("victory", [69, 76, 81, 83, 84, 88, 93], .16),
        ("death", [76, 71, 67, 64, 59, 52], .16),
    ]:
        signal = np.zeros(int(SR * (len(notes) * spacing + .65)))
        for i, note in enumerate(notes):
            if note:
                sound = tone(note, .38 if name in ["victory", "death"] else .11, "bell") * .42
                start = int(i * spacing * SR)
                signal[start:start + len(sound)] += sound
        write(name + ".wav", signal, .70)


if __name__ == "__main__":
    for level in range(3):
        for intense in [False, True]:
            music(level, intense)
    effects()
    assets = list(OUT.glob('*.wav')) + list(OUT.glob('*.ogg'))
    print(f"Wrote {len(assets)} original audio files; "
          f"{sum(x.stat().st_size for x in assets) / 1024**2:.2f} MiB")
