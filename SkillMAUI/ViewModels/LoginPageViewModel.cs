using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Microsoft.Extensions.Logging;
using Skilled.Data.Models;
using Skilled.Services;
using System.Collections.ObjectModel;

namespace Skilled.ViewModels;

public partial class LoginPageViewModel : ObservableObject
{
    private readonly IAuthService _authService;
    private readonly ILogger<LoginPageViewModel> _logger;
    
    [ObservableProperty]
    private string _email;
    
    [ObservableProperty]
    private string _password;
    
    [ObservableProperty]
    private bool _isBusy;
    
    [ObservableProperty]
    private string _errorMessage;
    
    public LoginPageViewModel(IAuthService authService, ILogger<LoginPageViewModel> logger)
    {
        _authService = authService;
        _logger = logger;
    }
    
    public LoginPageViewModel() {}
    
    [RelayCommand]
    private async Task LoginAsync()
    {
        if (string.IsNullOrWhiteSpace(Email) || string.IsNullOrWhiteSpace(Password))
        {
            ErrorMessage = "Please enter email and password";
            return;
        }
        
        try
        {
            IsBusy = true;
            ErrorMessage = string.Empty;
            
            var result = await _authService.LoginAsync(Email, Password);
            if (result)
            {
                // Navigate to main tabs — matches the TabBar Route="MainTabs" and ShellContent Route="HomePage"
                await Shell.Current.GoToAsync("//MainTabs/HomePage");
            }
            else
            {
                ErrorMessage = "Invalid email or password";
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during login");
            ErrorMessage = "An error occurred during login. Please try again.";
        }
        finally
        {
            IsBusy = false;
        }
    }
    
    [RelayCommand]
    private async Task RegisterAsync()
    {
        await Shell.Current.GoToAsync("RegisterPage");
    }
    
    [RelayCommand]
    private async Task ForgotPasswordAsync()
    {
        if (string.IsNullOrWhiteSpace(Email))
        {
            ErrorMessage = "Please enter your email address";
            return;
        }
        
        try
        {
            IsBusy = true;
            ErrorMessage = string.Empty;
            
            var result = await _authService.ResetPasswordAsync(Email);
            if (result)
            {
                await Shell.Current.DisplayAlert("Password Reset", "A password reset link has been sent to your email address.", "OK");
            }
            else
            {
                ErrorMessage = "Failed to send password reset email";
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during password reset");
            ErrorMessage = "An error occurred. Please try again.";
        }
        finally
        {
            IsBusy = false;
        }
    }
}