using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Skilled.Data;
using Skilled.Services;
using Skilled.ViewModels;
using Skilled.Views;

namespace Skilled;

public static class MauiProgram
{
    public static MauiApp CreateMauiApp()
    {
        var builder = MauiApp.CreateBuilder();

        builder
            .UseMauiApp<App>()
            .ConfigureFonts(fonts =>
            {
                fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
                fonts.AddFont("OpenSans-Semibold.ttf", "OpenSansSemibold");
            });

        // ── Configuration ──────────────────────────────────────────────────
        // Prefer bundled appsettings, but don't crash the app if it is absent.
        try
        {
            using var stream = FileSystem.OpenAppPackageFileAsync("appsettings.json").GetAwaiter().GetResult();
            var config = new ConfigurationBuilder()
                .AddJsonStream(stream)
                .Build();
            builder.Configuration.AddConfiguration(config);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[MauiProgram] appsettings.json unavailable: {ex.Message}");
        }

        // ── Database (optional — app can work API-only without local DB) ───
        var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
        if (!string.IsNullOrEmpty(connectionString))
        {
            builder.Services.AddDbContext<SkilledDbContext>(options =>
                options.UseNpgsql(connectionString),
                ServiceLifetime.Scoped);
        }

        // ── HTTP Client ───────────────────────────────────────────────────
        var apiBaseUrl = builder.Configuration["ApiSettings:BaseUrl"]
                         ?? "http://localhost:5000/api";

        builder.Services.AddHttpClient("SkilledApi", client =>
        {
            // BaseAddress set to root so services can build full URLs from config
            client.BaseAddress = new Uri(apiBaseUrl.Replace("/api", "/"));
            client.DefaultRequestHeaders.Add("Accept", "application/json");
            client.Timeout = TimeSpan.FromSeconds(30);
        });

        // ── Services (Scoped — safe with DbContext lifetime) ───────────────
        builder.Services.AddScoped<IAuthService, AuthService>();
        builder.Services.AddScoped<IUserService, UserService>();
        builder.Services.AddScoped<ITradeServiceService, TradeServiceService>();
        builder.Services.AddSingleton<IPreferenceService, PreferenceService>();

        // ── ViewModels ─────────────────────────────────────────────────────
        builder.Services.AddTransient<LoginPageViewModel>();
        builder.Services.AddTransient<RegisterPageViewModel>();
        builder.Services.AddTransient<RegisterViewModel>();
        builder.Services.AddTransient<HomeViewModel>();
        builder.Services.AddTransient<MessagesViewModel>();
        builder.Services.AddTransient<BookingsViewModel>();
        builder.Services.AddTransient<SettingsViewModel>();

        // ── Views (Pages) ──────────────────────────────────────────────────
        builder.Services.AddTransient<LoginPage>();
        builder.Services.AddTransient<RegisterPage>();
        builder.Services.AddTransient<HomePage>();
        builder.Services.AddTransient<ProfilePage>();
        builder.Services.AddTransient<ServiceListPage>();
        builder.Services.AddTransient<ServiceDetailPage>();
        builder.Services.AddTransient<BookingPage>();
        builder.Services.AddTransient<BookingsPage>();
        builder.Services.AddTransient<MessagesPage>();
        builder.Services.AddTransient<SettingsPage>();

#if DEBUG
        builder.Logging.AddDebug();
#endif

        var app = builder.Build();

        // ── Initialize the database on first launch ──────────────────────
        InitializeDatabaseAsync(app.Services).GetAwaiter().GetResult();

        return app;
    }

    private static async Task InitializeDatabaseAsync(IServiceProvider services)
    {
        try
        {
            using var scope = services.CreateScope();
            var db = scope.ServiceProvider.GetService<SkilledDbContext>();
            if (db != null)
            {
                await db.Database.MigrateAsync();
            }
        }
        catch (Exception ex)
        {
            // Database unavailable is non-fatal — app works in API-only mode
            Console.WriteLine($"[MauiProgram] DB init skipped: {ex.Message}");
        }
    }
}
