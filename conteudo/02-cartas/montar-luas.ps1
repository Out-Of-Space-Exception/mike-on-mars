$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=$PSScriptRoot
$phobos=[System.Drawing.Image]::FromFile((Join-Path $root 'originais/fobos-nova.png'))
$deimos=[System.Drawing.Image]::FromFile((Join-Path $root 'originais/deimos-nova.png'))
$bitmap=[System.Drawing.Bitmap]::new(944,614)
$g=[System.Drawing.Graphics]::FromImage($bitmap)
$left=[System.Drawing.Drawing2D.GraphicsPath]::new()
$right=[System.Drawing.Drawing2D.GraphicsPath]::new()
$left.AddPolygon([System.Drawing.Point[]]@([System.Drawing.Point]::new(0,0),[System.Drawing.Point]::new(620,0),[System.Drawing.Point]::new(320,614),[System.Drawing.Point]::new(0,614)))
$right.AddPolygon([System.Drawing.Point[]]@([System.Drawing.Point]::new(620,0),[System.Drawing.Point]::new(944,0),[System.Drawing.Point]::new(944,614),[System.Drawing.Point]::new(320,614)))
$font=[System.Drawing.Font]::new('Arial',25,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Pixel)
$pen=[System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(35,28,22),4)
try {
    $g.Clear([System.Drawing.Color]::Black)
    $g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SetClip($left)
    # Crop around Phobos's illuminated terrain, retaining its limb at upper left.
    $g.DrawImage($phobos,[System.Drawing.Rectangle]::new(0,0,620,614),220,300,1100,1089,[System.Drawing.GraphicsUnit]::Pixel)
    $g.ResetClip()
    $g.SetClip($right)
    # Use just the left Deimos view from the source's two observations.
    $g.DrawImage($deimos,[System.Drawing.Rectangle]::new(320,0,624,614),85,95,590,581,[System.Drawing.GraphicsUnit]::Pixel)
    $g.ResetClip()
    $g.DrawLine($pen,620,0,320,614)
    $g.FillRectangle([System.Drawing.Brushes]::Black,16,16,128,38)
    $g.DrawString('PHOBOS',$font,[System.Drawing.Brushes]::White,24,21)
    $g.FillRectangle([System.Drawing.Brushes]::Black,790,16,136,38)
    $g.DrawString('DEIMOS',$font,[System.Drawing.Brushes]::White,800,21)
    $bitmap.Save((Join-Path $root 'originais/luas-diagonal.png'),[System.Drawing.Imaging.ImageFormat]::Png)
} finally { $pen.Dispose();$font.Dispose();$left.Dispose();$right.Dispose();$g.Dispose();$bitmap.Dispose();$phobos.Dispose();$deimos.Dispose() }
Write-Output 'Composicao diagonal com duas fotografias reais; escalas independentes.'
