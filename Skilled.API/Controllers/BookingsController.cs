using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Skilled.API.DTOs;
using Skilled.Data;
using Skilled.Data.Models;
using System.Security.Claims;

namespace Skilled.API.Controllers;

[ApiController]
[Route("api/bookings")]
[Authorize]
public class BookingsController : ControllerBase
{
    private readonly SkilledDbContext _db;

    public BookingsController(SkilledDbContext db) => _db = db;

    private Guid CurrentUserId =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    // GET api/bookings  — returns bookings for the current user
    [HttpGet]
    public async Task<IActionResult> GetMyBookings([FromQuery] string? status)
    {
        var query = _db.Bookings
            .Include(b => b.Provider)
            .Include(b => b.Service)
            .Where(b => b.UserId == CurrentUserId)
            .AsQueryable();

        if (!string.IsNullOrEmpty(status) && Enum.TryParse<BookingStatus>(status, true, out var parsed))
            query = query.Where(b => b.Status == parsed);

        var bookings = await query.OrderByDescending(b => b.Date).ToListAsync();
        return Ok(bookings.Select(BookingDto.FromBooking));
    }

    // GET api/bookings/{id}
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var booking = await _db.Bookings
            .Include(b => b.Provider)
            .Include(b => b.Service)
            .FirstOrDefaultAsync(b => b.Id == id);

        if (booking == null) return NotFound();
        if (booking.UserId != CurrentUserId && !IsProvider(booking.ProviderId))
            return Forbid();

        return Ok(BookingDto.FromBooking(booking));
    }

    // POST api/bookings
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateBookingRequest req)
    {
        var provider = await _db.ServiceProviders.FindAsync(req.ProviderId);
        if (provider == null) return BadRequest(new { message = "Provider not found." });

        var service = await _db.TradeServices.FindAsync(req.ServiceId);
        if (service == null) return BadRequest(new { message = "Service not found." });

        var booking = new Booking
        {
            Id = Guid.NewGuid(),
            UserId = CurrentUserId,
            ProviderId = req.ProviderId,
            ServiceId = req.ServiceId,
            Date = req.Date,
            Notes = req.Notes,
            TotalAmount = req.TotalAmount,
            Status = BookingStatus.Pending,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _db.Bookings.Add(booking);
        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = booking.Id }, BookingDto.FromBooking(booking));
    }

    // PATCH api/bookings/{id}/status
    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> UpdateStatus(Guid id, [FromBody] UpdateBookingStatusRequest req)
    {
        var booking = await _db.Bookings.FindAsync(id);
        if (booking == null) return NotFound();

        if (!Enum.TryParse<BookingStatus>(req.Status, true, out var newStatus))
            return BadRequest(new { message = "Invalid status value." });

        // Only the provider or the booking user can update status
        if (booking.UserId != CurrentUserId && !IsProvider(booking.ProviderId))
            return Forbid();

        booking.Status = newStatus;
        booking.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(BookingDto.FromBooking(booking));
    }

    private bool IsProvider(Guid providerId)
    {
        return _db.ServiceProviders.Any(p => p.Id == providerId && p.UserId == CurrentUserId);
    }
}
