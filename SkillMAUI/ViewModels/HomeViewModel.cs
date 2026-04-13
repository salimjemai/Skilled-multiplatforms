using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Microsoft.Extensions.Logging;
using Skilled.Data.Models;
using Skilled.Services;
using System.Collections.ObjectModel;

namespace Skilled.ViewModels;

public partial class HomeViewModel : ObservableObject
{
    private readonly ITradeServiceService _tradeServiceService;
    private readonly IUserService _userService;
    private readonly ILogger<HomeViewModel> _logger;

    [ObservableProperty]
    private ObservableCollection<TradeCategory> _categories = new();

    [ObservableProperty]
    private ObservableCollection<Skilled.Data.Models.ServiceProvider> _featuredProviders = new();

    [ObservableProperty]
    private bool _isLoading;

    [ObservableProperty]
    private string _errorMessage = string.Empty;

    public HomeViewModel(
        ITradeServiceService tradeServiceService,
        IUserService userService,
        ILogger<HomeViewModel> logger)
    {
        _tradeServiceService = tradeServiceService;
        _userService = userService;
        _logger = logger;
    }

    [RelayCommand]
    public async Task LoadDataAsync()
    {
        IsLoading = true;
        ErrorMessage = string.Empty;

        try
        {
            // Load categories from API
            var categories = await _tradeServiceService.GetCategoriesAsync();
            Categories.Clear();
            foreach (var c in categories)
                Categories.Add(c);

            // Load featured providers from API
            var providers = await _userService.GetServiceProvidersAsync();
            FeaturedProviders.Clear();
            // The API returns User objects for the legacy endpoint;
            // the providers endpoint now returns ServiceProvider objects via the typed call.
            foreach (var p in providers.Take(10))
            {
                // Map User → lightweight ServiceProvider for display
                FeaturedProviders.Add(new Skilled.Data.Models.ServiceProvider
                {
                    Id = p.Id,
                    BusinessName = p.FullName,
                    Name = p.FullName,
                    ProfileImageUrl = p.ProfileImageUrl
                });
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to load home data");
            ErrorMessage = "Failed to load data. Please check your connection.";
            await Shell.Current.DisplayAlert("Error", ErrorMessage, "OK");
        }
        finally
        {
            IsLoading = false;
        }
    }
}
