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
    public decimal TotalAmount { get; set; }
    public DateTime CreatedAt { get; set; }
    public BookingStatus Status { get; set; }
}