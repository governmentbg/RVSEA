using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace DAA.Data
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
