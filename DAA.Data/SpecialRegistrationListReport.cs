using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class SpecialRegistrationListReport
    {
        public string Title { get; set; } = string.Empty;
        public string Archive { get; set; } = string.Empty;
        public string? DescriptionLevel { get; set; }
        public string? FundNumber { get; set; }
        public string? InventoryNumber { get; set; }
        public string? ArchiveEntityNumber { get; set; }
        public long? Size { get; set; }
        public int? PapersCount { get; set; }
        public string? StartDate { get; set; }
        public string? EndDate { get; set; }
        public string? PhysicalCondition { get; set; }
        public bool? IsInRisk { get; set; }
        public string? Location { get; set; }
        public string? BuildingNumber { get; set; }
        public string? FloorNumber { get; set; }
        public string? PremisesNumber { get; set; }
        public string? RoomNumber { get; set; }
        public string? StillageNumber { get; set; }
        public string? StillageSide { get; set; }
        public string? RowNumber { get; set; }
        public string? CellNumber { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}
