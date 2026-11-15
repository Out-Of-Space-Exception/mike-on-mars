param()
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = $PSScriptRoot
$targetWidth = 944
$targetHeight = 614
$ratio = $targetWidth / $targetHeight
$keepAll = @()
$focus = @{3=@(0.5,0.44);4=@(0.40,0.52);19=@(0.23,0.5);20=@(0.5,0.5);21=@(0.5,0.52);22=@(0.70,0.5);28=@(0.48,0.58);29=@(0.5,0.5);31=@(0.5,0.58)}
$backup = Join-Path $root 'originais/antes-do-enquadramento'
if (-not (Test-Path -LiteralPath $backup)) { throw 'Faltam as fotos anteriores ao enquadramento.' }
$records = @()
foreach ($file in (Get-ChildItem -LiteralPath $backup -Filter '*.png' | Sort-Object Name)) {
    $id = [int]$file.Name.Substring(0,2)
    $source = $file.FullName
    if ($id -eq 6) { $source = Join-Path $root 'originais/pimenta-frutos.png' }
    if ($id -eq 21) { $source = Join-Path $root 'originais/tempestade-nova.png' }
    if ($id -eq 37) { $source = Join-Path $root 'originais/luas-diagonal.png' }
    $high = Join-Path $root ('originais/fonte-enquadramento-{0:D2}.png' -f $id)
    if (Test-Path -LiteralPath $high) { $source = $high }
    $image = [System.Drawing.Image]::FromFile($source)
    $bitmap = [System.Drawing.Bitmap]::new($targetWidth,$targetHeight,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $attributes = [System.Drawing.Imaging.ImageAttributes]::new()
    try {
        $graphics.Clear([System.Drawing.Color]::Black)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $attributes.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)
        $x = 0.0; $y = 0.0; $width = [double]$image.Width; $height = [double]$image.Height
        # The Gale panorama has an incomplete mosaic edge at the top.
        $topInset = 0.0
        if ($id -eq 20) { $topInset = [Math]::Ceiling($height*0.12); $height -= 2*$topInset }
        $mode = 'recorte'
        if ($keepAll -contains $id) {
            $mode = 'inteira-com-margens'
        } else {
            if ($width / $height -gt $ratio) { $width = $height * $ratio } else { $height = $width / $ratio }
            $point = @(0.5,0.5)
            if ($focus.ContainsKey($id)) { $point = $focus[$id] }
            $x = [Math]::Max(0,[Math]::Min($image.Width-$width,$image.Width*$point[0]-$width/2))
            $y = [Math]::Max($topInset,[Math]::Min($image.Height-$height,$image.Height*$point[1]-$height/2))
        }
        if ($id -eq 6) { $x=320.0; $y=400.0; $width=1280.0; $height=$width/$ratio }
        # Isolate the left aurora observation, excluding the comparison and legend.
        if ($id -eq 25) { $x=12.0; $y=200.0; $width=260.0; $height=$width/$ratio }
        $scale = $targetWidth/$width
        $dw = $targetWidth
        $dh = $targetHeight
        $dx = 0
        $dy = 0
        $destination = [System.Drawing.Rectangle]::new($dx,$dy,$dw,$dh)
        $graphics.DrawImage($image,$destination,[single]$x,[single]$y,[single]$width,[single]$height,[System.Drawing.GraphicsUnit]::Pixel,$attributes)
        $output = Join-Path $root ('fotos/'+$file.Name)
        $bitmap.Save($output,[System.Drawing.Imaging.ImageFormat]::Png)
        $records += [pscustomobject]@{id=$id;arquivo=$file.Name;modo=$mode;origem_largura=$image.Width;origem_altura=$image.Height;recorte_x=[Math]::Round($x,2);recorte_y=[Math]::Round($y,2);recorte_largura=[Math]::Round($width,2);recorte_altura=[Math]::Round($height,2);imagem_largura=$dw;imagem_altura=$dh;saida_largura=$targetWidth;saida_altura=$targetHeight;ampliacao=($scale -gt 1)}
    } finally {
        $attributes.Dispose();$graphics.Dispose();$bitmap.Dispose();$image.Dispose()
    }
}
if ($records.Count -ne 40) { throw 'Esperadas 40 fotos.' }
$records | Export-Csv -LiteralPath (Join-Path $root 'enquadramento.csv') -NoTypeInformation -Encoding UTF8
Write-Output '40 fotos preparadas em PNG 944 x 614, preenchendo toda a janela.'
