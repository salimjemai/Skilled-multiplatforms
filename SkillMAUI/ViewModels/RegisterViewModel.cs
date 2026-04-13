using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Microsoft.Extensions.Logging;
using Skilled.Data.Models;
using Skilled.Services;

namespace Skilled.ViewModels;

public partial class RegisterViewModel : ObservableObject
{
    private readonly IAuthService _authService;
    private readonly ILogger<RegisterViewModel> _logger;

    [ObservableProperty] private string _firstName = string.Empty;
    [ObservableProperty] private string _lastName = string.Empty;
    [ObservableProperty] private string _email = string.Empty;
    [ObservableProperty] private string _phone = string.Empty;
    [ObservableProperty] private string _password = string.Empty;
    [ObservableProperty] private string _confirmPassword = string.Empty;
    [ObservableProperty] private bool _isCustomer = true;
    [ObservableProperty] private bool _isProvider = false;
    [ObservableProperty] private bool _agreeToTerms = false;
    [ObservableProperty] private bool _isLoading = false;
    [ObservableProperty] private string _errorMessage = string.Empty;

    public RegisterViewModel(IAuthService authService, ILogger<RegisterViewModel> logger)
    {
        _authService = authService;
        _logger = logger;
    }

    [RelayCommand]
    public async Task Register()
    {
        if (!ValidateInput())
            return;

        IsLoading = true;
        ErrorMessage = string.Empty;

        try
        {
            var role = IsProvider ? UserRole.Provider : UserRole.Customer;

            // Split name into first/last — RegisterViewModel only has a single Name field
            // so derive from FirstName/LastName directly.
            var success = await _authService.RegisterAsync(
                FirstName, LastName, Email, Password, role);

            if (success)
            {
                await Shell.Current.DisplayAlert("Success", "Account created successfully!", "OK");
                await Shell.Current.GoToAsync("//MainTabs/HomePage");
            }
            else
            {
                ErrorMessage = "Registration failed. The email may already be in use.";
                await Shell.Current.DisplayAlert("Error", ErrorMessage, "OK");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during registration");
            ErrorMessage = "An unexpected error occurred. Please try again.";
            await Shell.Current.DisplayAlert("Error", ErrorMessage, "OK");
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
        if (string.IsNullOrWhiteSpace(FirstName))
        {
            Shell.Current.DisplayAlert("Error", "Please enter your first name", "OK");
            return false;
        }

        if (string.IsNullOrWhiteSpace(LastName))
        {
            Shell.Current.DisplayAlert("Error", "Please enter your last name", "OK");
            return false;
        }

        if (string.IsNullOrWhiteSpace(Email) || !Email.Contains('@'))
        {
            Shell.Current.DisplayAlert("Error", "Please enter a valid email address", "OK");
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
