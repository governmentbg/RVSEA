using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    //TODO Да се изтрие
    [Keyless]
    public partial class Number
    {
        public int? Id { get; set; }
        public string? Num { get; set; } = null!;
        public int LevelOfDescriptionCode { get; set; }
    }
}
