using System.ComponentModel.DataAnnotations;

namespace Skilled.Data.Models;

public class TradeCategory
{
    public Guid Id { get; set; }

    [Required, MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(100)]
    public string Icon { get; set; } = string.Empty;

    [MaxLength(500)]
    public string Description { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    // ── Navigation properties ────────────────────────────────────────────────
    public virtual ICollection<TradeService> Services { get; set; } = new List<TradeService>();
}
