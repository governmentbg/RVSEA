
using Microsoft.AspNetCore.Http;

namespace DAA.Services.Watermark
{
    public interface IWatermarkService
    {
        public Task<Tuple<string, string>> AddWatermark(IFormFile model, string systemFileName);
    }
}
