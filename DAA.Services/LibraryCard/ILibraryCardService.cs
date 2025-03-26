namespace DAA.Services.LibraryCardService
{
    public interface ILibraryCardService
    {
        Task<bool> IsValid(string number);
        Task<bool> IsValidCardOfCurrentUser(Guid? userId = null);
        Task<bool> IsExpiringInAWeekCurrentUser(Guid? userId = null);
    }
}
