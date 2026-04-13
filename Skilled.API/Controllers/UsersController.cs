using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Skilled.API.DTOs;
using Skilled.Data;
using Skilled.Data.Models;
using System.Security.Claims;

namespace Skilled.API.Controllers;

[ApiController]
[Route("api/users")]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly SkilledDbContext _db;
    private readonly IPasswordHasher<User> _hasher;

    public UsersController(SkilledDbContext db, IPasswordHasher<User> hasher)
    {
        _db = db;
        _hasher = hasher;
    }

    private Guid CurrentUserId =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    // GET api/users/me
    [HttpGet("me")]
    public async Task<IActionResult> GetMe()
    {
        var user = await _db.Users.FindAsync(CurrentUserId);
        if (user == null) return NotFound();
        return Ok(UserDto.FromUser(user));
    }

    // GET api/users/{id}
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetUser(Guid id)
    {
        var user = await _db.Users.FindAsync(id);
        if (user == null) return NotFound();
        return Ok(UserDto.FromUser(user));
    }

    // PUT api/users/{id}
    [HttpPut("{id:guid}")]
    public async Task<IActionResult> UpdateUser(Guid id, [FromBody] UpdateProfileRequest req)
    {
        if (id != CurrentUserId)
            return Forbid();

        var user = await _db.Users.FindAsync(id);
        if (user == null) return NotFound();

        if (req.FirstName != null) user.FirstName = req.FirstName;
        if (req.LastName != null) user.LastName = req.LastName;
        if (req.PhoneNumber != null) user.PhoneNumber = req.PhoneNumber;
        if (req.Bio != null) user.Bio = req.Bio;
        if (req.ProfileImageUrl != null) user.ProfileImageUrl = req.ProfileImageUrl;

        user.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(UserDto.FromUser(user));
    }

    // GET api/users/providers
    [HttpGet("providers")]
    [AllowAnonymous]
    public async Task<IActionResult> GetProviders()
    {
        var providers = await _db.ServiceProviders
            .Include(p => p.Location)
            .OrderByDescending(p => p.AverageRating)
            .ToListAsync();

        return Ok(providers.Select(ProviderDto.FromProvider));
    }

    // GET api/users/providers/category/{categoryId}
    [HttpGet("providers/category/{categoryId:guid}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetProvidersByCategory(Guid categoryId)
    {
        var providers = await _db.ServiceProviders
            .Include(p => p.Location)
            .Include(p => p.Services)
            .Where(p => p.Services.Any(s => s.CategoryId == categoryId && s.IsActive))
            .OrderByDescending(p => p.AverageRating)
            .ToListAsync();

        return Ok(providers.Select(ProviderDto.FromProvider));
    }
}
