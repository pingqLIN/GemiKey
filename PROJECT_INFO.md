# GemiKey 專案資訊

## 專案類型

**Mixed (C# WPF + MSIX Packaging)**

## 技術棧

- **語言**: C# .NET
- **UI 框架**: WPF (Windows Presentation Foundation)
- **Web 整合**: WebView2
- **打包方式**: MSIX (Windows App Packaging)
- **IDE**: Visual Studio 2022+

## 專案目的

為 Windows 11 的 Copilot 硬體鍵（Copilot Key）提供自訂啟動行為，讓使用者可以將 Copilot 鍵 設定為開啟 Google Gemini，而非 Microsoft Copilot。

## 核心功能

1. **Copilot Key Provider 註冊**

   - 在 Windows 設定中的「自訂鍵盤上的 Copilot 鍵」選項出現
   - 使用 `com.microsoft.windows.copilotkeyprovider` AppExtension

2. **WebView2 整合**

   - 開啟 `https://gemini.google.com/` 的 WebView2 視窗
   - 支援 URL 參數化（可從命令列傳入不同網址）

3. **MSIX 封裝**
   - 包含必要的數位簽章（開發用測試憑證）
   - 符合 Windows Store 與 sideload 部署規範

## 開發環境需求

- Windows 11 (21H2+ 建議)
- Visual Studio 2022 with:
  - .NET Desktop Development workload
  - Windows Application Packaging Tools
- WebView2 Runtime (通常 Windows 11 已內建)

## 專案結構

```
gemikey/
├── src/
│   └── GemiKey.App/          # WPF 主應用程式
│       ├── MainWindow.xaml   # 主視窗 XAML
│       ├── MainWindow.xaml.cs # 視窗邏輯 (WebView2 初始化)
│       └── GemiKey.App.csproj
├── packaging/                # MSIX 封裝資源
│   └── copilot-key-provider.extension.xml
├── docs/                     # 開發文件
└── GemiKey.sln              # Visual Studio Solution
```

---

**最後更新**: 2026-01-12  
**維護人**: PingqLIN
