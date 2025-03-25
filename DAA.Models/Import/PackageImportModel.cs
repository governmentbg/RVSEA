using DAA.Shared.Attributes;
using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Import
{
    public class PackageImportModel
    {
        [ExportTemplate("Номер на файл")]
        [Required(ErrorMessage = "Поле Номер на файл е задължително")]
        [Range(1, int.MaxValue, ErrorMessage = "Поле Номер на файл трябва да е цяло число по-голямо от 1")]
        public int Number { get; set; }

        [ExportTemplate("Номер на документ")]
        [Required(ErrorMessage = "Поле Номер на документ е задължително")]
        public int DocumentNumber { get; set; }

        public Guid? SystemIdentifier { get; set; }

    }
}
