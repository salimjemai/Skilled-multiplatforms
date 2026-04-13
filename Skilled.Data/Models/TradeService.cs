using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Skilled.Data.Models;

public class TradeService
{
    public Guid Id { get; set; }

    [Required, MaxLength(200)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string Description { get; set; } = string.Empty;

    /// <summary>FK to the ServiceProvider who offers this service.</summary>
    public Guid ProviderId { get; set; }

    /// <summary>FK to the TradeCategory this service belongs to.</summary>
    public Guid CategoryId { get; set; }

    /// <summary>Legacy string category field — kept for backward compat.</summary>
    [MaxLength(100)]
    public string Category { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // ── Navigation properties ────────────────────────────────────────────────
    public virtual ServiceProvider? Provider { get; set; }
    public virtual TradeCategory? TradeCategory { get; set; }
    public virtual ServicePricing? Pricing { get; set; }
    public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();
    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
}

public class ServicePricing
{
    [Key]
    public int Id { get; set; }

    [Required]
    public PricingType PricingType { get; set; }

    [Required, Column(TypeName = "decimal(18,2)")]
    public decimal BasePrice { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? HourlyRate { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? MinimumFee { get; set; }

    public virtual CostRange? EstimatedCostRange { get; set; }

    /// <summary>FK to the TradeService — fixed from string to Guid.</summary>
    public Guid? TradeServiceId { get; set; }
    public virtual TradeService? TradeService { get; set; }
}

public class CostRange
{
    [Key]
    public int Id { get; set; }

    [Required, Column(TypeName = "decimal(18,2)")]
    public decimal Minimum { get; set; }

    [Required, Column(TypeName = "decimal(18,2)")]
    public decimal Maximum { get; set; }

    public int? ServicePricingId { get; set; }
    public virtual ServicePricing? ServicePricing { get; set; }
}

public enum PricingType
{
    Flat,
    Hourly,
    Estimate
}
