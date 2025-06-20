using Skilled.Data.Models;
using Skilled.ViewModels;

namespace Skilled.Views;

public partial class BookingsPage : ContentPage
{
    private BookingsViewModel _viewModel;

    public BookingsPage()
    {
        InitializeComponent();
        _viewModel = new BookingsViewModel();
        BindingContext = _viewModel;
    }

    protected override async void OnAppearing()
    {
        base.OnAppearing();
        await _viewModel.LoadBookingsAsync();
    }

    private async void OnBookingSelected(object sender, SelectionChangedEventArgs e)
    {
        if (e.CurrentSelection.FirstOrDefault() is Booking booking)
        {
            // Navigate to booking detail page
            await Shell.Current.GoToAsync($"//BookingDetailPage?bookingId={booking.Id}");
        }
    }
} 