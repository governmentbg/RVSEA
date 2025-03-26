using System.Globalization;

namespace DAA.Shared
{
    public class OperationResult
    {
        private static readonly OperationResult _success = new OperationResult { Succeeded = true };
        private readonly List<string> _errors = new List<string>();

        public bool Succeeded { get; protected set; }
        public bool RawErrors { get; protected set; }
        public object? Data { get; protected set; }

        public int? HResult { get; protected set; }
        public IEnumerable<string> Errors => _errors;

        public static OperationResult Success => _success;

        public static OperationResult Succeed(object data)
        {
            var result = new OperationResult() { Succeeded = true, Data = data };
            return result;
        }

        public static OperationResult Failed(params string[] errors)
        {
            var result = new OperationResult { Succeeded = false, RawErrors = true };
            if (errors != null)
            {
                result._errors.AddRange(errors);
            }
            return result;
        }

        public static OperationResult Failed(int hResult, params string[] errors)
        {
            var result = new OperationResult { Succeeded = false, HResult = hResult, RawErrors = true };
            if (errors != null)
            {
                result._errors.AddRange(errors);
            }
            return result;
        }

        public static OperationResult Failed(bool rawFormat, params string[] errors)
        {
            var result = new OperationResult { Succeeded = false, RawErrors = rawFormat };
            if (errors != null)
            {
                result._errors.AddRange(errors);
            }
            return result;
        }

        public static OperationResult Failed(bool rawFormat, int hResult, params string[] errors)
        {
            var result = new OperationResult { Succeeded = false, HResult = hResult, RawErrors = rawFormat };
            if (errors != null)
            {
                result._errors.AddRange(errors);
            }
            return result;
        }

        public override string ToString()
        {
            return Succeeded ?
                   "Succeeded" :
                   string.Format(CultureInfo.InvariantCulture, "{0} : {1}", "Failed", string.Join(CultureInfo.CurrentCulture.TextInfo.ListSeparator, Errors.ToList()));
        }

        public string ToString(bool rawFormat)
        {
            if (!rawFormat)
            {
                return Succeeded ?
                   "" :
                   string.Join(CultureInfo.CurrentCulture.TextInfo.ListSeparator, Errors.ToList());
            }
            return ToString();
        }
    }
}
