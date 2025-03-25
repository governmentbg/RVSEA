using DAA.Data;
using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.ArchiveEntities;
using DAA.Models.DigitalObjects;
using DAA.Models.Documents;
using DAA.Models.FileUploadApp;
using DAA.Models.Funds;
using DAA.Models.Inventories;
using DAA.Services.ArchivalEntities;
using DAA.Services.DigitalObjects;
using DAA.Services.Documents;
using DAA.Services.Files;
using DAA.Services.FileUploadApp;
using DAA.Services.Funds;
using DAA.Services.Inventories;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using System.Collections;
using System.Text;

namespace DAA.Web.Intranet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class FileUploadAppController : BaseApiController
    {
        private readonly IFileUploadAppService _service;

        public FileUploadAppController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<FileUploadAppController> logger,
           IUserInfo userInfo,
           IFileUploadAppService service)
           : base(localizer, logger, userInfo)
        {
            _service = service;
        }

        [HttpGet("authorize")]
        public async Task<AuthorizeResultModel> Authorize()
        {
            _logger.LogDebug($"{nameof(Authorize)}: Entering authorization");
            _logger.LogDebug($"{nameof(Authorize)}: Current user: {_currentUserInfo.CurrentUserUsername}, {_currentUserInfo.CurrentUserId}");

            return await _service.Authorize();
        }

        [HttpGet("getExtensions")]
        public async Task<GetExtensionsResultModel> GetExtensions()
        {
            _logger.LogDebug($"{nameof(List)}: Entering getExtensions");
            _logger.LogDebug($"{nameof(List)}: Current user: {_currentUserInfo.CurrentUserUsername}, {_currentUserInfo.CurrentUserId}");

            return await _service.GetExtensions();
        }

        [HttpGet("list")]
        public async Task<ListQueueResultModel> List([FromQuery] string computerName)
        {
            _logger.LogDebug($"{nameof(List)}: Entering list for {computerName}");
            _logger.LogDebug($"{nameof(List)}: Current user: {_currentUserInfo.CurrentUserUsername}, {_currentUserInfo.CurrentUserId}");

            return await _service.List(computerName);
        }

        [HttpPost("addToQueue")]
        public async Task<AddToQueueResultModel> AddToQueue([FromBody] QueueItemModel model)
        {
            _logger.LogDebug($"{nameof(AddToQueue)}: Adding item to queue documentId: {model.DocumentId}, filename: {model.LocalFileName}");
            _logger.LogDebug($"{nameof(AddToQueue)}: Current user: {_currentUserInfo.CurrentUserUsername}, {_currentUserInfo.CurrentUserId}");

            return await _service.Add(model);
        }
        [HttpPost("updateQueue")]
        public async Task<OperationResultModel> UpdateQueue([FromBody] QueueItemModel model)
        {
            return await _service.Update(model);
        }
        [HttpPost("deleteFromQueue")]
        public async Task<OperationResultModel> DeleteFromQueue([FromBody] QueueItemIdModel model)
        {
            return await _service.Delete(model.Id);
        }

        [HttpGet("documentExists")]
        public async Task<DocumentExistsResultModel> DocumentExists([FromQuery] ProcessKind processKind, [FromQuery] Guid documentId)
        {
            return await _service.DocumentExists(processKind, documentId);
        }
        [HttpGet("fileExists")]
        public async Task<DocumentExistsResultModel> FileExists([FromQuery] ProcessKind processKind, [FromQuery] FileKind? fileKind, 
            [FromQuery] Guid documentId, [FromQuery] int? currentQueueId, [FromQuery] string fileName)
        {
            return await _service.FileExists(processKind, fileKind, documentId, currentQueueId, fileName);
        }

        [HttpGet("mastersForDocument")]
        public async Task<MastersForDocumentResultModel> MastersForDocument([FromQuery] Guid documentId)
        {
            return await _service.MastersForDocument(documentId);
        }

        [HttpPost("upload")]
        public async Task<OperationResultModel> Upload(IFormFile file, [FromForm] int id, [FromForm] long offset, [FromForm] int? length)
        {
            _logger.LogDebug($"{nameof(Upload)}: Uploading file from queue {file.Name}");
            _logger.LogDebug($"{nameof(Upload)}: Current user: {_currentUserInfo.CurrentUserUsername}, {_currentUserInfo.CurrentUserId}");

            //throw new NotImplementedException();
            if (file.Length != length)
            {
                throw new ArgumentException("file.Length != length");
            }
            return await _service.UploadFileAsync(file.FileName, file.OpenReadStream(), id, offset);
        }

        [HttpPost("validateAndFinish")]
        public async Task<OperationResultModel> ValidateAndFinish(QueueItemIdModel model)
        {
            return await _service.ValidateAndFinish(model.Id);
        }

        [HttpPost("verifyChecksums")]
        public async Task<ChecksumsVerifyResultModel> VerifyChecksums([FromBody]ProcessKind? processKind)
        {
            return await _service.VerifyChecksums(processKind);
        }

    }
}
