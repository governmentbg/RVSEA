using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Applications
{
    public class ApplicationDisplayModel
    {
        public int Id { get; set; }
        public int Number { get; set; }
        public string ApplicantFullName { get; set; }
        public string ApplicantEmail { get; set; }
        public string ApplicantPhone { get; set; }
        public string Address { get; set; }
        public string Organization { get; set; }
        public string OrganizationRepresentative { get; set; }
        public string OrganizationEIK { get; set; }
        public string Archive { get; set; }
        public int ArchiveId { get; set; }
        public string Type { get; set; }
        public string TypeId { get; set; }
        public DateTime ApplicationDate { get; set; }
        public string Status { get; set; }
        public int StatusId { get; set; }
        public string FileName { get; set; }
        public int FileId { get; set; }
        public string? RejectReason { get; set; }
        public string DocumentsOwner { get; set; }
        public int DocumentsSize { get; set; }
        public string DocumentsPeriod { get; set; }
        public string DocumentsOriginType { get; set; }
        public string? RedirectedFromArchiveName { get; set; }
        public string? RedirectedToArchiveName { get; set; }
        public string? PackageARejectReason { get; set; }
        public string? PackageBRejectReason { get; set; }

        public string? FundNumber { get; set; }
        public string? FundSysId { get; set; }
        public string? InventorySysId { get; set; }
    }
}
