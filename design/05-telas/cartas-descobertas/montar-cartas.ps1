# Monta as cartas desta pasta: foto (cover) + moldura da raridade + título + fato. Uso: powershell -File montar-cartas.ps1
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$here = $PSScriptRoot; $telas = Split-Path $here
$pfc = [System.Drawing.Text.PrivateFontCollection]::new(); $pfc.AddFontFile((Join-Path $telas 'carregamento/rubik.ttf'))
$fam = $pfc.Families[0]
$fTitle = [System.Drawing.Font]::new($fam, 52, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fText = [System.Drawing.Font]::new($fam, 44, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bTitle = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#73242A'))
$bText = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#3A261C'))
$sf = [System.Drawing.StringFormat]::new(); $sf.Alignment = 'Center'; $sf.LineAlignment = 'Center'
foreach ($c in (Import-Csv (Join-Path $here 'cartas.csv') -Encoding UTF8)) {
  $card = [System.Drawing.Bitmap]::new(1066, 1280); $g = [System.Drawing.Graphics]::FromImage($card)
  $g.SmoothingMode = 'AntiAlias'; $g.InterpolationMode = 'HighQualityBicubic'; $g.TextRenderingHint = 'AntiAliasGridFit'
  $photo = [System.Drawing.Image]::FromFile((Join-Path $here $c.foto))
  $pw = $photo.Width; if ([int]$c.largura_util -gt 0) { $pw = [int]$c.largura_util }  # usa só a parte da esquerda (tira os recortes A B C)
  $W = 944; $H = 614; $s = [Math]::Max($W / $pw, $H / $photo.Height)
  $sw = $W / $s; $sh = $H / $s; $sx = ($pw - $sw) * [double]$c.foco_x; $sy = ($photo.Height - $sh) * [double]$c.foco_y
  $g.DrawImage($photo, [System.Drawing.RectangleF]::new(60, 236, $W, $H), [System.Drawing.RectangleF]::new($sx, $sy, $sw, $sh), 'Pixel')
  $frame = [System.Drawing.Image]::FromFile((Join-Path $telas ('moldura-carta-' + $c.raridade + '.png')))
  $g.DrawImage($frame, 0, 0, 1066, 1280)
  $g.DrawString($c.titulo_en.ToUpperInvariant(), $fTitle, $bTitle, [System.Drawing.RectangleF]::new(107, 92, 855, 108), $sf)
  $g.DrawString($c.fato_en, $fText, $bText, [System.Drawing.RectangleF]::new(84, 866, 906, 268), $sf)
  $card.Save((Join-Path $here $c.arquivo), [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $card.Dispose(); $photo.Dispose(); $frame.Dispose(); "ok $($c.arquivo)"
}
# prévia das 5 lado a lado
$prev = [System.Drawing.Bitmap]::new(5 * 426, 512); $gp = [System.Drawing.Graphics]::FromImage($prev); $gp.InterpolationMode = 'HighQualityBicubic'; $i = 0
foreach ($c in (Import-Csv (Join-Path $here 'cartas.csv') -Encoding UTF8)) { $im = [System.Drawing.Image]::FromFile((Join-Path $here $c.arquivo)); $gp.DrawImage($im, $i * 426, 0, 426, 512); $im.Dispose(); $i++ }
$prev.Save((Join-Path $here 'cartas-previa.png'), [System.Drawing.Imaging.ImageFormat]::Png); $gp.Dispose(); $prev.Dispose()
