SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE OR ALTER view [dbo].[v_Documents]
AS

SELECT d.Id
	  ,d.SystemIdentifier
      ,CAST(0 as bit) as IsDraft
	  ,d.IsSuspended
      ,d.ArchiveId
      ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,NULL as FundDraftId
      ,d.FundSystemIdentifier
      ,f.Number as FundNumber
	  ,f.NumberNumeric as FundNumberNumeric
	  ,f.NumberArray as FundNumberArray
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
	  ,f.DescriptionLevelCode as FundDescriptionLevelCode
	  ,f.StatusCode as FundStatusCode
      ,NULL as InventoryDraftId
      ,d.InventorySystemIdentifier
	  ,i.Number as InventoryNumber
	  ,i.NumberNumeric as InventoryNumberNumeric
	  ,i.NumberArray as InventoryNumberArray
	  ,i.HasExternalSource as InventoryHasExternalSource
	  ,i.ExternalIdentifier as InventoryExternalIdentifier
	  ,i.AvailabilityStatusCode  as InventoryAvailabilityStatusCode
	  ,i.DescriptionLevelCode as InventoryDescriptionLevelCode
	  ,i.StatusCode as InventoryStatusCode
	  ,NULL as ArchivalEntityDraftId
      ,d.ArchivalEntitySystemIdentifier
	  ,ae.Number as ArchivalEntityNumber
	  ,ae.NumberNumeric AS ArchivalEntityNumberNumeric
	  ,ae.NumberArray as ArchivalEntityNumberArray
	  ,ae.HasExternalSource as ArchivalEntityHasExternalSource
	  ,ae.ExternalIdentifier as ArchivalEntityExternalIdentifier
	  ,ae.AvailabilityStatusCode as ArchivalEntityAvailabilityStatusCode
	  ,ae.DescriptionLevelCode as ArchivalEntityDescriptionLevelCode
	  ,ae.StatusCode as ArchivalEntityStatusCode
	  ,d.CreatedOn
      ,d.CreatedBy
      ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,d.UpdatedOn
      ,d.UpdatedBy
      ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,d.Deleted
      ,d.DeletedOn
      ,d.DeletedBy
      ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,d.HasExternalSource
      ,d.ExternalIdentifier
      ,d.ExternalSourceUpdatedOn
      ,d.Number
      ,d.Title
      ,d.DescriptionLevelCode
	  ,l.Text as DescriptionLevelText
	  ,d.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
      ,d.StatusCode
	  ,s.Text as StatusText
	  ,d.FileFormatCode
	  ,d.HasNoChronologicalScope
	  ,d.StartDateYear
	  ,d.StartDateMonth
	  ,d.StartDateDay
	  ,d.EndDateYear
	  ,d.EndDateMonth
	  ,d.EndDateDay
	  ,d.ApproxmateChronologicalScope
	  ,d.Author
	  ,d.Location
	  ,d.Bytes
	  ,d.SheetCount
	  ,d.StartSheetNumber
	  ,d.EndSheetNumber
	  ,d.DigitalDevice
	  ,d.OtherMetrics
	  ,d.SizeCm
	  ,d.Scaling
	  ,d.Duration
	  ,d.Description
	  ,d.DocumentsAccessDescription
	  ,d.Features
	  ,d.MicrofilmedCopyCount
	  ,d.DigitizedCopyCount
	  ,d.PaperCopyCount
	  ,d.NegativeFrameCount
	  ,d.PositiveFrameCount
	  ,d.OtherCopyCount
	  ,d.Transcription
	  ,d.Notes
	  ,d.IsImported
	  ,d.DescriptionAuthor
	  ,d.Cypher
	  ,d.TextDocsCount
	  ,d.GraphicalDocsCount
	  ,d.Phase
	  ,d.Part
	  ,d.Stage
	  ,d.OtherLanguage
	  , case when (select IsNull(count(A.Id),0) from v_DigitalObjects A 
				  where A.DocumentSystemIdentifier = d.SystemIdentifier 
				  and A.IsDraft = 0 
				  and A.IsDigitized = 1) > 0 
			 then 1 else 0 end as HasDigitizedDigitalObjects

  FROM dbo.Documents d
  JOIN dbo.Archives a ON d.ArchiveId = a.Id
  JOIN dbo.Funds f ON d.FundSystemIdentifier = f.SystemIdentifier
  JOIN dbo.Inventories i ON d.InventorySystemIdentifier = i.SystemIdentifier
  JOIN dbo.ArchivalEntities ae ON d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier 
  LEFT JOIN dbo.DocumentDrafts dd on d.SystemIdentifier = dd.SystemIdentifier and dd.IsCurrent = 1
  LEFT JOIN N.DocumentDescriptionLevel l ON d.DescriptionLevelCode = l.Code
  LEFT JOIN N.AvailabilityStatus ast ON d.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON d.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON d.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON d.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON d.CreatedBy = du.Id
 WHERE dd.Id IS NULL


 UNION

 
 SELECT dd.Id
	   ,dd.SystemIdentifier
       ,CAST(1 as bit) as IsDraft
	   ,CAST(0 as bit) as IsSuspended
       ,dd.ArchiveId
       ,a.Code as ArchiveCode
	   ,a.Name as ArchiveName
	   ,dd.FundDraftId
       ,dd.FundSystemIdentifier
       ,f.Number as FundNumber
	   ,f.NumberNumeric AS FundNumberNumeric
	   ,f.NumberArray as FundNumberArray
	   ,f.HasExternalSource as FundHasExternalSource
	   ,f.ExternalIdentifier as FundExternalIdentifier
	   ,f.DescriptionLevelCode as FundDescriptionLevelCode
	   ,f.StatusCode as FundStatusCode
       ,dd.InventoryDraftId
       ,dd.InventorySystemIdentifier
	   ,i.Number as InventoryNumber
	   ,i.NumberNumeric AS InventoryNumberNumeric
	   ,i.NumberArray as InventoryNumberArray
	   ,i.HasExternalSource as InventoryHasExternalSource
	   ,i.ExternalIdentifier as InventoryExternalIdentifier
	   ,i.AvailabilityStatusCode as InventoryAvailabilityStatusCode
	   ,i.DescriptionLevelCode as InventoryDescriptionLevelCode
	   ,i.StatusCode as InventoryStatusCode
	   ,dd.ArchivalEntityDraftId
       ,dd.ArchivalEntitySystemIdentifier
	   ,ae.Number as ArchivalEntityNumber
	   ,ae.NumberNumeric AS ArchivalEntityNumberNumeric
	   ,ae.NumberArray as ArchivalEntityNumberArray
	   ,ae.HasExternalSource as ArchivalEntityHasExternalSource
	   ,ae.ExternalIdentifier as ArchivalEntityExternalIdentifier
	   ,ae.AvailabilityStatusCode as ArchivalEntityAvailabilityStatusCode
	   ,ae.DescriptionLevelCode as ArchivalEntityDescriptionLevelCode
	   ,ae.StatusCode as ArchivalEntityStatusCode
	   ,dd.CreatedOn
       ,dd.CreatedBy
       ,cu.DisplayName as CreatedByDisplayName
	   ,cu.UserName as CreatedByUserName
	   ,dd.UpdatedOn
       ,dd.UpdatedBy
       ,uu.DisplayName as UpdatedByDisplayName
	   ,uu.UserName as UpdatedByUserName
       ,dd.Deleted
       ,dd.DeletedOn
       ,dd.DeletedBy
       ,du.DisplayName as DeletedByDisplayName
	   ,du.UserName as DeletedByUserName
       ,dd.HasExternalSource
       ,dd.ExternalIdentifier
       ,dd.ExternalSourceUpdatedOn
       ,dd.Number
       ,dd.Title
       ,dd.DescriptionLevelCode
	   ,l.Text as DescriptionLevelText
	   ,dd.AvailabilityStatusCode
	   ,ast.Text as AvailabilityStatusText
       ,dd.StatusCode
	   ,s.Text as StatusText
	   ,dd.FileFormatCode
	   ,dd.HasNoChronologicalScope
	   ,dd.StartDateYear
	   ,dd.StartDateMonth
	   ,dd.StartDateDay
	   ,dd.EndDateYear
	   ,dd.EndDateMonth
	   ,dd.EndDateDay
	   ,dd.ApproxmateChronologicalScope
	   ,dd.Author
	   ,dd.Location
	   ,dd.Bytes
	   ,dd.SheetCount
	   ,dd.StartSheetNumber
	   ,dd.EndSheetNumber
	   ,dd.DigitalDevice
	   ,dd.OtherMetrics
	   ,dd.SizeCm
	   ,dd.Scaling
	   ,dd.Duration
	   ,dd.Description
	   ,dd.DocumentsAccessDescription
	   ,dd.Features
	   ,dd.MicrofilmedCopyCount
	   ,dd.DigitizedCopyCount
	   ,dd.PaperCopyCount
	   ,dd.NegativeFrameCount
	   ,dd.PositiveFrameCount
	   ,dd.OtherCopyCount
	   ,dd.Transcription
	   ,dd.Notes
	   ,dd.IsImported
	   ,dd.DescriptionAuthor
	   ,dd.Cypher
	   ,dd.TextDocsCount
	   ,dd.GraphicalDocsCount
	   ,dd.Phase
	   ,dd.Part
	   ,dd.Stage
	   ,dd.OtherLanguage
	   , 0 as HasDigitizedDigitalObjects

  FROM dbo.DocumentDrafts dd
  JOIN dbo.Archives a ON dd.ArchiveId = a.Id
  LEFT JOIN dbo.Funds f ON dd.FundSystemIdentifier = f.SystemIdentifier
  LEFT JOIN dbo.FundDrafts fd ON dd.FundSystemIdentifier = fd.SystemIdentifier AND dd.FundDraftId = fd.Id 
  LEFT JOIN dbo.Inventories i ON dd.InventorySystemIdentifier = i.SystemIdentifier 
  LEFT JOIN dbo.InventoryDrafts id ON dd.InventorySystemIdentifier = id.SystemIdentifier AND dd.InventoryDraftId = id.Id
  LEFT JOIN dbo.ArchivalEntities ae ON dd.ArchivalEntitySystemIdentifier = ae.SystemIdentifier
  LEFT JOIN dbo.ArchivalEntityDrafts aed ON dd.ArchivalEntitySystemIdentifier = aed.SystemIdentifier AND dd.ArchivalEntityDraftId = aed.Id
  LEFT JOIN N.DocumentDescriptionLevel l ON dd.DescriptionLevelCode = l.Code
  LEFT JOIN N.AvailabilityStatus ast ON dd.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON dd.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON dd.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON dd.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON dd.CreatedBy = du.Id
 WHERE dd.IsCurrent = 1
GO
