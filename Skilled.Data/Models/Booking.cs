using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Skilled.Data.Models;

public enum BookingStatus
{
    Pending,
    Confirmed,
    Cancelled,
    Completed
}

public class Booking
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }
    public Guid ProviderId { get; set; }
    public Guid ServiceId { get; set; }

    public DateTime Date { get; set; }

    [MaxLength(1000)]
    public string Notes { get; set; } = string.Empty;

    [Column(TypeName = "decimal(18,2)")]
    public decimal TotalAmount { get; set; }

    public BookingStatus Status { get; set; } = BookingStatus.Pending;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // ── Navigation properties ────────────────────────────────────────────────
    public virtual User? User { get; set; }
    public virtual ServiceProvider? Provider { get; set; }
    public virtual TradeService? Service { get; set; }
    public virtual Payment? Payment { get; set; }
    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
}
