using Skilled.ViewModels;

namespace Skilled.Views;

public partial class MessagesPage : ContentPage
{
    private readonly MessagesViewModel _viewModel;

    public MessagesPage() : this(ServiceHelper.GetRequiredService<MessagesViewModel>())
    {
    }

    public MessagesPage(MessagesViewModel viewModel)
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

    private async void OnChatSelected(object sender, SelectionChangedEventArgs e)
    {
        if (e.CurrentSelection.FirstOrDefault() is ChatPreviewDisplayItem chat)
        {
            // Navigate to conversation
            await Shell.Current.GoToAsync(
                $"{nameof(ServiceDetailPage)}?userId={chat.OtherUserId}&name={Uri.EscapeDataString(chat.Name)}");
        }
        // Clear selection so the item can be tapped again
        ((CollectionView)sender).SelectedItem = null;
    }
}
