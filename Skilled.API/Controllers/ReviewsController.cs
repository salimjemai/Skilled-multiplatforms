using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Skilled.API.DTOs;
using Skilled.Data;
using Skilled.Data.Models;
using System.Security.Claims;

namespace Skilled.API.Controllers;

[ApiController]
[Route("api/reviews")]
public class ReviewsController : ControllerBase
{
    private readonly SkilledDbContext _db;

    public ReviewsController(SkilledDbContext db) => _db = db;

    private Guid CurrentUserId =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    // GET api/reviews/provider/{providerId}
    [HttpGet("provider/{providerId:guid}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetForProvider(Guid providerId)
    {
        var reviews = await _db.Reviews
            .Include(r => r.User)
            .Where(r => r.ProviderId == providerId)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

        return Ok(reviews.Select(ReviewDto.FromReview));
    }

    // POST api/reviews
    [HttpPost]
    [Authorize]
    public async Task<IActionResult> Create([FromBody] CreateReviewRequest req)
    {
        if (req.Rating < 1 || req.Rating > 5)
            return BadRequest(new { message = "Rating must be between 1 and 5." });

        var provider = await _db.ServiceProviders.FindAsync(req.ProviderId);
        if (provider == null) return BadRequest(new { message = "Provider not found." });

        var review = new Review
        {
            Id = Guid.NewGuid(),
            UserId = CurrentUserId,
            ProviderId = req.ProviderId,
            ServiceId = req.ServiceId,
            BookingId = req.BookingId,
            Rating = req.Rating,
            Comment = req.Comment,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _db.Reviews.Add(review);

        // Recalculate provider average rating
        var allRatings = await _db.Reviews
            .Where(r => r.ProviderId == req.ProviderId)
            .Select(r => r.Rating)
            .ToListAsync();
        allRatings.Add(req.Rating);
        provider.AverageRating = (decimal)allRatings.Average();
        provider.TotalReviews = allRatings.Count;

        await _db.SaveChangesAsync();
        return CreatedAtAction(null, new { id = review.Id }, ReviewDto.FromReview(review));
    }
}
