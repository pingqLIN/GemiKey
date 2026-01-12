using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System;
using System.Diagnostics;
using Microsoft.Web.WebView2.Core;

namespace GemiHotkeyProvider.App;

/// <summary>
/// Interaction logic for MainWindow.xaml
/// </summary>
public partial class MainWindow : Window
{
    public string? InitialUrl { get; init; }

    private bool _webViewReady;

    public MainWindow()
    {
        InitializeComponent();
    }

    private async void MainWindow_OnLoaded(object sender, RoutedEventArgs e)
    {
        var target = InitialUrl ?? DefaultUrls.Gemini;
        AddressTextBox.Text = target;

        try
        {
            await Browser.EnsureCoreWebView2Async();
        }
        catch (Exception ex)
        {
            MessageBox.Show(
                this,
                "Microsoft Edge WebView2 Runtime is required.\n\nInstall it and try again.\n\nDetails: " + ex.Message,
                "WebView2 Runtime required",
                MessageBoxButton.OK,
                MessageBoxImage.Error);
            Close();
            return;
        }

        _webViewReady = true;

        Browser.CoreWebView2.Settings.AreDevToolsEnabled = false;
        Browser.CoreWebView2.Settings.IsStatusBarEnabled = false;
        Browser.CoreWebView2.Settings.IsZoomControlEnabled = true;

        Browser.CoreWebView2.NavigationStarting += (_, _) => UpdateNavButtons();
        Browser.CoreWebView2.NavigationCompleted += (_, _) =>
        {
            AddressTextBox.Text = Browser.Source?.ToString() ?? AddressTextBox.Text;
            UpdateNavButtons();
        };

        NavigateTo(target);
    }

    private void AddressTextBox_OnKeyDown(object sender, KeyEventArgs e)
    {
        if (e.Key != Key.Enter)
        {
            return;
        }

        e.Handled = true;
        NavigateTo(AddressTextBox.Text);
    }

    private void BackButton_OnClick(object sender, RoutedEventArgs e)
    {
        if (_webViewReady && Browser.CanGoBack)
        {
            Browser.GoBack();
        }
    }

    private void ForwardButton_OnClick(object sender, RoutedEventArgs e)
    {
        if (_webViewReady && Browser.CanGoForward)
        {
            Browser.GoForward();
        }
    }

    private void ReloadButton_OnClick(object sender, RoutedEventArgs e)
    {
        if (_webViewReady)
        {
            Browser.Reload();
        }
    }

    private void OpenInBrowserButton_OnClick(object sender, RoutedEventArgs e)
    {
        var url = Browser.Source?.ToString() ?? AddressTextBox.Text;
        if (string.IsNullOrWhiteSpace(url))
        {
            return;
        }

        try
        {
            Process.Start(new ProcessStartInfo(url) { UseShellExecute = true });
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Failed to open browser", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private void NavigateTo(string? raw)
    {
        if (!_webViewReady)
        {
            return;
        }

        var url = NormalizeUrl(raw);
        if (url is null)
        {
            return;
        }

        AddressTextBox.Text = url;
        Browser.CoreWebView2.Navigate(url);
    }

    private static string? NormalizeUrl(string? raw)
    {
        if (string.IsNullOrWhiteSpace(raw))
        {
            return null;
        }

        raw = raw.Trim();
        if (raw.StartsWith("gemini", StringComparison.OrdinalIgnoreCase))
        {
            return DefaultUrls.Gemini;
        }

        if (!raw.Contains("://", StringComparison.Ordinal))
        {
            raw = "https://" + raw;
        }

        if (!Uri.TryCreate(raw, UriKind.Absolute, out var uri))
        {
            return null;
        }

        if (uri.Scheme is not ("https" or "http"))
        {
            return null;
        }

        return uri.ToString();
    }

    private void UpdateNavButtons()
    {
        BackButton.IsEnabled = _webViewReady && Browser.CanGoBack;
        ForwardButton.IsEnabled = _webViewReady && Browser.CanGoForward;
    }
}
