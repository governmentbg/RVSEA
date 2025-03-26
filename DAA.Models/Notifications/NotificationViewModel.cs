
namespace DAA.Models.Notifications
{
    public class NotificationViewModel
    {
        public int Id { get; set; }
        public Guid ToUserId { get; set; }
        public string To { get; set; }
        public string Subject { get; set; }
        public string Body { get; set; }
        public DateTime CreatedOn { get; set; }
        public DateTime? SentOn { get; set; }
        public bool IsSeen { get; set; }
        public bool IsSent { get; set; }
    }
}
