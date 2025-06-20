using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Skilled.Data.Models;
using System.Collections.ObjectModel;

namespace Skilled.ViewModels;

public partial class HomeViewModel : ObservableObject
{
    [ObservableProperty]
    private ObservableCollection<TradeCategory> _categories;

    [ObservableProperty]
    private ObservableCollection<Skilled.Data.Models.ServiceProvider> _featuredProviders;

    [ObservableProperty]
    private bool _isLoading;

    public HomeViewModel()
    {
        _categories = new ObservableCollection<TradeCategory>();
        _featuredProviders = new ObservableCollection<Skilled.Data.Models.ServiceProvider>();
    }

    [RelayCommand]
    public async Task LoadDataAsync()
    {
        IsLoading = true;
        
        try
        {
            LoadDefaultCategories();
            LoadMockProviders();
        }
        catch (Exception ex)
        {
            // Handle error
            await Shell.Current.DisplayAlert("Error", "Failed to load data", "OK");
        }
        finally
        {
            IsLoading = false;
        }
    }

    private void LoadDefaultCategories()
    {
        Categories.Clear();
        var defaultCategories = new[]
        {
            new TradeCategory { Id = Guid.NewGuid(), Name = "Plumbing", Icon = "plumbing.png" },
            new TradeCategory { Id = Guid.NewGuid(), Name = "Electrical", Icon = "electrical.png" },
            new TradeCategory { Id = Guid.NewGuid(), Name = "Carpentry", Icon = "carpentry.png" },
            new TradeCategory { Id = Guid.NewGuid(), Name = "Painting", Icon = "painting.png" },
            new TradeCategory { Id = Guid.NewGuid(), Name = "Landscaping", Icon = "landscaping.png" },
            new TradeCategory { Id = Guid.NewGuid(), Name = "HVAC", Icon = "hvac.png" },
            new TradeCategory { Id = Guid.NewGuid(), Name = "Cleaning", Icon = "cleaning.png" },
            new TradeCategory { Id = Guid.NewGuid(), Name = "Handyman", Icon = "handyman.png" }
        };

        foreach (var category in defaultCategories)
        {
            Categories.Add(category);
        }
    }

    private void LoadMockProviders()
    {
        FeaturedProviders.Clear();
        var mockProviders = new[]
        {
            new Skilled.Data.Models.ServiceProvider
            {
                Id = Guid.NewGuid(),
                Name = "Mike's Plumbing",
                Description = "Professional plumbing services with 15 years experience",
                Email = "mike@plumbing.com",
                Phone = "(555) 123-4567"
            },
            new Skilled.Data.Models.ServiceProvider
            {
                Id = Guid.NewGuid(),
                Name = "ElectraPro",
                Description = "Licensed electricians for residential and commercial work",
                Email = "info@electrapro.com",
                Phone = "(555) 234-5678"
            },
            new Skilled.Data.Models.ServiceProvider
            {
                Id = Guid.NewGuid(),
                Name = "Green Landscapes",
                Description = "Complete landscaping solutions for beautiful yards",
                Email = "contact@greenlandscapes.com",
                Phone = "(555) 345-6789"
            }
        };

        foreach (var provider in mockProviders)
        {
            FeaturedProviders.Add(provider);
        }
    }
} 