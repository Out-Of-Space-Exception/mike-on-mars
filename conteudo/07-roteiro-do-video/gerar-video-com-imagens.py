"""Reference edit using only existing repository images, with no simulated UI."""
from pathlib import Path
import os,sys,subprocess,math
from PIL import Image,ImageDraw,ImageFont,ImageOps,ImageFilter
ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
sys.path.insert(0,str(Path.home()/'AppData/Local/Temp/mike-video-deps'))
sys.path.insert(0,str(Path(os.environ['TEMP'])/'mike-video-deps'))
import imageio_ffmpeg
W,H,FPS=1280,720,24
FONT=str(ROOT/'jogo/web/rubik.ttf')
def f(n): return ImageFont.truetype(FONT,n)
def txt(d,xy,s,n=28,fill='#fff4d9',anchor=None):d.text(xy,s,font=f(n),fill=fill,anchor=anchor)
greenhouse=Image.open(ROOT/'design/05-telas/previa-plantas-estufa.png').convert('RGB')
# Remove only phone browser chrome and bottom operating-system navigation.
greenhouse=greenhouse.crop((0,172,greenhouse.width,1567))
shelf=Image.open(ROOT/'design/05-telas/estante/tela-2-zoom.png').convert('RGB')
photo=Image.open(ROOT/'conteudo/02-cartas/fotos/09-enxofre.png').convert('RGB')
logo=Image.open(ROOT/'design/06-logo-e-icone/logo.png').convert('RGB')
qr=Image.open(ROOT/'ferramentas/qr-code.png').convert('RGB')
times=[0,4,9,15,20,25,29]
captions=['Can you run a base on Mars?','Build your base. Grow space food.',
          'NASA DONKI. Archived storms. Real choices.','Raise the shield. Spend your energy.',
          'Explore Mars. Discover real NASA science.','Mike on Mars. Learn through play.']
heads=['YOUR MISSION','BUILD + GROW','NASA DATA','EVERY CHOICE COUNTS','REAL DISCOVERIES','MIKE ON MARS']
lines=[['A Mars base for ages 7-12.','Power. Oxygen. Protection.'],
       ['Build a base.','Grow food in the greenhouse.'],
       ['NASA DONKI','Archived data, not live.'],
       ['Protection uses energy.','Plan how to spend it.'],
       ['Sulfur crystals on Mars.','A discovery by Curiosity.'],
       ['Out of Space Exception','Play in your browser.']]
def frame(t):
 s=next(i for i in range(6) if t<times[i+1]); p=(t-times[s])/(times[s+1]-times[s])
 src=shelf if s==4 else greenhouse
 # Background and foreground are repository assets, never reconstructed game UI.
 bg=ImageOps.fit(src,(W,H),centering=(.5,.52)).filter(ImageFilter.GaussianBlur(15))
 im=Image.blend(bg,Image.new('RGB',(W,H),'#171e2a'),.62)
 d=ImageDraw.Draw(im)
 txt(d,(40,25),'MIKE ON MARS',22,'#edbb65')
 txt(d,(1240,28),'REPOSITORY IMAGES / REFERENCE EDIT',17,'#e4d8cc','ra')
 txt(d,(54,125),f'0{s+1} / {heads[s]}',24,'#edbb65')
 for i,line in enumerate(lines[s]):txt(d,(54,211+i*47),line,29)
 txt(d,(54,480),'Existing project images.',19,'#d2c8bd')
 txt(d,(54,511),'Made with AI',18,'#d2c8bd')
 if s<4:
  shot=ImageOps.contain(greenhouse,(590,496),Image.Resampling.LANCZOS)
  im.paste(shot,(int(820-shot.width/2),85))
  d=ImageDraw.Draw(im)
  # Source annotation is editorial text outside the unchanged screenshot.
  txt(d,(54,333),'NASA DONKI / WSA-ENLIL' if s==2 else 'Mike on Mars',19,'#edbb65')
 elif s==4:
  image=ImageOps.fit(photo,(605,360),Image.Resampling.LANCZOS)
  im.paste(image,(618,140));d=ImageDraw.Draw(im)
  txt(d,(618,104),'SULFUR / GALE CRATER',22,'#edbb65')
  txt(d,(618,519),'Curiosity found sulfur inside a crushed rock.',22)
  txt(d,(618,554),'Photo: NASA/JPL-Caltech/MSSS',17,'#e4d8cc')
 else:
  mark=ImageOps.contain(logo,(330,385),Image.Resampling.LANCZOS)
  im.paste(mark,(590,102))
  code=qr.resize((145,145),Image.Resampling.NEAREST)
  im.paste(code,(1035,148));d=ImageDraw.Draw(im)
  txt(d,(1107,319),'PLAY',26,'#edbb65','ma')
  txt(d,(619,513),'out-of-space-exception.github.io/mike-on-mars/',22)
 # All text is an editorial caption, with no buttons, meters, shield or fake actions.
 d.rounded_rectangle((30,608,1250,685),radius=20,fill='#1b2939')
 size=34
 while d.textlength(captions[s],font=f(size))>1120:size-=1
 txt(d,(640,629),captions[s],size,anchor='ma')
 for i in range(6):
  x=42+i*202;d.rounded_rectangle((x,700,x+184,704),radius=2,fill='#edbb65' if i<=s else '#667077')
 a=min(1,(t-times[s])/.16,(times[s+1]-t)/.16)
 return Image.blend(Image.new('RGB',(W,H),'#171e2a'),im,max(0,a)) if a<1 else im
if __name__=='__main__':
 ff=imageio_ffmpeg.get_ffmpeg_exe();output=OUT/'video-exemplo-29s.mp4'
 cmd=[ff,'-y','-loglevel','error','-f','rawvideo','-vcodec','rawvideo','-s',f'{W}x{H}','-pix_fmt','rgb24','-r',str(FPS),'-i','-',
      '-i',str(ROOT/'conteudo/01-sons/sons/musica-base.wav'),'-t','29','-c:v','libx264','-preset','fast','-crf','21','-pix_fmt','yuv420p',
      '-af','volume=0.16,afade=t=in:st=0:d=1,afade=t=out:st=27:d=2','-c:a','aac','-b:a','128k','-movflags','+faststart',str(output)]
 proc=subprocess.Popen(cmd,stdin=subprocess.PIPE)
 for i in range(29*FPS):proc.stdin.write(frame(i/FPS).tobytes())
 proc.stdin.close()
 if proc.wait():raise RuntimeError('Encoding failed')
 contact=Image.new('RGB',(1280,1080))
 for i,t in enumerate([2,6.5,12,17.5,23,27]):contact.paste(frame(t).resize((640,360)),(i%2*640,i//2*360))
 contact.save(OUT/'video-exemplo-previa.jpg')
 check=subprocess.run([ff,'-v','error','-i',str(output),'-f','null','-'],capture_output=True,text=True)
 if check.returncode:raise RuntimeError(check.stderr)
 print('MP4 regenerated and fully decoded: 29 seconds, 1280x720, existing repository images only.')
