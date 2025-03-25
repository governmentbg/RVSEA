using DAA.Extensions.Controller;
using DAA.Services.Authorization;
using DAA.Services.Import;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using ISystemAuthorizationService = Microsoft.AspNetCore.Authorization.IAuthorizationService;

namespace DAA.Web.Intranet.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class ImportController : BaseApiController
    {
        private readonly IImportService _importService;

        public ImportController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IImportService importService,
           ISystemAuthorizationService authorizationService)
           : base(localizer, logger, userInfo, authorizationService)
        {
            _importService = importService;
        }

        /// <summary>
        /// Test posting data. 
        /// </summary>
        /// <param name="data">Any object convertible to JSON.</param>
        /// <returns>Message for success and echoed data.</returns>
        [HttpPost("test")]
        [ProducesResponseType(200)]
        [ProducesResponseType(400)]
        [ProducesResponseType(401)]
        [ProducesResponseType(403)]
        [ProducesResponseType(500)]
        public async Task<IActionResult> Test([FromBody] object data)
        {
            try
            {
                var roles = new string[] { ApplicationRoleType.GroupB };
                var authResultStatusCode = await AuthorizeRolesInArchive(0, roles);
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                if (data == null)
                    return BadRequest("Missing data!");

                var json = Newtonsoft.Json.JsonConvert.SerializeObject(data);
                string result = $"Test succeeded! user: {_currentUserInfo.CurrentUserId}/{_currentUserInfo.CurrentUserUsername}; data: {json}";
                return Success(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error on import test");
                return InternalServerError();
            }
        }


        /// <summary>
        /// Test posting file. 
        /// </summary>
        /// <returns>Message for success and echoed data.</returns>
        [HttpPost("testFile")]
        [ProducesResponseType(200)]
        [ProducesResponseType(400)]
        [ProducesResponseType(401)]
        [ProducesResponseType(403)]
        [ProducesResponseType(500)]
        public async Task<IActionResult> TestFile()
        {
            try
            {
                var roles = new string[] { ApplicationRoleType.GroupB };
                var authResultStatusCode = await AuthorizeRolesInArchive(0, roles);
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                if (Request.Form.Files == null || Request.Form.Files.Count() == 0 || Request.Form.Files[0] == null)
                {
                    return BadRequest("Missing import file!");
                }

                var file = await _importService.ParseFile(Request.Form.Files[0]);

                var json = Newtonsoft.Json.JsonConvert.SerializeObject(file);
                string result = $"Test succeeded! user: {_currentUserInfo.CurrentUserId}/{_currentUserInfo.CurrentUserUsername}; file: {json}";
                return Success(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error on importing a test file");
                return InternalServerError();
            }
        }


        [HttpPost("archivalEntities/{inventorySysId}")]
        public async Task<IActionResult> ImportArchivalEntitiesFromExcel(Guid inventorySysId, [FromQuery] bool readPackagesSheet = true, [FromQuery] bool readInventorySheet = false)
        {
            if (inventorySysId == Guid.Empty)
            {
                return BadRequest(_localizer.GetString("Error_InvalidData").Value);
            }

            try
            {
                var roles = new string[] { ApplicationRoleType.GroupB };
                var authResultStatusCode = await AuthorizeRolesInArchive(0, roles);
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                if (Request.Form.Files == null || Request.Form.Files.Count() == 0 || Request.Form.Files[0] == null)
                {
                    return BadRequest("Missing import file!");
                }

                OperationResult result = await _importService.ImportArchivalEntitesFromExcelAsync(Request.Form.Files[0], inventorySysId, readPackagesSheet, true, readInventorySheet);

                if (!result.Succeeded)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success(result.Data);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error on importing file");
                return InternalServerError();
            }

        }


        [HttpPost("readArchivalEntities")]
        public async Task<IActionResult> ReadArchivalEntitiesFromExcel()
        {
            try
            {
                //var roles = new string[] { ApplicationRoleType.GroupB };
                //var authResultStatusCode = await AuthorizeRolesInArchive(0, roles);
                //if (authResultStatusCode != StatusCodes.Status200OK)
                //{
                //    return Forbid();
                //}

                if (Request.Form.Files == null || Request.Form.Files.Count() == 0 || Request.Form.Files[0] == null)
                {
                    return BadRequest("Missing import file!");
                }

                OperationResult result = await _importService.ImportArchivalEntitesFromExcelAsync(Request.Form.Files[0], Guid.Empty, true, false, true);

                if (!result.Succeeded)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success(result.Data);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error on reading data from import file");
                return InternalServerError();
            }

        }

        [AllowAnonymous]
        [HttpGet("exportFileTemplate")]
        public async Task<IActionResult> ExportFileTemplate()
        {
            try
            {
                var result = await _importService.ExportFileTemplateToExcel();
                if(result == null)
                {
                    throw new Exception("File is null");
                }

                Response.Headers.Add("Content-Disposition", $"{"attachment"}; filename={result.Filename}");
                string? extension = Path.GetExtension(result.Filename);
                string contentType = result.Mimetype!;
                return new FileContentResult(Convert.FromBase64String(result.Data!), contentType);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error on exporting file");
                return InternalServerError();
            }

        }


        [NonAction]
        private async Task<int> AuthorizeRolesInArchive(int? archiveId, IEnumerable<string> roles)
        {
            try
            {
                AuthorizationResult authorizationResult =
                await _authorizationService.AuthorizeAsync(
                    _currentUserInfo.CurrentUser,
                    archiveId,
                    new ArchiveAuthorizationRequirement(roles));

                if (!authorizationResult.Succeeded)
                {
                    string failureReasons = "";
                    if (authorizationResult.Failure?.FailureReasons != null && authorizationResult.Failure.FailureReasons.Count() > 0)
                    {
                        failureReasons = String.Join(";", authorizationResult.Failure.FailureReasons.Select(reason => reason.Message));
                    }
                    _logger.LogError($"Authorization Failed for user {_currentUserInfo.CurrentUserId}. {failureReasons}");

                    return StatusCodes.Status403Forbidden;
                }

                return StatusCodes.Status200OK;
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error authorizing roles in archive");
                return StatusCodes.Status500InternalServerError;
            }
        }
    }
}
