using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class FundInternalReport
    {
        //public int LGid { get; set; } // ид
        //public string? CreationAuthor { get; set; }
        //public string? ModificationDate { get; set; }
        //public string? ModificationAuthor { get; set; }
        public double? LinearMeters { get; set; }
        public long? DigitalSize { get; set; }
        public long? Duration { get; set; }
        public int? InventoryCount { get; set; } // на InventoryCount
        //public int? BoxesCount { get; set; }
        //public int? RolledTubesCount { get; set; } // рулонни тубуси
        public int? AECount { get; set; } // ArchiveEntityCount
        //public string? ExtentOther { get; set; } 
        //public string? FundFormerNameChange { get; set; }
        //public string? FundFormerFunction { get; set; }
        //public string? FundFormerHistory { get; set; }
        //public string? ArchivalHistory { get; set; }
        public string? ImmediateSourceOfAcquisition { get; set; }
        public string Archive { get; set; } = string.Empty;
        //public string? DocumentProperties { get; set; }
        public string? Number { get; set; } // FundNumber
        public string? FundType { get; set; }
        public string? IndustryIndex { get; set; }
        public string? MethodOfAcquisition { get; set; }
        public string? TextDate { get; set; }
        public string? StartDate { get; set; }
        public string? EndDate { get; set; }
        public string? CreationDate { get; set; }
        public string? Title { get; set; }
        public string? Note { get; set; }
        public string? FundStatus { get; set; }
        public string? LevelOfDescription { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}
