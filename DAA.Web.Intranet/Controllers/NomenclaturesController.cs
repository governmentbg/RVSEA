using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Nomenclatures;
using DAA.Services.Nomenclatures;
using DAA.Shared.Authorization;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Intranet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class NomenclaturesController : BaseApiController
    {
        protected readonly INomenclatureService _nomenclatureService;
        
        public NomenclaturesController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<BaseApiController> logger,
            IUserInfo userInfo,
            INomenclatureService nomenclatureService)
            : base(localizer, logger, userInfo)
        {
            _nomenclatureService = nomenclatureService;
        }

        
        [HttpPost("listall")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public IActionResult ListAll(DataSourceRequestModel model)
        {
            try
            {
                var result = _nomenclatureService.GetNomenclatures(model);
                if (result?.Errors != null)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(result.Errors);
                }
                else
                {
                    return Success(result);
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"{nameof(ListAll)} Error getting nomenclatures list");
                return InternalServerError();
            }
        }

        [HttpPost("values/list/{parentId}")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public IActionResult ListNomenclatureValues(DataSourceRequestModel model, int parentId)
        {
            try
            {
                return Success(_nomenclatureService.GetNomenclatureValues(model, parentId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"{nameof(ListNomenclatureValues)} Error getting nomenclature values for nomenclature {parentId}");
                return InternalServerError();
            }
        }

        [HttpGet("{id}")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> GetNomenclature(int id)
        {
            try
            {
                return Success(await _nomenclatureService.GetNomenclatureByIdAsync(id));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"{nameof(GetNomenclature)} Error getting nomenclature {id}");
                return InternalServerError();
            }
        }

        [HttpGet("{parentId}/values/{id}")]
        public async Task<IActionResult> GetNomenclatureValue(int id, int parentId)
        {
            try
            {
                return Success(await _nomenclatureService.GetNomenclatureValueByIdAsync(id, parentId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"{nameof(GetNomenclatureValue)} Error getting nomenclature value {id}");
                return InternalServerError();
            }
        }

        [HttpPost("")]
        //TODO: това да се изпълнява само от глобалния админ
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> PostNomenclature(NomenclatureModel model)
        {
            try
            {
                var result = await _nomenclatureService.CreateNomenclatureAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    if (!result.RawErrors)
                    {
                        return BadRequest(result.ToString(false));
                    }
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"{nameof(PostNomenclature)} Error creating nomenclature");
                return InternalServerError();
            }
        }

        [HttpPost("values")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> PostNomenclatureValue(NomenclatureValueModel model)
        {
            try
            {
                var result = await _nomenclatureService.CreateNomenclatureValueAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    if (!result.RawErrors)
                    {
                        return BadRequest(result.ToString(false));
                    }
                    if (result.Errors.Any(err => err.Contains("UI_ParentId_Code")))
                    {
                        return BadRequest(String.Format(_localizer.GetString("Error_DuplicateNomenclatureValueCode").ToString(), model.Code));
                    }
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"{nameof(PostNomenclatureValue)} Error creating nomenclature value");
                return InternalServerError();
            }
        }

        [HttpPut("")]
        //TODO: това да се изпълнява само от глобалния админ
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> PutNomenclature(NomenclatureModel model)
        {
            try
            {
                var result = await _nomenclatureService.UpdateNomenclatureAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError($"{nameof(PutNomenclature)} {result}");
                    if (!result.RawErrors)
                    {
                        return BadRequest(result.ToString(false));
                    }
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"{nameof(PutNomenclature)} Error updating nomenclature {model}");
                return InternalServerError();
            }
        }

        [HttpPut("values")]
        [Admin(AdminType.Admin,AdminType.GlobalAdmin)]
        public async Task<IActionResult> PutNomenclatureValue(NomenclatureValueModel model)
        {
            
            try
            {
                var result = await _nomenclatureService.UpdateNomenclatureValueAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError($"{nameof(PutNomenclatureValue)} {result}");
                    if (!result.RawErrors)
                    {
                        return BadRequest(result.ToString(false));
                    }
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error updating nomenclature value {model}");
                return InternalServerError();
            }
        }

        [HttpDelete("{id}")]
        //TODO: това да се изпълнява само от глобалния админ
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> DeleteNomenclature(int id)
        {
            try
            {
                var result = await _nomenclatureService.DeleteNomenclatureAsync(id);
                if (!result.Succeeded)
                {
                    _logger.LogError($"{nameof(DeleteNomenclature)} {result}");
                    if (!result.RawErrors)
                    {
                        return BadRequest(result.ToString(false));
                    }
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting nomenclature with id {id}");
                return InternalServerError();
            }
        }

        
        [HttpDelete("values/{id}")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> DeleteNomenclatureValue(int id)
        {
            try
            {
                var result = await _nomenclatureService.DeleteNomenclatureValueAsync(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    if (!result.RawErrors)
                    {
                        return BadRequest(result.ToString(false));
                    }
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting nomenclature value with id {id}");
                return InternalServerError();
            }
        }
    }
}
