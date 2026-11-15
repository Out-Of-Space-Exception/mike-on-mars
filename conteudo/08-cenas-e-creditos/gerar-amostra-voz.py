"""Create a synthetic English voice sample from the approved script 2."""
from pathlib import Path
import asyncio
import subprocess
import sys
import wave

for package in ('mike-voz-deps', 'mike-video-deps'):
    sys.path.insert(0, str(Path.home() / 'AppData/Local/Temp' / package))
import edge_tts
import imageio_ffmpeg

OUT = Path(__file__).resolve().parent
SCRIPT = OUT.parent / '07-roteiro-do-video/roteiro-rascunho-2.md'
VOICE = 'en-US-AndrewMultilingualNeural'

async def main():
    lines = [line.split('|')[-2].strip() for line in SCRIPT.read_text(encoding='utf-8').splitlines()
             if line.startswith('| ') and ' s |' in line]
    if len(lines) != 6:
        raise ValueError('Expected the six approved narration lines')
    mp3 = OUT / 'amostra-voz-andrew-en.mp3'
    await edge_tts.Communicate(' '.join(lines), VOICE, rate='-3%').save(str(mp3))
    wav = OUT / 'amostra-voz-andrew-en.wav'
    subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), '-y', '-v', 'error',
                    '-i', str(mp3), '-ar', '48000', '-ac', '1', str(wav)], check=True)
    with wave.open(str(wav)) as audio:
        print(f'{VOICE}: {audio.getnframes()/audio.getframerate():.2f} s; {mp3.name}')

if __name__ == '__main__':
    asyncio.run(main())
