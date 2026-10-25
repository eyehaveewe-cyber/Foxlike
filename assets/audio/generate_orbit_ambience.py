#!/usr/bin/env python3
"""Render the observatory's quiet, sample-free ambient loop (NumPy + ffmpeg)."""
from pathlib import Path
import subprocess
import tempfile
import wave
import numpy as np
ROOT = Path(__file__).resolve().parent
RATE, SECONDS = 44100, 48
frames = np.arange(RATE * SECONDS, dtype=np.float64)
t = frames / RATE
stereo = np.zeros((len(frames), 2), dtype=np.float64)
# Quantized whole-loop frequencies preserve waveform and modulation continuity.
for index, frequency in enumerate([73.416, 110.0, 146.832, 184.997, 220.0, 329.628]):
    frequency = round(frequency * SECONDS) / SECONDS
    phase = index * 0.71
    envelope = .55 + .45 * np.sin(2 * np.pi * t / SECONDS + phase) ** 2
    tone = np.sin(2 * np.pi * frequency * t + phase) + .11 * np.sin(2 * np.pi * frequency * 2 * t + phase)
    pan = .22 + .56 * (index % 3) / 2
    gain = .046 if index < 3 else .019
    stereo[:, 0] += tone * envelope * gain * np.sqrt(1 - pan)
    stereo[:, 1] += tone * envelope * gain * np.sqrt(pan)
# A very low orbital hum; no combat percussion or spoken alerts.
stereo += (np.sin(2 * np.pi * 43 * t) * .012)[:, None]
peak = float(np.abs(stereo).max())
assert peak < .7
pcm = np.asarray(stereo * 32767, dtype='<i2')
with tempfile.TemporaryDirectory() as directory:
    wav = Path(directory) / 'orbit.wav'
    with wave.open(str(wav), 'wb') as stream:
        stream.setnchannels(2)
        stream.setsampwidth(2)
        stream.setframerate(RATE)
        stream.writeframes(pcm.tobytes())
    subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-y', '-i', str(wav), '-c:a', 'libvorbis', '-q:a', '4', str(ROOT / 'orbit_ambience.ogg')], check=True)
print(f'48-second original orbit ambience; PCM peak {peak:.4f}')
