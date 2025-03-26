using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Films
{
    public class FilmPackageDocumentShortModel
    {
        public int Id { get; set; }
        public int PackageId { get; set; }
        public int DocumentTypeId { get; set; }
        public string? DocumentTypeName { get; set; }
        public string? Description { get; set; }
        public string? FileName { get; set; }
        public long? FileSizeInBytes { get; set; }
    }
}
