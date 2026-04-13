using Skilled.ViewModels;

namespace Skilled.Views;

public partial class RegisterPage : ContentPage
{
    public RegisterPage() : this(ServiceHelper.GetRequiredService<RegisterViewModel>())
    {
    }

    public RegisterPage(RegisterViewModel viewModel)
    {
        InitializeComponent();
        BindingContext = viewModel;
    }
}
