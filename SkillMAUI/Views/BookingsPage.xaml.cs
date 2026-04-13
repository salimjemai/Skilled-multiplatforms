using Skilled.ViewModels;

namespace Skilled.Views;

public partial class BookingsPage : ContentPage
{
    private readonly BookingsViewModel _viewModel;

    public BookingsPage() : this(ServiceHelper.GetRequiredService<BookingsViewModel>())
    {
    }

    public BookingsPage(BookingsViewModel viewModel)
    {
        InitializeComponent();
        _viewModel = viewModel;
        BindingContext = _viewModel;
    }

    protected override async void OnAppearing()
    {
        base.OnAppearing();
        await _viewModel.LoadBookingsAsync();
    }
}
