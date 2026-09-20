Add-Type -AssemblyName System.Drawing

$src = "assets\images\college_logo.png"
$orig = [System.Drawing.Bitmap]::FromFile($src)

function Resize-Image($source, $width, $height, $targetPath) {
    $destRect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
    $destImage = New-Object System.Drawing.Bitmap($width, $height)
    $destImage.SetResolution($source.HorizontalResolution, $source.VerticalResolution)
    
    $graphics = [System.Drawing.Graphics]::FromImage($destImage)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    $graphics.DrawImage($source, $destRect, 0, 0, $source.Width, $source.Height, [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.Dispose()

    $parent = Split-Path -Parent $targetPath
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $destImage.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $destImage.Dispose()
    Write-Output "Generated: $targetPath ($($width)x$($height))"
}

# Android mipmap launcher icons
Resize-Image $orig 48 48 "android\app\src\main\res\mipmap-mdpi\ic_launcher.png"
Resize-Image $orig 72 72 "android\app\src\main\res\mipmap-hdpi\ic_launcher.png"
Resize-Image $orig 96 96 "android\app\src\main\res\mipmap-xhdpi\ic_launcher.png"
Resize-Image $orig 144 144 "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png"
Resize-Image $orig 192 192 "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png"

# Web icons
Resize-Image $orig 192 192 "web\icons\Icon-192.png"
Resize-Image $orig 512 512 "web\icons\Icon-512.png"
Resize-Image $orig 64 64 "web\favicon.png"

$orig.Dispose()
Write-Output "All icons generated successfully."
