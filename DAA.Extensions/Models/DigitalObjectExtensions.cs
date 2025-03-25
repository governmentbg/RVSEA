using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Models.DigitalObjects;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Extensions.Models
{
    public static class DigitalObjectExtensions 
    {
        public static DigitalObjectDisplayModel? ToDisplayModel(this VDigitalObject entity)
        {
            if (entity == null)
            {
                return null;
            }

            DigitalObjectDisplayModel model = new DigitalObjectDisplayModel()
            {
                Id = entity.Id,
                SystemIdentifier = entity.SystemIdentifier,
                ParentId = entity.ParentId,
                ParentSystemIdentifier = entity.ParentSystemIdentifier,
                IsDraft = entity.IsDraft ?? false,
                HasExternalSource = entity.HasExternalSource ?? false,
                ExternalIdentifier = entity.ExternalIdentifier,
                ExternalSourceUpdatedOn = entity.ExternalSourceUpdatedOn.UtcToLocalTime(),
                ArchiveId = entity.ArchiveId,
                ArchiveCode = entity.ArchiveCode,
                ArchiveName = entity.ArchiveName,
                FundDraftId = entity.FundDraftId,
                FundSystemIdentifier = entity.FundSystemIdentifier,
                FundHasExternalSource = entity.FundHasExternalSource ?? false,
                FundExternalIdentifier = entity.FundExternalIdentifier,
                FundNumber = entity.FundNumber,
                InventoryDraftId = entity.InventoryDraftId,
                InventorySystemIdentifier = entity.InventorySystemIdentifier,
                InventoryHasExternalSource = entity.InventoryHasExternalSource ?? false,
                InventoryExternalIdentifier = entity.InventoryExternalIdentifier,
                InventoryNumber = entity.InventoryNumber,
                ArchivalEntityDraftId = entity.ArchivalEntityDraftId,
                ArchivalEntitySystemIdentifier = entity.ArchivalEntitySystemIdentifier,
                ArchivalEntityHasExternalSource = entity.ArchivalEntityHasExternalSource ?? false,
                ArchivalEntityExternalIdentifier = entity.ArchivalEntityExternalIdentifier,
                ArchivalEntityNumber = entity.ArchivalEntityNumber,
                DocumentDraftId = entity.DocumentDraftId,
                DocumentSystemIdentifier = entity.DocumentSystemIdentifier,
                DocumentHasExternalSource = entity.DocumentHasExternalSource ?? false,
                DocumentExternalIdentifier = entity.DocumentExternalIdentifier,
                DocumentNumber = entity.DocumentNumber,
                TypeCode = entity.TypeCode,
                Name = entity.Name,
                SourceName = entity.SourceName,
                FileType = entity.FileType,
                FileSize= entity.FileSize,
                ContentType = entity.ContentType,
                UncPath = entity.UncPath,
                StatusCode = entity.StatusCode!,
                CreatedBy = entity.CreatedBy,
                CreatedByDisplayName = entity.CreatedByDisplayName,
                CreatedByUserName = entity.CreatedByUserName,
                CreatedOn = entity.CreatedOn.UtcToLocalTime(),
                UpdatedBy = entity.UpdatedBy,
                UpdatedByDisplayName = entity.UpdatedByDisplayName,
                UpdatedByUserName = entity.UpdatedByUserName,
                UpdatedOn = entity.UpdatedOn.UtcToLocalTime(),
                Deleted = entity.Deleted,
                DeletedBy = entity.DeletedBy,
                DeletedByDisplayName = entity.DeletedByDisplayName,
                DeletedByUserName = entity.DeletedByUserName,
                DeletedOn = entity.DeletedOn.UtcToLocalTime(),
                WatermarkName = entity.WatermarkName,
                WatermarkUncPath = entity.WatermarkUncPath,
                HashCode = entity.HashCode,
                Duration = entity.Duration,
                IsImported = entity.IsImported,
                IsDigitized = entity.IsDigitized,
                IsSuspended = entity.IsSuspended ?? false,
            };

            return model;
        }
      
    }
}
