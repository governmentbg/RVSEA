
namespace DAA.Models.Information
{
    public class CalendarDisplayModel
    {
        public int Id { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string? Title { get; set; }
        public string? Status { get; set; }
    }
}
