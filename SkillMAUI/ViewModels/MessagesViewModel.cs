using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Skilled.Data.Models;
using System.Collections.ObjectModel;

namespace Skilled.ViewModels;

public partial class MessagesViewModel : ObservableObject
{
    [ObservableProperty]
    private ObservableCollection<User> _serviceProviders;

    [ObservableProperty]
    private ObservableCollection<ChatPreview> _chatPreviews;

    [ObservableProperty]
    private bool _isLoading;

    public MessagesViewModel()
    {
        _serviceProviders = new ObservableCollection<User>();
        _chatPreviews = new ObservableCollection<ChatPreview>();
    }

    [RelayCommand]
    public async Task LoadDataAsync()
    {
        IsLoading = true;
        
        try
        {
            LoadMockProviders();
            LoadMockChatPreviews();
        }
        catch (Exception ex)
        {
            // Handle error
            await Shell.Current.DisplayAlert("Error", "Failed to load messages", "OK");
        }
        finally
        {
            IsLoading = false;
        }
    }

    private void LoadMockProviders()
    {
        ServiceProviders.Clear();
        var mockProviders = new[]
        {
            new User
            {
                Id = Guid.NewGuid(),
                FirstName = "John",
                LastName = "Smith",
                ProfileImageUrl = "provider1.png"
            },
            new User
            {
                Id = Guid.NewGuid(),
                FirstName = "Sarah",
                LastName = "Johnson",
                ProfileImageUrl = "provider2.png"
            },
            new User
            {
                Id = Guid.NewGuid(),
                FirstName = "Mike",
                LastName = "Brown",
                ProfileImageUrl = "provider3.png"
            }
        };

        foreach (var provider in mockProviders)
        {
            ServiceProviders.Add(provider);
        }
    }

    private void LoadMockChatPreviews()
    {
        ChatPreviews.Clear();
        var mockChats = new[]
        {
            new ChatPreview
            {
                Id = Guid.NewGuid(),
                UserId = Guid.NewGuid(),
                Name = "John Smith",
                LastMessage = "I'll be there at 2pm",
                Timestamp = DateTime.Now,
                UnreadCount = 2,
                ProfileImage = "provider1.png"
            },
            new ChatPreview
            {
                Id = Guid.NewGuid(),
                UserId = Guid.NewGuid(),
                Name = "Sarah Johnson",
                LastMessage = "The quote looks good",
                Timestamp = DateTime.Now.AddHours(-1),
                UnreadCount = 0,
                ProfileImage = "provider2.png"
            },
            new ChatPreview
            {
                Id = Guid.NewGuid(),
                UserId = Guid.NewGuid(),
                Name = "Mike Brown",
                LastMessage = "Can you come earlier?",
                Timestamp = DateTime.Now.AddHours(-2),
                UnreadCount = 1,
                ProfileImage = "provider3.png"
            }
        };

        foreach (var chat in mockChats)
        {
            ChatPreviews.Add(chat);
        }
    }
} 