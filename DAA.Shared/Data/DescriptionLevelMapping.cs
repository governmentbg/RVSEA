namespace DAA.Shared.Data
{
    public static class DescriptionLevelMapping
    {
        public static readonly Dictionary<string, string> FundDescriptionLevel 
            = new Dictionary<string, string>() 
            { 
                { "1", "1" }, //Фонд
                { "2", "4" }, //ЧП
                { "3", "3" }, //Спомен
                { "4", "2" }, //Фонд с необработени документи
            };

        public static readonly Dictionary<string, string> InventoryDescriptionLevel
            = new Dictionary<string, string>()
            {
                { "5", "5" }, //Инвентарен опис
                { "6", "6" }, //Груб опис
                { "12", "12" }, //Служебен опис
            };

        public static readonly Dictionary<string, string> ArchivalEntityDescriptionLevel
            = new Dictionary<string, string>()
            {
                { "8", "1" }, //Архивна единица
                { "13", "2" }, //Служебна архивна единица
            };

        public static readonly Dictionary<string, string> DocumentDescriptionLevel
            = new Dictionary<string, string>()
            {
                { "7", "1" }, //Документ
            };
    }
}
