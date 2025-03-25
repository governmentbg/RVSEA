using DAA.Shared;
using HtmlAgilityPack;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.FileUploadApp
{
    public class ChecksumsVerifyResultModel : OperationResultModel
    {
        public ChecksumVerifyProcessModel[] Processes { get; set; } = null!;
    }

    public class ChecksumVerifyProcessModel
    {
        public ProcessKind ProcessKind { get; set; }
        public string? ProcessName { get; set; }

        public string Summary { get; set; } = null!;

        public ChecksumVerifyItemModel[] Items { get; set; } = null!;
    }

    public class ChecksumVerifyItemModel
    {
        public string DocumentIdentifier { get; set; } = null!;
        public string Identifier { get; set; } = null!;
        public string FileName { get; set; } = null!;

        [JsonIgnore]
        public bool IsMaster { get; set; }

        [JsonIgnore]
        public string UncFileName { get; set; } = null!;

        [JsonIgnore]
        public string? ChecksumDb { get; set; }

        public bool? Success { get; set; } // null, ако файлът не може да бъде проверен - няма записана чексума
        public string? Message { get; set; }
    }

    public class ChecksumVerifyFileModel
    {
        public FileStreamLocation Location { get; set; }
        public string Identifier { get; set; }
        public string UncFileName { get; set; }
        public string? ChecksumDb { get; set; }
        public string? ChecksumCalc { get; set; }

        public bool? Success { get; set; } // null, ако файлът не може да бъде проверен - няма записана чексума
        public string? Message { get; set; }

        public ChecksumVerifyFileModel(FileStreamLocation location, string identifier, string uncFileName, string? checksumDb)
        {
            Location = location;
            Identifier = identifier;
            UncFileName = uncFileName;
            ChecksumDb = checksumDb;
        }

        private string SuccessStr
        {
            get
            {
                return
                    Success == true ? "Ок" :
                    Success == false ? "Грешка" :
                    "--";
            }
        }
        public override string ToString()
        {
            return $"{Location}: {SuccessStr} {Message}";
        }
    }
}