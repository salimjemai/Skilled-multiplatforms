namespace Skilled.Data.Models;

public class ChatMessage
{
    public Guid Id { get; set; }
    public Guid SenderId { get; set; }
    public Guid ReceiverId { get; set; }
    public string Message { get; set; } = string.Empty;
    public DateTime SentAt { get; set; }
    public bool IsRead { get; set; }
}

public enum MessageType
{
    Text,
    Image,
    File
} 