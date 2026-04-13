using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Microsoft.Extensions.Logging;
using Skilled.Data.Models;
using Skilled.Services;
using System.Collections.ObjectModel;
using System.Net.Http.Json;

namespace Skilled.ViewModels;

public partial class BookingsViewModel : ObservableObject
{
    private readonly IAuthService _authService;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IPreferenceService _preferenceService;
    private readonly ILogger<BookingsViewModel> _logger;

    [ObservableProperty]
    private ObservableCollection<BookingDisplayItem> _bookings = new();

    [ObservableProperty]
    private bool _isLoading;

    [ObservableProperty]
    private bool _isUpcomingSelected = true;

    [ObservableProperty]
    private bool _isPastSelected = false;

    [ObservableProperty]
    private bool _isEmpty = false;

    public BookingsViewModel(
        IAuthService authService,
        IHttpClientFactory httpClientFactory,
        IPreferenceService preferenceService,
        ILogger<BookingsViewModel> logger)
    {
        _authService = authService;
        _httpClientFactory = httpClientFactory;
        _preferenceService = preferenceService;
        _logger = logger;
    }

    [RelayCommand]
    public async Task LoadBookingsAsync()
    {
        IsLoading = true;
        try
        {
            var token = _preferenceService.Get<string>("auth_token");
            if (string.IsNullOrEmpty(token))
            {
                IsEmpty = true;
                return;
            }

            var statusFilter = IsUpcomingSelected
                ? "Confirmed"
                : "Completed";

            var client = _httpClientFactory.CreateClient("SkilledApi");
            client.DefaultRequestHeaders.Authorization =
                new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);

            var response = await client.GetAsync($"api/bookings?status={statusFilter}");
            if (response.IsSuccessStatusCode)
            {
                var bookings = await response.Content.ReadFromJsonAsync<List<BookingApiDto>>()
                               ?? new List<BookingApiDto>();

                Bookings.Clear();
                foreach (var b in bookings)
                {
                    Bookings.Add(new BookingDisplayItem
                    {
                        Id = b.Id,
                        ProviderName = b.ProviderName,
                        ServiceName = b.ServiceName,
                        Date = b.Date,
                        TotalAmount = b.TotalAmount,
                        Status = b.Status
                    });
                }
            }
            IsEmpty = !Bookings.Any();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error loading bookings");
            await Shell.Current.DisplayAlert("Error", "Failed to load bookings.", "OK");
            IsEmpty = true;
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
}

// Lightweight display model for the bookings list
public class BookingDisplayItem
{
    public Guid Id { get; set; }
    public string ProviderName { get; set; } = string.Empty;
    public string ServiceName { get; set; } = string.Empty;
    public DateTime Date { get; set; }
    public decimal TotalAmount { get; set; }
    public string Status { get; set; } = string.Empty;
}

// Matches the API BookingDto shape
public class BookingApiDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid ProviderId { get; set; }
    public string ProviderName { get; set; } = string.Empty;
    public Guid ServiceId { get; set; }
    public string ServiceName { get; set; } = string.Empty;
    public DateTime Date { get; set; }
    public string Notes { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}
