using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Pozdravlyator.Core.DTOs;
using Pozdravlyator.Core.Entities;
using Pozdravlyator.Infrastructure.Data;

namespace Pozdravlyator.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BirthdaysController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IWebHostEnvironment _env;

    public BirthdaysController(ApplicationDbContext context, IWebHostEnvironment env)
    {
        _context = context;
        _env = env;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var today = DateTime.Today;

        var birthdays = await _context.Birthdays
            .Select(b => new BirthdayDto
            {
                Id = b.Id,
                FirstName = b.FirstName,
                LastName = b.LastName,
                BirthDate = b.BirthDate,
                YearOfBirth = b.YearOfBirth,
                Phone = b.Phone,
                Email = b.Email,
                PhotoPath = b.PhotoPath,
                Age = 0, // Временно, вычислим после загрузки
                DaysUntilBirthday = 0,
                IsToday = false
            })
            .ToListAsync();

        // Вычисляем возраст и дни до ДР в памяти (после загрузки из БД)
        var result = birthdays.Select(b =>
        {
            var birthday = new Birthday(b.FirstName, b.LastName, b.BirthDate);
            if (b.YearOfBirth.HasValue)
                birthday.SetYearOfBirth(b.YearOfBirth.Value);

            return new BirthdayDto
            {
                Id = b.Id,
                FirstName = b.FirstName,
                LastName = b.LastName,
                BirthDate = b.BirthDate,
                YearOfBirth = b.YearOfBirth,
                Phone = b.Phone,
                Email = b.Email,
                PhotoPath = b.PhotoPath,
                Age = birthday.GetAge(today),
                DaysUntilBirthday = birthday.GetDaysUntilNextBirthday(today),
                IsToday = birthday.IsBirthdayToday(today)
            };
        })
        .OrderBy(b => b.DaysUntilBirthday)
        .ToList();

        return Ok(result);
    }

    [HttpGet("upcoming")]
    public async Task<IActionResult> GetUpcoming([FromQuery] int days = 7)
    {
        var today = DateTime.Today;

        var birthdays = await _context.Birthdays
            .Select(b => new BirthdayDto
            {
                Id = b.Id,
                FirstName = b.FirstName,
                LastName = b.LastName,
                BirthDate = b.BirthDate,
                YearOfBirth = b.YearOfBirth,
                Phone = b.Phone,
                Email = b.Email,
                PhotoPath = b.PhotoPath,
                Age = 0,
                DaysUntilBirthday = 0,
                IsToday = false
            })
            .ToListAsync();

        // Вычисляем в памяти
        var result = birthdays
            .Select(b =>
            {
                var birthday = new Birthday(b.FirstName, b.LastName, b.BirthDate);
                if (b.YearOfBirth.HasValue)
                    birthday.SetYearOfBirth(b.YearOfBirth.Value);

                return new BirthdayDto
                {
                    Id = b.Id,
                    FirstName = b.FirstName,
                    LastName = b.LastName,
                    BirthDate = b.BirthDate,
                    YearOfBirth = b.YearOfBirth,
                    Phone = b.Phone,
                    Email = b.Email,
                    PhotoPath = b.PhotoPath,
                    Age = birthday.GetAge(today),
                    DaysUntilBirthday = birthday.GetDaysUntilNextBirthday(today),
                    IsToday = birthday.IsBirthdayToday(today)
                };
            })
            .Where(b => b.DaysUntilBirthday >= 0 && b.DaysUntilBirthday <= days)
            .OrderBy(b => b.DaysUntilBirthday)
            .ToList();

        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var birthday = await _context.Birthdays.FindAsync(id);
        if (birthday == null)
            return NotFound($"День рождения с ID {id} не найден");

        var today = DateTime.Today;
        var dto = new BirthdayDto
        {
            Id = birthday.Id,
            FirstName = birthday.FirstName,
            LastName = birthday.LastName,
            BirthDate = birthday.BirthDate,
            YearOfBirth = birthday.YearOfBirth,
            Phone = birthday.Phone,
            Email = birthday.Email,
            PhotoPath = birthday.PhotoPath,
            Age = birthday.GetAge(today),
            DaysUntilBirthday = birthday.GetDaysUntilNextBirthday(today),
            IsToday = birthday.IsBirthdayToday(today)
        };

        return Ok(dto);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateBirthdayDto dto)
    {
        try
        {
            var birthday = new Birthday(dto.FirstName, dto.LastName, dto.BirthDate);

            if (dto.YearOfBirth.HasValue)
                birthday.SetYearOfBirth(dto.YearOfBirth.Value);

            birthday.SetPhone(dto.Phone);
            birthday.SetEmail(dto.Email);

            await _context.Birthdays.AddAsync(birthday);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetById), new { id = birthday.Id }, birthday);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateBirthdayDto dto)
    {
        var birthday = await _context.Birthdays.FindAsync(id);
        if (birthday == null)
            return NotFound($"День рождения с ID {id} не найден");

        try
        {
            birthday.SetFirstName(dto.FirstName);
            birthday.SetLastName(dto.LastName);
            birthday.SetBirthDate(dto.BirthDate);

            if (dto.YearOfBirth.HasValue)
                birthday.SetYearOfBirth(dto.YearOfBirth.Value);

            birthday.SetPhone(dto.Phone);
            birthday.SetEmail(dto.Email);

            await _context.SaveChangesAsync();

            return Ok(new { message = "Успешно обновлено" });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var birthday = await _context.Birthdays.FindAsync(id);
        if (birthday == null)
            return NotFound($"День рождения с ID {id} не найден");

        if (!string.IsNullOrEmpty(birthday.PhotoPath))
        {
            var fullPath = Path.Combine(_env.WebRootPath, birthday.PhotoPath.TrimStart('/'));
            if (System.IO.File.Exists(fullPath))
                System.IO.File.Delete(fullPath);
        }

        _context.Birthdays.Remove(birthday);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    [HttpPost("{id}/photo")]
    public async Task<IActionResult> UploadPhoto(int id, IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest("Файл не выбран");

        var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
        var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!allowedExtensions.Contains(ext))
            return BadRequest("Разрешены только изображения: jpg, png, gif");

        if (file.Length > 5 * 1024 * 1024)
            return BadRequest("Размер файла не должен превышать 5MB");

        var birthday = await _context.Birthdays.FindAsync(id);
        if (birthday == null)
            return NotFound($"День рождения с ID {id} не найден");

        if (!string.IsNullOrEmpty(birthday.PhotoPath))
        {
            var oldPath = Path.Combine(_env.WebRootPath, birthday.PhotoPath.TrimStart('/'));
            if (System.IO.File.Exists(oldPath))
                System.IO.File.Delete(oldPath);
        }

        var uploadsFolder = Path.Combine(_env.WebRootPath, "uploads");
        if (!Directory.Exists(uploadsFolder))
            Directory.CreateDirectory(uploadsFolder);

        var fileName = $"{Guid.NewGuid()}_{file.FileName}";
        var filePath = Path.Combine(uploadsFolder, fileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        var photoPath = $"/uploads/{fileName}";
        birthday.SetPhotoPath(photoPath);
        await _context.SaveChangesAsync();

        return Ok(new { photoPath });
    }
}