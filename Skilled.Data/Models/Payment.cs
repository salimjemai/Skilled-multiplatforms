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
    public decimal Amount { get; set; }
    public DateTime Date { get; set; }
    public string Status { get; set; } = string.Empty;
    
    [Required]
    public PaymentMethod Method { get; set; }
    
    public string? TransactionId { get; set; }
    
    [MaxLength(500)]
    public string? Notes { get; set; }
    
    public DateTime? CompletedAt { get; set; }
    
    // Navigation properties
    [ForeignKey("UserId")]
    public virtual User? User { get; set; }
    
    [ForeignKey("ProviderId")]
    public virtual User? Provider { get; set; }
    
    public Payment()
    {
        Id = Guid.NewGuid();
        Status = PaymentStatus.Pending.ToString();
        Date = DateTime.UtcNow;
    }
}