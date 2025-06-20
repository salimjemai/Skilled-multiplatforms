using Skilled.ViewModels;

namespace Skilled.Views;

public partial class SettingsPage : ContentPage
{
    private SettingsViewModel _viewModel;

    public SettingsPage()
    {
        InitializeComponent();
        _viewModel = new SettingsViewModel();
        BindingContext = _viewModel;
    }

    protected override async void OnAppearing()
    {
        base.OnAppearing();
        await _viewModel.LoadUserDataAsync();
    }

    private async void OnEditProfileClicked(object sender, EventArgs e)
    {
        await Shell.Current.GoToAsync("//EditProfilePage");
    }

    private async void OnLogoutClicked(object sender, EventArgs e)
    {
        bool confirmed = await DisplayAlert("Logout", "Are you sure you want to logout?", "Yes", "No");
        if (confirmed)
        {
            await _viewModel.LogoutAsync();
            await Shell.Current.GoToAsync("//LoginPage");
        }
    }
} 