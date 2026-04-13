namespace Skilled;

public partial class App : Application
{
    public App()
    {
        InitializeComponent();
    }

    protected override Window CreateWindow(IActivationState? activationState)
    {
        return new Window(new AppShell())
        {
            Title = "Skilled",
            Width = 1280,
            Height = 800
        };
    }
}
