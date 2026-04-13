using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Skilled.Data.Models;

public class ChatPreview
{
    public Guid Id { get; set; }

    /// <summary>The current user who owns this chat preview.</summary>
    public Guid UserId { get; set; }

    /// <summary>The other participant in the conversation.</summary>
    public Guid OtherUserId { get; set; }

    [MaxLength(500)]
    public string LastMessage { get; set; } = string.Empty;

    public DateTime LastMessageTime { get; set; } = DateTime.UtcNow;

    public int UnreadCount { get; set; } = 0;

    [MaxLength(200)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(500)]
    public string ProfileImage { get; set; } = string.Empty;

    // ── Computed (not mapped) ────────────────────────────────────────────────
    [NotMapped]
    public bool HasUnreadMessages => UnreadCount > 0;

    [NotMapped]
    public DateTime Timestamp => LastMessageTime;

    // ── Navigation properties ────────────────────────────────────────────────
    public virtual User? User { get; set; }
    public virtual User? OtherUser { get; set; }
}
