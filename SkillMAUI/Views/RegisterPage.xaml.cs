using Skilled.ViewModels;

namespace Skilled.Views;

public partial class RegisterPage : ContentPage
{
    private RegisterViewModel _viewModel;

    public RegisterPage()
    {
        InitializeComponent();
        _viewModel = new RegisterViewModel();
        BindingContext = _viewModel;
    }
} 