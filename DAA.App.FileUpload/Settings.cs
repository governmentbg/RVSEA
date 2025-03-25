using DAA.Models.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Net.WebRequestMethods;

namespace DAA.App.FileUpload
{
    public static class Settings
    {
        //local
        public static readonly string WebServiceBaseAddress = "https://localhost:44308/";

        // Kestrel
        //public static readonly string WebServiceBaseAddress = "https://localhost:7238/";

        //AppTest
        //public static string WebServiceBaseAddress = "https://apptest.kontrax.bg/DAAIntranet/";

        //AppTest - Demo
        //public static string WebServiceBaseAddress = "https://apptest.kontrax.bg/DAAIntranetDemo/";

        //SEA production
        //public static readonly string WebServiceBaseAddress = "https://sea-internal.archives.government.bg/";

        public static readonly string UserNameLocalhost = "kontrax\\ttest";
        public static readonly string PasswordLocalhost = "Kontrax1234&";

        public static readonly string UserNameAppTest = "APPTEST\\MDimitrova";
        public static readonly string PasswordAppTest = "kontrax";


        public static readonly string AuthenticateUrl = "api/Account/authenticate";
        public static readonly string AuthorizeUrl = "api/FileUploadApp/authorize";

        public static readonly string DocumentExistsUrl = "api/FileUploadApp/documentExists";
        public static readonly string FileExistsUrl = "api/FileUploadApp/fileExists";
        public static readonly string MastersForDocumentUrl = "api/FileUploadApp/mastersForDocument";
        
        public static readonly string GetExtensionsUrl = "api/FileUploadApp/getExtensions";

        public static readonly string ListQueueUrl = "api/FileUploadApp/list";
        public static readonly string AddToQueueUrl = "api/FileUploadApp/addToQueue";
        public static readonly string UpdateQueueUrl = "api/FileUploadApp/updateQueue";
        public static readonly string DeleteFromQueueUrl = "api/FileUploadApp/deleteFromQueue";

        public static readonly string UploadFileUrl = "api/FileUploadApp/upload";
        public static readonly string ValidateAndFinishUrl = "api/FileUploadApp/validateAndFinish";


        public static bool CanQueueEd { get; set; }
        public static bool CanQueueKmf { get; set; }
        public static bool CanQueueFund { get; set; }
        public static bool CanQueueRaw { get; set; }

        public static FileUploaderAppSettings AppSettings = null!;
    }
}
