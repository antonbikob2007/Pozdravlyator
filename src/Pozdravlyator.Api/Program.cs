using Microsoft.EntityFrameworkCore;
using Pozdravlyator.Infrastructure.Data;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowAll");
app.UseDefaultFiles();
app.UseStaticFiles();
app.UseAuthorization();
app.MapControllers();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    await db.Database.EnsureCreatedAsync();

    if (!db.Birthdays.Any())
    {
        db.Birthdays.AddRange(
            new Pozdravlyator.Core.Entities.Birthday("Иван", "Петров", new DateTime(1990, 5, 15)),
            new Pozdravlyator.Core.Entities.Birthday("Мария", "Сидорова", new DateTime(1988, 3, 10)),
            new Pozdravlyator.Core.Entities.Birthday("Алексей", "Иванов", new DateTime(1995, 12, 1))
        );
        await db.SaveChangesAsync();
    }
}

app.Run();