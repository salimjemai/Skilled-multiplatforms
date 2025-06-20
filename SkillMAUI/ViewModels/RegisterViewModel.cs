using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Skilled.Data.Models;

namespace Skilled.ViewModels;

public partial class RegisterViewModel : ObservableObject
{
    [ObservableProperty]
    private string _name = string.Empty;

    [ObservableProperty]
    private string _email = string.Empty;

    [ObservableProperty]
    private string _phone = string.Empty;

    [ObservableProperty]
    private string _password = string.Empty;

    [ObservableProperty]
    private string _confirmPassword = string.Empty;

    [ObservableProperty]
    private bool _isCustomer = true;

    [ObservableProperty]
    private bool _isProvider = false;

    [ObservableProperty]
    private bool _agreeToTerms = false;

    [ObservableProperty]
    private bool _isLoading = false;

    public RegisterViewModel()
    {
    }

    [RelayCommand]
    public async Task Register()
    {
        if (!ValidateInput())
            return;

        IsLoading = true;

        try
        {
            await Shell.Current.DisplayAlert("Success", "Account created successfully!", "OK");
            await Shell.Current.GoToAsync("//MainTabs/HomePage");
        }
        catch (Exception ex)
        {
            await Shell.Current.DisplayAlert("Error", "Registration failed. Please try again.", "OK");
        }
        finally
        {
            IsLoading = false;
        }
    }

    [RelayCommand]
    public async Task NavigateToLogin()
    {
        await Shell.Current.GoToAsync("//LoginPage");
    }

    private bool ValidateInput()
    {
        if (string.IsNullOrWhiteSpace(Name))
        {
            Shell.Current.DisplayAlert("Error", "Please enter your name", "OK");
            return false;
        }

        if (string.IsNullOrWhiteSpace(Email) || !Email.Contains("@"))
        {
            Shell.Current.DisplayAlert("Error", "Please enter a valid email address", "OK");
            return false;
        }

        if (string.IsNullOrWhiteSpace(Phone))
        {
            Shell.Current.DisplayAlert("Error", "Please enter your phone number", "OK");
            return false;
        }

        if (string.IsNullOrWhiteSpace(Password) || Password.Length < 6)
        {
            Shell.Current.DisplayAlert("Error", "Password must be at least 6 characters", "OK");
            return false;
        }

        if (Password != ConfirmPassword)
        {
            Shell.Current.DisplayAlert("Error", "Passwords do not match", "OK");
            return false;
        }

        if (!AgreeToTerms)
        {
            Shell.Current.DisplayAlert("Error", "Please agree to the terms and conditions", "OK");
            return false;
        }

        return true;
    }
} 