using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Skilled.Data;

namespace Skilled;

public static class DatabaseInitializer
{
    public static async Task InitializeAsync(SkilledDbContext context, ILogger? logger = null)
    {
        try
        {
            // Ensure the database exists
            await context.Database.EnsureCreatedAsync();
            
            // Create schema if it doesn't exist
            await context.Database.ExecuteSqlRawAsync("CREATE SCHEMA IF NOT EXISTS skilled_db");
            
            logger?.LogInformation("Database and schema initialized successfully");
        }
        catch (Exception ex)
        {
            logger?.LogError(ex, "Error initializing database");
            throw;
        }
    }
} 