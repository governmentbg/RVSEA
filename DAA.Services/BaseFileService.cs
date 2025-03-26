using DAA.Data.Files;
using DAA.Models.Configuration;
using DAA.Shared.Localization;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace DAA.Services
{
    public abstract class BaseFileService
    {
        protected readonly FileStreamSettings _settings;
        protected readonly IStringLocalizer<SharedResources> _localizer;
        protected readonly ILogger _logger;
        private bool disposed;

        protected FileContext _fileContext { get; private set; }
        protected BufferFileContext _bufferFileContext { get; private set; }
        protected AdjunctFileContext _adjunctFileContext { get; private set; }
        protected MasterFileContext _masterFileContext { get; private set; }

        protected BaseFileService(
            FileContext fileContext,
            BufferFileContext bufferFileContext,
            AdjunctFileContext adjunctFileContext,
            MasterFileContext masterFileContext,
            IOptions<FileStreamSettings> options,
            IStringLocalizer<SharedResources> localizer = null!,
            ILogger logger = null!)
        {
            _fileContext = fileContext;
            _bufferFileContext = bufferFileContext;
            _adjunctFileContext = adjunctFileContext;
            _masterFileContext = masterFileContext;
            _settings = options.Value;
            _localizer = localizer;
            _logger = logger;
        }

        // Public implementation of Dispose pattern callable by consumers.
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        //public void SetContext(MasterFileContext context)
        //{
        //    _context = context;
        //}

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
                //_context.Dispose();
                _bufferFileContext.Dispose();
                _fileContext.Dispose();
                _adjunctFileContext.Dispose();
                _masterFileContext.Dispose();
            }

            // Free any unmanaged objects here.

            disposed = true;
        }

        ~BaseFileService()
        {
            Dispose(false);
        }

    }
}
