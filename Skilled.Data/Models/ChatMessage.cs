using System.ComponentModel.DataAnnotations;

namespace Skilled.Data.Models;

public enum MessageType
{
    Text,
    Image,
    File
}

public class ChatMessage
{
    public Guid Id { get; set; }

    public Guid SenderId { get; set; }
    public Guid ReceiverId { get; set; }

    [Required, MaxLength(2000)]
    public string Message { get; set; } = string.Empty;

    public MessageType MessageType { get; set; } = MessageType.Text;

    public DateTime SentAt { get; set; } = DateTime.UtcNow;

    public bool IsRead { get; set; } = false;

    public DateTime? ReadAt { get; set; }

    // ── Navigation properties ────────────────────────────────────────────────
    public virtual User? Sender { get; set; }
    public virtual User? Receiver { get; set; }
}
