using System.ComponentModel.DataAnnotations;

namespace DAA.Models.ArchiveEntities
{
    public class ArchivalEntityPublicImportModel
    {
        public Guid? SystemIdentifier { get; set; }

        [Required(ErrorMessage = "Поле Числов номер на архивна единица е задължително")]
        [Range(1, int.MaxValue, ErrorMessage = "Поле Числов номер на архивна единица трябва да е цяло число, по-голямо от 0")]
        public int NumberNumeric { get; set; }

        [MaxLength(250, ErrorMessage = "Поле Буквен номер на архивна единица може да е най-много 250 символа")]
        public string? NumberArray { get; set; }

        [MaxLength(250, ErrorMessage = "Поле Индекс по класификационната схема може да е най-много 250 символа")]
        public string? ClassificationSchemeIndex { get; set; }

        public string? Cypher { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Поле Заглавие на архивна единица е задължително")]
        public string? Title { get; set; }



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



        public string? Location { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Поле Брой е-документи текстови трябва да е цяло число по-голямо от 0")]
        public int? TextDocsCount { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Поле Брой е-документи графични трябва да е цяло число по-голямо от 0")]
        public int? GraphicalDocsCount { get; set; }

        [MaxLength(256, ErrorMessage = "Поле Друго може да е най-много 256 символа")]
        public string? OtherMetrics { get; set; }

        public string? Author { get; set; }

        [MaxLength(256, ErrorMessage = "Поле Мащаб може да е най-много 256 символа")]
        public string? Scaling { get; set; }

        public string? Description { get; set; }

        public string? LanguageText { get; set; }

        public string? OtherLanguage { get; set; }

        public string? DocumentsAccessDescription { get; set; }

        public string? Features { get; set; }

        public string? Notes { get; set; }

        public string? Phase { get; set; }

        public string? Part { get; set; }

        public string? Stage { get; set; }

        [MaxLength(250, ErrorMessage = "Поле Автор на описанието може да е най-много 250 символа")]
        public string? DescriptionAuthor { get; set; }

        public IEnumerable<string>? LanguageCodes { get; set; }
        public string? InventoryNumberArray { get; set; }
        public string? ApproximateChronologicalScope { get; set; }
        public int? ArchiveId { get; set; }
        public Guid? InventorySystemIdentifier { get; set; }
        public string DescriptionLevelCode { get; set; } = null!;

    }
}
