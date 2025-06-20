using Skilled.Views;

namespace Skilled;

public partial class AppShell : Shell
{
    public AppShell()
    {
        InitializeComponent();
        
        // Register routes for navigation
        Routing.RegisterRoute(nameof(LoginPage), typeof(LoginPage));
        Routing.RegisterRoute(nameof(RegisterPage), typeof(RegisterPage));
        Routing.RegisterRoute(nameof(HomePage), typeof(HomePage));
        Routing.RegisterRoute(nameof(ProfilePage), typeof(ProfilePage));
        Routing.RegisterRoute(nameof(ServiceListPage), typeof(ServiceListPage));
        Routing.RegisterRoute(nameof(ServiceDetailPage), typeof(ServiceDetailPage));
        Routing.RegisterRoute(nameof(BookingPage), typeof(BookingPage));
        Routing.RegisterRoute(nameof(BookingsPage), typeof(BookingsPage));
    }

    protected override void OnAppearing()
    {
        base.OnAppearing();
        Shell.Current?.GoToAsync("//LoginPage");
    }
}