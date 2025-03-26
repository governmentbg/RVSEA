using Microsoft.AspNetCore.Http;

namespace DAA.Models.Commission
{
    public class CommissionSessionUploadProtocolModel
    {
        public int? SessionId { get; set; }
        public IFormFile[]? Files { get; set; }
    }
}
