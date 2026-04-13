using Microsoft.EntityFrameworkCore;
using Skilled.Data.Models;

namespace Skilled.Data;

public class SkilledDbContext : DbContext
{
    public SkilledDbContext(DbContextOptions<SkilledDbContext> options) : base(options) { }

    // ── DbSets ───────────────────────────────────────────────────────────────
    public DbSet<User> Users { get; set; }
    public DbSet<ServiceProvider> ServiceProviders { get; set; }
    public DbSet<TradeService> TradeServices { get; set; }
    public DbSet<ServicePricing> ServicePricings { get; set; }
    public DbSet<CostRange> CostRanges { get; set; }
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
        modelBuilder.HasDefaultSchema("skilled_db");

        // ── User ─────────────────────────────────────────────────────────────
        modelBuilder.Entity<User>(e =>
        {
            e.HasKey(u => u.Id);
            e.Property(u => u.Id).ValueGeneratedOnAdd();
            e.Property(u => u.Email).IsRequired().HasMaxLength(255);
            e.Property(u => u.FirstName).IsRequired().HasMaxLength(100);
            e.Property(u => u.LastName).IsRequired().HasMaxLength(100);
            e.Property(u => u.Role).HasConversion<string>().HasMaxLength(20);
            e.Property(u => u.PhoneNumber).HasMaxLength(20);
            e.Property(u => u.ProfileImageUrl).HasMaxLength(500);
            e.Property(u => u.Bio).HasMaxLength(500);
            e.HasIndex(u => u.Email).IsUnique();
        });

        // ── Location ──────────────────────────────────────────────────────────
        modelBuilder.Entity<Location>(e =>
        {
            e.HasKey(l => l.Id);
            e.Property(l => l.Id).ValueGeneratedOnAdd();
            e.Property(l => l.Address).IsRequired().HasMaxLength(255);
            e.Property(l => l.City).IsRequired().HasMaxLength(100);
            e.Property(l => l.State).IsRequired().HasMaxLength(100);
            e.Property(l => l.ZipCode).HasMaxLength(20);
            e.Property(l => l.Country).IsRequired().HasMaxLength(100);
        });

        // ── ServiceProvider ───────────────────────────────────────────────────
        modelBuilder.Entity<ServiceProvider>(e =>
        {
            e.HasKey(p => p.Id);
            e.Property(p => p.Id).ValueGeneratedOnAdd();
            e.Property(p => p.BusinessName).IsRequired().HasMaxLength(200);
            e.Property(p => p.Name).HasMaxLength(200);
            e.Property(p => p.Email).HasMaxLength(255);
            e.Property(p => p.Phone).HasMaxLength(20);
            e.Property(p => p.Description).HasMaxLength(1000);
            e.Property(p => p.ProfileImageUrl).HasMaxLength(500);
            e.Property(p => p.AverageRating).HasColumnType("decimal(3,2)");

            // One-to-one: User → ServiceProvider
            e.HasOne(p => p.User)
             .WithOne(u => u.ProviderProfile)
             .HasForeignKey<ServiceProvider>(p => p.UserId)
             .OnDelete(DeleteBehavior.Cascade);

            // Many-to-one: ServiceProvider → Location
            e.HasOne(p => p.Location)
             .WithMany(l => l.ServiceProviders)
             .HasForeignKey(p => p.LocationId)
             .OnDelete(DeleteBehavior.SetNull)
             .IsRequired(false);
        });

        // ── TradeCategory ─────────────────────────────────────────────────────
        modelBuilder.Entity<TradeCategory>(e =>
        {
            e.HasKey(c => c.Id);
            e.Property(c => c.Id).ValueGeneratedOnAdd();
            e.Property(c => c.Name).IsRequired().HasMaxLength(100);
            e.Property(c => c.Description).HasMaxLength(500);
            e.Property(c => c.Icon).HasMaxLength(100);
        });

        // ── TradeService ──────────────────────────────────────────────────────
        modelBuilder.Entity<TradeService>(e =>
        {
            e.HasKey(s => s.Id);
            e.Property(s => s.Id).ValueGeneratedOnAdd();
            e.Property(s => s.Name).IsRequired().HasMaxLength(200);
            e.Property(s => s.Description).HasMaxLength(1000);
            e.Property(s => s.Category).HasMaxLength(100);

            // Many-to-one: TradeService → ServiceProvider
            e.HasOne(s => s.Provider)
             .WithMany(p => p.Services)
             .HasForeignKey(s => s.ProviderId)
             .OnDelete(DeleteBehavior.Cascade);

            // Many-to-one: TradeService → TradeCategory
            e.HasOne(s => s.TradeCategory)
             .WithMany(c => c.Services)
             .HasForeignKey(s => s.CategoryId)
             .OnDelete(DeleteBehavior.Restrict);
        });

        // ── ServicePricing ────────────────────────────────────────────────────
        modelBuilder.Entity<ServicePricing>(e =>
        {
            e.HasKey(p => p.Id);
            e.Property(p => p.BasePrice).HasColumnType("decimal(18,2)");
            e.Property(p => p.HourlyRate).HasColumnType("decimal(18,2)");
            e.Property(p => p.MinimumFee).HasColumnType("decimal(18,2)");
            e.Property(p => p.PricingType).HasConversion<string>();

            // One-to-one: TradeService → ServicePricing
            e.HasOne(p => p.TradeService)
             .WithOne(s => s.Pricing)
             .HasForeignKey<ServicePricing>(p => p.TradeServiceId)
             .OnDelete(DeleteBehavior.Cascade)
             .IsRequired(false);
        });

        // ── CostRange ─────────────────────────────────────────────────────────
        modelBuilder.Entity<CostRange>(e =>
        {
            e.HasKey(c => c.Id);
            e.Property(c => c.Minimum).HasColumnType("decimal(18,2)");
            e.Property(c => c.Maximum).HasColumnType("decimal(18,2)");

            // One-to-one: ServicePricing → CostRange
            e.HasOne(c => c.ServicePricing)
             .WithOne(p => p.EstimatedCostRange)
             .HasForeignKey<CostRange>(c => c.ServicePricingId)
             .OnDelete(DeleteBehavior.Cascade)
             .IsRequired(false);
        });

        // ── Booking ───────────────────────────────────────────────────────────
        modelBuilder.Entity<Booking>(e =>
        {
            e.HasKey(b => b.Id);
            e.Property(b => b.Id).ValueGeneratedOnAdd();
            e.Property(b => b.TotalAmount).HasColumnType("decimal(18,2)");
            e.Property(b => b.Status).HasConversion<string>().HasMaxLength(20);
            e.Property(b => b.Notes).HasMaxLength(1000);

            e.HasOne(b => b.User)
             .WithMany(u => u.Bookings)
             .HasForeignKey(b => b.UserId)
             .OnDelete(DeleteBehavior.Cascade);

            e.HasOne(b => b.Provider)
             .WithMany(p => p.Bookings)
             .HasForeignKey(b => b.ProviderId)
             .OnDelete(DeleteBehavior.Restrict);

            e.HasOne(b => b.Service)
             .WithMany(s => s.Bookings)
             .HasForeignKey(b => b.ServiceId)
             .OnDelete(DeleteBehavior.Restrict);
        });

        // ── Payment ───────────────────────────────────────────────────────────
        modelBuilder.Entity<Payment>(e =>
        {
            e.HasKey(p => p.Id);
            e.Property(p => p.Id).ValueGeneratedOnAdd();
            e.Property(p => p.Amount).HasColumnType("decimal(18,2)");
            e.Property(p => p.RefundAmount).HasColumnType("decimal(18,2)");
            e.Property(p => p.Status).HasConversion<string>().HasMaxLength(20);
            e.Property(p => p.TransactionId).HasMaxLength(100);
            e.Property(p => p.Notes).HasMaxLength(500);

            e.HasOne(p => p.User)
             .WithMany()
             .HasForeignKey(p => p.UserId)
             .OnDelete(DeleteBehavior.Restrict);

            e.HasOne(p => p.Provider)
             .WithMany(sp => sp.Payments)
             .HasForeignKey(p => p.ProviderId)
             .OnDelete(DeleteBehavior.Restrict);

            // One-to-one: Booking → Payment
            e.HasOne(p => p.Booking)
             .WithOne(b => b.Payment)
             .HasForeignKey<Payment>(p => p.BookingId)
             .OnDelete(DeleteBehavior.SetNull)
             .IsRequired(false);
        });

        // ── Review ────────────────────────────────────────────────────────────
        modelBuilder.Entity<Review>(e =>
        {
            e.HasKey(r => r.Id);
            e.Property(r => r.Id).ValueGeneratedOnAdd();
            e.Property(r => r.Comment).HasMaxLength(1000);

            e.HasOne(r => r.User)
             .WithMany(u => u.ReviewsWritten)
             .HasForeignKey(r => r.UserId)
             .OnDelete(DeleteBehavior.Cascade);

            e.HasOne(r => r.Provider)
             .WithMany(p => p.Reviews)
             .HasForeignKey(r => r.ProviderId)
             .OnDelete(DeleteBehavior.Restrict);

            e.HasOne(r => r.Service)
             .WithMany(s => s.Reviews)
             .HasForeignKey(r => r.ServiceId)
             .OnDelete(DeleteBehavior.Restrict);

            e.HasOne(r => r.Booking)
             .WithMany(b => b.Reviews)
             .HasForeignKey(r => r.BookingId)
             .OnDelete(DeleteBehavior.SetNull)
             .IsRequired(false);
        });

        // ── ChatMessage ───────────────────────────────────────────────────────
        modelBuilder.Entity<ChatMessage>(e =>
        {
            e.HasKey(m => m.Id);
            e.Property(m => m.Id).ValueGeneratedOnAdd();
            e.Property(m => m.Message).IsRequired().HasMaxLength(2000);
            e.Property(m => m.MessageType).HasConversion<string>();

            e.HasOne(m => m.Sender)
             .WithMany(u => u.SentMessages)
             .HasForeignKey(m => m.SenderId)
             .OnDelete(DeleteBehavior.Cascade);

            e.HasOne(m => m.Receiver)
             .WithMany(u => u.ReceivedMessages)
             .HasForeignKey(m => m.ReceiverId)
             .OnDelete(DeleteBehavior.Restrict);
        });

        // ── ChatPreview ───────────────────────────────────────────────────────
        modelBuilder.Entity<ChatPreview>(e =>
        {
            e.HasKey(c => c.Id);
            e.Property(c => c.Id).ValueGeneratedOnAdd();
            e.Property(c => c.LastMessage).HasMaxLength(500);
            e.Property(c => c.Name).IsRequired().HasMaxLength(200);
            e.Property(c => c.ProfileImage).HasMaxLength(500);

            e.HasOne(c => c.User)
             .WithMany(u => u.ChatPreviews)
             .HasForeignKey(c => c.UserId)
             .OnDelete(DeleteBehavior.Cascade);

            e.HasOne(c => c.OtherUser)
             .WithMany()
             .HasForeignKey(c => c.OtherUserId)
             .OnDelete(DeleteBehavior.Restrict);
        });
    }
}
