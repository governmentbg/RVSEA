using DAA.Shared.Data;

namespace DAA.Models.Information
{
    public class InformationItemDisplayModel : InformationItemModel, IDisplayable
    {
        public string? CreatedByUserName { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public string? UpdatedByUserName { get; set; }
        public string? UpdatedByDisplayName { get; set; }
        public string? DeletedByUserName { get; set; }
        public string? DeletedByDisplayName { get; set; }
        public string Uid => Guid.NewGuid().ToString();
    }
}
