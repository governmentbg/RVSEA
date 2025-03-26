using System;
using System.Collections.Generic;

namespace DAA.Data.Files
{
    public partial class VFileContent
    {
        public Guid StreamId { get; set; }
        public string Name { get; set; } = null!;
        public string UncPath { get; set; } = null!;
        public string? FileType { get; set; }
        public long? CachedFileSize { get; set; }
        public DateTimeOffset CreationTime { get; set; }
        public DateTimeOffset LastWriteTime { get; set; }
        public DateTimeOffset? LastAccessTime { get; set; }
        public bool IsDirectory { get; set; }
        public bool IsOffline { get; set; }
        public bool IsHidden { get; set; }
        public bool IsReadonly { get; set; }
        public bool IsArchive { get; set; }
        public bool IsSystem { get; set; }
        public bool IsTemporary { get; set; }
        public byte[]? FileStream { get; set; }
    }
}
