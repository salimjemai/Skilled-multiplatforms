using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using Skilled.Views;
using Skilled.Services;
using Skilled.ViewModels;
using Skilled.Data;

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

        // Add Entity Framework with PostgreSQL
        builder.Services.AddDbContext<SkilledDbContext>(options =>
        {
            var connectionString = builder.Configuration["ConnectionStrings:DefaultConnection"];
            options.UseNpgsql(connectionString);
        });

        // Add HttpClient
        builder.Services.AddHttpClient("SkilledApi", client =>
        {
            client.BaseAddress = new Uri("https://skilled-api.yourdomain.com/api/");
            client.DefaultRequestHeaders.Add("Accept", "application/json");
        });

        // Register services
        builder.Services.AddSingleton<IAuthService, AuthService>();
        builder.Services.AddSingleton<IUserService, UserService>();
        builder.Services.AddSingleton<ITradeServiceService, TradeServiceService>();
        builder.Services.AddSingleton<IPreferenceService, PreferenceService>();

        // Register view models
        builder.Services.AddTransient<LoginPageViewModel>();
        builder.Services.AddTransient<RegisterPageViewModel>();
        builder.Services.AddTransient<HomeViewModel>();
        builder.Services.AddTransient<MessagesViewModel>();
        builder.Services.AddTransient<BookingsViewModel>();
        builder.Services.AddTransient<SettingsViewModel>();
        builder.Services.AddTransient<RegisterViewModel>();

        // Register views
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

        return builder.Build();
    }
}
