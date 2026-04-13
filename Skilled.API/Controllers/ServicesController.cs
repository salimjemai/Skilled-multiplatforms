using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Skilled.API.DTOs;
using Skilled.Data;
using Skilled.Data.Models;
using System.Security.Claims;

namespace Skilled.API.Controllers;

[ApiController]
[Route("api/services")]
public class ServicesController : ControllerBase
{
    private readonly SkilledDbContext _db;

    public ServicesController(SkilledDbContext db) => _db = db;

    private Guid? CurrentUserId =>
        Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var id) ? id : null;

    // GET api/services
    [HttpGet]
    [AllowAnonymous]
    public async Task<IActionResult> GetAll([FromQuery] string? search)
    {
        var query = _db.TradeServices
            .Include(s => s.Provider)
            .Include(s => s.TradeCategory)
            .Where(s => s.IsActive)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(search))
            query = query.Where(s => s.Name.Contains(search) || s.Description.Contains(search));

        var items = await query.OrderBy(s => s.Name).ToListAsync();
        return Ok(items.Select(ServiceDto.FromService));
    }

    // GET api/services/{id}
    [HttpGet("{id:guid}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetById(Guid id)
    {
        var service = await _db.TradeServices
            .Include(s => s.Provider)
            .Include(s => s.TradeCategory)
            .FirstOrDefaultAsync(s => s.Id == id);

        if (service == null) return NotFound();
        return Ok(ServiceDto.FromService(service));
    }

    // GET api/services/category/{categoryId}
    [HttpGet("category/{categoryId:guid}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetByCategory(Guid categoryId)
    {
        var services = await _db.TradeServices
            .Include(s => s.Provider)
            .Include(s => s.TradeCategory)
            .Where(s => s.CategoryId == categoryId && s.IsActive)
            .OrderBy(s => s.Name)
            .ToListAsync();

        return Ok(services.Select(ServiceDto.FromService));
    }

    // GET api/services/provider/{providerId}
    [HttpGet("provider/{providerId:guid}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetByProvider(Guid providerId)
    {
        var services = await _db.TradeServices
            .Include(s => s.TradeCategory)
            .Where(s => s.ProviderId == providerId && s.IsActive)
            .ToListAsync();

        return Ok(services.Select(ServiceDto.FromService));
    }

    // GET api/services/categories
    [HttpGet("categories")]
    [AllowAnonymous]
    public async Task<IActionResult> GetCategories()
    {
        var categories = await _db.TradeCategories
            .Where(c => c.IsActive)
            .OrderBy(c => c.Name)
            .ToListAsync();

        return Ok(categories.Select(CategoryDto.FromCategory));
    }

    // POST api/services
    [HttpPost]
    [Authorize]
    public async Task<IActionResult> Create([FromBody] CreateServiceRequest req)
    {
        var userId = CurrentUserId;
        if (userId == null) return Unauthorized();

        var provider = await _db.ServiceProviders.FirstOrDefaultAsync(p => p.UserId == userId.Value);
        if (provider == null) return Forbid();

        var category = await _db.TradeCategories.FindAsync(req.CategoryId);
        if (category == null) return BadRequest(new { message = "Category not found." });

        var service = new TradeService
        {
            Id = Guid.NewGuid(),
            Name = req.Name,
            Description = req.Description,
            ProviderId = provider.Id,
            CategoryId = req.CategoryId,
            Category = category.Name,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        _db.TradeServices.Add(service);
        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = service.Id }, ServiceDto.FromService(service));
    }

    // PUT api/services/{id}
    [HttpPut("{id:guid}")]
    [Authorize]
    public async Task<IActionResult> Update(Guid id, [FromBody] CreateServiceRequest req)
    {
        var userId = CurrentUserId;
        if (userId == null) return Unauthorized();

        var service = await _db.TradeServices.Include(s => s.Provider).FirstOrDefaultAsync(s => s.Id == id);
        if (service == null) return NotFound();
        if (service.Provider?.UserId != userId.Value) return Forbid();

        service.Name = req.Name;
        service.Description = req.Description;
        service.CategoryId = req.CategoryId;

        await _db.SaveChangesAsync();
        return Ok(ServiceDto.FromService(service));
    }

    // DELETE api/services/{id}
    [HttpDelete("{id:guid}")]
    [Authorize]
    public async Task<IActionResult> Delete(Guid id)
    {
        var userId = CurrentUserId;
        if (userId == null) return Unauthorized();

        var service = await _db.TradeServices.Include(s => s.Provider).FirstOrDefaultAsync(s => s.Id == id);
        if (service == null) return NotFound();
        if (service.Provider?.UserId != userId.Value) return Forbid();

        service.IsActive = false;  // soft delete
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
