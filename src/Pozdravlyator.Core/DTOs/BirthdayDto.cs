namespace Pozdravlyator.Core.DTOs;

public class BirthdayDto
{
    public int Id { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public DateTime BirthDate { get; set; }
    public int? YearOfBirth { get; set; }
    public string? Phone { get; set; }
    public string? Email { get; set; }
    public string? PhotoPath { get; set; }
    public string FullName => $"{FirstName} {LastName}";
    public int Age { get; set; }
    public int DaysUntilBirthday { get; set; }
    public bool IsToday { get; set; }
}