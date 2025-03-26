USE DAA
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER view [dbo].[v_FundReconstructions]
AS

SELECT fr.Id
      ,fr.ProcessId
	  ,fr.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
      ,fr.ArchiveId
      ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,fr.FundSystemIdentifier
	  ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,fr.CreatedOn
      ,fr.CreatedBy
	  ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,fr.UpdatedOn
      ,fr.UpdatedBy
	  ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,fr.Deleted
      ,fr.DeletedOn
      ,fr.DeletedBy
	  ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,fr.SourceInventorySystemIdentifier
	  ,sinv.Number as SourceInventoryNumber
	  ,sinv.DescriptionLevelCode as SourceInventoryDescriptionLevelCode
	  ,sinv.DescriptionLevelText as SourceInventoryDescriptionLevelText
	  ,sinv.AvailabilityStatusCode as SourceInventoryAvailabilityStatusCode
	  ,sinv.AvailabilityStatusText as SourceInventoryAvailabilityStatusText
	  ,sinv.ApproxmateChronologicalScope as SourceInventoryApproximateChronologicalScope
	  ,sinv.HasExternalSource as SourceInventoryHasExternalSource
	  ,sinv.ExternalIdentifier as SourceInventoryExternalIdentifier
      ,fr.SourceArchivalEntitySystemIdentifier
	  ,sae.Number as SourceArchivalEntityNumber
	  ,sae.Title as SourceArchivalEntityTitle
	  ,sae.DescriptionLevelCode as SourceArchivalEntityDescriptionLevelCode
	  ,sae.DescriptionLevelText as SourceArchivalEntityDescriptionLevelText
	  ,sae.AvailabilityStatusCode as SourceArchivalEntityAvailabilityStatusCode
	  ,sae.AvailabilityStatusText as SourceArchivalEntityAvailabilityStatusText
	  ,sae.ApproxmateChronologicalScope as SourceArchivalEntityApproximateChronologicalScope
	  ,sae.HasExternalSource as SourceArchivalEntityHasExternalSource
	  ,sae.ExternalIdentifier as SourceArchivalEntityExternalIdentifier
      ,fr.SourceDocumentSystemIdentifier
	  ,sd.Title as SourceDocumentTitle
	  ,sd.DescriptionLevelCode as SourceDocumentDescriptionLevelCode
	  ,sd.DescriptionLevelText as SourceDocumentDescriptionLevelText
	  ,sd.AvailabilityStatusCode as SourceDocumentAvailabilityStatusCode
	  ,sd.AvailabilityStatusText as SourceDocumentAvailabilityStatusText
	  ,sd.ApproxmateChronologicalScope as SourceDocumentApproxmateChronologicalScope
	  ,sd.HasExternalSource as SourceDocumentHasExternalSource
	  ,sd.ExternalIdentifier as SourceDocumentExternalIdentifier
      ,fr.TargetInventorySystemIdentifier
	  ,tinv.Number as TargetInventoryNumber
	  ,tinv.DescriptionLevelCode as TargetInventoryDescriptionLevelCode
	  ,tinv.DescriptionLevelText as TargetInventoryDescriptionLevelText
	  ,tinv.AvailabilityStatusCode as TargetInventoryAvailabilityStatusCode
	  ,tinv.AvailabilityStatusText as TargetInventoryAvailabilityStatusText
	  ,tinv.ApproxmateChronologicalScope as TargetInventoryApproximateChronologicalScope
      ,fr.TargetArchivalEntitySystemIdentifier
	  ,tae.Number as TargetArchivalEntityNumber
	  ,tae.Title as TargetArchivalEntityTitle
	  ,tae.DescriptionLevelCode as TargetArchivalEntityDescriptionLevelCode
	  ,tae.DescriptionLevelText as TargetArchivalEntityDescriptionLevelText
	  ,tae.AvailabilityStatusCode as TargetArchivalEntityAvailabilityStatusCode
	  ,tae.AvailabilityStatusText as TargetArchivalEntityAvailabilityStatusText
	  ,tae.ApproxmateChronologicalScope as TargetArchivalEntityApproximateChronologicalScope
	  ,tae.HasExternalSource as TargetArchivalEntityHasExternalSource
	  ,tae.ExternalIdentifier as TargetArchivalEntityExternalIdentifier
      ,fr.TargetDocumentSystemIdentifier
	  ,td.Title as TargetDocumentTitle
	  ,td.DescriptionLevelCode as TargetDocumentDescriptionLevelCode
	  ,td.DescriptionLevelText as TargetDocumentDescriptionLevelText
	  ,td.AvailabilityStatusCode as TargetDocumentAvailabilityStatusCode
	  ,td.AvailabilityStatusText as TargetDocumentAvailabilityStatusText
	  ,td.ApproxmateChronologicalScope as TargetDocumentApproxmateChronologicalScope
	  ,td.HasExternalSource as TargetDocumentHasExternalSource
	  ,td.ExternalIdentifier as TargetDocumentExternalIdentifier
      
  FROM dbo.FundReconstructions fr
  JOIN dbo.Archives a ON fr.ArchiveId = a.Id
  JOIN dbo.v_Funds f ON fr.FundSystemIdentifier = f.SystemIdentifier
  LEFT JOIN v_Inventories sinv ON fr.SourceInventorySystemIdentifier = sinv.SystemIdentifier
  LEFT JOIN v_ArchivalEntities sae ON fr.SourceArchivalEntitySystemIdentifier = sae.SystemIdentifier
  LEFT JOIN v_Documents sd ON fr.SourceDocumentSystemIdentifier = sd.SystemIdentifier
  LEFT JOIN v_Inventories tinv ON fr.TargetInventorySystemIdentifier = tinv.SystemIdentifier
  LEFT JOIN v_ArchivalEntities tae ON fr.TargetArchivalEntitySystemIdentifier = tae.SystemIdentifier
  LEFT JOIN v_Documents td ON fr.TargetDocumentSystemIdentifier = td.SystemIdentifier
  LEFT JOIN N.AvailabilityStatus ast ON fr.AvailabilityStatusCode = ast.Code
  LEFT JOIN dbo.AspNetUsers cu ON fr.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON fr.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON fr.CreatedBy = du.Id

GO

