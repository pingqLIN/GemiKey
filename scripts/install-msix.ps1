param(
    [string]$MsixPath = (Join-Path (Split-Path -Parent $PSScriptRoot) "artifacts\\GeminiProvider.msix"),
    [string]$CerPath = (Join-Path (Split-Path -Parent $PSScriptRoot) "artifacts\\GemiHotkeyProvider-dev.cer")
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $MsixPath)) {
    throw "MSIX not found: $MsixPath. Run scripts\\build-msix.ps1 and scripts\\sign-msix.ps1 first."
}

if (-not (Test-Path $CerPath)) {
    throw "CER not found: $CerPath. Run scripts\\new-dev-cert.ps1 first."
}

Write-Host "Importing certificate into trust stores..." -ForegroundColor Cyan
Import-Certificate -FilePath $CerPath -CertStoreLocation "Cert:\\CurrentUser\\Root" | Out-Null
Import-Certificate -FilePath $CerPath -CertStoreLocation "Cert:\\CurrentUser\\TrustedPeople" | Out-Null

try {
    Import-Certificate -FilePath $CerPath -CertStoreLocation "Cert:\\LocalMachine\\Root" | Out-Null
    Import-Certificate -FilePath $CerPath -CertStoreLocation "Cert:\\LocalMachine\\TrustedPeople" | Out-Null
}
catch {
    Write-Warning "Failed to import into LocalMachine stores. Try running elevated if Add-AppxPackage fails with trust errors."
}

Write-Host "Installing MSIX..." -ForegroundColor Cyan
Add-AppxPackage -Path $MsixPath

Write-Host "Installed. Now go to:" -ForegroundColor Green
Write-Host "  Settings > Personalization > Text input > Customize Copilot key on keyboard"
Write-Host "Select 'Custom' and pick 'Gemini'." -ForegroundColor Green
