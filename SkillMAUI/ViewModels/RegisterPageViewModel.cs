using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Microsoft.Extensions.Logging;
using Skilled.Data.Models;
using Skilled.Services;

namespace Skilled.ViewModels;

public partial class RegisterPageViewModel : ObservableObject
{
    private readonly IAuthService _authService;
    private readonly ILogger<RegisterPageViewModel> _logger;
    
    [ObservableProperty]
    private string _firstName;
    
    [ObservableProperty]
    private string _lastName;
    
    [ObservableProperty]
    private string _email;
    
    [ObservableProperty]
    private string _password;
    
    [ObservableProperty]
    private string _confirmPassword;
    
    [ObservableProperty]
    private bool _isProvider;
    
    [ObservableProperty]
    private bool _isBusy;
    
    [ObservableProperty]
    private string _errorMessage;
    
    public RegisterPageViewModel(IAuthService authService, ILogger<RegisterPageViewModel> logger)
    {
        _authService = authService;
        _logger = logger;
    }
    
    [RelayCommand]
    private async Task RegisterAsync()
    {
        if (string.IsNullOrWhiteSpace(FirstName) || 
            string.IsNullOrWhiteSpace(LastName) || 
            string.IsNullOrWhiteSpace(Email) || 
            string.IsNullOrWhiteSpace(Password) ||
            string.IsNullOrWhiteSpace(ConfirmPassword))
        {
            ErrorMessage = "Please fill in all fields";
            return;
        }
        
        if (Password != ConfirmPassword)
        {
            ErrorMessage = "Passwords do not match";
            return;
        }
        
        try
        {
            IsBusy = true;
            ErrorMessage = string.Empty;
            
            var userRole = IsProvider ? UserRole.Provider : UserRole.Customer;
            var result = await _authService.RegisterAsync(FirstName, LastName, Email, Password, userRole);
            
            if (result)
            {
                // Navigate to home page
                await Shell.Current.GoToAsync("//MainTabs/HomePage");
            }
            else
            {
                ErrorMessage = "Failed to register. Email may already be in use.";
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during registration");
            ErrorMessage = "An error occurred during registration. Please try again.";
        }
        finally
        {
            IsBusy = false;
        }
    }
    
    [RelayCommand]
    private async Task LoginAsync()
    {
        await Shell.Current.GoToAsync("//LoginPage");
    }
}