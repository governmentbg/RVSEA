using DAA.Data;
using DAA.Models.Settings;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Task = System.Threading.Tasks.Task;

namespace DAA.Services.Settings
{
    public class PackageATemplatesService : BaseService, IPackageATemplatesService
    {
        public PackageATemplatesService(ArchivingContext context, IStringLocalizer<SharedResources> localizer)
           : base(context, localizer)
        {
        }

        public async Task<IQueryable<PackageATemplateModel>> GetTemplatesForApplication(int applicationId)
        {
            int[] relatedProcesses = new int[] 
            { 
                (int)Shared.ProcessType.AddFundAndInventory, 
                (int)Shared.ProcessType.AddInventory, 
                (int)Shared.ProcessType.AddRawFundAndRawInventory, 
                (int)Shared.ProcessType.AddRawInventoryToRawFund,
                (int)Shared.ProcessType.AddSystemInventory,
            };
            var process = await (from i in _context.InventoryDrafts
                                 let p = _context.Processes.Where(x => x.Completed == false
                                                                       && relatedProcesses.Contains(x.ProcessTypeId)
                                                                       && (x.InventorySystemIdentifier == i.SystemIdentifier
                                                                           || x.FundSystemIdentifier == i.FundSystemIdentifier))
                                                           .FirstOrDefault()
                                 where i.ApplicationId == applicationId
                                 && i.IsCurrent
                                 && !i.Deleted
                                 select p).FirstOrDefaultAsync();
            if (process != null)
            {
                return GetTemplates(process.ProcessTypeId);
            }

            return null;
        }

        public IQueryable<PackageATemplateModel> GetTemplatesForSignatureRequest(int packageId, int processId)
        {
            var templates = _context.SignatureRequests
                            .Where(req => req.PackageId == packageId && req.ProcessId == processId && !req.Completed && !req.Deleted)
                            .Select(req => new PackageATemplateModel()
                            {
                                Description = req.PackageDocument.DocType!.Description!,
                                FileId = req.PackageDocument.DocType.DocumentId,
                                FileName = req.PackageDocument.DocType.Document.FileName,
                                Id = req.PackageDocument.DocType.Id,
                                ProcedureId = req.PackageDocument.DocType.ProcedureId,
                                Required = req.PackageDocument.DocType.Required,
                                Sort = req.PackageDocument.DocType.Sort,
                                Title = req.PackageDocument.DocType.Title,
                                Static = req.PackageDocument.DocType.Static ?? false
                            }).Distinct();

           return templates;
        }

        public IQueryable<PackageATemplateModel> GetTemplates(int processId)
        {
            var templates = from t in _context.PackageAdocsTemplates
                            where t.ProcedureId == processId
                            && !t.Deleted
                            orderby t.Sort
                            select new PackageATemplateModel()
                            {
                                Description = t.Description!,
                                FileId = t.DocumentId,
                                FileName = t.Document.FileName,
                                Id = t.Id,
                                ProcedureId = t.ProcedureId,
                                Required = t.Required,
                                Sort = t.Sort,
                                Title = t.Title,
                                Static = t.Static ?? false
                            };

            return templates;
        }

        public async Task<IQueryable<PackageATemplateModel>> GetEmptyPackageTemplatesByInventoryId(int packageId, int processId)
        {
            var process = await _context.Processes.FindAsync(processId);

            if (process != null)
            {
                
                //var usedTemplates = from p in _context.PackageDocuments
                //                    where p.PackageId == packageId
                //                    && !p.Deleted
                //                    && p.DocTypeId.HasValue
                //                    select p.DocTypeId.Value;

                var templates = from t in _context.PackageAdocsTemplates
                                where t.ProcedureId == process.ProcessTypeId
                                && !t.Deleted
                                //&& (usedTemplates != null && !usedTemplates.Contains(t.Id))
                                orderby t.Sort
                                select new PackageATemplateModel()
                                {
                                    Description = t.Description,
                                    FileId = t.DocumentId,
                                    FileName = t.Document.FileName,
                                    Id = t.Id,
                                    ProcedureId = t.ProcedureId,
                                    Required = t.Required,
                                    Sort = t.Sort,
                                    Title = t.Required ? $"{t.Title}*" : t.Title,
                                };

                return templates;
            }

            throw new NullReferenceException("Process not found");
        }


        public PackageATemplateModel GetTemplateById(int id)
        {
            var template = from t in _context.PackageAdocsTemplates
                           where t.Id == id
                           && !t.Deleted
                           select new PackageATemplateModel()
                           {
                               Description = t.Description,
                               FileId = t.DocumentId,
                               FileName = t.Document.FileName,
                               Id = t.Id,
                               ProcedureId = t.ProcedureId,
                               Required = t.Required,
                               Sort = t.Sort,
                               Title = t.Title,
                           };

            return template.FirstOrDefault();
        }

        public async Task<int> AddTemplate(PackageATemplateCreateModel model)
        {
            Data.File f = new Data.File();

            using (var stream = new MemoryStream())
            {
                await model.File.CopyToAsync(stream);

                f.FileName = model.File.FileName;
                f.ContentType = model.File.ContentType;
                f.FileType = model.File.FileName.Split('.').Last();
                f.Content = stream.ToArray();
            }

            PackageAdocsTemplate template = new()
            {
                ProcedureId = model.ProcedureId,
                Sort = model.Sort,
                Required = model.Required,
                Title = model.Title,
                Document = f,
                Description = model.Description,
                Static = model.Static,
            };

            _context.Files.Add(f);
            _context.PackageAdocsTemplates.Add(template);
            await _context.SaveAsync($"Package A template added to procedure ID {model.ProcedureId}");
            return template.Id;
        }


        public async Task RemoveTemplate(int id)
        {
            var template = await _context.PackageAdocsTemplates.FindAsync(id);

            if (template != null)
            {
                template.Deleted = true;
                await _context.SaveAsync($"Template ID {id} deleted");
            }
        }

        public async Task UpdateTemplate(PackageATemplateUpdateModel model)
        {
            PackageAdocsTemplate template = await _context.PackageAdocsTemplates.FindAsync(model.Id);
            if (template == null)
            {
                throw new NullReferenceException($"Template with ID {model.Id} not found");
            }

            template.Sort = model.Sort;
            template.Title = model.Title;
            template.Required = model.Required;
            template.Description = model.Description;

            if (model.File != null)
            {
                //Delete old file
                var oldFile = await _context.Files.FindAsync(template.DocumentId);
                if (oldFile != null)
                {
                    oldFile.Deleted = true;
                }

                //Add new file
                Data.File f = new Data.File();

                using (var stream = new MemoryStream())
                {
                    await model.File.CopyToAsync(stream);

                    f.FileName = model.File.FileName;
                    f.ContentType = model.File.ContentType;
                    f.FileType = model.File.FileName.Split('.').Last();
                    f.Content = stream.ToArray();
                }

                _context.Files.Add(f);
                template.Document = f;
            }

            await _context.SaveAsync($"Package A template ID {model.Id} updated");
        }

        public async Task<Data.File> GetFile(int templateId)
        {
            var file = from t in _context.PackageAdocsTemplates
                       where t.Id == templateId && !t.Deleted
                       select t.Document;

            return await file.FirstOrDefaultAsync();
        }
    }
}
