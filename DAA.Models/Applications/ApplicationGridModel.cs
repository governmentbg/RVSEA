using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Applications
{
    public class ApplicationGridModel
    {
        public int Id { get; set; }
        public int Number { get; set; }
        public string Applicant { get; set; }
        public string Archive { get; set; }
        public string Type { get; set; }
        public string TypeId { get; set; }
        public string DocumentOriginType { get; set; }
        public string DocumentOriginTypeId { get; set; }
        public DateTime ApplicationDate { get; set; }
        public string Status { get; set; }
        public int StatusId { get; set; }
        public string Organization { get; set; }
    }
}
