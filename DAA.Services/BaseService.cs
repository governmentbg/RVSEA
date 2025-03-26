using DAA.Data;
using DAA.Models.File;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;

namespace DAA.Services
{
    public abstract class BaseService
    {
        protected readonly IStringLocalizer<SharedResources> _localizer;
        protected readonly ILogger _logger;
        private bool disposed;

        protected ArchivingContext _context { get; private set; }

        
        protected BaseService(ArchivingContext context,
            IStringLocalizer<SharedResources> localizer = null!,
            ILogger logger = null!)
        {
            _context = context;
            _localizer = localizer;
            _logger = logger;
        }

        //protected Task<int> SaveAsync(string description = null)
        //{
        //    return _context.SaveAsync(description);
        //}

        // Public implementation of Dispose pattern callable by consumers.
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        // Protected implementation of Dispose pattern.
        protected virtual void Dispose(bool disposing)
        {
            if (disposed)
            {
                return;
            }

            if (disposing)
            {
                // Free any other managed objects here.
                _context.Dispose();
            }

            // Free any unmanaged objects here.

            disposed = true;
        }

        ~BaseService()
        {
            Dispose(false);
        }


        protected async Task<FileModel> ParseAttachmentAsync(IFormFile file)
        {
            var result = new FileModel();

            using (var stream = new MemoryStream())
            {
                await file.CopyToAsync(stream);
                result.Name = file.FileName;
                result.ContentType = file.ContentType;
                result.Type = file.FileName.Split('.').Last();
                result.Size = stream.Length;
                result.Content = stream.ToArray();
                result.SystemName = $"{Guid.NewGuid()}.{result.Type}";
            }

            return result;
        }
    }
}
