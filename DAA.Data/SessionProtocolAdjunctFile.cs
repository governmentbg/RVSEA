using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class SessionProtocolAdjunctFile
    {
        public SessionProtocolAdjunctFile()
        {
            SessionDecisions = new HashSet<SessionDecision>();
            Sessions = new HashSet<Session>();
        }

        public int Id { get; set; }
        public string? FileId { get; set; }
        public string? FilePath { get; set; }
        public string? FileName { get; set; }
        public string? FileType { get; set; }
        public string? ContentType { get; set; }
        public int? FileSizeInMegabytes { get; set; }
        public int? FileLocation { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<SessionDecision> SessionDecisions { get; set; }
        public virtual ICollection<Session> Sessions { get; set; }
    }
}
