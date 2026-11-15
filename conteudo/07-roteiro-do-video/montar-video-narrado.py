from pathlib import Path
import importlib.util,subprocess,sys,os
OUT=Path(__file__).resolve().parent;ROOT=OUT.parents[1]
spec=importlib.util.spec_from_file_location('video',OUT/'gerar-video-com-imagens.py')
video=importlib.util.module_from_spec(spec);spec.loader.exec_module(video)
spec=importlib.util.spec_from_file_location('voice',OUT/'gerar-narracao.py')
voice=importlib.util.module_from_spec(spec);spec.loader.exec_module(voice)
video.captions=voice.EN
english=os.environ.get('MIKE_PITCH_EN')=='1'
if english:
 video.lines[0]=['Junior astronaut training.','For ages 7-12.']
 video.lines[1]=['Build. Grow. Collect.','Real NASA discoveries.']
 video.lines[4]=['Energy. Oxygen. Shielding.','Food for the base.']
ff=video.imageio_ffmpeg.get_ffmpeg_exe()
output=OUT/('video-pitch-ingles-29s.mp4' if english else 'video-narracao-sintetica-29s.mp4')
cmd=[ff,'-y','-v','error','-f','rawvideo','-vcodec','rawvideo','-s','1280x720','-pix_fmt','rgb24','-r','24','-i','-',
     '-i',str(OUT/('narracao-sintetica-en.wav' if english else 'narracao-sintetica-pt.wav')),'-i',str(ROOT/'conteudo/01-sons/sons/musica-base.wav'),
     '-filter_complex','[1:a]volume=1.0[v];[2:a]volume=0.06,afade=t=in:st=0:d=1,afade=t=out:st=27:d=2[m];[v][m]amix=inputs=2:duration=first:normalize=0,alimiter=limit=0.95[a]',
     '-map','0:v','-map','[a]','-t','29','-c:v','libx264','-crf','21','-preset','fast','-pix_fmt','yuv420p','-c:a','aac','-b:a','160k','-movflags','+faststart',str(output)]
proc=subprocess.Popen(cmd,stdin=subprocess.PIPE)
for i in range(29*24):proc.stdin.write(video.frame(i/24).tobytes())
proc.stdin.close()
if proc.wait():raise RuntimeError('Video encoding failed')
guide=OUT/('video-guia-voz-humana-ingles-29s.mp4' if english else 'video-para-narracao-humana-29s.mp4')
subprocess.run([ff,'-y','-v','error','-i',str(output),'-i',str(ROOT/'conteudo/01-sons/sons/musica-base.wav'),
 '-map','0:v','-map','1:a','-c:v','copy','-af','volume=0.06,afade=t=in:st=0:d=1,afade=t=out:st=27:d=2',
 '-t','29','-c:a','aac','-movflags','+faststart',str(guide)],check=True)
contact=video.Image.new('RGB',(1280,1080))
for i,t in enumerate([2,6.5,12,17.5,23,27]):contact.paste(video.frame(t).resize((640,360)),(i%2*640,i//2*360))
contact.save(OUT/('video-pitch-ingles-previa.jpg' if english else 'video-narrado-previa.jpg'))
for path in [output,guide]:
 subprocess.run([ff,'-v','error','-i',str(path),'-f','null','-'],check=True)
print('Created and decoded: synthetic narrated MP4 and human-recording guide MP4; 29 seconds each.')
