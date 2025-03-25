using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Inventories
{
    public class InventoryPublicImportModel
    {
        public Guid? SystemIdentifier { get; set; }

        public int? AcquisitionMethodId { get; set; }

        [Range(1, 31, ErrorMessage = "Поле Начална дата ден трябва да е цяло число между 1 и 31")]
        public int? StartDateDay { get; set; }

        [Range(1, 12, ErrorMessage = "Поле Начална дата месец трябва да е цяло число между 1 и 12")]
        public int? StartDateMonth { get; set; }

        [Required(ErrorMessage = "Поле Начална дата година е задължително")]
        [Range(1, 3000, ErrorMessage = "Поле Начална дата година трябва да е цяло число между 1 и 3000")]
        public int StartDateYear { get; set; }

        [Range(1, 31, ErrorMessage = "Поле Крайна дата ден трябва да е цяло число между 1 и 31")]
        public int? EndDateDay { get; set; }

        [Range(1, 12, ErrorMessage = "Поле Крайна дата месец трябва да е цяло число между 1 и 12")]
        public int? EndDateMonth { get; set; }

        [Required(ErrorMessage = "Поле Крайна дата година е задължително")]
        [Range(1, 3000, ErrorMessage = "Поле Крайна дата година трябва да е цяло число между 1 и 3000")]
        public int EndDateYear { get; set; }

        public string? ApproxmateChronologicalScope { get; set; }

        [MaxLength(256, ErrorMessage = "Поле Друго може да е най-много 256 символа")]
        public string? OtherMetrics { get; set; }

        public string? FundCreatorTitleHistory { get; set; }

        [Required(ErrorMessage = "Поле История на фондообразувателя/биографични данни е задължително")]
        public string FundCreatorBiographicalHistory { get; set; }

        [Required(ErrorMessage = "Поле История на фонда е задължително")]
        public string History { get; set; }

        public string? DocumentsProvider { get; set; }

        public string? DocumentsDescription { get; set; }

        public string? ClassificationScheme { get; set; }

        public string? AbbreviationList { get; set; }

        public string? DocumentsAccessDescription { get; set; }

        public string? Notes { get; set; }
        public string? OtherLanguage { get; set; }

    }
}
