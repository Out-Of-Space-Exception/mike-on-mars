from pathlib import Path
import sys,os,asyncio,subprocess,wave,json
ROOT=Path(__file__).resolve().parents[2];OUT=Path(__file__).resolve().parent
for name in ['mike-video-deps','mike-voz-deps']:
 sys.path.insert(0,str(Path.home()/'AppData/Local/Temp'/name))
 sys.path.insert(0,str(Path(os.environ['TEMP'])/name))
import edge_tts,imageio_ffmpeg
PHRASES=[
 'Como crianças aprendem a cuidar de uma base em Marte?',
 'Em Mike on Mars, elas constroem, cultivam e exploram.',
 'Tempestades do arquivo DONKI, da NASA, inspiram escolhas no jogo.',
 'Proteger Mike custa energia. Cada escolha muda o plano.',
 'Explorar revela cartas com fotos e descobertas reais da NASA.',
 'Mike on Mars. Ciência para descobrir brincando.'
]
STARTS=[0,4,9,15,20,25];DURATIONS=[4,5,6,5,5,4]
EN=[
 'How do children learn to run a base on Mars?',
 'In Mike on Mars, they build, grow and explore.',
 "Storms from NASA's DONKI archive inspire choices in the game.",
 'Protecting Mike costs energy. Each choice changes the plan.',
 'Exploring reveals cards with real NASA photos and discoveries.',
 'Mike on Mars. Discover science through play.'
]
if os.environ.get('MIKE_PITCH_EN')=='1':
 PHRASES=[
  'How can kids train for Mars?',
  'Build, grow, and collect real NASA discoveries.',
  "Archived NASA data powers the game's storms.",
  'Protect Mike or save power? You decide.',
  'Kids practice resource management through play.',
  'Mike on Mars. Small choices, real science.'
 ]
 EN=PHRASES[:]
async def main():
 english=os.environ.get('MIKE_PITCH_EN')=='1'
 folder=OUT/('narracao-ingles' if english else 'narracao-sintetica');folder.mkdir(exist_ok=True)
 ff=imageio_ffmpeg.get_ffmpeg_exe();tracks=[];stats=[]
 for i,phrase in enumerate(PHRASES):
  mp3=folder/f'fala-{i+1:02}.mp3';wav=folder/f'fala-{i+1:02}.wav'
  await edge_tts.Communicate(phrase,'en-US-AriaNeural' if english else 'pt-BR-FranciscaNeural',rate='+5%').save(str(mp3))
  subprocess.run([ff,'-y','-v','error','-i',str(mp3),'-ar','48000','-ac','1',str(wav)],check=True)
  with wave.open(str(wav)) as w:duration=w.getnframes()/w.getframerate()
  rate=max(1,duration/(DURATIONS[i]-.25))
  if rate>1.35:raise RuntimeError(f'Phrase {i+1} too long: {duration}')
  fixed=folder/f'tempo-{i+1:02}.wav'
  subprocess.run([ff,'-y','-v','error','-i',str(wav),'-af',f'atempo={rate:.6f},apad','-t',str(DURATIONS[i]),'-ar','48000','-ac','1',str(fixed)],check=True)
  with wave.open(str(fixed)) as w:tracks.append(w.readframes(w.getnframes()))
  stats.append({'scene':i+1,'original_seconds':round(duration,3),'speed_adjustment':round(rate,3)})
 with wave.open(str(OUT/('narracao-sintetica-en.wav' if english else 'narracao-sintetica-pt.wav')),'wb') as w:
  w.setnchannels(1);w.setsampwidth(2);w.setframerate(48000);w.writeframes(b''.join(tracks))
 (folder/'tempos.json').write_text(json.dumps(stats,indent=2),encoding='utf-8')
 print('Synthetic narration created: 29 seconds; '+('en-US-AriaNeural' if english else 'pt-BR-FranciscaNeural'))
if __name__=='__main__':asyncio.run(main())
