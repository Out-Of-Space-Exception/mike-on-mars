"""Compare delivered WAVs with downloaded originals; never alter game assets.

Usage: python conferir-audios.py DIRECTORY_WITH_ORIGINALS
Requires numpy and the imageio-ffmpeg used for the reference video.
"""
from pathlib import Path
import csv, hashlib, subprocess, sys, zipfile
import numpy as np
sys.path.insert(0, str(Path.home() / 'AppData/Local/Temp/mike-video-deps'))
import imageio_ffmpeg

root = Path(__file__).resolve().parents[2]
source = Path(sys.argv[1]).resolve()
for name in ('interface-sounds', 'sci-fi-sounds'):
    archive = source / (name + '.zip')
    if archive.exists():
        with zipfile.ZipFile(archive) as z:
            # Reject paths outside the temporary extraction directory.
            target = source / name
            for member in z.namelist():
                if not (target / member).resolve().is_relative_to(target.resolve()):
                    raise ValueError('Unsafe archive path')
            z.extractall(target)

def pcm(path):
    raw = subprocess.check_output([imageio_ffmpeg.get_ffmpeg_exe(), '-v', 'error',
        '-i', str(path), '-f', 'f32le', '-ac', '1', '-ar', '44100', '-'])
    return np.frombuffer(raw, dtype='<f4')

originals = [(p, pcm(p)) for p in source.rglob('*')
             if p.suffix.lower() in ('.wav', '.ogg', '.mp3')]
rows = []
for delivered in sorted((root / 'conteudo/01-sons/sons').glob('*.wav')):
    audio = pcm(delivered)
    best = (0.0, '', '')
    for path, original in originals:
        # Full-length aligned comparison only. No match does not disprove origin.
        if abs(len(audio) - len(original)) > 2205:
            continue
        count = min(len(audio), len(original))
        a, b = audio[:count].astype('float64'), original[:count].astype('float64')
        denom = np.linalg.norm(a) * np.linalg.norm(b)
        score = float(np.dot(a, b) / denom) if denom else 0.0
        if score > best[0]:
            best = (score, path.relative_to(source).as_posix(),
                    hashlib.sha256(path.read_bytes()).hexdigest())
    matched = best[0] >= 0.9999
    method = 'PCM mono 44100 Hz; alinhamento integral; similaridade >= 0.9999'
    if not matched:
        # Find edited excerpts, then compare the central half (excluding fades).
        for path, original in originals:
            if len(original) <= len(audio):
                continue
            a, b = audio.astype('float64'), original.astype('float64')
            size = 1 << (len(a) + len(b) - 1).bit_length()
            corr = np.fft.irfft(np.fft.rfft(b, size) * np.fft.rfft(a[::-1], size), size)
            offset = int(np.argmax(corr)) - len(a) + 1
            if offset < 0 or offset + len(a) > len(b):
                continue
            lo, hi = len(a)//4, 3*len(a)//4
            aa, bb = a[lo:hi], b[offset+lo:offset+hi]
            denom = np.linalg.norm(aa) * np.linalg.norm(bb)
            score = float(np.dot(aa, bb)/denom) if denom else 0
            if score >= 0.9999:
                best = (score, path.relative_to(source).as_posix(), hashlib.sha256(path.read_bytes()).hexdigest())
                matched = True
                method = f'Trecho inicia em {offset/44100:.6f} s; metade central corresponde; bordas editadas nao verificadas.'
                break
    rows.append([delivered.name, 'correspondencia de sinal' if matched else 'CONFERIR',
                 best[1], f'{best[0]:.8f}', hashlib.sha256(delivered.read_bytes()).hexdigest(),
                 best[2], method if matched
                 else 'Sem correspondencia integral confirmada; pode haver corte, loop ou edicao.'])
with (Path(__file__).parent / 'audios-conferidos.csv').open('w', encoding='utf-8', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['arquivo', 'resultado', 'original_candidato', 'similaridade',
                     'sha256_entrega', 'sha256_original', 'metodo_ou_pendencia'])
    writer.writerows(rows)
print(f'{sum(r[1] != "CONFERIR" for r in rows)}/{len(rows)} correspondencias de sinal')
