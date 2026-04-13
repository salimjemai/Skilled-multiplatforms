using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Skilled.Data.Models;

public class ServiceProvider
{
    public Guid Id { get; set; }

    /// <summary>FK to the User account that owns this provider profile.</summary>
    public Guid UserId { get; set; }

    [Required, MaxLength(200)]
    public string BusinessName { get; set; } = string.Empty;

    /// <summary>Display / contact name (kept for backward compat).</summary>
    [MaxLength(200)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(255)]
    public string Email { get; set; } = string.Empty;

    [MaxLength(20)]
    public string Phone { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string Description { get; set; } = string.Empty;

    [MaxLength(500)]
    public string ProfileImageUrl { get; set; } = string.Empty;

    [Column(TypeName = "decimal(3,2)")]
    public decimal AverageRating { get; set; } = 0;

    public int TotalReviews { get; set; } = 0;

    public int YearsOfExperience { get; set; } = 0;

    /// <summary>Whether the provider's insurance documents have been verified.</summary>
    public bool InsuranceVerified { get; set; } = false;

    /// <summary>Whether the provider's identity / credentials have been verified.</summary>
    public bool IsVerified { get; set; } = false;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>Optional link to a Location (service area).</summary>
    public Guid? LocationId { get; set; }

    // ── Navigation properties ────────────────────────────────────────────────
    public virtual User? User { get; set; }
    public virtual Location? Location { get; set; }
    public virtual ICollection<TradeService> Services { get; set; } = new List<TradeService>();
    public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();
    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();
}
