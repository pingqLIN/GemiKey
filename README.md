# GemiKey

**GemiKey** 是一個概念驗證專案（PoC），旨在探索並實作 Windows 11「Copilot 鍵」的自訂行為。透過微軟官方的 `Copilot hardware key provider` 規格，將實體鍵盤上的 Copilot 鍵重新導向至 Google Gemini（或其他自訂應用程式），使其能出現在 Windows 設定的 App Picker 中。

## 專案背景

Windows 11 允許使用者在設定中變更「Copilot 鍵」觸發的行為，路徑如下：

`設定 (Settings)` \> `個人化 (Personalization)` \> `文字輸入 (Text input)` \> `自訂鍵盤上的 Copilot 鍵 (Customize Copilot key on keyboard)`

然而，該選單僅會列出符合特定規範的應用程式。本專案即是為了解析該規範並提供實作範本。

## 技術原理與規格

要讓應用程式出現在 Windows 的 Copilot 鍵選項清單中，**不需要**修改 Windows 系統檔，而是應用程式本身需滿足以下三個條件：

1. **MSIX 封裝**：應用程式必須以 MSIX 格式打包（支援 Desktop、UWP、WinUI 3 等架構）。
2. **Manifest 註冊**：在 `Package.appxmanifest` 中宣告支援 `Microsoft Copilot hardware key provider` 擴充。
3. **數位簽章**：應用程式必須經過簽署（Signed），否則 Windows 不會將其視為有效的 Copilot 鍵目標。

### 解決方案架構

針對「Gemini」的整合，本專案採用以下輕量化策略：

- 建立一個輕量級 Provider App（例如：使用 WebView2 開啟 `https://gemini.google.com/` 的殼層程式）。
- 依據規格註冊為 Provider。
- 在系統選單中以「Gemini」名稱顯示。

## 開發者指南

### 1\. Package Manifest 設定

在應用程式的 `Package.appxmanifest` 中，必須加入 `uap3:AppExtension`，且 `Name` 屬性必須指定為 `com.microsoft.windows.copilotkeyprovider`。

```xml
<Package ... xmlns:uap3="[http://schemas.microsoft.com/appx/manifest/uap/windows10/3](http://schemas.microsoft.com/appx/manifest/uap/windows10/3)" ...>
  <Applications>
    <Application ...>
      <Extensions>
        <uap3:Extension Category="windows.appExtension">
          <uap3:AppExtension
            Name="com.microsoft.windows.copilotkeyprovider"
            Id="GeminiKeyProvider"
            DisplayName="Gemini"
            Description="Launch Google Gemini via Copilot Key"
            PublicFolder="Public" />
        </uap3:Extension>
      </Extensions>
    </Application>
  </Applications>
</Package>

* `DisplayName`：即為顯示在 Windows 設定 App Picker 中的名稱（如：Gemini）。
* `Description`：應用程式的描述文字。

### 2\. 簽章要求 (Signing)

官方文件明確指出：

"Provider apps must be signed in order to be enabled as a target of the Microsoft Copilot hardware key." (應用程式必須簽章才能被啟用為目標。)

實務上的簽章策略如下：

* **開發階段**：可使用自簽憑證（Self-signed certificate）並將憑證安裝至「受信任的根憑證授權單位」。
* **發布階段**：需使用正式的程式碼簽署憑證。

## 除錯與驗證

若應用程式未出現在清單中，可透過以下 Registry 機碼檢查系統狀態與目前的綁定情形。

**登錄檔路徑：**

`HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\BrandedKey`

| 機碼名稱 | 說明 | 可能值 |
| :---- | :---- | :---- |
| **BrandedKeyChoiceType** | 目前按鍵行為類型 | `Search` (搜尋) \`App\` (自訂 App) \`AppEnforcedByPolicy\` (政策強制) |
| **AppAumid** | 目前綁定的 App ID | 目標 App 的 AUMID (Application User Model ID) |

**常見失敗原因：**

1. App 未安裝或需重新安裝（以觸發系統掃描 Manifest）。
2. App 未正確簽章。
3. Manifest 中的 Extension Name 拼寫錯誤。

## 專案路線圖與 MVP

目前的最小可行性產品（MVP）目標為「讓設定頁能選到 Gemini」。

### 技術選項評估

* **WPF \+ WebView2**：✅ **(目前採用)** 直覺、相容性高，適合快速開發。
* **WinUI 3 (Windows App SDK)**：貼近原生 Windows 11 UI，但專案架構較重。
* **最小化 EXE \+ MSIX**：僅啟動預設瀏覽器導向網址，維護成本最低。

### 目前進度 (Current Status)

已建立基於 WPF \+ WebView2 的 MVP：

* **原始碼**：`Projects/gemikey/src/GemiHotkeyProvider.App`
* **文件指引**：`Projects/gemikey/docs/provider-app-wpf-webview2.md`
* **Manifest 範本**：`Projects/gemikey/packaging/copilot-key-provider.extension.xml`

## 參考文件 (Microsoft Official)

* [Windows 鍵盤快速鍵與 Copilot 鍵說明](https://support.microsoft.com/en-us/windows/keyboard-shortcuts-in-windows-dcc61a57-8ff0-cffe-9796-cb9706c75eec)
* [IT 管理：管理 Windows Copilot](https://learn.microsoft.com/en-us/windows/client-management/manage-windows-copilot)
* [開發者規格：Microsoft Copilot hardware key provider](https://learn.microsoft.com/en-us/windows/apps/develop/windows-integration/microsoft-copilot-key-provider)
```
