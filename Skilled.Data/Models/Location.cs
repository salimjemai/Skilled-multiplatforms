using System.ComponentModel.DataAnnotations;

namespace Skilled.Data.Models;

public class Location
{
    public Guid Id { get; set; }

    [Required, MaxLength(255)]
    public string Address { get; set; } = string.Empty;

    [Required, MaxLength(100)]
    public string City { get; set; } = string.Empty;

    [Required, MaxLength(100)]
    public string State { get; set; } = string.Empty;

    [MaxLength(20)]
    public string ZipCode { get; set; } = string.Empty;

    [Required, MaxLength(100)]
    public string Country { get; set; } = string.Empty;

    /// <summary>Latitude for map display.</summary>
    public double? Latitude { get; set; }

    /// <summary>Longitude for map display.</summary>
    public double? Longitude { get; set; }

    // ── Navigation properties ────────────────────────────────────────────────
    public virtual ICollection<ServiceProvider> ServiceProviders { get; set; } = new List<ServiceProvider>();
}
