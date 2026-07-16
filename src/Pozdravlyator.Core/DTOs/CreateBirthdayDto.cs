namespace Pozdravlyator.Core.DTOs;

public class CreateBirthdayDto
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public DateTime BirthDate { get; set; }
    public int? YearOfBirth { get; set; }
    public string? Phone { get; set; }
    public string? Email { get; set; }
}