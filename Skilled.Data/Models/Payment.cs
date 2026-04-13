using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Skilled.Data.Models;

public enum PaymentStatus
{
    Pending,
    Processing,
    Completed,
    Failed,
    Refunded,
    Disputed
}

public enum PaymentMethod
{
    CreditCard,
    DebitCard,
    BankTransfer,
    PayPal,
    ApplePay,
    GooglePay,
    Cash,
    Other
}

public class Payment
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }
    public Guid ProviderId { get; set; }

    /// <summary>Link to the booking this payment covers.</summary>
    public Guid? BookingId { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal Amount { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal RefundAmount { get; set; } = 0;

    public DateTime Date { get; set; } = DateTime.UtcNow;

    public PaymentStatus Status { get; set; } = PaymentStatus.Pending;

    [Required]
    public PaymentMethod Method { get; set; }

    [MaxLength(100)]
    public string? TransactionId { get; set; }

    [MaxLength(500)]
    public string? Notes { get; set; }

    public DateTime? CompletedAt { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // ── Navigation properties ────────────────────────────────────────────────
    public virtual User? User { get; set; }
    public virtual ServiceProvider? Provider { get; set; }
    public virtual Booking? Booking { get; set; }
}
