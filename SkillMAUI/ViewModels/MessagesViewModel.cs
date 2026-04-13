using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Microsoft.Extensions.Logging;
using Skilled.Data.Models;
using Skilled.Services;
using System.Collections.ObjectModel;
using System.Net.Http.Json;

namespace Skilled.ViewModels;

public partial class MessagesViewModel : ObservableObject
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IPreferenceService _preferenceService;
    private readonly ILogger<MessagesViewModel> _logger;

    [ObservableProperty]
    private ObservableCollection<ChatPreviewDisplayItem> _chatPreviews = new();

    [ObservableProperty]
    private bool _isLoading;

    public MessagesViewModel(
        IHttpClientFactory httpClientFactory,
        IPreferenceService preferenceService,
        ILogger<MessagesViewModel> logger)
    {
        _httpClientFactory = httpClientFactory;
        _preferenceService = preferenceService;
        _logger = logger;
    }

    [RelayCommand]
    public async Task LoadDataAsync()
    {
        IsLoading = true;
        try
        {
            var token = _preferenceService.Get<string>("auth_token");
            if (string.IsNullOrEmpty(token))
                return;

            var client = _httpClientFactory.CreateClient("SkilledApi");
            client.DefaultRequestHeaders.Authorization =
                new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);

            var response = await client.GetAsync("api/messages/chats");
            if (response.IsSuccessStatusCode)
            {
                var chats = await response.Content.ReadFromJsonAsync<List<ChatPreviewApiDto>>()
                            ?? new List<ChatPreviewApiDto>();

                ChatPreviews.Clear();
                foreach (var c in chats)
                {
                    ChatPreviews.Add(new ChatPreviewDisplayItem
                    {
                        Id = c.Id,
                        OtherUserId = c.OtherUserId,
                        Name = c.Name,
                        ProfileImage = c.ProfileImage,
                        LastMessage = c.LastMessage,
                        Timestamp = c.LastMessageTime,
                        UnreadCount = c.UnreadCount
                    });
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error loading chat previews");
            await Shell.Current.DisplayAlert("Error", "Failed to load messages.", "OK");
        }
        finally
        {
            IsLoading = false;
        }
    }
}

/// <summary>Display model for the messages list — all properties the XAML binds to.</summary>
public class ChatPreviewDisplayItem
{
    public Guid Id { get; set; }
    public Guid OtherUserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string ProfileImage { get; set; } = string.Empty;
    public string LastMessage { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }
    public int UnreadCount { get; set; }
    public bool HasUnreadMessages => UnreadCount > 0;
}

/// <summary>Matches the API ChatPreviewDto shape.</summary>
public class ChatPreviewApiDto
{
    public Guid Id { get; set; }
    public Guid OtherUserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string ProfileImage { get; set; } = string.Empty;
    public string LastMessage { get; set; } = string.Empty;
    public DateTime LastMessageTime { get; set; }
    public int UnreadCount { get; set; }
}
