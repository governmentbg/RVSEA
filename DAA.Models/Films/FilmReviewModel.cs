using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Films
{
    public class FilmReviewModel
    {
        //public int Id { get; set; }
        public Guid SystemIdentifier { get; set; }
        public string ReaderName { get; set; } = null!;
        public Guid FilmSystemIdentifier { get; set; }
        public Guid UserId { get; set; }
        public bool AccessAllowed { get; set; }
        public bool Deleted { get; set; }
    }
}
