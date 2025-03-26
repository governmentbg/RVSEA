namespace DAA.Services.ApplicationStore
{
    public interface IApplicationStoreService
    {
        string? GetApplicationBaseUrl(string requestId);
        void SetApplicationBaseUrl(string requestId, string url);
        string? GetEmail(string requestId);
        void SetEmail(string requestId, string? email);
        void Clear(string requestId);
    }
}
