using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Skilled.Data.Models;

public class Review
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid ProviderUserId { get; set; }
    public Guid ServiceId { get; set; }
    public int Rating { get; set; }
    public string Comment { get; set; } = string.Empty;
}