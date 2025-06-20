using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Skilled.Data.Models;
using System.Collections.ObjectModel;

namespace Skilled.ViewModels;

public partial class BookingsViewModel : ObservableObject
{
    [ObservableProperty]
    private ObservableCollection<Booking> _bookings;

    [ObservableProperty]
    private bool _isLoading;

    [ObservableProperty]
    private bool _isUpcomingSelected = true;

    [ObservableProperty]
    private bool _isPastSelected = false;

    [ObservableProperty]
    private bool _isEmpty = false;

    public BookingsViewModel()
    {
        _bookings = new ObservableCollection<Booking>();
    }

    [RelayCommand]
    public async Task LoadBookingsAsync()
    {
        IsLoading = true;
        
        try
        {
            LoadMockBookings();
        }
        catch (Exception ex)
        {
            // Load mock data if API fails
            LoadMockBookings();
        }
        finally
        {
            IsLoading = false;
        }
    }

    [RelayCommand]
    public async Task SelectUpcoming()
    {
        IsUpcomingSelected = true;
        IsPastSelected = false;
        await LoadBookingsAsync();
    }

    [RelayCommand]
    public async Task SelectPast()
    {
        IsUpcomingSelected = false;
        IsPastSelected = true;
        await LoadBookingsAsync();
    }

    private void LoadMockBookings()
    {
        Bookings.Clear();
        var mockBookings = new[]
        {
            new Booking
            {
                Id = Guid.NewGuid(),
                UserId = Guid.NewGuid(),
                ProviderId = Guid.NewGuid(),
                ServiceId = Guid.NewGuid(),
                TotalAmount = 150.00m,
                Status = BookingStatus.Confirmed,
                CreatedAt = DateTime.UtcNow
            },
            new Booking
            {
                Id = Guid.NewGuid(),
                UserId = Guid.NewGuid(),
                ProviderId = Guid.NewGuid(),
                ServiceId = Guid.NewGuid(),
                TotalAmount = 200.00m,
                Status = BookingStatus.Completed,
                CreatedAt = DateTime.UtcNow.AddDays(-3)
            }
        };

        var filteredBookings = IsUpcomingSelected 
            ? mockBookings.Where(b => b.Status == BookingStatus.Confirmed).ToList()
            : mockBookings.Where(b => b.Status == BookingStatus.Completed).ToList();

        foreach (var booking in filteredBookings)
        {
            Bookings.Add(booking);
        }

        IsEmpty = !Bookings.Any();
    }
} 