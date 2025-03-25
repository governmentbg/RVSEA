using Microsoft.EntityFrameworkCore;

namespace DAA.Data.RemoteDBEntities
{
    [Keyless]
    public class Nomenclature
    {
        public int Gid { get; set; }
        public string Name { get; set; } = string.Empty;
    }
}
