namespace DAA.Extensions.Exceptions
{
    public class DBRequestTimeoutException : Exception
    {
        public DBRequestTimeoutException(string msg = "DBRequestTimeout")
            : base(msg)
        { }
    }
}
