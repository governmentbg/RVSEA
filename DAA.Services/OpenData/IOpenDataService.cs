namespace DAA.Services.OpenData
{
    public interface IOpenDataService
    {
        Task<string> Sync(CancellationToken cancellationToken);
    }
}
