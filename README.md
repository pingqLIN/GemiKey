# GemiKey

**GemiKey** 概念驗證（PoC），探索並實作 Windows 11「Copilot 鍵」的自訂行為。
微軟官方 `Copilot hardware key provider` 將實體鍵盤上的 Copilot 鍵重新導向至 Google Gemini（或其他自訂應用程式），使其能出現在 Windows 設定的 App Picker 中。

## Project Background

Windows 11 allows users to change the behavior triggered by the "Copilot key" in Settings, through the following path:

`Settings` \> `Personalization` \> `Text input` \> `Customize Copilot key on keyboard`

However, this menu only lists applications that meet specific specifications. This project aims to understand these specifications and provide an implementation template.

## Technical Specifications

To make an application appear in Windows' Copilot key option list, you do **not** need to modify Windows system files. Instead, the application itself must meet the following three conditions:

1. **MSIX Packaging**: The application must be packaged in MSIX format (supports Desktop, UWP, WinUI 3, and other frameworks).
2. **Manifest Registration**: Declare support for the `Microsoft Copilot hardware key provider` extension in `Package.appxmanifest`.
3. **Digital Signature**: The application must be signed; otherwise, Windows will not consider it a valid Copilot key target.

### Solution Architecture

For integrating "Gemini," this project adopts the following lightweight strategy:

- Create a lightweight Provider App (e.g., a shell program using WebView2 to open `https://gemini.google.com/`).
- Register as a Provider according to the specification.
- Display with the name "Gemini" in the system menu.

## Developer Guide

### 1\. Package Manifest Configuration

In the application's `Package.appxmanifest`, you must add `uap3:AppExtension`, and the `Name` attribute must be specified as `com.microsoft.windows.copilotkeyprovider`.

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
```
* `DisplayName`: The name displayed in the Windows Settings App Picker (e.g., Gemini).
* `Description`: Descriptive text for the application.

### 2\. Signing Requirements

The official documentation explicitly states:

"Provider apps must be signed in order to be enabled as a target of the Microsoft Copilot hardware key."

Practical signing strategies:

* **Development Phase**: You can use a self-signed certificate and install the certificate in "Trusted Root Certification Authorities."
* **Release Phase**: You need to use an official code signing certificate.

## Debugging and Verification

If the application does not appear in the list, you can check the system status and current bindings through the following Registry key.

**Registry Path:**

`HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\BrandedKey`

| Key Name | Description | Possible Values |
| :---- | :---- | :---- |
| **BrandedKeyChoiceType** | Current key behavior type | `Search` (Search) \`App\` (Custom App) \`AppEnforcedByPolicy\` (Policy Enforced) |
| **AppAumid** | Currently bound App ID | Target App's AUMID (Application User Model ID) |

**Common Failure Reasons:**

1. App is not installed or needs to be reinstalled (to trigger system Manifest scanning).
2. App is not properly signed.
3. Extension Name in the Manifest is misspelled.

## Project Roadmap and MVP

The current Minimum Viable Product (MVP) goal is to "make Gemini selectable in the Settings page."

### Technical Options Evaluation

* **WPF \+ WebView2**: ✅ **(Currently Adopted)** Intuitive, high compatibility, suitable for rapid development.
* **WinUI 3 (Windows App SDK)**: Closer to native Windows 11 UI, but the project architecture is heavier.
* **Minimized EXE \+ MSIX**: Only launches the default browser to the URL, with the lowest maintenance cost.

### Current Status

An MVP based on WPF \+ WebView2 has been established:

* **Source Code**: `Projects/gemikey/src/GemiHotkeyProvider.App`
* **Documentation Guide**: `Projects/gemikey/docs/provider-app-wpf-webview2.md`
* **Manifest Template**: `Projects/gemikey/packaging/copilot-key-provider.extension.xml`

## References (Microsoft Official)

* [Windows Keyboard Shortcuts and Copilot Key Description](https://support.microsoft.com/en-us/windows/keyboard-shortcuts-in-windows-dcc61a57-8ff0-cffe-9796-cb9706c75eec)
* [IT Management: Manage Windows Copilot](https://learn.microsoft.com/en-us/windows/client-management/manage-windows-copilot)
* [Developer Specification: Microsoft Copilot hardware key provider](https://learn.microsoft.com/en-us/windows/apps/develop/windows-integration/microsoft-copilot-key-provider)
```
