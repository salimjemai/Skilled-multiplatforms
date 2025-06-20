using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration.UserSecrets;
using Skilled.Data;

namespace Skilled;

public class SkilledDbContextFactory : IDesignTimeDbContextFactory<SkilledDbContext>
{
    public SkilledDbContext CreateDbContext(string[] args)
    {
        var configuration = new ConfigurationBuilder()
            .AddUserSecrets<SkilledDbContextFactory>()
            .Build();

        var connectionString = configuration.GetConnectionString("DefaultConnection");
        
        var optionsBuilder = new DbContextOptionsBuilder<SkilledDbContext>();
        optionsBuilder.UseNpgsql(connectionString);

        return new SkilledDbContext(optionsBuilder.Options);
    }
} 