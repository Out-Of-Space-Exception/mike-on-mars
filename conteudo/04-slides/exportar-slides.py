"""Save the reviewed live-deck exports in this delivery folder.

Usage: python exportar-slides.py DIRECTORY_WITH_SESSION_EXPORTS
The PDF embeds the reviewed slide renders; the PPTX remains editable.
"""
from pathlib import Path
import shutil
import sys
import zipfile
import xml.etree.ElementTree as ET
from reportlab.pdfgen import canvas
from pypdf import PdfReader

source = Path(sys.argv[1]).resolve()
out = Path(__file__).resolve().parent
pdf = canvas.Canvas(str(out / 'slides.pdf'), pagesize=(960, 540))
pdf.setTitle('Mike on Mars - Out of Space Exception')
pdf.setAuthor('Out of Space Exception')
for i in range(1, 8):
    image = source / f'slide-{i}.png'
    if not image.is_file():
        raise FileNotFoundError(image)
    pdf.drawImage(str(image), 0, 0, width=960, height=540)
    pdf.showPage()
pdf.save()
shutil.copy2(source / 'presentation.pptx', out / 'slides.pptx')
ns = {'a': 'http://schemas.openxmlformats.org/drawingml/2006/main'}
with zipfile.ZipFile(out / 'slides.pptx') as deck:
    slide_files = [n for n in deck.namelist() if __import__('re').fullmatch(r'ppt/slides/slide\d+\.xml', n)]
    assert len(slide_files) == 7
    for name in slide_files:
        ET.fromstring(deck.read(name))
assert len(PdfReader(out / 'slides.pdf').pages) == 7
print('7 reviewed slide renders in PDF; 7 editable PPTX slides.')
