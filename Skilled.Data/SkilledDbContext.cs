using Microsoft.EntityFrameworkCore;
using Skilled.Data.Models;

namespace Skilled.Data;

public class SkilledDbContext : DbContext
{
    public SkilledDbContext(DbContextOptions<SkilledDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users { get; set; }
    public DbSet<ServiceProvider> ServiceProviders { get; set; }
    public DbSet<TradeService> TradeServices { get; set; }
    public DbSet<TradeCategory> TradeCategories { get; set; }
    public DbSet<Booking> Bookings { get; set; }
    public DbSet<Payment> Payments { get; set; }
    public DbSet<Review> Reviews { get; set; }
    public DbSet<ChatMessage> ChatMessages { get; set; }
    public DbSet<ChatPreview> ChatPreviews { get; set; }
    public DbSet<Location> Locations { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Set the default schema for all entities
        modelBuilder.HasDefaultSchema("skilled_db");

        // Configure User entity
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).ValueGeneratedOnAdd();
            entity.Property(e => e.Email).IsRequired().HasMaxLength(255);
            entity.Property(e => e.FirstName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.LastName).IsRequired().HasMaxLength(100);
            entity.HasIndex(e => e.Email).IsUnique();
        });

        // Configure ServiceProvider entity
        modelBuilder.Entity<ServiceProvider>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).ValueGeneratedOnAdd();
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Email).IsRequired().HasMaxLength(255);
            entity.Property(e => e.Phone).HasMaxLength(20);
            entity.HasIndex(e => e.Email).IsUnique();
        });

        // Configure TradeService entity
        modelBuilder.Entity<TradeService>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).ValueGeneratedOnAdd();
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Description).HasMaxLength(1000);
            entity.Property(e => e.Category).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Pricing).HasMaxLength(100);
            
            // Foreign key relationship
            entity.HasOne<ServiceProvider>()
                .WithMany()
                .HasForeignKey(e => e.ProviderId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure TradeCategory entity
        modelBuilder.Entity<TradeCategory>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).ValueGeneratedOnAdd();
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.Icon).HasMaxLength(100);
        });

        // Configure Booking entity
        modelBuilder.Entity<Booking>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).ValueGeneratedOnAdd();
            entity.Property(e => e.TotalAmount).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Status).HasConversion<string>();
            
            // Foreign key relationships
            entity.HasOne<User>()
                .WithMany()
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
                
            entity.HasOne<ServiceProvider>()
                .WithMany()
                .HasForeignKey(e => e.ProviderId)
                .OnDelete(DeleteBehavior.Cascade);
                
            entity.HasOne<TradeService>()
                .WithMany()
                .HasForeignKey(e => e.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure Payment entity
        modelBuilder.Entity<Payment>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).ValueGeneratedOnAdd();
            entity.Property(e => e.Amount).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Status).IsRequired().HasMaxLength(50);
            
            // Foreign key relationships
            entity.HasOne<User>()
                .WithMany()
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
                
            entity.HasOne<ServiceProvider>()
                .WithMany()
                .HasForeignKey(e => e.ProviderId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure Review entity
        modelBuilder.Entity<Review>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).ValueGeneratedOnAdd();
            entity.Property(e => e.Rating).IsRequired();
            entity.Property(e => e.Comment).HasMaxLength(1000);
            
            // Foreign key relationships
            entity.HasOne<User>()
                .WithMany()
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
                
            entity.HasOne<User>()
                .WithMany()
                .HasForeignKey(e => e.ProviderUserId)
                .OnDelete(DeleteBehavior.Cascade);
                
            entity.HasOne<TradeService>()
                .WithMany()
                .HasForeignKey(e => e.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure ChatMessage entity
        modelBuilder.Entity<ChatMessage>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).ValueGeneratedOnAdd();
            entity.Property(e => e.Message).IsRequired().HasMaxLength(1000);
            entity.Property(e => e.SentAt).IsRequired();
            entity.Property(e => e.IsRead).IsRequired();
            
            // Foreign key relationships
            entity.HasOne<User>()
                .WithMany()
                .HasForeignKey(e => e.SenderId)
                .OnDelete(DeleteBehavior.Cascade);
                
            entity.HasOne<User>()
                .WithMany()
                .HasForeignKey(e => e.ReceiverId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure ChatPreview entity
        modelBuilder.Entity<ChatPreview>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).ValueGeneratedOnAdd();
            entity.Property(e => e.LastMessage).HasMaxLength(500);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
            entity.Property(e => e.ProfileImage).HasMaxLength(255);
            
            // Foreign key relationship
            entity.HasOne<User>()
                .WithMany()
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure Location entity
        modelBuilder.Entity<Location>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).ValueGeneratedOnAdd();
            entity.Property(e => e.Address).IsRequired().HasMaxLength(255);
            entity.Property(e => e.City).IsRequired().HasMaxLength(100);
            entity.Property(e => e.State).IsRequired().HasMaxLength(100);
            entity.Property(e => e.ZipCode).HasMaxLength(20);
            entity.Property(e => e.Country).IsRequired().HasMaxLength(100);
        });
    }
}