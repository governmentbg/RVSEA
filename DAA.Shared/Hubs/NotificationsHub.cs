using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace DAA.Shared.Hubs
{
    [Authorize]
    public class NotificationsHub : Hub<INotificationsHub>
    {
    }
}
