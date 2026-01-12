param(
    [string]$Subject = "CN=GemiHotkeyProvider",
    [string]$OutDir = (Join-Path (Split-Path -Parent $PSScriptRoot) "artifacts"),
    [string]$PfxPassword = "dev-password"
)

$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Force $OutDir | Out-Null

$pfxPath = Join-Path $OutDir "GemiHotkeyProvider-dev.pfx"
$cerPath = Join-Path $OutDir "GemiHotkeyProvider-dev.cer"

if ((Test-Path $pfxPath) -and (Test-Path $cerPath)) {
    Write-Host "Certificate already exists:" -ForegroundColor Yellow
    Write-Host "  $pfxPath"
    Write-Host "  $cerPath"
    exit 0
}

Write-Host "Creating self-signed code signing certificate..." -ForegroundColor Cyan
$cert = New-SelfSignedCertificate `
    -Type CodeSigningCert `
    -Subject $Subject `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -KeyExportPolicy Exportable `
    -CertStoreLocation "Cert:\\CurrentUser\\My"

$secure = ConvertTo-SecureString -String $PfxPassword -AsPlainText -Force
Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $secure | Out-Null
Export-Certificate -Cert $cert -FilePath $cerPath | Out-Null

Write-Host "Created:" -ForegroundColor Green
Write-Host "  PFX: $pfxPath (password: $PfxPassword)"
Write-Host "  CER: $cerPath"
Write-Host ""
Write-Host "To trust for MSIX install (CurrentUser), import the CER into:" -ForegroundColor Yellow
Write-Host "  Cert:\\CurrentUser\\TrustedPeople"
