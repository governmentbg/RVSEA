using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Films
{
    public class FilmPackageDocumentUpdateModel : FilmPackageDocumentCreateModel
    {
        public int Id { get; set; }
    }
}
