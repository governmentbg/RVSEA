using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public partial class Result
    {
        public int Ok { get; set; }
    }
}
