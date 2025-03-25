

namespace DAA.Models.Users
{
    public class InternalUserProfileModel : UserProfileModel
    {
        public IEnumerable<int> Archives { get; set; } = Enumerable.Empty<int>();
        public IEnumerable<Guid> Roles { get; set; } = Enumerable.Empty<Guid>();
    }
}
