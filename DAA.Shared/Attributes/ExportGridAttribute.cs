namespace DAA.Shared.Attributes
{
    [AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = false)]
    public class ExportGridAttribute : Attribute
    {
        public bool IsColumnHeader { get; }
        public bool IsColumnDataPropertyName { get; }
        public bool IsColumnType { get; }

        public ExportGridAttribute()
        {
            this.IsColumnHeader = false;
            this.IsColumnDataPropertyName = false;
            this.IsColumnType = false;
        }

        public ExportGridAttribute(bool isColumnHeader, bool isColumnDataPropertyName, bool isColumnType)
        {
            this.IsColumnHeader = isColumnHeader;
            this.IsColumnDataPropertyName = isColumnDataPropertyName;
            this.IsColumnType = isColumnType;
        }

    }
}
