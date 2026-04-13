using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Skilled.API.DTOs;
using Skilled.Data;
using Skilled.Data.Models;
using System.Security.Claims;

namespace Skilled.API.Controllers;

[ApiController]
[Route("api/payments")]
[Authorize]
public class PaymentsController : ControllerBase
{
    private readonly SkilledDbContext _db;

    public PaymentsController(SkilledDbContext db) => _db = db;

    private Guid CurrentUserId =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    // GET api/payments
    [HttpGet]
    public async Task<IActionResult> GetMyPayments()
    {
        var payments = await _db.Payments
            .Where(p => p.UserId == CurrentUserId)
            .OrderByDescending(p => p.Date)
            .ToListAsync();

        return Ok(payments.Select(PaymentDto.FromPayment));
    }

    // GET api/payments/{id}
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var payment = await _db.Payments.FindAsync(id);
        if (payment == null) return NotFound();
        if (payment.UserId != CurrentUserId) return Forbid();

        return Ok(PaymentDto.FromPayment(payment));
    }

    // POST api/payments
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreatePaymentRequest req)
    {
        if (!Enum.TryParse<PaymentMethod>(req.Method, true, out var method))
            return BadRequest(new { message = "Invalid payment method." });

        var provider = await _db.ServiceProviders.FindAsync(req.ProviderId);
        if (provider == null) return BadRequest(new { message = "Provider not found." });

        var payment = new Payment
        {
            Id = Guid.NewGuid(),
            UserId = CurrentUserId,
            ProviderId = req.ProviderId,
            BookingId = req.BookingId,
            Amount = req.Amount,
            Method = method,
            Status = PaymentStatus.Pending,
            Date = DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow
        };

        _db.Payments.Add(payment);

        // Mark linked booking as confirmed
        if (req.BookingId.HasValue)
        {
            var booking = await _db.Bookings.FindAsync(req.BookingId.Value);
            if (booking != null)
            {
                booking.Status = BookingStatus.Confirmed;
                booking.UpdatedAt = DateTime.UtcNow;
            }
        }

        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = payment.Id }, PaymentDto.FromPayment(payment));
    }
}
