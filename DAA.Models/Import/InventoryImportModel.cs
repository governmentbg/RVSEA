using DAA.Shared.Attributes;
using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Import
{

    public class InventoryImportModel
    {
        [ExportTemplate("Индекс", Shared.ExcelDropDownListType.InventoryNumberArray)]
        [Required(ErrorMessage = "Поле Индекс е задължително")]
        [MaxLength(50, ErrorMessage = "Поле Индекс може да е най-много 50 символа")]
        public string NumberArray { get; set; }

        [ExportTemplate("Начин на продобиване", Shared.ExcelDropDownListType.AcquisitionMethod)]
        public int? AcquisitionMethod { get; set; }



        [ExportTemplate("Начална дата ден")]
        [Range(1, 31, ErrorMessage = "Поле Начална дата ден трябва да е цяло число между 1 и 31")]
        public int? StartDateDay { get; set; }

        [ExportTemplate("Начална дата месец")]
        [Range(1, 12, ErrorMessage = "Поле Начална дата месец трябва да е цяло число между 1 и 12")]
        public int? StartDateMonth { get; set; }

        [ExportTemplate("Начална дата година")]
        [Required(ErrorMessage = "Поле Начална дата година е задължително")]
        [Range(1, 3000, ErrorMessage = "Поле Начална дата година трябва да е цяло число между 1 и 3000")]
        public int StartDateYear { get; set; }


        [ExportTemplate("Крайна дата ден")]
        [Range(1, 31, ErrorMessage = "Поле Крайна дата ден трябва да е цяло число между 1 и 31")]
        public int? EndDateDay { get; set; }

        [ExportTemplate("Крайна дата месец")]
        [Range(1, 12, ErrorMessage = "Поле Крайна дата месец трябва да е цяло число между 1 и 12")]
        public int? EndDateMonth { get; set; }

        [ExportTemplate("Крайна дата година")]
        [Required(ErrorMessage = "Поле Крайна дата година е задължително")]
        [Range(1, 3000, ErrorMessage = "Поле Крайна дата година трябва да е цяло число между 1 и 3000")]
        public int EndDateYear { get; set; }



        [ExportTemplate("Друго")]
        [MaxLength(256, ErrorMessage = "Поле Друго може да е най-много 256 символа")]
        public string? OtherMetrics { get; set; }

        [ExportTemplate("Промени в наименование на фондообразувателя")]
        public string? FundCreatorTitleHistory { get; set; }

        [ExportTemplate("История на фондообразувателя/биографични данни")]
        [Required(ErrorMessage = "Поле История на фондообразувателя/биографични данни е задължително")]
        public string FundCreatorBiographicalHistory { get; set; }

        [ExportTemplate("История на фонда")]
        [Required(ErrorMessage = "Поле История на фонда е задължително")]
        public string History { get; set; }

        [ExportTemplate("Наименование на учреждението/лицето, предало документите")]
        public string? DocumentsProvider { get; set; }

        [ExportTemplate("Характеристика на документите")]
        public string? DocumentsDescription { get; set; }

        [ExportTemplate("Класификационна схема")]
        public string? ClassificationScheme { get; set; }

        [ExportTemplate("Списък на съкращенията")]
        public string? AbbreviationList { get; set; }

        [ExportTemplate("Условия на достъп")]
        public string? DocumentsAccessDescription { get; set; }

        [ExportTemplate("Забележка")]
        public string? Notes { get; set; }

        [ExportTemplate("Друго (език)")]
        public string? OtherLanguage { get; set; }

        public bool IsStartDateValid
        {
            get
            {
                try
                {
                    var date = new DateTime(StartDateYear, StartDateMonth ?? 1, StartDateDay ?? 1);
                    return true;
                }
                catch
                {
                    return false;
                }
            }
        }

        public bool IsEndDateValid
        {
            get
            {
                try
                {
                    var date = new DateTime(EndDateYear, EndDateMonth ?? 1, EndDateDay ?? 1);
                    return true;
                }
                catch
                {
                    return false;
                }
            }
        }

        public bool IsEndDateMoreThanStartDay
        {
            get
            {
                try
                {
                    var startDate = new DateTime(StartDateYear, StartDateMonth ?? 1, StartDateDay ?? 1);

                    var endDate = new DateTime(EndDateYear, EndDateMonth ?? 1, EndDateDay ?? 1);

                    return (startDate < endDate || startDate == endDate) ? true : false;
                }
                catch
                {
                    return false;
                }
            }
        }
    }
}
