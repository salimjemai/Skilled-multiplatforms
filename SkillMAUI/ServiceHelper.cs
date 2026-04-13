using Microsoft.Extensions.DependencyInjection;
using Microsoft.Maui;

namespace Skilled;

internal static class ServiceHelper
{
    public static T GetRequiredService<T>() where T : notnull
    {
        IServiceProvider? services =
            IPlatformApplication.Current?.Services ??
            Application.Current?.Handler?.MauiContext?.Services;

        if (services is null)
        {
            throw new InvalidOperationException("MAUI service provider is not available.");
        }

        return services.GetRequiredService<T>();
    }
}
