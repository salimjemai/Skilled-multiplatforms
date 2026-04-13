using Skilled.Data.Models;

namespace Skilled.API.DTOs;

public class BookingDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid ProviderId { get; set; }
    public string ProviderName { get; set; } = string.Empty;
    public Guid ServiceId { get; set; }
    public string ServiceName { get; set; } = string.Empty;
    public DateTime Date { get; set; }
    public string Notes { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }

    public static BookingDto FromBooking(Booking b) => new()
    {
        Id = b.Id,
        UserId = b.UserId,
        ProviderId = b.ProviderId,
        ProviderName = b.Provider?.BusinessName ?? string.Empty,
        ServiceId = b.ServiceId,
        ServiceName = b.Service?.Name ?? string.Empty,
        Date = b.Date,
        Notes = b.Notes,
        TotalAmount = b.TotalAmount,
        Status = b.Status.ToString(),
        CreatedAt = b.CreatedAt
    };
}

public class CreateBookingRequest
{
    public Guid ProviderId { get; set; }
    public Guid ServiceId { get; set; }
    public DateTime Date { get; set; }
    public string Notes { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
}

public class UpdateBookingStatusRequest
{
    public string Status { get; set; } = string.Empty;
}

public class ReviewDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public Guid ProviderId { get; set; }
    public Guid ServiceId { get; set; }
    public int Rating { get; set; }
    public string Comment { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }

    public static ReviewDto FromReview(Review r) => new()
    {
        Id = r.Id,
        UserId = r.UserId,
        UserName = r.User?.FullName ?? string.Empty,
        ProviderId = r.ProviderId,
        ServiceId = r.ServiceId,
        Rating = r.Rating,
        Comment = r.Comment,
        CreatedAt = r.CreatedAt
    };
}

public class CreateReviewRequest
{
    public Guid ProviderId { get; set; }
    public Guid ServiceId { get; set; }
    public Guid? BookingId { get; set; }
    public int Rating { get; set; }
    public string Comment { get; set; } = string.Empty;
}

public class PaymentDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid ProviderId { get; set; }
    public Guid? BookingId { get; set; }
    public decimal Amount { get; set; }
    public string Status { get; set; } = string.Empty;
    public string Method { get; set; } = string.Empty;
    public string? TransactionId { get; set; }
    public DateTime Date { get; set; }
    public DateTime? CompletedAt { get; set; }

    public static PaymentDto FromPayment(Payment p) => new()
    {
        Id = p.Id,
        UserId = p.UserId,
        ProviderId = p.ProviderId,
        BookingId = p.BookingId,
        Amount = p.Amount,
        Status = p.Status.ToString(),
        Method = p.Method.ToString(),
        TransactionId = p.TransactionId,
        Date = p.Date,
        CompletedAt = p.CompletedAt
    };
}

public class CreatePaymentRequest
{
    public Guid ProviderId { get; set; }
    public Guid? BookingId { get; set; }
    public decimal Amount { get; set; }
    public string Method { get; set; } = string.Empty;
}

public class MessageDto
{
    public Guid Id { get; set; }
    public Guid SenderId { get; set; }
    public string SenderName { get; set; } = string.Empty;
    public Guid ReceiverId { get; set; }
    public string Message { get; set; } = string.Empty;
    public string MessageType { get; set; } = string.Empty;
    public DateTime SentAt { get; set; }
    public bool IsRead { get; set; }

    public static MessageDto FromMessage(ChatMessage m) => new()
    {
        Id = m.Id,
        SenderId = m.SenderId,
        SenderName = m.Sender?.FullName ?? string.Empty,
        ReceiverId = m.ReceiverId,
        Message = m.Message,
        MessageType = m.MessageType.ToString(),
        SentAt = m.SentAt,
        IsRead = m.IsRead
    };
}

public class SendMessageRequest
{
    public Guid ReceiverId { get; set; }
    public string Message { get; set; } = string.Empty;
}

public class ChatPreviewDto
{
    public Guid Id { get; set; }
    public Guid OtherUserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string ProfileImage { get; set; } = string.Empty;
    public string LastMessage { get; set; } = string.Empty;
    public DateTime LastMessageTime { get; set; }
    public int UnreadCount { get; set; }
    public bool HasUnreadMessages => UnreadCount > 0;
}
