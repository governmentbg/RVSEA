using DAA.Models.Configuration;
using DAA.Services.Interfaces;
using DAA.Shared;
using Microsoft.Extensions.Options;
using DAA.Data;
using DAA.Shared.Localization;
using Microsoft.Extensions.Localization;

namespace DAA.Services
{
    public class LinksService : BaseService, ILinksService
    {
        private readonly DaaSurveysLink _daaSurveysLink;

        public LinksService(
            ArchivingContext context,
            IOptions<DaaSurveysLink> daaSurveysLink,
            IStringLocalizer<SharedResources> localizer = null)
            : base(context, localizer)
        {
            _daaSurveysLink = daaSurveysLink.Value;
        }

        public OperationResult GetDaaSurveysLink()
        {
            string link = _daaSurveysLink.Link;

            if (link == null)
            {
                return OperationResult.Failed("");
            }

            return OperationResult.Succeed(link);
        }
    }
}
