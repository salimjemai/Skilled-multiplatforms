using Skilled.Data.Models;
using Skilled.ViewModels;

namespace Skilled.Views;

public partial class MessagesPage : ContentPage
{
    private MessagesViewModel _viewModel;

    public MessagesPage()
    {
        InitializeComponent();
        _viewModel = new MessagesViewModel();
        BindingContext = _viewModel;
    }

    protected override async void OnAppearing()
    {
        base.OnAppearing();
        await _viewModel.LoadDataAsync();
    }

    private async void OnProviderSelected(object sender, SelectionChangedEventArgs e)
    {
        if (e.CurrentSelection.FirstOrDefault() is User provider)
        {
            // Start a new chat with the selected provider
            await Shell.Current.GoToAsync($"//ChatPage?userId={provider.Id}&name={provider.FirstName} {provider.LastName}");
        }
    }

    private async void OnChatSelected(object sender, SelectionChangedEventArgs e)
    {
        if (e.CurrentSelection.FirstOrDefault() is ChatPreview chat)
        {
            // Navigate to existing chat
            await Shell.Current.GoToAsync($"//ChatPage?userId={chat.UserId}&name={chat.Name}");
        }
    }
} 