param(
    [string]$MsixPath = (Join-Path (Split-Path -Parent $PSScriptRoot) "artifacts\\GeminiProvider.msix"),
    [string]$PfxPath = (Join-Path (Split-Path -Parent $PSScriptRoot) "artifacts\\GemiHotkeyProvider-dev.pfx"),
    [string]$PfxPassword = "dev-password"
)

$ErrorActionPreference = "Stop"

function Get-WindowsSdkToolPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ToolName
    )

    $base = "C:\Program Files (x86)\Windows Kits\10\bin"
    $tool = Get-ChildItem -Path $base -Recurse -Filter $ToolName -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match "\\10\.0\.\d+\.\d+\\x64\\" } |
        Sort-Object FullName -Descending |
        Select-Object -First 1

    if (-not $tool) {
        throw "Could not locate '$ToolName' under '$base'."
    }

    return $tool.FullName
}

if (-not (Test-Path $MsixPath)) {
    throw "MSIX not found: $MsixPath. Run scripts\\build-msix.ps1 first."
}

if (-not (Test-Path $PfxPath)) {
    throw "PFX not found: $PfxPath. Run scripts\\new-dev-cert.ps1 first."
}

$signtool = Get-WindowsSdkToolPath -ToolName "signtool.exe"

Write-Host "Signing MSIX..." -ForegroundColor Cyan
& $signtool sign /fd SHA256 /f $PfxPath /p $PfxPassword $MsixPath | Out-Null

Write-Host "Signed: $MsixPath" -ForegroundColor Green

