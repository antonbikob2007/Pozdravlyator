using Microsoft.EntityFrameworkCore;
using Pozdravlyator.Core.Entities;

namespace Pozdravlyator.Infrastructure.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options) { }

    public DbSet<Birthday> Birthdays { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Birthday>(entity =>
        {
            entity.ToTable("Birthdays");

            entity.HasKey(b => b.Id);

            entity.Property(b => b.FirstName)
                .IsRequired()
                .HasMaxLength(50);

            entity.Property(b => b.LastName)
                .IsRequired()
                .HasMaxLength(50);

            entity.Property(b => b.BirthDate)
                .IsRequired()
                .HasColumnType("DATE");

            entity.Property(b => b.Phone)
                .HasMaxLength(20);

            entity.Property(b => b.Email)
                .HasMaxLength(100);

            entity.Property(b => b.PhotoPath)
                .HasMaxLength(200);

            entity.HasIndex(b => b.BirthDate);
        });
    }
}