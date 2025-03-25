using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class SessionType
    {
        public SessionType()
        {
            Sessions = new HashSet<Session>();
        }

        public string Code { get; set; } = null!;
        public string Text { get; set; } = null!;

        public virtual ICollection<Session> Sessions { get; set; }
    }
}
