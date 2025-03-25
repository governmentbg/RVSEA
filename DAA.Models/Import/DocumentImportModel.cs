using DAA.Shared.Attributes;
using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Import
{
    public class DocumentImportModel
    {
        //[ExportTemplate("Номер на архивна единица")]
        //[Required]
        //[Range(1, int.MaxValue)]
        //public int ArchivalEntityNumber { get; set; }

        [ExportTemplate("Номер на архивна единица")]
        [Required(AllowEmptyStrings = false, ErrorMessage = "Поле Номер на архивна единица е задължително")]
        public string? ArchivalEntityNumber { get; set; }


        [ExportTemplate("Номер на документ")]
        [Required(AllowEmptyStrings = false, ErrorMessage = "Поле Номер на документ е задължително")]
        [Range(1, int.MaxValue, ErrorMessage = "Поле Номер на документ трябва да е цяло число, по-голямо от 0")]
        public int DocumentNumber { get; set; }

        [ExportTemplate("Означение/Шифър")]
        public string? Cypher { get; set; }


        [ExportTemplate("Заглавие на документ")]
        [Required(AllowEmptyStrings = false, ErrorMessage = "Поле Заглавие на документ е задължително")]
        public string? Title { get; set; }

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



        [ExportTemplate("Място на създаване")]
        public string? Location { get; set; }

        [ExportTemplate("Брой е-документи текстови")]
        [Range(0, int.MaxValue, ErrorMessage = "Поле Брой е-документи текстови трябва да е цяло число по-голямо от 0")]
        public int? TextDocsCount { get; set; }

        [ExportTemplate("Брой е-документи графични")]
        [Range(0, int.MaxValue, ErrorMessage = "Поле Брой е-документи графични трябва да е цяло число по-голямо от 0")]
        public int? GraphicalDocsCount { get; set; }

        [ExportTemplate("Друго")]
        [MaxLength(256, ErrorMessage = "Поле Друго може да е най-много 256 символа")]
        public string? OtherMetrics { get; set; }

        [ExportTemplate("Създател/Институция/Автор")]
        public string? Author { get; set; }

        [ExportTemplate("Мащаб")]
        [MaxLength(256, ErrorMessage = "Поле Мащаб може да е най-много 256 символа")]
        public string? Scaling { get; set; }

        [ExportTemplate("Стадий")]
        public string? Stage { get; set; }

        [ExportTemplate("Разширено описание на съдържанието")]
        public string? Description { get; set; }

        [ExportTemplate("Език", Shared.ExcelDropDownListType.Language, true, "LanguageCodes")]
        public string? Language { get; set; }

        [ExportTemplate("Друго (език)")]
        public string? OtherLanguage { get; set; }

        [ExportTemplate("Условия на достъп")]
        public string? AccessConditions { get; set; }

        [ExportTemplate("Особености")]
        public string? Features { get; set; }

        [ExportTemplate("Забележка")]
        public string? Note { get; set; }

        [ExportTemplate("Фаза")]
        public string? Phase { get; set; }

        [ExportTemplate("Част")]
        public string? Part { get; set; }


        [ExportTemplate("Автор на описанието")]
        [Required(ErrorMessage = "Поле Автор на описанието трябва да бъде попълнено")]
        [MaxLength(250, ErrorMessage = "Поле Автор на описанието може да е най-много 250 символа")]
        public string? DescriptionAuthor { get; set; }


        public IEnumerable<PackageImportModel> PackageFiles { get; set; }
        public IEnumerable<string>? LanguageCodes { get; set; }
        public Guid? SystemIdentifier { get; set; }


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


        public List<int> PackageFileIds
        {
            get
            {
                if(PackageFiles != null && PackageFiles.Count() > 0)
                {
                    return PackageFiles.Select(x => x.Number).ToList();
                }

                return new List<int>();
            }
        }
    }
}
