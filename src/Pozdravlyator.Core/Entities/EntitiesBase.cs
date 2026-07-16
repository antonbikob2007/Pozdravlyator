namespace Pozdravlyator.Core.Entities;

public abstract class EntityBase
{
    public int Id { get; protected set; }
    public DateTime CreatedAt { get; protected set; }
    public DateTime? UpdatedAt { get; protected set; }

    protected EntityBase()
    {
        CreatedAt = DateTime.UtcNow;
    }
}