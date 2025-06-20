using Skilled.Data.Models;
using Skilled.ViewModels;

namespace Skilled.Views;

public partial class HomePage : ContentPage
{
    private HomeViewModel _viewModel;

    public HomePage()
    {
        InitializeComponent();
        _viewModel = new HomeViewModel();
        BindingContext = _viewModel;
    }

    protected override async void OnAppearing()
    {
        base.OnAppearing();
        await _viewModel.LoadDataAsync();
    }

    private async void OnCategorySelected(object sender, SelectionChangedEventArgs e)
    {
        if (e.CurrentSelection.FirstOrDefault() is TradeCategory category)
        {
            // Navigate to service list page with selected category
            await Shell.Current.GoToAsync($"//ServiceListPage?category={category.Name}");
        }
    }

    private async void OnProviderSelected(object sender, SelectionChangedEventArgs e)
    {
        if (e.CurrentSelection.FirstOrDefault() is Skilled.Data.Models.ServiceProvider provider)
        {
            // Navigate to service provider detail page
            await Shell.Current.GoToAsync($"//ServiceDetailPage?providerId={provider.Id}");
        }
    }
} 