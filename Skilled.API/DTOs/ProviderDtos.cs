using Skilled.Data.Models;

namespace Skilled.API.DTOs;

public class ProviderDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string BusinessName { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string ProfileImageUrl { get; set; } = string.Empty;
    public decimal AverageRating { get; set; }
    public int TotalReviews { get; set; }
    public int YearsOfExperience { get; set; }
    public bool InsuranceVerified { get; set; }
    public bool IsVerified { get; set; }
    public DateTime CreatedAt { get; set; }
    public LocationDto? Location { get; set; }

    public static ProviderDto FromProvider(Skilled.Data.Models.ServiceProvider p) => new()
    {
        Id = p.Id,
        UserId = p.UserId,
        BusinessName = p.BusinessName,
        Name = p.Name,
        Email = p.Email,
        Phone = p.Phone,
        Description = p.Description,
        ProfileImageUrl = p.ProfileImageUrl,
        AverageRating = p.AverageRating,
        TotalReviews = p.TotalReviews,
        YearsOfExperience = p.YearsOfExperience,
        InsuranceVerified = p.InsuranceVerified,
        IsVerified = p.IsVerified,
        CreatedAt = p.CreatedAt,
        Location = p.Location != null ? LocationDto.FromLocation(p.Location) : null
    };
}

public class CreateProviderRequest
{
    public string BusinessName { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int YearsOfExperience { get; set; }
}

public class LocationDto
{
    public Guid Id { get; set; }
    public string Address { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string State { get; set; } = string.Empty;
    public string ZipCode { get; set; } = string.Empty;
    public string Country { get; set; } = string.Empty;
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }

    public static LocationDto FromLocation(Location l) => new()
    {
        Id = l.Id,
        Address = l.Address,
        City = l.City,
        State = l.State,
        ZipCode = l.ZipCode,
        Country = l.Country,
        Latitude = l.Latitude,
        Longitude = l.Longitude
    };
}
