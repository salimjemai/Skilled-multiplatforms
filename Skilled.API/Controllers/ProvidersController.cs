using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Skilled.API.DTOs;
using Skilled.Data;
using Skilled.Data.Models;
using System.Security.Claims;

namespace Skilled.API.Controllers;

[ApiController]
[Route("api/providers")]
public class ProvidersController : ControllerBase
{
    private readonly SkilledDbContext _db;

    public ProvidersController(SkilledDbContext db) => _db = db;

    private Guid? CurrentUserId =>
        Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var id) ? id : null;

    // GET api/providers
    [HttpGet]
    [AllowAnonymous]
    public async Task<IActionResult> GetAll([FromQuery] string? search, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var query = _db.ServiceProviders
            .Include(p => p.Location)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(search))
            query = query.Where(p =>
                p.BusinessName.Contains(search) ||
                p.Description.Contains(search));

        var total = await query.CountAsync();
        var items = await query
            .OrderByDescending(p => p.AverageRating)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return Ok(new { total, page, pageSize, items = items.Select(ProviderDto.FromProvider) });
    }

    // GET api/providers/{id}
    [HttpGet("{id:guid}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetById(Guid id)
    {
        var provider = await _db.ServiceProviders
            .Include(p => p.Location)
            .Include(p => p.Services.Where(s => s.IsActive))
                .ThenInclude(s => s.TradeCategory)
            .FirstOrDefaultAsync(p => p.Id == id);

        if (provider == null) return NotFound();
        return Ok(ProviderDto.FromProvider(provider));
    }

    // GET api/providers/{id}/services
    [HttpGet("{id:guid}/services")]
    [AllowAnonymous]
    public async Task<IActionResult> GetServices(Guid id)
    {
        var services = await _db.TradeServices
            .Include(s => s.TradeCategory)
            .Where(s => s.ProviderId == id && s.IsActive)
            .ToListAsync();

        return Ok(services.Select(ServiceDto.FromService));
    }

    // GET api/providers/{id}/reviews
    [HttpGet("{id:guid}/reviews")]
    [AllowAnonymous]
    public async Task<IActionResult> GetReviews(Guid id)
    {
        var reviews = await _db.Reviews
            .Include(r => r.User)
            .Where(r => r.ProviderId == id)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

        return Ok(reviews.Select(ReviewDto.FromReview));
    }

    // POST api/providers  (create own provider profile)
    [HttpPost]
    [Authorize]
    public async Task<IActionResult> CreateProfile([FromBody] CreateProviderRequest req)
    {
        var userId = CurrentUserId;
        if (userId == null) return Unauthorized();

        if (await _db.ServiceProviders.AnyAsync(p => p.UserId == userId.Value))
            return Conflict(new { message = "Provider profile already exists for this user." });

        var user = await _db.Users.FindAsync(userId.Value);
        if (user == null) return Unauthorized();

        var provider = new Skilled.Data.Models.ServiceProvider
        {
            Id = Guid.NewGuid(),
            UserId = userId.Value,
            BusinessName = req.BusinessName,
            Name = req.Name,
            Email = user.Email,
            Phone = req.Phone,
            Description = req.Description,
            YearsOfExperience = req.YearsOfExperience,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        user.Role = UserRole.Provider;
        _db.ServiceProviders.Add(provider);
        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = provider.Id }, ProviderDto.FromProvider(provider));
    }
}
