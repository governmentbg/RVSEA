namespace DAA.Services.Numbers
{
    public interface INumberService
    {
        Task<int> GetFundNumberNumeric(int archiveId, string descriptionLevelCode, string fundArray);
        //Task<string> GenerateFundNumber(int archive, string fundArray, int levelOfDescriptionCode);
        //Task<int> GetLastFundNumberExternal(int archive, string fundArray, int levelOfDescriptionCode);
        Task<bool> IsValidFundNumber(int archiveId, string number, string fundArray, string descriptionLevelCode, Guid? systemIdentifier = null);
        //Task<string> GenerateInventoryNumber(
        //    int archive, int fundExternalIdentifier, Guid fundSystemIdentifier, string inventoryArray, int levelOfDescriptionCode);
        //Task<int?> GetLastInventoryNumberExternal(
        //    int archive, int fundExternalIdentifier, string inventoryArray, int levelOfDescriptionCode);
        Task<int> GetInventoryNumberNumeric(int archiveId, Guid fundSystemIdentifier, string descriptionLevelCode, string inventoryArray);
        Task<bool> IsValidInventoryNumber(int archiveId, Guid fundSystemIdentifier, int numberNumeric, string inventoryArray, string descriptionLevelCode, Guid? systemIdentifier = null);
        //Task<string> GetNextArchivalEntityNumberExternal(int archive, int inventoryExternalIdentifier);
        Task<bool> IsValidArchivalEntityNumber(int archiveId, Guid inventorySystemIdentifier, string number, string descriptionLevelCode, Guid? systemIdentifier = null);
        Task<int> GetArchivalEntityNumberNumeric(int archiveId, Guid inventorySystemIdentifier, string descriptionLevelCode);
        Task<bool> IsValidDocumentNumber(int archiveId, Guid inventorySystemIdentifier, Guid archivalEntitySystemIdentifier,string number, Guid? systemIdentifier = null);
        Task<int> GetDocumentNumberNumeric(int archiveId, Guid inventorySystemIdentifier, string archivalEntitySystemIdentifier);
    }
}
