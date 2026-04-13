using Skilled.Data.Models;
using Skilled.ViewModels;

namespace Skilled.Views;

public partial class HomePage : ContentPage
{
    private readonly HomeViewModel _viewModel;

    public HomePage() : this(ServiceHelper.GetRequiredService<HomeViewModel>())
    {
    }

    public HomePage(HomeViewModel viewModel)
    {
        InitializeComponent();
        _viewModel = viewModel;
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
            await Shell.Current.GoToAsync(
                $"{nameof(ServiceListPage)}?categoryId={category.Id}&categoryName={Uri.EscapeDataString(category.Name)}");
        }
        ((CollectionView)sender).SelectedItem = null;
    }

    private async void OnProviderSelected(object sender, SelectionChangedEventArgs e)
    {
        if (e.CurrentSelection.FirstOrDefault() is Skilled.Data.Models.ServiceProvider provider)
        {
            await Shell.Current.GoToAsync(
                $"{nameof(ServiceDetailPage)}?providerId={provider.Id}");
        }
        ((CollectionView)sender).SelectedItem = null;
    }
}
