using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined
    {
        public string? EmployeeRowName { get; set; }
        public int? EmployeeKMFCount { get; set; }
        public int? EmployeeAECount { get; set; }
        public int? EmployeeElDocsCount { get; set; }
        public double? EmployeeElDocsMB { get; set; }
        public string? ReaderRowName { get; set; }
        public int? ReaderKMFCount { get; set; }
        public int? ReaderAECount { get; set; }
        public int? ReaderElDocsCount { get; set; }
        public double? ReaderElDocsMB { get; set; }
        public string? TotalRowName { get; set; }
        public int? TotalKMFCount { get; set; }
        public int? TotalAECount { get; set; }
        public int? TotalElDocsCount { get; set; }
        public long? TotalElDocsMB { get; set; }
/*        public string? RowName { get; set; }
        public int? KmfCount { get; set; }
        public int? AeCount { get; set; }
        public int? ElDocsCount { get; set; }
        public string? ElDocsMB { get; set; }*/
    }
}
