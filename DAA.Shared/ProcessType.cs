namespace DAA.Shared
{
    public enum ProcessType
    {
        AddInventory = 1,
        AddRawInventory = 2,
        AddSystemInventory = 20,

        FilmRegisterData = 4,
        FilmRegisterCard = 5,
        FilmEditData = 6,

        AddDocument = 7,
        PreparationOfADigitalObject = 8,
        ImportDigitalObject = 9,

        DeductData = 10,
        EditData = 11,
        RefineData = 12,

        EditFundData = 13,
        AddRawInventoryToRawFund = 14,
        AddFundAndInventory = 15,
        AddRawFundAndRawInventory = 16,
        ProcessRawFundWithRawInventory = 17,
        ReconstructFundData = 18,
        ProcessFundWithRawInventory = 19,
    }
}
