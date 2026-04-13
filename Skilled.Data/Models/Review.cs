using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Skilled.Data.Models;

public class Review
{
    public Guid Id { get; set; }

    /// <summary>User who wrote the review.</summary>
    public Guid UserId { get; set; }

    /// <summary>ServiceProvider being reviewed.</summary>
    public Guid ProviderId { get; set; }

    public Guid ServiceId { get; set; }

    /// <summary>Optional link to the booking this review is for.</summary>
    public Guid? BookingId { get; set; }

    [Range(1, 5)]
    public int Rating { get; set; }

    [MaxLength(1000)]
    public string Comment { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // ── Navigation properties ────────────────────────────────────────────────
    public virtual User? User { get; set; }
    public virtual ServiceProvider? Provider { get; set; }
    public virtual TradeService? Service { get; set; }
    public virtual Booking? Booking { get; set; }
}
