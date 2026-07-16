namespace Pozdravlyator.Core.Entities;

public class Birthday : EntityBase
{
    public string FirstName { get; private set; } = string.Empty;
    public string LastName { get; private set; } = string.Empty;
    public DateTime BirthDate { get; private set; }
    public int? YearOfBirth { get; private set; }
    public string? Phone { get; private set; }
    public string? Email { get; private set; }
    public string? PhotoPath { get; private set; }

    public string FullName => $"{FirstName} {LastName}";

    public Birthday(string firstName, string lastName, DateTime birthDate)
    {
        SetFirstName(firstName);
        SetLastName(lastName);
        SetBirthDate(birthDate);
    }

    private Birthday() { }

    public void SetFirstName(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
            throw new ArgumentException("Имя обязательно");
        FirstName = value.Trim();
    }

    public void SetLastName(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
            throw new ArgumentException("Фамилия обязательна");
        LastName = value.Trim();
    }

    public void SetBirthDate(DateTime value)
    {
        if (value > DateTime.Today)
            throw new ArgumentException("Дата рождения не может быть в будущем");
        BirthDate = value;
    }

    public void SetYearOfBirth(int year)
    {
        if (year < 1900 || year > DateTime.Today.Year)
            throw new ArgumentException("Некорректный год рождения");
        YearOfBirth = year;
    }

    public void SetPhone(string? phone) => Phone = phone;
    public void SetEmail(string? email) => Email = email;
    public void SetPhotoPath(string? path) => PhotoPath = path;

    public int GetAge(DateTime? currentDate = null)
    {
        var today = currentDate ?? DateTime.Today;
        var age = today.Year - BirthDate.Year;
        if (BirthDate.Date > today.AddYears(-age)) age--;
        return age;
    }

    public int GetDaysUntilNextBirthday(DateTime? currentDate = null)
    {
        var today = currentDate ?? DateTime.Today;
        var nextBirthday = new DateTime(today.Year, BirthDate.Month, BirthDate.Day);

        if (nextBirthday < today)
            nextBirthday = nextBirthday.AddYears(1);

        return (nextBirthday - today).Days;
    }

    public bool IsBirthdayToday(DateTime? currentDate = null)
    {
        var today = currentDate ?? DateTime.Today;
        return BirthDate.Month == today.Month && BirthDate.Day == today.Day;
    }
}