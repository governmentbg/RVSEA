using DAA.Data;
using DAA.Models.Settings;
using DAA.Shared.Localization;
using Microsoft.Extensions.Localization;
using Task = System.Threading.Tasks.Task;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using DAA.Extensions.Exceptions;
using Microsoft.AspNetCore.Mvc;
using DAA.Shared;

namespace DAA.Services.Settings
{
    public class TaskTemplatesService : BaseService, ITaskTemplatesService
    {
        public TaskTemplatesService(ArchivingContext context, IStringLocalizer<SharedResources> localizer)
           : base(context, localizer)
        {
        }

        public IQueryable<TaskTemplateDisplayModel> GetTemplates(int processStepId)
        {
            var templates = _context.TaskTemplates
                                    .Where(tt => tt.ProcessSteps.Any(ps => ps.Id == processStepId))
                                    .Select(tt => new TaskTemplateDisplayModel()
                                    {
                                        TaskTemplateId = tt.Id,
                                        Title = tt.Title,
                                        Description = tt.Description,
                                        RelatedContentUrl = tt.RelatedContentUrl
                                    });

            /*if (templates.Count() == 0)
            {
                throw new NullReferenceException($"No templates found for step with ID {processStepId}");
            }*/

            return templates;
        }

        public TaskTemplateModel GetTemplateById(int id)
        {
            var template = _context.TaskTemplates
                                   .Where(tt => tt.Id == id)
                                   .Select(tt => new TaskTemplateModel()
                                   {
                                       TaskTemplateId = tt.Id,
                                       Title = tt.Title,
                                       Description = tt.Description,
                                       RelatedContentUrl = tt.RelatedContentUrl,
                                       ProcessesStepId = tt.ProcessSteps
                                                           .Select(pt => pt.Id)
                                                           .ToList()
                                   })
                                   .FirstOrDefault();

            /*if (template == null)
            {
                throw new NullReferenceException($"Template with ID {id} not found");
            }*/

            return template;
        }

        public async Task<OperationResult> AddTemplate(TaskTemplateCreateModel model)
        {
            if (model.ProcessesStepId.Count() == 0)
            {
                throw new NullReferenceException($"No steps given");
            }

            if(model.Title.Trim().Length == 0)
            {
                throw new NullReferenceException($"No title given");
            }

            if (model.Description.Trim().Length == 0)
            {
                throw new NullReferenceException($"No description given");
            }

            model.Description = $"<p>{model.Description}</p>";

            var existTemplate = _context.TaskTemplates.Where(t => t.ProcessSteps.Any(s => model.ProcessesStepId.Contains(s.Id))).FirstOrDefault();

            if (existTemplate != null)
            {
                return OperationResult.Failed("");
            }

            List<ProcessStep> processSteps = _context.ProcessSteps
                                             .Where(ps => model.ProcessesStepId.Contains(ps.Id))
                                             .ToList();

            TaskTemplate template = new ()
            {
                Title = model.Title,
                Description = model.Description,
                RelatedContentUrl = model.RelatedContentUrl,
                ProcessSteps = processSteps
            };

            _context.TaskTemplates.Add(template);
            await _context.SaveAsync($"Task template added with ID {template.Id}");

            return OperationResult.Succeed(template.Id);
        }

        public async Task UpdateTemplate(TaskTemplateUpdateModel model)
        {
            if (model.ProcessesStepId.Count() == 0)
            {
                throw new NullReferenceException($"No steps given");
            }

            if (model.Title.Trim().Length == 0)
            {
                throw new NullReferenceException($"No title given");
            }

            if (model.Description.Trim().Length == 0)
            {
                throw new NullReferenceException($"No description given");
            }

            TaskTemplate? template = await _context.TaskTemplates.Include(i => i.ProcessSteps).FirstOrDefaultAsync(i => i.Id == model.TaskTemplateId);

            if (template == null)
            {
                throw new ItemNotFoundException($"Template with ID {model.TaskTemplateId} not found");
            }


            template.Title = model.Title;
            template.Description = model.Description;
            template.RelatedContentUrl = model.RelatedContentUrl;

            List<ProcessStep> processSteps = _context.ProcessSteps
                                              .Where(ps => model.ProcessesStepId.Contains(ps.Id)).ToList();

            template.ProcessSteps = processSteps;
            _context.TaskTemplates.Update(template);

            await _context.SaveAsync($"Package A template ID {model.TaskTemplateId} updated");
        }
    }
}
