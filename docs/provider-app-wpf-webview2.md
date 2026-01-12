# Gemini Copilot Key Provider（WPF + WebView2）

本文件描述如何用 `WPF + WebView2` 做一個「Gemini Provider App」，並透過 **MSIX + manifest app extension** 讓它出現在 Windows 11 的：

`設定 > 個人化 > 文字輸入 > 自訂鍵盤上的 Copilot 鍵` 的 app picker 中。

## 專案位置

- WPF App：`Projects/gemi-hotkey-codex/src/GemiHotkeyProvider.App`

## 本機執行（僅驗證 UI/功能）

```powershell
cd C:\Dev\Projects\gemi-hotkey-codex
dotnet run --project .\src\GemiHotkeyProvider.App
```

可加 `--url` 指定啟動網址（預設開 Gemini）：

```powershell
dotnet run --project .\src\GemiHotkeyProvider.App -- --url https://gemini.google.com/
```

## 讓它出現在 Copilot 鍵 app picker（必要條件）

依微軟文件，必須同時滿足：

1. **MSIX 封裝**
2. **套件已簽章（signed）**
3. 在 `Package.appxmanifest` 內註冊 app extension：
   - `uap3:AppExtension Name="com.microsoft.windows.copilotkeyprovider" ...`

extension 範本：`Projects/gemi-hotkey-codex/packaging/copilot-key-provider.extension.xml`

## 產出可安裝的已簽章 MSIX（本專案已提供腳本）

先把你要用的 logo 放到這裡（建議 PNG、保留透明背景）：

- `Projects/gemi-hotkey-codex/packaging/source-logo.png`

依序執行（PowerShell）：

```powershell
cd C:\Dev\Projects\gemi-hotkey-codex
.\scripts\generate-assets.ps1
.\scripts\build-msix.ps1 -Configuration Release -Version 1.0.0.0
.\scripts\new-dev-cert.ps1 -PfxPassword dev-password
.\scripts\sign-msix.ps1 -PfxPassword dev-password
.\scripts\install-msix.ps1
```

產物預設在：`Projects/gemi-hotkey-codex/artifacts/GeminiProvider.msix`

`install-msix.ps1` 會把測試憑證匯入 `CurrentUser` 及 `LocalMachine` 的信任存放區（避免 `Add-AppxPackage` 出現 0x800B0109 信任鏈錯誤）；若你不希望修改 `LocalMachine`，可自行調整 `Projects/gemi-hotkey-codex/scripts/install-msix.ps1:1`。

## 建議封裝方式（Visual Studio）

WPF 桌面程式要做 MSIX，最簡單的工作流通常是：

1. 用 Visual Studio 建立/加入「Windows Application Packaging Project」（`.wapproj`）
2. 將 `GemiHotkeyProvider.App` 設為封裝專案的 Application
3. 在封裝專案產生的 `Package.appxmanifest` 內加入 provider extension（見範本檔）
4. 設定套件 Identity、DisplayName、Logos
5. 以測試憑證或正式憑證簽章，產出 `.msix` 並安裝

安裝後，進到 Windows 11 設定頁選 `自訂`，應會看到你設定的 `DisplayName`（例如：Gemini）。

## 常見問題

- App picker 沒看到 Gemini：
  - 確認你安裝的是 **MSIX** 版本（不是單純執行 EXE）
  - 確認 MSIX 有簽章
  - 確認 manifest 真的包含 `com.microsoft.windows.copilotkeyprovider` extension
  - 若公司/學校裝置有政策強制（`AppEnforcedByPolicy`），使用者可能無法自行更改
