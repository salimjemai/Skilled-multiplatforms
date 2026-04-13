using Skilled.Views;

namespace Skilled;

public partial class AppShell : Shell
{
    public AppShell()
    {
        InitializeComponent();

        BuildShellItems();

        Routing.RegisterRoute(nameof(ProfilePage),       typeof(ProfilePage));
        Routing.RegisterRoute(nameof(ServiceListPage),   typeof(ServiceListPage));
        Routing.RegisterRoute(nameof(ServiceDetailPage), typeof(ServiceDetailPage));
        Routing.RegisterRoute(nameof(BookingPage),       typeof(BookingPage));

        // Use MAUI Preferences directly — AppShell is not DI-constructed.
        // "auth_token" is the key AuthService uses to persist the JWT.
        var token = Preferences.Default.Get("auth_token", string.Empty);
        CurrentItem = string.IsNullOrEmpty(token) ? Items[0] : Items[^1];
    }

    private void BuildShellItems()
    {
        Items.Clear();

        Items.Add(CreateRootItem(nameof(LoginPage), "Login", typeof(LoginPage)));
        Items.Add(CreateRootItem(nameof(RegisterPage), "Register", typeof(RegisterPage)));
        Items.Add(CreateMainTabs());
    }

    private static FlyoutItem CreateRootItem(string route, string title, Type pageType)
    {
        var shellContent = new ShellContent
        {
            Route = route,
            Title = title,
            ContentTemplate = new DataTemplate(pageType)
        };

        var tab = new Tab();
        tab.Items.Add(shellContent);

        var item = new FlyoutItem
        {
            Route = route,
            Title = title,
            FlyoutDisplayOptions = FlyoutDisplayOptions.AsSingleItem
        };

        item.Items.Add(tab);
        return item;
    }

    private static TabBar CreateMainTabs()
    {
        var tabBar = new TabBar
        {
            Route = "MainTabs"
        };

        tabBar.Items.Add(CreateTab("Home", "home.svg", nameof(HomePage), typeof(HomePage)));
        tabBar.Items.Add(CreateTab("Messages", "message.svg", nameof(MessagesPage), typeof(MessagesPage)));
        tabBar.Items.Add(CreateTab("Bookings", "calendar.svg", nameof(BookingsPage), typeof(BookingsPage)));
        tabBar.Items.Add(CreateTab("Settings", "settings.svg", nameof(SettingsPage), typeof(SettingsPage)));

        return tabBar;
    }

    private static Tab CreateTab(string title, string icon, string route, Type pageType)
    {
        var shellContent = new ShellContent
        {
            Route = route,
            Title = title,
            ContentTemplate = new DataTemplate(pageType)
        };

        var tab = new Tab
        {
            Title = title,
            Icon = icon,
            Route = route
        };

        tab.Items.Add(shellContent);
        return tab;
    }
}
