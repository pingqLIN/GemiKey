# GemiKey 實作計畫 (Implementation Plan)

## 專案目標

實作一個 Windows 擴充預配程式 (Copilot Key Provider)，將實體 Copilot 鍵重新導向至 Google Gemini 網頁介面。

## 核心組件

### 1. WPF 應用程式 (GemiKey.App)

- **技術棧**: C# .NET + WebView2。
- **功能**:
  - 初始化 WebView2 控制項。
  - 載入 `https://gemini.google.com/`。
  - 處理視窗啟動與顯示設定。

### 2. MSIX 封裝 (Packaging)

- **目的**: 符合 Windows 11 對於 Copilot Key Provider 的安全性要求（必須通過 MSIX 安裝且具備簽章）。
- **關鍵配置**:
  - 在 `Package.appxmanifest` 中註冊 `com.microsoft.windows.copilotkeyprovider` 擴充。
  - 設定 `DisplayName` 為 "Gemini"。

## 實作步驟

1. **環境準備**: 安裝 WebView2 SDK 與 Windows App Packaging 工具。
2. **開發主程式**: 建立 WPF 專案並整合 WebView2。
3. **設定 Manifest**: 寫入必要的 AppExtension 宣告。
4. **簽署與部署**: 建立測試憑證，封裝為 `.msix` 並進行安裝測試。

## 驗證計畫

- **安裝驗證**: 確認應用程式出現在「設定 > 個人化 > 文字輸入 > 自訂鍵盤上的 Copilot 鍵」選單中。
- **功能驗證**: 按下 Copilot 鍵後，應彈出 Gemini 視窗。
