using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Settings
{
    public class TaskTemplateModel
    {
        public int TaskTemplateId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string RelatedContentUrl { get; set; }
        public ICollection<int> ProcessesStepId { get; set; }
    }

    public class TaskTemplateDisplayModel
    {
        public int TaskTemplateId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string RelatedContentUrl { get; set; }
    }

    public class TaskTemplateCreateModel
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public string RelatedContentUrl { get; set; }
        public ICollection<int> ProcessesStepId { get; set; }
    }

    public class TaskTemplateUpdateModel : TaskTemplateCreateModel
    {
        public int TaskTemplateId { get; set; }
    }
}
