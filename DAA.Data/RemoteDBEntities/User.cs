using Microsoft.EntityFrameworkCore;

namespace DAA.Data.RemoteDBEntities
{
    [Keyless]
    public class User
    {
        public int Gid { get; set; }
        public string? Name { get; set; } = string.Empty;
    }
}
