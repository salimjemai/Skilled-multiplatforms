using Skilled.ViewModels;

namespace Skilled.Views;

public partial class LoginPage : ContentPage
{
    public LoginPage() : this(ServiceHelper.GetRequiredService<LoginPageViewModel>())
    {
    }

    public LoginPage(LoginPageViewModel viewModel)
    {
        InitializeComponent();
        BindingContext = viewModel;
    }
}
