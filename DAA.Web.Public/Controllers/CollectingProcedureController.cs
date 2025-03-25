using DAA.Extensions.Controller;
using DAA.Services.DocsCollectingProc;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Public.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CollectingProcedureController : BaseApiController
    {
      //  private readonly IDocsCollectingProcedureService _procService;

        public CollectingProcedureController(
            IStringLocalizer<SharedResources> localizer)
           // IDocsCollectingProcedureService procService)
            : base(localizer)
        {
           // _procService = procService;
        }

        //[HttpPost]
        //public async  Task<ActionResult> Create(CollectionProcedureCreateModel model)
        //{
        //    await _procService.Start(model.ArchiveId, model.RequestId);
        //    return Success();
        //}

        //[HttpPost]
        //public ActionResult UploadPackageA(PackageDocumentCreateModel[] docs)
        //{
        //    return Success();
        //}

        //[HttpPost]
        //public ActionResult UploadPackageB(PackageDocumentCreateModel[] docs)
        //{
        //    return Success();
        //}
    }

    //public class CollectionProcedureCreateModel
    //{
    //    public int ArchiveId { get; set; }
    //    public int? RequestId { get; set; }
    //}

    //public class PackageDocumentCreateModel
    //{
    //    public int PackageId { get; set; }
    //    public IFormFile Document { get; set; }
    //    public string Description { get; set; }
    //    public int DocumentTypeId { get; set; }
    //}
}