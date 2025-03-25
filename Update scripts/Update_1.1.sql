SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.1'
where Code = 'DB_VERSION'


-- add scripts here
update N.FilmDocumentType
set Text = N'ѕриемателно-предавателен протокол'
where Code = 'Protocol'
go

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'NumberNumeric'
          AND Object_ID = Object_ID(N'dbo.ArchivalEntityDrafts'))
BEGIN
    ALTER TABLE dbo.ArchivalEntityDrafts
    ADD NumberNumeric int NULL
END

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'NumberNumeric'
          AND Object_ID = Object_ID(N'dbo.ArchivalEntities'))
BEGIN
	ALTER TABLE dbo.ArchivalEntities
	ADD NumberNumeric int NULL
END

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'NumberNumeric'
          AND Object_ID = Object_ID(N'dbo.InventoryDrafts'))
BEGIN
    ALTER TABLE dbo.InventoryDrafts
    ADD NumberNumeric int NULL
END

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'NumberNumeric'
          AND Object_ID = Object_ID(N'dbo.Inventories'))
BEGIN
    ALTER TABLE dbo.Inventories
    ADD NumberNumeric int NULL
END

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'NumberNumeric'
          AND Object_ID = Object_ID(N'dbo.FundDrafts'))
BEGIN
    ALTER TABLE dbo.FundDrafts
    ADD NumberNumeric int NULL
END

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'NumberNumeric'
          AND Object_ID = Object_ID(N'dbo.Funds'))
BEGIN
    ALTER TABLE dbo.Funds
    ADD NumberNumeric int NULL
END
GO


CREATE OR ALTER view [dbo].[v_Funds]
AS
SELECT 
	   fd.Id
	  ,fd.SystemIdentifier
	  ,CAST(1 as bit) as IsDraft
	  ,CAST(0 as bit) as IsSuspended
      ,fd.ArchiveId
	  ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
      ,fd.CreatedOn
      ,fd.CreatedBy
	  ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,fd.UpdatedOn
      ,fd.UpdatedBy
	  ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,fd.Deleted
      ,fd.DeletedOn
      ,fd.DeletedBy
	  ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,fd.ExternalIdentifier
      ,fd.HasExternalSource
      ,fd.ExternalSourceUpdatedOn
      ,fd.NumberArray
	  ,fd.NumberNumeric
      ,fd.Number
      ,fd.Title
      ,fd.DescriptionLevelCode
	  ,dl.Text as DescriptionLevelText
      ,fd.TypeCode
	  ,ft.Text as TypeText
      ,fd.StatusCode
	  ,s.Text as StatusText
      ,fd.HasNoChronologicalScope
      ,fd.StartDateYear
      ,fd.StartDateMonth
      ,fd.StartDateDay
      ,fd.EndDateYear
      ,fd.EndDateMonth
      ,fd.EndDateDay
      ,fd.ApproxmateChronologicalScope
      ,fd.Bytes
      ,fd.LinearMeters
      ,fd.OtherMetrics
      ,fd.InventoryCount
      ,fd.ArchivalEntityCount
      ,fd.DocumentCount
      ,fd.FundCreatorTitleHistory
      ,fd.FundCreatorActivityHistory
      ,fd.FundCreatorBiographicalHistory
      ,fd.DocumentsProvider
      ,fd.DocumentsDescription
      ,fd.ValuableDocumentsInventoryCount
      ,fd.InvaluableDocumentsInventoryCount
      ,fd.DocumentsAccessDescription
      ,fd.History
      ,fd.RelatedFunds
      ,fd.Notes
      ,fd.EnrolledBytes
      ,fd.EnrolledInventoryCount
      ,fd.DeductedBytes
      ,fd.DeductedInventoryCount
    FROM FundDrafts fd
	JOIN Archives a ON fd.ArchiveId = a.Id
	LEFT JOIN N.FundDescriptionLevel dl ON fd.DescriptionLevelCode = dl.Code
	LEFT JOIN N.FundType ft ON fd.TypeCode = ft.Code
	LEFT JOIN N.Status s ON fd.StatusCode = s.Code
	LEFT JOIN AspNetUsers cu ON fd.CreatedBy = cu.Id
	LEFT JOIN AspNetUsers uu ON fd.UpdatedBy = uu.Id
	LEFT JOIN AspNetUsers du ON fd.CreatedBy = du.Id
   WHERE fd.IsCurrent = 1
   UNION
   SELECT 
	   f.Id
	  ,f.SystemIdentifier
	  ,CAST(0 as bit) as IsDraft
	  ,f.IsSuspended
      ,f.ArchiveId
	  ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
      ,f.CreatedOn
      ,f.CreatedBy
      ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,f.UpdatedOn
      ,f.UpdatedBy
      ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,f.Deleted
      ,f.DeletedOn
      ,f.DeletedBy
      ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,f.ExternalIdentifier
      ,f.HasExternalSource
      ,f.ExternalSourceUpdatedOn
      ,f.NumberArray
	  ,f.NumberNumeric
      ,f.Number
      ,f.Title
      ,f.DescriptionLevelCode
	  ,dl.Text as DescriptionLevelText
      ,f.TypeCode
	  ,ft.Text as TypeText
      ,f.StatusCode
	  ,s.Text as StatusText
      ,f.HasNoChronologicalScope
      ,f.StartDateYear
      ,f.StartDateMonth
      ,f.StartDateDay
      ,f.EndDateYear
      ,f.EndDateMonth
      ,f.EndDateDay
      ,f.ApproxmateChronologicalScope
      ,f.Bytes
      ,f.LinearMeters
      ,f.OtherMetrics
      ,f.InventoryCount
      ,f.ArchivalEntityCount
      ,f.DocumentCount
      ,f.FundCreatorTitleHistory
      ,f.FundCreatorActivityHistory
      ,f.FundCreatorBiographicalHistory
      ,f.DocumentsProvider
      ,f.DocumentsDescription
      ,f.ValuableDocumentsInventoryCount
      ,f.InvaluableDocumentsInventoryCount
      ,f.DocumentsAccessDescription
      ,f.History
      ,f.RelatedFunds
      ,f.Notes
      ,f.EnrolledBytes
      ,f.EnrolledInventoryCount
      ,f.DeductedBytes
      ,f.DeductedInventoryCount
    FROM Funds f
	JOIN Archives a ON f.ArchiveId = a.Id
	LEFT JOIN FundDrafts fd on f.SystemIdentifier = fd.SystemIdentifier and fd.IsCurrent = 1
	LEFT JOIN N.FundDescriptionLevel dl ON f.DescriptionLevelCode = dl.Code
	LEFT JOIN N.FundType ft ON f.TypeCode = ft.Code
	LEFT JOIN N.Status s ON f.StatusCode = s.Code
	LEFT JOIN AspNetUsers cu ON f.CreatedBy = cu.Id
	LEFT JOIN AspNetUsers uu ON f.UpdatedBy = uu.Id
	LEFT JOIN AspNetUsers du ON f.CreatedBy = du.Id
   WHERE fd.id is null
GO


CREATE OR ALTER view [dbo].[v_Inventories]
AS

SELECT i.Id
      ,i.SystemIdentifier
	  ,CAST(0 as bit) as IsDraft
	  ,i.IsSuspended
      ,i.ArchiveId
	  ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,NULL as FundDraftId
      ,i.FundSystemIdentifier
	  ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,i.CreatedOn
      ,i.CreatedBy
      ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,i.UpdatedOn
      ,i.UpdatedBy
      ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,i.Deleted
      ,i.DeletedOn
      ,i.DeletedBy
      ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,i.ExternalIdentifier
      ,i.HasExternalSource
      ,i.ExternalSourceUpdatedOn
      ,i.NumberArray
	  ,i.NumberNumeric
      ,i.Number
      ,i.DescriptionLevelCode
      ,idl.Text as DescriptionLevelText
      ,i.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
      ,i.StatusCode
      ,s.Text as StatusText
      ,i.HasNoChronologicalScope
      ,i.StartDateYear
      ,i.StartDateMonth
      ,i.StartDateDay
      ,i.EndDateYear
      ,i.EndDateMonth
      ,i.EndDateDay
      ,i.ApproxmateChronologicalScope
      ,i.Bytes
      ,i.LinearMeters
      ,i.OtherMetrics
      ,i.ArchivalEntityCount
      ,i.DocumentCount
      ,i.BoxCount
      ,i.RollCount
      ,i.AudioDocumentArchivalEntityCount
      ,i.PhotoDocumentArchivalEntityCount
      ,i.VideoDocumentArchivalEntityCount
      ,i.DigitalDocumentArchivalEntityCount
      ,i.FundCreatorTitleHistory
      ,i.FundCreatorBiographicalHistory
      ,i.History
      ,i.DocumentsProvider
      ,i.DocumentsDescription
      ,i.DocumentsAccessDescription
      ,i.ClassificationScheme
      ,i.AbbreviationList
      ,i.MicrofilmedArchivalEntityCount
      ,i.DigitizedArchivalEntityCount
      ,i.NegativeFrameCount
      ,i.PositiveFrameCount
      ,i.Notes
  FROM Inventories i
  JOIN Archives a ON i.ArchiveId = a.Id
  JOIN Funds f ON i.FundSystemIdentifier = f.SystemIdentifier
  LEFT JOIN InventoryDrafts id on i.SystemIdentifier = id.SystemIdentifier and id.IsCurrent = 1
  LEFT JOIN N.InventoryDescriptionLevel idl ON i.DescriptionLevelCode = idl.Code
  LEFT JOIN N.AvailabilityStatus ast ON i.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON i.StatusCode = s.Code
  LEFT JOIN AspNetUsers cu ON i.CreatedBy = cu.Id
  LEFT JOIN AspNetUsers uu ON i.UpdatedBy = uu.Id
  LEFT JOIN AspNetUsers du ON i.CreatedBy = du.Id
 WHERE id.Id IS NULL

 UNION

 SELECT id.Id
      ,id.SystemIdentifier
	  ,CAST(1 as bit) as IsDraft
	  ,CAST(0 as bit) as IsSuspended
      ,id.ArchiveId
	  ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,id.FundDraftId
      ,id.FundSystemIdentifier
	  ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,id.CreatedOn
      ,id.CreatedBy
      ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,id.UpdatedOn
      ,id.UpdatedBy
      ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,id.Deleted
      ,id.DeletedOn
      ,id.DeletedBy
      ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,id.ExternalIdentifier
      ,id.HasExternalSource
      ,id.ExternalSourceUpdatedOn
      ,id.NumberArray
	  ,id.NumberNumeric
      ,id.Number
      ,id.DescriptionLevelCode
      ,idl.Text as DescriptionLevelText
      ,id.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
      ,id.StatusCode
      ,s.Text as StatusText
      ,id.HasNoChronologicalScope
      ,id.StartDateYear
      ,id.StartDateMonth
      ,id.StartDateDay
      ,id.EndDateYear
      ,id.EndDateMonth
      ,id.EndDateDay
      ,id.ApproxmateChronologicalScope
      ,id.Bytes
      ,id.LinearMeters
      ,id.OtherMetrics
      ,id.ArchivalEntityCount
      ,id.DocumentCount
      ,id.BoxCount
      ,id.RollCount
      ,id.AudioDocumentArchivalEntityCount
      ,id.PhotoDocumentArchivalEntityCount
      ,id.VideoDocumentArchivalEntityCount
      ,id.DigitalDocumentArchivalEntityCount
      ,id.FundCreatorTitleHistory
      ,id.FundCreatorBiographicalHistory
      ,id.History
      ,id.DocumentsProvider
      ,id.DocumentsDescription
      ,id.DocumentsAccessDescription
      ,id.ClassificationScheme
      ,id.AbbreviationList
      ,id.MicrofilmedArchivalEntityCount
      ,id.DigitizedArchivalEntityCount
      ,id.NegativeFrameCount
      ,id.PositiveFrameCount
      ,id.Notes
  FROM InventoryDrafts id
  JOIN Archives a ON id.ArchiveId = a.Id
  LEFT JOIN Funds f ON id.FundSystemIdentifier = f.SystemIdentifier
  LEFT JOIN FundDrafts fd ON id.FundSystemIdentifier = fd.SystemIdentifier AND id.FundDraftId = fd.Id 
  LEFT JOIN N.InventoryDescriptionLevel idl ON id.DescriptionLevelCode = idl.Code
  LEFT JOIN N.AvailabilityStatus ast ON id.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON id.StatusCode = s.Code
  LEFT JOIN AspNetUsers cu ON id.CreatedBy = cu.Id
  LEFT JOIN AspNetUsers uu ON id.UpdatedBy = uu.Id
  LEFT JOIN AspNetUsers du ON id.CreatedBy = du.Id
 WHERE id.IsCurrent = 1
GO


CREATE OR ALTER view [dbo].[v_ArchivalEntities]
AS

SELECT ae.Id
	  ,ae.SystemIdentifier
      ,CAST(0 as bit) as IsDraft
	  ,ae.IsSuspended
      ,ae.ArchiveId
      ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,NULL as FundDraftId
      ,ae.FundSystemIdentifier
      ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,NULL as InventoryDraftId
      ,ae.InventorySystemIdentifier
	  ,i.Number as InventoryNumber
	  ,i.HasExternalSource as InventoryHasExternalSource
	  ,i.ExternalIdentifier as InventoryExternalIdentifier
	  ,i.AvailabilityStatusCode as InventoryAvailabilityStatusCode
	  ,ae.CreatedOn
      ,ae.CreatedBy
      ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,ae.UpdatedOn
      ,ae.UpdatedBy
      ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,ae.Deleted
      ,ae.DeletedOn
      ,ae.DeletedBy
      ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,ae.HasExternalSource
      ,ae.ExternalIdentifier
      ,ae.ExternalSourceUpdatedOn
      ,ae.Number
	  ,ae.NumberNumeric
      ,ae.Title
	  ,ae.DescriptionLevelCode
	  ,l.Text as DescriptionLevelText
      ,ae.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
      ,ae.StatusCode
	  ,s.Text as StatusText
      ,ae.HasNoChronologicalScope
      ,ae.StartDateYear
      ,ae.StartDateMonth
      ,ae.StartDateDay
      ,ae.EndDateYear
      ,ae.EndDateMonth
      ,ae.EndDateDay
      ,ae.ApproxmateChronologicalScope
      ,ae.Author
      ,ae.Location
      ,ae.Bytes
      ,ae.SheetCount
      ,ae.TapeCount
      ,ae.MicrofilmCount
      ,ae.FrameCount
      ,ae.VideoTapeCount
      ,ae.DigitalDeviceCount
      ,ae.OtherMetrics
      ,ae.SizeCm
      ,ae.Scaling
      ,ae.Description
      ,ae.DocumentsAccessDescription
      ,ae.Features
      ,ae.Condition
      ,ae.MicrofilmedCopyCount
      ,ae.DigitizedCopyCount
      ,ae.PaperCopyCount
      ,ae.NegativeFrameCount
      ,ae.PositiveFrameCount
      ,ae.OtherCopyCount
      ,ae.Notes
      ,ae.EnrolledBytes
      ,ae.EnrolledDocumentCount
      ,ae.EnrolledLinearMeters
      ,ae.DeductedBytes
      ,ae.DeductedDocumentCount
      ,ae.DeductedLinearMeters
  FROM dbo.ArchivalEntities ae
  JOIN dbo.Archives a ON ae.ArchiveId = a.Id
  JOIN dbo.Funds f ON ae.FundSystemIdentifier = f.SystemIdentifier
  JOIN dbo.Inventories i ON ae.InventorySystemIdentifier = i.SystemIdentifier
  LEFT JOIN dbo.ArchivalEntityDrafts d on ae.SystemIdentifier = d.SystemIdentifier and d.IsCurrent = 1
  LEFT JOIN N.ArchivalEntityDescriptionLevel l ON ae.DescriptionLevelCode = l.Code
  LEFT JOIN N.AvailabilityStatus ast ON ae.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON ae.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON ae.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON ae.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON ae.DeletedBy = du.Id
 WHERE d.Id IS NULL

 UNION

 
SELECT d.Id
	  ,d.SystemIdentifier
      ,CAST(1 as bit) as IsDraft
	  ,CAST(0 as bit) as IsSuspended
      ,d.ArchiveId
      ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,d.FundDraftId
      ,d.FundSystemIdentifier
      ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,d.InventoryDraftId
      ,d.InventorySystemIdentifier
	  ,i.Number as InventoryNumber
	  ,i.HasExternalSource as InventoryHasExternalSource
	  ,i.ExternalIdentifier as InventoryExternalIdentifier
	  ,i.AvailabilityStatusCode as InventoryAvailabilityStatusCode
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
	  ,d.NumberNumeric
      ,d.Title
      ,d.DescriptionLevelCode
	  ,l.Text as DescriptionLevelText
	  ,d.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
      ,d.StatusCode
	  ,s.Text as StatusText
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
      ,d.TapeCount
      ,d.MicrofilmCount
      ,d.FrameCount
      ,d.VideoTapeCount
      ,d.DigitalDeviceCount
      ,d.OtherMetrics
      ,d.SizeCm
      ,d.Scaling
      ,d.Description
      ,d.DocumentsAccessDescription
      ,d.Features
      ,d.Condition
      ,d.MicrofilmedCopyCount
      ,d.DigitizedCopyCount
      ,d.PaperCopyCount
      ,d.NegativeFrameCount
      ,d.PositiveFrameCount
      ,d.OtherCopyCount
      ,d.Notes
      ,d.EnrolledBytes
      ,d.EnrolledDocumentCount
      ,d.EnrolledLinearMeters
      ,d.DeductedBytes
      ,d.DeductedDocumentCount
      ,d.DeductedLinearMeters
  FROM dbo.ArchivalEntityDrafts d
  JOIN dbo.Archives a ON d.ArchiveId = a.Id
  LEFT JOIN dbo.Funds f ON d.FundSystemIdentifier = f.SystemIdentifier
  LEFT JOIN dbo.FundDrafts fd ON d.FundSystemIdentifier = fd.SystemIdentifier AND d.FundDraftId = fd.Id 
  LEFT JOIN dbo.Inventories i ON d.InventorySystemIdentifier = i.SystemIdentifier 
  LEFT JOIN dbo.InventoryDrafts id ON d.InventorySystemIdentifier = id.SystemIdentifier AND d.InventoryDraftId = id.Id
  LEFT JOIN N.ArchivalEntityDescriptionLevel l ON d.DescriptionLevelCode = l.Code
  LEFT JOIN N.AvailabilityStatus ast ON d.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON d.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON d.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON d.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON d.DeletedBy = du.Id
 WHERE d.IsCurrent = 1
GO


commit