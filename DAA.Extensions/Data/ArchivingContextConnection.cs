using Microsoft.Extensions.Configuration;
using System.Data.SqlClient;

namespace DAA.Extensions.Data
{
    public class ArchivingContextConnection
    {
        public ArchivingContextConnection(IConfiguration configuration)
        {
            Connection = new SqlConnection(
                configuration.GetConnectionString("DefaultConnection"));
        }
        public SqlConnection Connection { get; }
    }
}
