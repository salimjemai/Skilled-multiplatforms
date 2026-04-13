using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Skilled.Data.Models;

public class User
{
    public Guid Id { get; set; }

    [Required, MaxLength(100)]
    public string FirstName { get; set; } = string.Empty;

    [Required, MaxLength(100)]
    public string LastName { get; set; } = string.Empty;

    [Required, MaxLength(255)]
    public string Email { get; set; } = string.Empty;

    [Required]
    public string PasswordHash { get; set; } = string.Empty;

    /// <summary>Stored as enum value string (Admin / Provider / Customer).</summary>
    public UserRole Role { get; set; } = UserRole.Customer;

    [MaxLength(500)]
    public string ProfileImageUrl { get; set; } = string.Empty;

    [MaxLength(20)]
    public string PhoneNumber { get; set; } = string.Empty;

    [MaxLength(500)]
    public string Bio { get; set; } = string.Empty;

    public bool IsVerified { get; set; } = false;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // ── Navigation properties ────────────────────────────────────────────────

    /// <summary>The provider profile linked to this user (if Role == Provider).</summary>
    public virtual ServiceProvider? ProviderProfile { get; set; }

    public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();
    public virtual ICollection<Review> ReviewsWritten { get; set; } = new List<Review>();
    public virtual ICollection<ChatMessage> SentMessages { get; set; } = new List<ChatMessage>();
    public virtual ICollection<ChatMessage> ReceivedMessages { get; set; } = new List<ChatMessage>();
    public virtual ICollection<ChatPreview> ChatPreviews { get; set; } = new List<ChatPreview>();

    // ── Computed helpers (not mapped) ────────────────────────────────────────
    [NotMapped]
    public string FullName => $"{FirstName} {LastName}".Trim();
}
