using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Skilled.Data.Models;

public class TradeService
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public Guid ProviderId { get; set; }
    public string Category { get; set; } = string.Empty;
    public string Pricing { get; set; } = string.Empty;
}

public class ServicePricing
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    public PricingType PricingType { get; set; }
    
    [Required]
    [Column(TypeName = "decimal(18,2)")]
    public decimal BasePrice { get; set; }
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal? HourlyRate { get; set; }
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal? MinimumFee { get; set; }
    
    public CostRange? EstimatedCostRange { get; set; }
    
    // Foreign key to TradeService
    public string? TradeServiceId { get; set; }
}

public class CostRange
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    [Column(TypeName = "decimal(18,2)")]
    public decimal Minimum { get; set; }
    
    [Required]
    [Column(TypeName = "decimal(18,2)")]
    public decimal Maximum { get; set; }
    
    // Foreign key to ServicePricing
    public int? ServicePricingId { get; set; }
}

public enum PricingType
{
    Flat,
    Hourly,
    Estimate
}