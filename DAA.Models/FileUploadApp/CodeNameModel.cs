namespace DAA.Models.FileUploadApp
{
    public class CodeNameModel
    {
        public CodeNameModel(Guid code, string name)
        {
            Code = code;
            Name = name;
        }

        public Guid Code { get; }

        public string Name { get; }
    }
}

