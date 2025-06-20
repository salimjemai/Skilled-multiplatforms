using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Skilled.Data.Models;

namespace Skilled.ViewModels;

public partial class SettingsViewModel : ObservableObject
{
    [ObservableProperty]
    private User _currentUser;

    [ObservableProperty]
    private bool _notificationsEnabled;

    public SettingsViewModel()
    {
        _currentUser = new User
        {
            FirstName = "John",
            LastName = "Doe",
            Email = "john.doe@example.com"
        };
        _notificationsEnabled = true;
    }

    [RelayCommand]
    public async Task LoadUserDataAsync()
    {
        try
        {
            // Mock data already loaded in constructor
        }
        catch (Exception ex)
        {
            // Handle error
            await Shell.Current.DisplayAlert("Error", "Failed to load user data", "OK");
        }
    }

    [RelayCommand]
    public async Task LogoutAsync()
    {
        try
        {
            await Shell.Current.DisplayAlert("Logout", "Logout successful", "OK");
        }
        catch (Exception ex)
        {
            // Handle error
            await Shell.Current.DisplayAlert("Error", "Failed to logout", "OK");
        }
    }

    partial void OnNotificationsEnabledChanged(bool value)
    {
        // Mock implementation
    }
} 