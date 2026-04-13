using Skilled.Data.Models;

namespace Skilled.API.DTOs;

public class ServiceDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public Guid ProviderId { get; set; }
    public string ProviderName { get; set; } = string.Empty;
    public Guid CategoryId { get; set; }
    public string Category { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }

    public static ServiceDto FromService(TradeService s) => new()
    {
        Id = s.Id,
        Name = s.Name,
        Description = s.Description,
        ProviderId = s.ProviderId,
        ProviderName = s.Provider?.BusinessName ?? string.Empty,
        CategoryId = s.CategoryId,
        Category = s.TradeCategory?.Name ?? s.Category,
        IsActive = s.IsActive,
        CreatedAt = s.CreatedAt
    };
}

public class CreateServiceRequest
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public Guid CategoryId { get; set; }
}

public class CategoryDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;

    public static CategoryDto FromCategory(TradeCategory c) => new()
    {
        Id = c.Id,
        Name = c.Name,
        Icon = c.Icon,
        Description = c.Description
    };
}
