using DAA.Services.OpenData;
using Hangfire;
using System.Globalization;

namespace DAA.Services.Notifications
{
    public class OpenDataServiceJob : IOpenDataServiceJob
    {
        private readonly IOpenDataService _openDataService;

        public OpenDataServiceJob(IOpenDataService openDataService)
        {
            _openDataService = openDataService;
        }

        public async Task Run(IJobCancellationToken token)
        {
            token.ThrowIfCancellationRequested();
            await RunAtTimeOf(DateTime.UtcNow);
        }

        public async Task RunAtTimeOf(DateTime now)
        {
            var specifiedCulture = new CultureInfo("bg-BG");
            CultureInfo.CurrentCulture = specifiedCulture;
            CultureInfo.CurrentUICulture = specifiedCulture;

            await _openDataService.Sync(CancellationToken.None);
        }
    }
}
