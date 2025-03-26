using DAA.Data;
using DAA.Models.Configuration;
using DAA.Services.Interfaces;
using DAA.Shared.Localization;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;
using Task = System.Threading.Tasks.Task;

namespace DAA.Services.Notifications
{
    public class EmailService : BaseService, IEmailService
    {
        private readonly EmailSettings _emailSettings;

        public EmailService(ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IOptions<EmailSettings> emailConfig,
            ILogger<IEmailService> logger)
            : base(context,localizer, logger)
        {
            _emailSettings = emailConfig.Value;
        }

        private MailAddress GetMailAddress()
        {
            return new MailAddress(_emailSettings.SenderEmail!, _emailSettings.SenderName);
        }

        /// <summary>
        /// Create the SmtpClient object
        /// </summary>
        /// <returns></returns>
        private SmtpClient GetSmtpClient()
        {
            var client = new SmtpClient();
            if (!string.IsNullOrEmpty(_emailSettings.MailServer))
            {
                client.Host = _emailSettings.MailServer;
            }
            if(_emailSettings.MailPort.HasValue)
            {
                client.Port = _emailSettings.MailPort.Value;
            }
            client.UseDefaultCredentials = false;
            client.EnableSsl = _emailSettings.EnableSsl ?? false;
            client.Credentials = string.IsNullOrEmpty(_emailSettings.Username) ? null : new NetworkCredential(_emailSettings.Username, _emailSettings.Password);
            
            _logger.LogInformation($"EMAIL SETTINGS: Host {client.Host}, Port: {client.Port}, UserName: {_emailSettings.Username}, password: {_emailSettings.Password}");
            return client;
        }

        public void SendEmail(string to, string cc, string bcc, string subject, string body, IList<byte[]> files = null!)
        {
            if (string.IsNullOrWhiteSpace(to))
            {
                _logger.LogInformation($"{nameof(SendEmail)}: empty TO");
                return;
            }

            //Create the MailMessage instance 
            var myMailMessage = new MailMessage()
            {
                From = GetMailAddress(),
                Subject = subject,
                Body = body,
                IsBodyHtml = true,
                BodyEncoding = Encoding.UTF8,
                SubjectEncoding = Encoding.UTF8
            };
            SmtpClient smtp = null!;

            try
            {
                myMailMessage.To.Add(to);

                if (!string.IsNullOrWhiteSpace(cc))
                {
                    myMailMessage.CC.Add(cc);
                }

                if (!string.IsNullOrWhiteSpace(bcc))
                {
                    myMailMessage.Bcc.Add(bcc);
                }

                if (files != null)
                {
                    foreach (byte[] file in files.Where(x => x.Length > 0))
                    {
                        myMailMessage.Attachments.Add(new System.Net.Mail.Attachment(new MemoryStream(file), "no file name"));
                    }
                }

                smtp = GetSmtpClient();
                smtp.SendCompleted += (s, e) =>
                {
                    // Get the unique identifier for this asynchronous operation.
                    var token = e.UserState;

                    if (e.Cancelled)
                    {
                        Debug.WriteLine("[{0}] Send canceled.", token);
                        _logger.LogInformation(e.Error, $"{nameof(SendEmail)}: send to {to} subject {subject} canceled");
                    }
                    if (e.Error != null)
                    {
                        _logger.LogError(e.Error, $"{nameof(SendEmail)}: send to {to} subject {subject} fail");
                        Debug.WriteLine("[{0}] {1}", token, e.Error.ToString());
                        throw e.Error;
                    }
                    else
                    {
                        Debug.WriteLine("Message sent.");
                        _logger.LogInformation($"{nameof(SendEmail)}: email sent to {to} subject {subject}");
                    }

                    smtp.Dispose();
                    myMailMessage.Dispose();
                };
                //Send the MailMessage (will use the Web.config settings) 
                smtp.Send(myMailMessage);
                _logger.LogInformation($"{nameof(SendEmail)}: sending email to {to} subject {subject}");
            }
            catch (Exception x)
            {
                _logger.LogError(x, $"{nameof(SendEmail)}: error sending email to {to} subject {subject}");
                if (smtp != null)
                    smtp.Dispose();
                if (myMailMessage != null)
                    myMailMessage.Dispose();
                return;
            }
        }

        public async Task<string> SendEmailAsync(string to, string cc, string bcc, string subject, string body, IList<byte[]> files = null!)
        {
            if (string.IsNullOrWhiteSpace(to)) throw new ArgumentNullException("No recipient");

            //Create the MailMessage instance 
            var myMailMessage = new MailMessage()
            {
                From = GetMailAddress(),
                Subject = subject,
                Body = body,
                IsBodyHtml = true,
                BodyEncoding = Encoding.UTF8,
                SubjectEncoding = Encoding.UTF8
            };
            SmtpClient smtp = null!;

            try
            {
                myMailMessage.To.Add(to);

                if (!string.IsNullOrWhiteSpace(cc))
                {
                    myMailMessage.CC.Add(cc);
                }

                if (!string.IsNullOrWhiteSpace(bcc))
                {
                    myMailMessage.Bcc.Add(bcc);
                }

                if (files != null)
                {
                    foreach (byte[] file in files.Where(x => x.Length > 0))
                    {
                        myMailMessage.Attachments.Add(new System.Net.Mail.Attachment(new MemoryStream(file), "no file name"));
                    }
                }

                smtp = GetSmtpClient();
                smtp.SendCompleted += (s, e) =>
                {
                    //Get the unique identifier for this asynchronous operation.
                    var token = e.UserState;


                    if (e.Cancelled)
                    {
                        Debug.WriteLine("[{0}] Send canceled.", token);
                        _logger.LogInformation(e.Error, $"{nameof(SendEmailAsync)}: send to {to} subject {subject} canceled");
                    }
                    if (e.Error != null)
                    {
                        _logger.LogError(e.Error, $"{nameof(SendEmailAsync)}: send to {to} subject {subject} fail");
                        Debug.WriteLine("[{0}] {1}", token, e.Error.ToString());
                        throw e.Error;
                    }
                    else
                    {
                        Debug.WriteLine("Message sent.");
                        _logger.LogInformation($"{nameof(SendEmailAsync)}: email sent to {to} subject {subject}");
                    }

                    smtp.Dispose();
                    myMailMessage.Dispose();
                };
                //Send the MailMessage (will use the Web.config settings) 
                await smtp.SendMailAsync(myMailMessage);
                _logger.LogInformation($"{nameof(SendEmailAsync)}: sending email to {to} subject {subject}");

                return null!;
            }
            catch (Exception e)
            {
                _logger.LogError(e, $"{nameof(SendEmailAsync)}: error sending email to {to} subject {subject}");

                if (smtp != null)
                    smtp.Dispose();
                if (myMailMessage != null)
                    myMailMessage.Dispose();
                var errors = e.InnerException != null ? e.Message + "; " + e.InnerException?.Message : e.Message;
                return errors; // За RecurrentJob е нужно да се знае грешката при пращане
            }
        }

        public async Task SendMassEmailAsync(IEnumerable<string> toArr, string subject, string body, IList<byte[]> files = null!)
        {
            if (toArr == null || !toArr.Any()) throw new ArgumentNullException("No recipients");

            //Create the MailMessage instance 
            var myMailMessage = new MailMessage()
            {
                From = GetMailAddress(),
                Subject = subject,
                Body = body,
                IsBodyHtml = true,
                BodyEncoding = Encoding.UTF8,
                SubjectEncoding = Encoding.UTF8
            };
            SmtpClient smtp = null!;

            try
            {

                foreach (string to in new HashSet<string>(toArr))
                {
                    if (!string.IsNullOrWhiteSpace(to))
                    {
                        myMailMessage.Bcc.Add(to);
                    }
                }

                if (files != null)
                {
                    foreach (byte[] file in files.Where(x => x.Length > 0))
                    {
                        myMailMessage.Attachments.Add(new System.Net.Mail.Attachment(new MemoryStream(file), "no file name"));
                    }
                }

                smtp = GetSmtpClient();
                smtp.SendCompleted += (s, e) =>
                {
                    // Get the unique identifier for this asynchronous operation.
                    var token = e.UserState;

                    if (e.Cancelled)
                    {
                        //TODO Log
                        Debug.WriteLine("[{0}] Send canceled.", token);
                    }
                    if (e.Error != null)
                    {
                        Debug.WriteLine("[{0}] {1}", token, e.Error.ToString());
                    }
                    else
                    {
                        Debug.WriteLine("Message sent.");
                    }

                    smtp.Dispose();
                    myMailMessage.Dispose();
                };

                //Send the MailMessage (will use the Web.config settings) 
                await smtp.SendMailAsync(myMailMessage);
            }
            catch (Exception)
            {
                if (smtp != null)
                    smtp.Dispose();
                if (myMailMessage != null)
                    myMailMessage.Dispose();
                return;
            }

        }
    }
}
