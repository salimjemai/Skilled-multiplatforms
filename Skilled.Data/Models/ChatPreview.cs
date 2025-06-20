namespace Skilled.Data.Models;

public class ChatPreview
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string LastMessage { get; set; } = string.Empty;
    public DateTime LastMessageTime { get; set; }
    public int UnreadCount { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }
    public string ProfileImage { get; set; } = string.Empty;
} 