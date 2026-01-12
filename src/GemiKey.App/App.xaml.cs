using System.Configuration;
using System.Data;
using System.Windows;

namespace GemiHotkeyProvider.App;

/// <summary>
/// Interaction logic for App.xaml
/// </summary>
public partial class App : Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        var initialUrl = UrlArgumentParser.GetInitialUrl(e.Args) ?? DefaultUrls.Gemini;

        var mainWindow = new MainWindow
        {
            InitialUrl = initialUrl,
        };

        mainWindow.Show();
    }
}

