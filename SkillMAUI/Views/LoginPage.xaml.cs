using Skilled.ViewModels;

namespace Skilled.Views;

public partial class LoginPage : ContentPage
{
    public LoginPage(LoginPageViewModel viewModel)
    {
        InitializeComponent();
        BindingContext = viewModel;
    }
}