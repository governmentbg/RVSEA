using DAA.Models.Funds;
using DAA.Shared;

namespace DAA.Services.Funds
{
    public interface IFundPublicService
    {
        Task<FundPublicDisplayModel?> GetFundBySystemIdentifierAsync(Guid sysId);
        Task<FundPublicDisplayModel?> GetFromExternalSourceAsync(int externalIdentifier, Guid? systemIdentifier = null);
        Task<OperationResult?> CreateFundReviewAsync(Guid? fundSystemIdentifier, int? fundExternalIdentifier);
    }
}
