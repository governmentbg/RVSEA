using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Services.Interfaces
{
    public interface IEmailService
    {
        void SendEmail(string to, string cc, string bcc, string subject, string body, IList<byte[]> files = null!);
        Task<string> SendEmailAsync(string to, string cc, string bcc, string subject, string body, IList<byte[]> files = null!);
        Task SendMassEmailAsync(IEnumerable<string> toArr, string subject, string body, IList<byte[]> files = null!);
    }
}
