namespace DAA.Models.FileUploadApp
{
    public class FileCheckResultModel
    {
        public bool? ChecksumCheckResult { get; set; }
        public bool? FileFormatCheckResult { get; set; }
        public bool? AntivirusCheckResult { get; set; }
        public string? AntivirusCheckInfo { get; set; }
        public string? FileInfo { get; set; }
        public string? ErrorMessage { get; set; }
    }
}
