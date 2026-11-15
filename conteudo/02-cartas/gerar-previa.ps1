$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = $PSScriptRoot
$repo = (Resolve-Path (Join-Path $root '../..')).Path
$cards = Import-Csv -LiteralPath (Join-Path $root 'cartas.csv') -Encoding UTF8
$frames = @{}
foreach ($name in @('comum','raro','epico','lendario')) {
    $frames[$name] = [System.Drawing.Image]::FromFile((Join-Path $repo ('design/05-telas/moldura-carta-'+$name+'.png')))
}
$sheet = [System.Drawing.Bitmap]::new(1200,1600)
$mounted = [System.Drawing.Bitmap]::new(1065,2048)
$g = [System.Drawing.Graphics]::FromImage($sheet)
$gm = [System.Drawing.Graphics]::FromImage($mounted)
$g.Clear([System.Drawing.Color]::FromArgb(245,245,245))
$gm.Clear([System.Drawing.Color]::FromArgb(235,230,220))
$font = [System.Drawing.Font]::new('Arial',11)
$titleFont = [System.Drawing.Font]::new('Arial',45,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Pixel)
$brush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#73242A'))
$sf = [System.Drawing.StringFormat]::new()
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$sf.LineAlignment = [System.Drawing.StringAlignment]::Center
try {
    foreach ($info in $cards) {
        $id = [int]$info.id
        $file = Get-ChildItem -LiteralPath (Join-Path $root 'fotos') -Filter ('{0:D2}-*.png' -f $id)
        $photo = [System.Drawing.Image]::FromFile($file.FullName)
        $card = [System.Drawing.Bitmap]::new(1066,1280)
        $gc = [System.Drawing.Graphics]::FromImage($card)
        try {
            $gc.Clear([System.Drawing.Color]::Transparent)
            $gc.DrawImage($photo,60,236,944,614)
            $rarity = $info.raridade
            if ($rarity -notin @('comum','raro')) { if ($rarity.StartsWith('l')) { $rarity='lendario' } else { $rarity='epico' } }
            $gc.DrawImage($frames[$rarity],0,0,1066,1280)
            $gc.DrawString($info.nome_en.ToUpperInvariant(),$titleFont,$brush,[System.Drawing.RectangleF]::new(107,92,855,108),$sf)
            $x = (($id-1)%5)*240
            $y = [Math]::Floor(($id-1)/5)*200
            $g.DrawImage($photo,[int]($x+8),[int]($y+8),224,146)
            $g.DrawString($file.BaseName,$font,[System.Drawing.Brushes]::Black,[single]($x+6),[single]($y+175))
            $mx = (($id-1)%5)*213
            $my = [Math]::Floor(($id-1)/5)*256
            $gm.DrawImage($card,[int]$mx,[int]$my,213,256)
        } finally { $gc.Dispose();$card.Dispose();$photo.Dispose() }
    }
    $sheet.Save((Join-Path $root 'previa-40-fotos.png'),[System.Drawing.Imaging.ImageFormat]::Png)
    $mounted.Save((Join-Path $root 'previa-nas-molduras.png'),[System.Drawing.Imaging.ImageFormat]::Png)
} finally {
    $sf.Dispose();$brush.Dispose();$titleFont.Dispose();$font.Dispose();$g.Dispose();$gm.Dispose();$sheet.Dispose();$mounted.Dispose()
    foreach ($frame in $frames.Values) { $frame.Dispose() }
}
Write-Output 'Previas de 40 fotos e 40 molduras geradas.'
