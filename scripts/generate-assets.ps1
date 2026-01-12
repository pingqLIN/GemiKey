param(
    [string]$AssetsDir = (Join-Path (Split-Path -Parent $PSScriptRoot) "packaging\\Assets")
)

$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Force $AssetsDir | Out-Null

Add-Type -AssemblyName System.Drawing

function Get-SourceLogoPath {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    $candidatePaths = @(
        (Join-Path $repoRoot "packaging\\source-logo.png"),
        (Join-Path $repoRoot "packaging\\source-logo.jpg"),
        (Join-Path $repoRoot "packaging\\source-logo.jpeg")
    )

    foreach ($path in $candidatePaths) {
        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

function New-Canvas {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Width,
        [Parameter(Mandatory = $true)]
        [int]$Height
    )

    $bitmap = New-Object System.Drawing.Bitmap $Width, $Height
    $bitmap.SetResolution(96, 96)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.Clear([System.Drawing.Color]::Transparent)

    return @{ Bitmap = $bitmap; Graphics = $graphics }
}

function Save-Png {
    param(
        [Parameter(Mandatory = $true)]
        $Canvas,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $Canvas.Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $Canvas.Graphics.Dispose()
    $Canvas.Bitmap.Dispose()
}

function Draw-ImageContained {
    param(
        [Parameter(Mandatory = $true)]
        [System.Drawing.Image]$Image,
        [Parameter(Mandatory = $true)]
        $Canvas,
        [Parameter(Mandatory = $true)]
        [double]$ScaleFactor
    )

    $targetWidth = [Math]::Floor($Canvas.Bitmap.Width * $ScaleFactor)
    $targetHeight = [Math]::Floor($Canvas.Bitmap.Height * $ScaleFactor)
    $ratio = [Math]::Min($targetWidth / $Image.Width, $targetHeight / $Image.Height)
    $drawWidth = [Math]::Max(1, [Math]::Floor($Image.Width * $ratio))
    $drawHeight = [Math]::Max(1, [Math]::Floor($Image.Height * $ratio))

    $x = [Math]::Floor(($Canvas.Bitmap.Width - $drawWidth) / 2)
    $y = [Math]::Floor(($Canvas.Bitmap.Height - $drawHeight) / 2)
    $destRect = New-Object System.Drawing.Rectangle $x, $y, $drawWidth, $drawHeight

    $Canvas.Graphics.DrawImage($Image, $destRect)
}

function New-LogoPng {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [int]$Size
    )

    $bitmap = New-Object System.Drawing.Bitmap $Size, $Size
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $bg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 20, 22, 28))
    $fg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 142, 181, 255))

    $radius = [Math]::Floor($Size * 0.18)
    $rect = New-Object System.Drawing.Rectangle 0, 0, $Size, $Size
    $rectF = New-Object System.Drawing.RectangleF 0, 0, $Size, $Size

    $pathObj = New-Object System.Drawing.Drawing2D.GraphicsPath
    $pathObj.AddArc($rect.X, $rect.Y, $radius * 2, $radius * 2, 180, 90) | Out-Null
    $pathObj.AddArc($rect.Right - $radius * 2, $rect.Y, $radius * 2, $radius * 2, 270, 90) | Out-Null
    $pathObj.AddArc($rect.Right - $radius * 2, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 0, 90) | Out-Null
    $pathObj.AddArc($rect.X, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 90, 90) | Out-Null
    $pathObj.CloseFigure()

    $graphics.FillPath($bg, $pathObj)

    $fontSize = [Math]::Max(10, [Math]::Floor($Size * 0.55))
    $font = New-Object System.Drawing.Font "Segoe UI", $fontSize, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $stringFormat = New-Object System.Drawing.StringFormat
    $stringFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Center

    $graphics.DrawString("G", $font, $fg, $rectF, $stringFormat)

    $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)

    $stringFormat.Dispose()
    $font.Dispose()
    $bg.Dispose()
    $fg.Dispose()
    $pathObj.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

function New-LogoWidePng {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [int]$Width,
        [Parameter(Mandatory = $true)]
        [int]$Height
    )

    $bitmap = New-Object System.Drawing.Bitmap $Width, $Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $bg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 20, 22, 28))
    $fg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 142, 181, 255))

    $rect = New-Object System.Drawing.Rectangle 0, 0, $Width, $Height
    $rectF = New-Object System.Drawing.RectangleF 0, 0, $Width, $Height
    $graphics.FillRectangle($bg, $rect)

    $fontSize = [Math]::Max(10, [Math]::Floor([Math]::Min($Width, $Height) * 0.55))
    $font = New-Object System.Drawing.Font "Segoe UI", $fontSize, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $stringFormat = New-Object System.Drawing.StringFormat
    $stringFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Center

    $graphics.DrawString("Gemini", $font, $fg, $rectF, $stringFormat)

    $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)

    $stringFormat.Dispose()
    $font.Dispose()
    $bg.Dispose()
    $fg.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

Write-Host "Generating MSIX assets in: $AssetsDir" -ForegroundColor Cyan

$sourceLogo = Get-SourceLogoPath
if ($sourceLogo) {
    Write-Host "Using source logo: $sourceLogo" -ForegroundColor Cyan
    $img = [System.Drawing.Image]::FromFile($sourceLogo)
    try {
        foreach ($spec in @(
            @{ File = "Square44x44Logo.png"; W = 44; H = 44; Scale = 0.95 },
            @{ File = "Square150x150Logo.png"; W = 150; H = 150; Scale = 0.95 },
            @{ File = "Square310x310Logo.png"; W = 310; H = 310; Scale = 0.95 },
            @{ File = "StoreLogo.png"; W = 50; H = 50; Scale = 0.95 }
        )) {
            $canvas = New-Canvas -Width $spec.W -Height $spec.H
            Draw-ImageContained -Image $img -Canvas $canvas -ScaleFactor $spec.Scale
            Save-Png -Canvas $canvas -Path (Join-Path $AssetsDir $spec.File)
        }

        $wideCanvas = New-Canvas -Width 310 -Height 150
        Draw-ImageContained -Image $img -Canvas $wideCanvas -ScaleFactor 0.95
        Save-Png -Canvas $wideCanvas -Path (Join-Path $AssetsDir "Wide310x150Logo.png")
    }
    finally {
        $img.Dispose()
    }
}
else {
    Write-Warning "No source logo found. Add one at 'packaging\\source-logo.png' to replace assets."
    New-LogoPng -Path (Join-Path $AssetsDir "Square44x44Logo.png") -Size 44
    New-LogoPng -Path (Join-Path $AssetsDir "Square150x150Logo.png") -Size 150
    New-LogoPng -Path (Join-Path $AssetsDir "Square310x310Logo.png") -Size 310
    New-LogoWidePng -Path (Join-Path $AssetsDir "Wide310x150Logo.png") -Width 310 -Height 150
    New-LogoPng -Path (Join-Path $AssetsDir "StoreLogo.png") -Size 50
}

Write-Host "Done." -ForegroundColor Green
