$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = $PSScriptRoot
$backup = Join-Path $root 'originais/antes-da-revisao-final'
New-Item -ItemType Directory -Force -Path $backup | Out-Null

function Export-CardCrop($file, $source, $x, $y, $width, $height) {
    $output = Join-Path $root ('fotos/' + $file)
    $old = Join-Path $backup $file
    if (-not (Test-Path -LiteralPath $old)) { Copy-Item -LiteralPath $output -Destination $old }
    $image = [System.Drawing.Image]::FromFile((Join-Path $root $source))
    $bitmap = [System.Drawing.Bitmap]::new(944, 614, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $attributes = [System.Drawing.Imaging.ImageAttributes]::new()
    try {
        if ($x -lt 0 -or $y -lt 0 -or ($x + $width) -gt $image.Width -or ($y + $height) -gt $image.Height) { throw 'Recorte fora da imagem.' }
        if ([Math]::Abs(($width / $height) - (944.0 / 614.0)) -gt 0.0001) { throw 'Recorte distorceria a proporcao.' }
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.Clear([System.Drawing.Color]::Black)
        $attributes.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)
        $graphics.DrawImage($image, [System.Drawing.Rectangle]::new(0, 0, 944, 614), [single]$x, [single]$y, [single]$width, [single]$height, [System.Drawing.GraphicsUnit]::Pixel, $attributes)
        $bitmap.Save($output, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally { $attributes.Dispose(); $graphics.Dispose(); $bitmap.Dispose(); $image.Dispose() }
}

# Real photographs; proportional crop and conventional resampling only.
Export-CardCrop '21-tempestade-de-poeira.png' 'originais/insight-poeira-pia25286.png' 4 350 1016 (1016.0 * 614 / 944)
Export-CardCrop '22-redemoinho-de-poeira.png' 'originais/spirit-apos-limpeza-pia11799.jpg' 0 (1024 - 1024.0 * 614 / 944) 1024 (1024.0 * 614 / 944)
# The mineral-bearing fracture is in the original NASA left-hand inset.
Export-CardCrop '32-oxido-de-manganes.png' 'originais/antes-do-enquadramento/32-oxido-de-manganes.png' 2 794 240 (240.0 * 614 / 944)
$earth = '39-terra-vista-de-marte.png'
if (-not (Test-Path -LiteralPath (Join-Path $backup $earth))) {
    Copy-Item -LiteralPath (Join-Path $root ('fotos/' + $earth)) -Destination (Join-Path $backup $earth)
}
Export-CardCrop $earth '39-terra-vista-de-marte-previa.png' 0 0 944 614
Write-Output 'Fotos 21, 22, 32 e 39 preparadas. Foto 29 preservada como mosaico oficial NASA.'
