param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",
    [string]$Version = "1.0.0.0"
)

$ErrorActionPreference = "Stop"

function Get-WindowsSdkToolPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ToolName
    )

    $base = "C:\Program Files (x86)\Windows Kits\10\bin"
    if (-not (Test-Path $base)) {
        throw "Windows SDK not found at '$base'. Install Windows 10/11 SDK."
    }

    $tool = Get-ChildItem -Path $base -Recurse -Filter $ToolName -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match "\\10\.0\.\d+\.\d+\\x64\\" } |
        Sort-Object FullName -Descending |
        Select-Object -First 1

    if (-not $tool) {
        throw "Could not locate '$ToolName' under '$base'."
    }

    return $tool.FullName
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$appProject = Join-Path $repoRoot "src\GemiHotkeyProvider.App\GemiHotkeyProvider.App.csproj"
$manifestTemplate = Join-Path $repoRoot "packaging\AppxManifest.xml"
$assetsSource = Join-Path $repoRoot "packaging\Assets"

$artifactsDir = Join-Path $repoRoot "artifacts"
$stagingDir = Join-Path $artifactsDir "staging"
$publishDir = Join-Path $artifactsDir "publish"
$msixPath = Join-Path $artifactsDir "GeminiProvider.msix"

New-Item -ItemType Directory -Force $artifactsDir | Out-Null
New-Item -ItemType Directory -Force $stagingDir | Out-Null
New-Item -ItemType Directory -Force $publishDir | Out-Null

Write-Host "Publishing app..." -ForegroundColor Cyan
dotnet publish $appProject -c $Configuration -o $publishDir | Out-Null

Write-Host "Preparing staging directory..." -ForegroundColor Cyan
Remove-Item -Recurse -Force (Join-Path $stagingDir "*") -ErrorAction SilentlyContinue
Copy-Item -Path (Join-Path $publishDir "*") -Destination $stagingDir -Recurse -Force

New-Item -ItemType Directory -Force (Join-Path $stagingDir "Assets") | Out-Null
New-Item -ItemType Directory -Force (Join-Path $stagingDir "Public") | Out-Null

if (Test-Path $assetsSource) {
    Copy-Item -Path (Join-Path $assetsSource "*") -Destination (Join-Path $stagingDir "Assets") -Force
}

$manifest = Get-Content -Raw $manifestTemplate
$manifest = $manifest.Replace("__PACKAGE_VERSION__", $Version)
Set-Content -Path (Join-Path $stagingDir "AppxManifest.xml") -Value $manifest -Encoding UTF8

$makeappx = Get-WindowsSdkToolPath -ToolName "makeappx.exe"

Write-Host "Packing MSIX..." -ForegroundColor Cyan
& $makeappx pack /o /d $stagingDir /p $msixPath
if ($LASTEXITCODE -ne 0) {
    throw "makeappx failed with exit code $LASTEXITCODE"
}

if (-not (Test-Path $msixPath)) {
    throw "Expected MSIX not found after packing: $msixPath"
}

Write-Host "MSIX created: $msixPath" -ForegroundColor Green
Write-Host "Next: run scripts\\sign-msix.ps1 to sign it." -ForegroundColor Yellow
