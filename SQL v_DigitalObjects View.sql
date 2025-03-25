
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER view [dbo].[v_DigitalObjects]
AS

SELECT do.Id
      ,do.SystemIdentifier
	  ,CAST(0 as bit) as IsDraft
	  ,do.IsSuspended
      ,do.ParentId
      ,do.ParentSystemIdentifier
	  ,do.ArchiveId
      ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,NULL as FundDraftId
      ,do.FundSystemIdentifier
      ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,NULL as InventoryDraftId
      ,do.InventorySystemIdentifier
	  ,i.Number as InventoryNumber
	  ,i.HasExternalSource as InventoryHasExternalSource
	  ,i.ExternalIdentifier as InventoryExternalIdentifier
	  ,NULL as ArchivalEntityDraftId
      ,do.ArchivalEntitySystemIdentifier
	  ,ae.Number as ArchivalEntityNumber
	  ,ae.HasExternalSource as ArchivalEntityHasExternalSource
	  ,ae.ExternalIdentifier as ArchivalEntityExternalIdentifier
      ,NULL as DocumentDraftId
	  ,do.DocumentSystemIdentifier
	  ,d.Number as DocumentNumber
	  ,d.HasExternalSource as DocumentHasExternalSource
	  ,d.ExternalIdentifier as DocumentExternalIdentifier
      ,do.CreatedOn
      ,do.CreatedBy
	  ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,do.UpdatedOn
      ,do.UpdatedBy
	  ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,do.Deleted
      ,do.DeletedOn
      ,do.DeletedBy
	  ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,do.ExternalIdentifier
      ,do.HasExternalSource
      ,do.ExternalSourceUpdatedOn
	  ,do.TypeCode
      ,do.Name
      ,do.SourceName
      ,do.UncPath
      ,do.FileType
	  ,do.FileSize
      ,do.StatusCode
      ,do.ContentType
	  ,do.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
	  ,do.WatermarkName
	  ,do.WatermarkUncPath
	  ,do.HashCode
	  ,do.IsImported
  FROM dbo.DigitalObjects do
  JOIN dbo.Archives a ON do.ArchiveId = a.Id
  JOIN dbo.Funds f ON do.FundSystemIdentifier = f.SystemIdentifier
  JOIN dbo.Inventories i ON do.InventorySystemIdentifier = i.SystemIdentifier
  JOIN dbo.ArchivalEntities ae ON do.ArchivalEntitySystemIdentifier = ae.SystemIdentifier 
  JOIN dbo.Documents d ON do.DocumentSystemIdentifier = d.SystemIdentifier
  LEFT JOIN dbo.DigitalObjectDrafts dod on do.SystemIdentifier = dod.SystemIdentifier and dod.IsCurrent = 1
  LEFT JOIN N.AvailabilityStatus ast ON do.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON do.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON do.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON do.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON do.CreatedBy = du.Id
 WHERE dod.Id IS NULL

 UNION

 
 SELECT dod.Id
      ,dod.SystemIdentifier
      ,CAST(1 as bit) as IsDraft
	  ,CAST(0 as bit) as IsSuspended
      ,dod.ParentId
      ,dod.ParentSystemIdentifier
	  ,dod.ArchiveId
	  ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
      ,dod.FundDraftId
      ,dod.FundSystemIdentifier
	  ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,dod.InventoryDraftId
      ,dod.InventorySystemIdentifier
	  ,i.Number as InventoryNumber
	  ,i.HasExternalSource as InventoryHasExternalSource
	  ,i.ExternalIdentifier as InventoryExternalIdentifier
      ,dod.ArchivalEntityDraftId
      ,dod.ArchivalEntitySystemIdentifier
	  ,ae.Number as ArchivalEntityNumber
	  ,ae.HasExternalSource as ArchivalEntityHasExternalSource
	  ,ae.ExternalIdentifier as ArchivalEntityExternalIdentifier
      ,dod.DocumentDraftId
      ,dod.DocumentSystemIdentifier
	  ,d.Number as DocumentNumber
	  ,d.HasExternalSource as DocumentHasExternalSource
	  ,d.ExternalIdentifier as DocumentExternalIdentifier
      ,dod.CreatedOn
      ,dod.CreatedBy
	  ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,dod.UpdatedOn
      ,dod.UpdatedBy
	  ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,dod.Deleted
      ,dod.DeletedOn
      ,dod.DeletedBy
	  ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,dod.ExternalIdentifier
      ,dod.HasExternalSource
      ,dod.ExternalSourceUpdatedOn
	  ,dod.TypeCode
      ,dod.Name
      ,dod.SourceName
      ,dod.UncPath
      ,dod.FileType
	  ,dod.FileSize
      ,dod.StatusCode
      ,dod.ContentType
	  ,dod.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
	  ,dod.WatermarkName
	  ,dod.WatermarkUncPath
	  ,dod.HashCode
	  ,dod.IsImported
  FROM dbo.DigitalObjectDrafts dod
  JOIN dbo.Archives a ON dod.ArchiveId = a.Id
  LEFT JOIN dbo.Funds f ON dod.FundSystemIdentifier = f.SystemIdentifier
  LEFT JOIN dbo.FundDrafts fd ON dod.FundSystemIdentifier = fd.SystemIdentifier AND dod.FundDraftId = fd.Id 
  LEFT JOIN dbo.Inventories i ON dod.InventorySystemIdentifier = i.SystemIdentifier 
  LEFT JOIN dbo.InventoryDrafts id ON dod.InventorySystemIdentifier = id.SystemIdentifier AND dod.InventoryDraftId = id.Id
  LEFT JOIN dbo.ArchivalEntities ae ON dod.ArchivalEntitySystemIdentifier = ae.SystemIdentifier
  LEFT JOIN dbo.ArchivalEntityDrafts aed ON dod.ArchivalEntitySystemIdentifier = aed.SystemIdentifier AND dod.ArchivalEntityDraftId = aed.Id
  LEFT JOIN dbo.Documents d ON dod.DocumentSystemIdentifier = d.SystemIdentifier
  LEFT JOIN dbo.DocumentDrafts dd ON dod.DocumentSystemIdentifier = dd.SystemIdentifier AND dod.DocumentDraftId = dd.Id
  LEFT JOIN N.AvailabilityStatus ast ON dod.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON dod.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON dod.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON dod.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON dod.CreatedBy = du.Id
 WHERE dod.IsCurrent = 1

GO
