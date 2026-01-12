using System;

namespace GemiHotkeyProvider.App;

internal static class UrlArgumentParser
{
    internal static string? GetInitialUrl(string[] args)
    {
        if (args.Length == 0)
        {
            return null;
        }

        for (var index = 0; index < args.Length; index++)
        {
            var value = args[index]?.Trim();
            if (string.IsNullOrWhiteSpace(value))
            {
                continue;
            }

            if (value.Equals("--url", StringComparison.OrdinalIgnoreCase))
            {
                if (index + 1 >= args.Length)
                {
                    return null;
                }

                return NormalizeUrl(args[index + 1]);
            }

            if (value.StartsWith("--url=", StringComparison.OrdinalIgnoreCase))
            {
                return NormalizeUrl(value["--url=".Length..]);
            }
        }

        return null;
    }

    private static string? NormalizeUrl(string? url)
    {
        if (string.IsNullOrWhiteSpace(url))
        {
            return null;
        }

        if (!Uri.TryCreate(url.Trim(), UriKind.Absolute, out var uri))
        {
            return null;
        }

        if (uri.Scheme is not ("https" or "http"))
        {
            return null;
        }

        return uri.ToString();
    }
}

