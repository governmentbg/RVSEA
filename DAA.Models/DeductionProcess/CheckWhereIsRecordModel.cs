
namespace DAA.Models.DeductionProcess
{
    public class CheckWhereIsRecordModel
    {
        public bool NotExistInOurSystem { get; set; }
        public bool IsOnlyInOurSystem { get; set; }
        public bool IsInBothOfSystems { get; set; }
    }
}
