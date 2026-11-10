"""Generator musik penenang orisinal untuk Focura (bebas hak cipta)."""
import numpy as np, subprocess, sys
from scipy import signal
SR = 44100
rng = np.random.default_rng(42)

def midi(n): return 440.0 * 2 ** ((n - 69) / 12)

def reverb_ir(seconds=2.8, decay=3.2, seed=1):
    r = np.random.default_rng(seed)
    n = int(SR * seconds); t = np.arange(n) / SR
    env = np.exp(-decay * t)
    ir = np.stack([r.standard_normal(n) * env, r.standard_normal(n) * env], 1)
    b, a = signal.butter(2, 5000 / (SR / 2), 'low')
    ir = signal.lfilter(b, a, ir, axis=0)
    return ir / np.sqrt((ir ** 2).sum(0))

def add_reverb(x, wet=0.35, seconds=2.8, decay=3.2):
    ir = reverb_ir(seconds, decay)
    out = np.zeros((len(x) + len(ir) - 1, 2))
    for c in range(2):
        out[:, c] = signal.fftconvolve(x[:, c], ir[:, c])
    out *= wet                      # seluruh sinyal basah (termasuk ekor)
    out[:len(x)] += x * (1 - wet)
    return out

def wrap(y, L):
    """Jadikan loop mulus: ekor setelah L ditambahkan ke awal."""
    out = y[:L].copy()
    tail = y[L:]
    while len(tail):
        k = min(len(tail), L)
        out[:k] += tail[:k]
        tail = tail[k:]
    return out

def xfade_loop(y, L):
    X = len(y) - L
    out = y[:L].copy()
    t = np.linspace(0, np.pi / 2, X)[:, None]
    out[:X] = y[:X] * np.sin(t) + y[L:L + X] * np.cos(t)
    return out

def norm_peak(y, db=-3.0):
    return y / np.abs(y).max() * 10 ** (db / 20)

def norm_rms(y, db=-20.0):
    rms = np.sqrt((y ** 2).mean())
    y = y / rms * 10 ** (db / 20)
    peak = np.abs(y).max()
    return y if peak < 0.95 else y / peak * 0.95

def pan(mono, p):  # p -1..1
    l = np.cos((p + 1) * np.pi / 4); r = np.sin((p + 1) * np.pi / 4)
    return np.stack([mono * l, mono * r], 1)

def piano_note(freq, dur, vel):
    n = int(SR * dur); t = np.arange(n) / SR
    tone = np.zeros(n)
    for h, amp in enumerate([1, .45, .22, .12, .06, .03], start=1):
        f = freq * h * (1 + 0.0004 * h * h)
        if f > SR / 2.2: break
        tone += amp * np.sin(2 * np.pi * f * t) * np.exp(-t * (1.1 + 0.9 * h) * (freq / 400) ** 0.3)
    att = np.minimum(1, t / 0.006)
    rel = np.minimum(1, (dur - t) / 0.25).clip(0)
    return tone * att * rel * vel

CHORDS = [  # Cmaj7, Am7, Fmaj7, G6 (tenang)
    [48, 55, 60, 64, 67, 71, 72, 76],
    [45, 52, 57, 60, 64, 67, 69, 72],
    [41, 48, 53, 57, 60, 64, 65, 69],
    [43, 50, 55, 59, 62, 64, 67, 71],
]

def piano_track(seconds_per_chord=4.0, cycles=4):
    beat = seconds_per_chord / 8
    L = int(SR * seconds_per_chord * 4 * cycles)
    y = np.zeros((L + SR * 8, 2))
    for cyc in range(cycles):
        for ci, chord in enumerate(CHORDS):
            start = (cyc * 4 + ci) * seconds_per_chord
            # bass
            for note, p in [(chord[0], -0.2), (chord[0] + 12, -0.1)]:
                s = piano_note(midi(note), seconds_per_chord * 1.6, 0.30)
                i = int(start * SR); y[i:i + len(s)] += pan(s, p)
            # arpeggio (pola berbeda tiap siklus)
            pattern = rng.permutation(range(2, 8))[:6] if cyc % 2 else [2, 3, 4, 5, 6, 7]
            steps = [0, 1, 2, 3, 4, 5]
            for k, step in enumerate(steps):
                if cyc == 3 and k in (1, 4):  # variasi: beberapa ketukan diam
                    continue
                note = chord[pattern[k % len(pattern)]]
                t0 = start + step * beat * 1.33 + rng.uniform(-0.01, 0.01)
                s = piano_note(midi(note), 3.2, rng.uniform(0.16, 0.26))
                i = int(t0 * SR); y[i:i + len(s)] += pan(s, rng.uniform(-0.5, 0.5))
            # melodi kecil di siklus 2 & 4
            if cyc in (1, 3):
                mel = chord[7] + 12 if ci % 2 == 0 else chord[6] + 12
                s = piano_note(midi(mel), 3.0, 0.12)
                i = int((start + beat * 5) * SR); y[i:i + len(s)] += pan(s, 0.3)
    y = add_reverb(y, wet=0.4, seconds=3.2, decay=2.4)
    return norm_peak(wrap(y, L), -4)

def pad_track(seconds_per_chord=8.0, cycles=2):
    L = int(SR * seconds_per_chord * 4 * cycles)
    t = np.arange(L) / SR
    out = np.zeros((L, 2))
    total = 4 * cycles
    for k in range(total):
        chord = CHORDS[k % 4]
        center = (k + 0.5) * seconds_per_chord
        # envelope periodik (raised-cosine), lebar 2 chord => crossfade halus
        d = ((t - center + L / SR / 2) % (L / SR)) - L / SR / 2
        env = np.where(np.abs(d) < seconds_per_chord, 0.5 * (1 + np.cos(np.pi * d / seconds_per_chord)), 0)
        for j, note in enumerate([chord[0], chord[2], chord[3], chord[4], chord[5]]):
            f = midi(note)
            for det, p in [(-0.12, -0.6), (0.12, 0.6)]:
                ff = f * 2 ** (det / 12 / 10)
                cycles_in_loop = round(ff * L / SR)          # frekuensi pas agar loop mulus
                ff = cycles_in_loop * SR / L
                tone = np.sin(2 * np.pi * ff * t) + 0.25 * np.sin(4 * np.pi * ff * t)
                amp = 0.5 if j == 0 else 0.22
                out += pan(tone * env * amp, p)
    # shimmer tinggi pelan
    lfo = 0.5 * (1 + np.sin(2 * np.pi * t * 3 / (L / SR)))
    for note in (84, 88, 91):
        ff = round(midi(note) * L / SR) * SR / L
        out += pan(np.sin(2 * np.pi * ff * t) * 0.03 * lfo, rng.uniform(-0.7, 0.7))
    b, a = signal.butter(2, 2500 / (SR / 2), 'low')
    tiled = np.concatenate([out, out, out])          # filter melingkar (tanpa efek tepi)
    out = signal.filtfilt(b, a, tiled, axis=0)[L:2 * L]
    y = add_reverb(out, wet=0.45, seconds=4, decay=1.6)  # ekor reverb dililit ke awal
    return norm_peak(wrap(y, L), -5)

def brown(n, seed):
    r = np.random.default_rng(seed)
    w = r.standard_normal(n)
    b = np.cumsum(w)
    bh, ah = signal.butter(1, 20 / (SR / 2), 'high')
    return signal.lfilter(bh, ah, b)

def brown_track(seconds=60):
    L = SR * seconds; X = SR * 3
    y = np.stack([brown(L + X, 1), brown(L + X, 2)], 1)
    b, a = signal.butter(2, 900 / (SR / 2), 'low')
    y = signal.lfilter(b, a, y, axis=0)
    return norm_rms(xfade_loop(y, L), -19)

def rain_track(seconds=60):
    L = SR * seconds; X = SR * 3; n = L + X
    w = rng.standard_normal((n, 2))
    b, a = signal.butter(2, [400 / (SR / 2), 4500 / (SR / 2)], 'band')
    hiss = signal.lfilter(b, a, w, axis=0)
    slow = signal.lfilter(*signal.butter(1, 0.3 / (SR / 2), 'low'), rng.standard_normal(n))
    hiss *= (1 + 0.25 * slow / np.abs(slow).max())[:, None]
    y = hiss * 0.6
    # tetesan
    for _ in range(seconds * 55):
        i = rng.integers(0, n - SR // 10)
        d = int(SR * rng.uniform(0.01, 0.04)); tt = np.arange(d) / SR
        f = rng.uniform(1800, 5500)
        drop = np.sin(2 * np.pi * f * tt * (1 - 0.3 * tt / tt[-1])) * np.exp(-tt * 120) * rng.uniform(0.1, 0.5)
        y[i:i + d] += pan(drop, rng.uniform(-0.9, 0.9))
    # gemuruh pelan
    rumble = np.stack([brown(n, 7), brown(n, 8)], 1)
    rumble = signal.lfilter(*signal.butter(2, 200 / (SR / 2), 'low'), rumble, axis=0)
    y += rumble / np.abs(rumble).max() * 0.25
    return norm_rms(xfade_loop(y, L), -21)

def ocean_track(wave_lengths=(9.5, 11, 8.5, 12, 10, 9)):
    L = int(SR * sum(wave_lengths)); n = L + SR * 3
    base = np.stack([brown(n, 11), brown(n, 12)], 1)
    base /= np.abs(base).max()
    env = np.zeros(n); t0 = 0
    for k in range(len(wave_lengths) + 1):
        wl = wave_lengths[k % len(wave_lengths)]
        m = int(wl * SR); tt = np.arange(m) / m
        e = np.where(tt < 0.4, (tt / 0.4) ** 2, np.exp(-(tt - 0.4) * 5))
        e = 0.25 + 0.75 * e
        seg = e[: max(0, min(m, n - t0))]
        env[t0:t0 + len(seg)] = seg; t0 += m
        if t0 >= n: break
    env = signal.filtfilt(*signal.butter(1, 2 / (SR / 2), 'low'), env)
    lo = signal.lfilter(*signal.butter(2, 500 / (SR / 2), 'low'), base, axis=0)
    hi = signal.lfilter(*signal.butter(2, [1500 / (SR / 2), 6000 / (SR / 2)], 'band'), rng.standard_normal((n, 2)), axis=0)
    y = lo * env[:, None] + hi * (env[:, None] ** 3) * 0.35
    return norm_rms(xfade_loop(y, L), -20)

def save(name, y, kbps):
    pcm = (np.clip(y, -1, 1) * 32767).astype('<i2')
    raw = f'{name}.raw'; pcm.tofile(raw)
    subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-f', 's16le', '-ar', str(SR), '-ac', '2', '-i', raw,
                    '-codec:a', 'libmp3lame', '-b:a', f'{kbps}k', f'{name}.mp3'], check=True)
    import os; os.remove(raw)
    print(name, f'{len(y)/SR:.1f}s', os.path.getsize(f'{name}.mp3') // 1024, 'KB')

which = sys.argv[1:] or ['piano', 'pad', 'rain', 'ocean', 'brown']
if 'piano' in which: save('piano_tenang', piano_track(), 112)
if 'pad' in which: save('ambient_senja', pad_track(), 96)
if 'rain' in which: save('hujan_lembut', rain_track(), 96)
if 'ocean' in which: save('ombak_pantai', ocean_track(), 96)
if 'brown' in which: save('brown_noise', brown_track(), 80)
