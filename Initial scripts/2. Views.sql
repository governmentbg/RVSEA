 
begin transaction

/****** Object:  View [A].[v_AuditLogs]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [A].[v_AuditLogs]
AS
SELECT 	
	Max(a.EntitySetName) AS EntityName
	, Max(a.StateName) AS StateName
	, Max(a.Ip) AS ClientIp
	, Max(a.CreatedBy) AS CreatedBy
	, Max(a.CreatedByUsername) AS CreatedByUsername
	, Max(a.CreatedOn) AS CreatedOn
	, Max(a.Description) AS Description
	, Max(a.CorrelationId) AS CorrelationId
	, Max(a.Lease) AS Lease
FROM A.AuditEntries a
GROUP BY a.CorrelationId, a.Lease
GO
/****** Object:  View [A].[v_AuditLogsWithDetails]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [A].[v_AuditLogsWithDetails]
AS
SELECT 
	a.*
	, (select 
		ae.EntitySetName AS EntityName
		, ae.AuditEntryID AS Id
		, Properties.PropertyName
		, Properties.IsKey
		, Properties.OldValue
		, Properties.NewValue
		FROM a.AuditEntryProperties Properties 
		INNER JOin a.AuditEntries ae ON Properties.AuditEntryID = ae.AuditEntryID
		WHERE ae.CorrelationId = a.CorrelationId and ae.Lease = a.Lease
		for json auto) as ChangedProperties
FROM A.v_AuditLogs a
GO
/****** Object:  View [dbo].[v_Funds_Search_FundDrafts]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   view [dbo].[v_Funds_Search_FundDrafts] WITH SCHEMABINDING
AS
SELECT 
	'fd_' +CAST(fd.Id AS varchar(10)) AS Idx 
	,CAST(1 as bit) as IsDraft
    ,fd.Number -- 
    ,fd.Title --
    ,fd.ApproxmateChronologicalScope --
    ,fd.FundCreatorTitleHistory -- 
    ,fd.FundCreatorActivityHistory --
    ,fd.FundCreatorBiographicalHistory --
    ,fd.DocumentsProvider -- 
    ,fd.DocumentsDescription --
    ,fd.DocumentsAccessDescription --
    ,fd.History --
    ,fd.RelatedFunds -- 
    ,fd.Notes -- 
FROM dbo.FundDrafts fd
WHERE fd.IsCurrent = 1
GO
/****** Object:  View [dbo].[v_Funds_Search_Funds]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   view [dbo].[v_Funds_Search_Funds] WITH SCHEMABINDING
AS
SELECT 
    'f_' +CAST(f.Id AS varchar(10)) AS Idx 
	,CAST(0 as bit) as IsDraft
    ,f.Number -- 
    ,f.Title -- 
    ,f.ApproxmateChronologicalScope --
    ,f.FundCreatorTitleHistory --
    ,f.FundCreatorActivityHistory --
    ,f.FundCreatorBiographicalHistory --
    ,f.DocumentsProvider --
    ,f.DocumentsDescription --
    ,f.DocumentsAccessDescription --
    ,f.History -- 
    ,f.RelatedFunds --
    ,f.Notes --
FROM dbo.Funds f 
LEFT JOIN dbo.FundDrafts fd on f.SystemIdentifier = fd.SystemIdentifier and fd.IsCurrent = 1
WHERE fd.Id is null
GO
/****** Object:  View [dbo].[v_Funds_Search]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   view [dbo].[v_Funds_Search] WITH SCHEMABINDING
AS
SELECT 
	fd.Idx
	,fd.IsDraft
	,fd.Number -- 
    ,fd.Title --
    ,fd.ApproxmateChronologicalScope --
    ,fd.FundCreatorTitleHistory -- 
    ,fd.FundCreatorActivityHistory --
    ,fd.FundCreatorBiographicalHistory --
    ,fd.DocumentsProvider -- 
    ,fd.DocumentsDescription --
    ,fd.DocumentsAccessDescription --
    ,fd.History --
    ,fd.RelatedFunds -- 
    ,fd.Notes -- 
FROM dbo.v_Funds_Search_FundDrafts fd
UNION
SELECT 
	f.Idx
	,f.IsDraft
	,f.Number -- 
    ,f.Title -- 
    ,f.ApproxmateChronologicalScope --
    ,f.FundCreatorTitleHistory --
    ,f.FundCreatorActivityHistory --
    ,f.FundCreatorBiographicalHistory --
    ,f.DocumentsProvider --
    ,f.DocumentsDescription --
    ,f.DocumentsAccessDescription --
    ,f.History -- 
    ,f.RelatedFunds --
    ,f.Notes --
FROM dbo.v_Funds_Search_Funds f 
GO
/****** Object:  View [dbo].[v_Inventories]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   view [dbo].[v_Inventories]
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
      ,i.Number
      --,i.Title
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
      ,id.Number
      --,id.Title
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
/****** Object:  View [dbo].[v_ArchivalEntities]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   view [dbo].[v_ArchivalEntities]
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
/****** Object:  View [dbo].[v_Documents]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   view [dbo].[v_Documents]
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
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,NULL as InventoryDraftId
      ,d.InventorySystemIdentifier
	  ,i.Number as InventoryNumber
	  ,i.HasExternalSource as InventoryHasExternalSource
	  ,i.ExternalIdentifier as InventoryExternalIdentifier
	  ,i.AvailabilityStatusCode  as InventoryAvailabilityStatusCode
	  ,NULL as ArchivalEntityDraftId
      ,d.ArchivalEntitySystemIdentifier
	  ,ae.Number as ArchivalEntityNumber
	  ,ae.HasExternalSource as ArchivalEntityHasExternalSource
	  ,ae.ExternalIdentifier as ArchivalEntityExternalIdentifier
	  ,ae.AvailabilityStatusCode as ArchivalEntityAvailabilityStatusCode
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
	   ,f.HasExternalSource as FundHasExternalSource
	   ,f.ExternalIdentifier as FundExternalIdentifier
       ,dd.InventoryDraftId
       ,dd.InventorySystemIdentifier
	   ,i.Number as InventoryNumber
	   ,i.HasExternalSource as InventoryHasExternalSource
	   ,i.ExternalIdentifier as InventoryExternalIdentifier
	   ,i.AvailabilityStatusCode as InventoryAvailabilityStatusCode
	   ,dd.ArchivalEntityDraftId
       ,dd.ArchivalEntitySystemIdentifier
	   ,ae.Number as ArchivalEntityNumber
	   ,ae.HasExternalSource as ArchivalEntityHasExternalSource
	   ,ae.ExternalIdentifier as ArchivalEntityExternalIdentifier
	   ,ae.AvailabilityStatusCode as ArchivalEntityAvailabilityStatusCode
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
/****** Object:  View [dbo].[v_Funds]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   view [dbo].[v_Funds]
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
/****** Object:  View [dbo].[v_FundReconstructions]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   view [dbo].[v_FundReconstructions]
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
/****** Object:  View [dbo].[v_DigitalObjects]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   view [dbo].[v_DigitalObjects]
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
      ,do.StatusCode
      ,do.ContentType
	  ,do.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
	  ,do.WatermarkName
	  ,do.WatermarkUncPath
	  ,do.HashCode
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
      ,dod.StatusCode
      ,dod.ContentType
	  ,dod.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
	  ,dod.WatermarkName
	  ,dod.WatermarkUncPath
	  ,dod.HashCode
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
/****** Object:  View [dbo].[v_FilmCards]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[v_FilmCards]
AS
SELECT 
	   fd.Id
	  ,fd.SystemIdentifier
	  ,CAST(1 as bit) as IsDraft
      ,fd.ArchiveId
	  ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,fd.FilmSystemIdentifier
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

	  ,fd.CountryId
	  ,nc.Text CountryName
	  ,nc.Code CountryCode
	  ,fd.City
	  ,fd.DocumentsCypher
	  ,fd.Title
	  ,fd.ArchiveOriginals
	  ,fd.StartDateDay
	  ,fd.StartDateMonth
	  ,fd.StartDateYear
	  ,fd.EndDateDay
	  ,fd.EndDateMonth
	  ,fd.EndDateYear
	  ,fd.AproximateDate
	  ,fd.FilmingExtentId
	  ,ne.Text FilmingExtentName
	  ,fd.Source
      ,fd.InventoryNumber     
      ,fd.FramesCount
      ,fd.MicrofilmNegativeCount
	  ,fd.MicrofilmPositiveCount
	  ,fd.PhotoCopy
	  ,fd.DigitalCopy
	  ,fd.Size
	  ,fd.Other
	  ,fd.Notes
	  ,fd.DocumentsFormat
	  ,fd.DocumentsCharacteristics

    FROM FilmCardDrafts fd
	JOIN Archives a ON fd.ArchiveId = a.Id
	LEFT JOIN N.Nomenclatures nc ON nc.Id = fd.CountryId
	LEFT JOIN N.Nomenclatures ne ON ne.Id = fd.FilmingExtentId
	LEFT JOIN AspNetUsers cu ON fd.CreatedBy = cu.Id
	LEFT JOIN AspNetUsers uu ON fd.UpdatedBy = uu.Id
	LEFT JOIN AspNetUsers du ON fd.CreatedBy = du.Id
   WHERE fd.IsCurrent = 1
   UNION
   SELECT 
	   f.Id
	  ,f.SystemIdentifier
	  ,CAST(0 as bit) as IsDraft
      ,f.ArchiveId
	  ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,f.FilmSystemIdentifier
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

	  ,f.CountryId
	  ,nc.Text CountryName
	  ,nc.Code CountryCode
	  ,f.City
	  ,f.DocumentsCypher
	  ,f.Title
	  ,f.ArchiveOriginals
	  ,f.StartDateDay
	  ,f.StartDateMonth
	  ,f.StartDateYear
	  ,f.EndDateDay
	  ,f.EndDateMonth
	  ,f.EndDateYear
	  ,f.AproximateDate
	  ,f.FilmingExtentId
	  ,ne.Text FilmingExtentName
	  ,f.Source
      ,f.InventoryNumber     
      ,f.FramesCount
      ,f.MicrofilmNegativeCount
	  ,f.MicrofilmPositiveCount
	  ,f.PhotoCopy
	  ,f.DigitalCopy
	  ,f.Size
	  ,f.Other
	  ,f.Notes
	  ,f.DocumentsFormat
	  ,f.DocumentsCharacteristics

    FROM FilmCards f
	JOIN Archives a ON f.ArchiveId = a.Id
	LEFT JOIN FilmCardDrafts fd on f.SystemIdentifier = fd.SystemIdentifier and fd.IsCurrent = 1
	LEFT JOIN N.Nomenclatures nc ON nc.Id = f.CountryId
	LEFT JOIN N.Nomenclatures ne ON ne.Id = f.FilmingExtentId
	LEFT JOIN AspNetUsers cu ON f.CreatedBy = cu.Id
	LEFT JOIN AspNetUsers uu ON f.UpdatedBy = uu.Id
	LEFT JOIN AspNetUsers du ON f.CreatedBy = du.Id
   WHERE fd.id is null
GO
/****** Object:  View [dbo].[v_FilmDocuments]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   view [dbo].[v_FilmDocuments]
AS
SELECT 
		doc.Id as DocumentId
		,doc.PackageId
		,fp.Type as PackageType
		,fp.Deleted as PackageIsDeleted
		,docT.Code as DocumentTypeCode
		,docT.Text as DocumentTypeText
		,doc.Description
		,doc.FileId
		,doc.FilePath
		,doc.FileName
		,doc.FileType
		,doc.ContentType
		,doc.FileSizeInBytes
		,doc.FileLocation
		,doc.Deleted as DocumentIsDeleted
		,doc.HashCode

		,fd.Id as FilmId
		,fd.SystemIdentifier as FilmSystemIdentifier
		,CAST(1 as bit) as IsDraft
		,fd.ArchiveId
		,a.Code as ArchiveCode
		,a.Name as ArchiveName
		,fd.Deleted as FilmIsDeleted
		,fd.ExternalIdentifier
		,fd.HasExternalSource
		,fd.ExternalSourceUpdatedOn
		,fd.InventoryNumber
		,fd.PackageAId
		,fd.PackageBId

    FROM FilmPackageDocuments doc
	JOIN N.FilmDocumentType docT on docT.Id = doc.DocumentTypeId
	JOIN FilmPackages fp on fp.Id = doc.PackageId
	JOIN FilmDrafts fd on (fd.PackageAId = fp.Id or fd.PackageBId = fp.Id)
	JOIN Archives a ON fd.ArchiveId = a.Id
   WHERE fd.IsCurrent = 1
   UNION
   SELECT 
		doc.Id as DocumentId
		,doc.PackageId
		,fp.Type as PackageType
		,fp.Deleted as PackageIsDeleted
		,docT.Code as DocumentTypeCode
		,docT.Text as DocumentTypeText
		,doc.Description
		,doc.FileId
		,doc.FilePath
		,doc.FileName
		,doc.FileType
		,doc.ContentType
		,doc.FileSizeInBytes
		,doc.FileLocation
		,doc.Deleted as DocumentIsDeleted
		,doc.HashCode

	    ,f.Id as FilmId
		,f.SystemIdentifier as FilmSystemIdentifier
		,CAST(0 as bit) as IsDraft
		,f.ArchiveId
		,a.Code as ArchiveCode
		,a.Name as ArchiveName
		,f.Deleted as FilmIsDeleted
		,f.ExternalIdentifier
		,f.HasExternalSource
		,f.ExternalSourceUpdatedOn
		,f.InventoryNumber
		,f.PackageAId
		,f.PackageBId

    FROM FilmPackageDocuments doc
	JOIN N.FilmDocumentType docT on docT.Id = doc.DocumentTypeId
	JOIN FilmPackages fp on fp.Id = doc.PackageId
	JOIN Films f on (f.PackageAId = fp.Id or f.PackageBId = fp.Id)
	JOIN Archives a ON f.ArchiveId = a.Id
	LEFT JOIN FilmDrafts fd on f.SystemIdentifier = fd.SystemIdentifier and fd.IsCurrent = 1
   WHERE fd.id is null
GO
/****** Object:  View [dbo].[v_FilmReviews]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[v_FilmReviews]
AS
SELECT fr.Id,
	   fr.SystemIdentifier,
	   fr.CreatedOn,
	   fr.CreatedBy,
	   fr.UpdatedOn,
	   fr.UpdatedBy,
	   fr.Deleted,
	   fr.DeletedOn,
	   fr.DeletedBy,
	   fr.UserId,
	   u.UserName as Username,
	   fr.ReaderName,
	   fr.FilmSystemIdentifier,
	   fr.AccessAllowed,
	   cu.DisplayName as CreatedByDisplayName,
	   cu.UserName as CreatedByUserName,
	   uu.DisplayName as UpdatedByDisplayName,
	   uu.UserName as UpdatedByUserName,
	   du.DisplayName as DeletedByDisplayName,
	   du.UserName as DeletedByUserName,
	   f.InventoryNumber as FilmInventoryNumber,
	   n.[Text] as FilmNumber
FROM FilmReviews as fr
LEFT JOIN AspNetUsers cu ON fr.CreatedBy = cu.Id
LEFT JOIN AspNetUsers uu ON fr.UpdatedBy = uu.Id
LEFT JOIN AspNetUsers du ON fr.DeletedBy = du.Id
LEFT JOIN AspNetUsers u ON fr.UserId = u.Id
LEFT JOIN Films f ON fr.FilmSystemIdentifier = f.SystemIdentifier
LEFT JOIN N.Nomenclatures n ON f.CountryId = n.Id
GO
/****** Object:  View [dbo].[v_Films]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[v_Films]
AS
SELECT 
	   fd.Id
	  ,fd.SystemIdentifier
	  ,CAST(1 as bit) as IsDraft
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

      ,fd.InventoryNumber
      ,fd.CountryId
	  ,fc.Text CountryName
	  ,fc.Code CountryCode
      ,fd.FramesCount
      ,fd.MicrofilmNegativeRollsCount
      ,fd.MicrofilmNegativeFramesCount
	  ,fd.MicrofilmPositiveRollsCount
      ,fd.MicrofilmPositiveFramesCount
	  ,fd.PhotoCopy
	  ,fd.DigitalCopy
	  ,fd.Size
	  ,fd.Other
	  ,fd.AcceptedOnDay
	  ,fd.AcceptedOnMonth
	  ,fd.AcceptedOnYear
	  ,fd.Source
	  ,fd.Content
	  ,fd.Notes
	  ,fd.PackageAId
	  ,fd.PackageBId

    FROM FilmDrafts fd
	JOIN Archives a ON fd.ArchiveId = a.Id
	LEFT JOIN N.Nomenclatures fc ON fc.Id = fd.CountryId
	LEFT JOIN AspNetUsers cu ON fd.CreatedBy = cu.Id
	LEFT JOIN AspNetUsers uu ON fd.UpdatedBy = uu.Id
	LEFT JOIN AspNetUsers du ON fd.CreatedBy = du.Id
   WHERE fd.IsCurrent = 1
   UNION
   SELECT 
	   f.Id
	  ,f.SystemIdentifier
	  ,CAST(0 as bit) as IsDraft
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

      ,f.InventoryNumber
      ,f.CountryId
	  ,fc.Text CountryName
	  ,fc.Code CountryCode
      ,f.FramesCount
      ,f.MicrofilmNegativeRollsCount
      ,f.MicrofilmNegativeFramesCount
	  ,f.MicrofilmPositiveRollsCount
      ,f.MicrofilmPositiveFramesCount
	  ,f.PhotoCopy
	  ,f.DigitalCopy
	  ,f.Size
	  ,f.Other
	  ,f.AcceptedOnDay
	  ,f.AcceptedOnMonth
	  ,f.AcceptedOnYear
	  ,f.Source
	  ,f.Content
	  ,f.Notes
	  ,f.PackageAId
	  ,f.PackageBId

    FROM Films f
	JOIN Archives a ON f.ArchiveId = a.Id
	LEFT JOIN FilmDrafts fd on f.SystemIdentifier = fd.SystemIdentifier and fd.IsCurrent = 1
	LEFT JOIN N.Nomenclatures fc ON fc.Id = f.CountryId
	LEFT JOIN AspNetUsers cu ON f.CreatedBy = cu.Id
	LEFT JOIN AspNetUsers uu ON f.UpdatedBy = uu.Id
	LEFT JOIN AspNetUsers du ON f.CreatedBy = du.Id
   WHERE fd.id is null
GO
/****** Object:  View [dbo].[v_Funds_Search1]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   view [dbo].[v_Funds_Search1] WITH SCHEMABINDING
AS
SELECT 
	'fd_' +CAST(fd.Id AS varchar(10)) AS Idx 
	,CAST(1 as bit) as IsDraft
    ,fd.Number -- 
    ,fd.Title --
    ,fd.ApproxmateChronologicalScope --
    ,fd.FundCreatorTitleHistory -- 
    ,fd.FundCreatorActivityHistory --
    ,fd.FundCreatorBiographicalHistory --
    ,fd.DocumentsProvider -- 
    ,fd.DocumentsDescription --
    ,fd.DocumentsAccessDescription --
    ,fd.History --
    ,fd.RelatedFunds -- 
    ,fd.Notes -- 
FROM dbo.FundDrafts fd
WHERE fd.IsCurrent = 1
UNION
SELECT 
    'f_' +CAST(f.Id AS varchar(10)) AS Idx 
	,CAST(0 as bit) as IsDraft
    ,f.Number -- 
    ,f.Title -- 
    ,f.ApproxmateChronologicalScope --
    ,f.FundCreatorTitleHistory --
    ,f.FundCreatorActivityHistory --
    ,f.FundCreatorBiographicalHistory --
    ,f.DocumentsProvider --
    ,f.DocumentsDescription --
    ,f.DocumentsAccessDescription --
    ,f.History -- 
    ,f.RelatedFunds --
    ,f.Notes --
FROM dbo.Funds f 
LEFT JOIN dbo.FundDrafts fd on f.SystemIdentifier = fd.SystemIdentifier and fd.IsCurrent = 1
WHERE fd.Id is null
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PublicArchivalEntities] AS
SELECT ae.Id, ae.SystemIdentifier, CAST(0 AS bit) AS IsDraft, ae.ArchiveId, a.Code AS ArchiveCode, a.Name AS ArchiveName, NULL AS FundDraftId, ae.FundSystemIdentifier, f.Number AS FundNumber, 
                  f.HasExternalSource AS FundHasExternalSource, f.ExternalIdentifier AS FundExternalIdentifier, NULL AS InventoryDraftId, ae.InventorySystemIdentifier, i.Number AS InventoryNumber, 
                  i.HasExternalSource AS InventoryHasExternalSource, i.ExternalIdentifier AS InventoryExternalIdentifier, ae.CreatedOn, ae.CreatedBy, cu.DisplayName AS CreatedByDisplayName, cu.UserName AS CreatedByUserName, ae.UpdatedOn, 
                  ae.UpdatedBy, uu.DisplayName AS UpdatedByDisplayName, uu.UserName AS UpdatedByUserName, ae.Deleted, ae.DeletedOn, ae.DeletedBy, du.DisplayName AS DeletedByDisplayName, du.UserName AS DeletedByUserName, 
                  ae.HasExternalSource, ae.ExternalIdentifier, ae.ExternalSourceUpdatedOn, ae.Number, ae.Title, ae.DescriptionLevelCode, l.Text AS DescriptionLevelText, ae.StatusCode, s.Text AS StatusText, ae.HasNoChronologicalScope, 
                  ae.StartDateYear, ae.StartDateMonth, ae.StartDateDay, ae.EndDateYear, ae.EndDateMonth, ae.EndDateDay, ae.ApproxmateChronologicalScope, ae.Author, ae.Location, ae.Bytes, ae.SheetCount, ae.TapeCount, ae.MicrofilmCount, 
                  ae.FrameCount, ae.VideoTapeCount, ae.DigitalDeviceCount, ae.OtherMetrics, ae.SizeCm, ae.Scaling, ae.Description, ae.DocumentsAccessDescription, ae.Features, ae.Condition, ae.MicrofilmedCopyCount, ae.DigitizedCopyCount, 
                  ae.PaperCopyCount, ae.NegativeFrameCount, ae.PositiveFrameCount, ae.OtherCopyCount, ae.Notes, ae.EnrolledBytes, ae.EnrolledDocumentCount, ae.EnrolledLinearMeters, ae.DeductedBytes, ae.DeductedDocumentCount, 
                  ae.DeductedLinearMeters, f.NumberNumeric as FundNumberNumeric, i.NumberNumeric as InventoryNumberNumeric, ae.NumberNumeric, ast.Text as AvailabilityStatusText, i.AvailabilityStatusCode
FROM dbo.ArchivalEntities AS ae INNER JOIN
                  dbo.Archives AS a ON ae.ArchiveId = a.Id INNER JOIN
                  dbo.Funds AS f ON ae.FundSystemIdentifier = f.SystemIdentifier INNER JOIN
                  dbo.Inventories AS i ON ae.InventorySystemIdentifier = i.SystemIdentifier LEFT OUTER JOIN
                  N.ArchivalEntityDescriptionLevel AS l ON ae.DescriptionLevelCode = l.Code LEFT OUTER JOIN
                  N.Status AS s ON ae.StatusCode = s.Code LEFT OUTER JOIN
                  dbo.AspNetUsers AS cu ON ae.CreatedBy = cu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS uu ON ae.UpdatedBy = uu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS du ON ae.CreatedBy = du.Id
				  LEFT JOIN N.AvailabilityStatus ast ON ae.AvailabilityStatusCode = ast.Code
WHERE ae.IsSuspended = 0
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[v_PublicDocuments] AS
SELECT d.Id, d.SystemIdentifier, CAST(0 AS bit) AS IsDraft, d.ArchiveId, a.Code AS ArchiveCode, a.Name AS ArchiveName, NULL AS FundDraftId, d.FundSystemIdentifier, f.Number AS FundNumber, 
                  f.HasExternalSource AS FundHasExternalSource, f.ExternalIdentifier AS FundExternalIdentifier, NULL AS InventoryDraftId, d.InventorySystemIdentifier, i.Number AS InventoryNumber, 
                  i.HasExternalSource AS InventoryHasExternalSource, i.ExternalIdentifier AS InventoryExternalIdentifier, NULL AS ArchivalEntityDraftId, d.ArchivalEntitySystemIdentifier, ae.Number AS ArchivalEntityNumber, 
                  ae.HasExternalSource AS ArchivalEntityHasExternalSource, ae.ExternalIdentifier AS ArchivalEntityExternalIdentifier, d.CreatedOn, d.CreatedBy, cu.DisplayName AS CreatedByDisplayName, cu.UserName AS CreatedByUserName, 
                  d.UpdatedOn, d.UpdatedBy, uu.DisplayName AS UpdatedByDisplayName, uu.UserName AS UpdatedByUserName, d.Deleted, d.DeletedOn, d.DeletedBy, du.DisplayName AS DeletedByDisplayName, du.UserName AS DeletedByUserName, 
                  d.HasExternalSource, d.ExternalIdentifier, d.ExternalSourceUpdatedOn, d.Number, d.Title, d.DescriptionLevelCode, l.Text AS DescriptionLevelText, d.StatusCode, s.Text AS StatusText, d.FileFormatCode, d.HasNoChronologicalScope, 
                  d.StartDateYear, d.StartDateMonth, d.StartDateDay, d.EndDateYear, d.EndDateMonth, d.EndDateDay, d.ApproxmateChronologicalScope, d.Author, d.Location, d.Bytes, d.SheetCount, d.StartSheetNumber, d.EndSheetNumber, 
                  d.DigitalDevice, d.OtherMetrics, d.SizeCm, d.Scaling, d.Duration, d.Description, d.DocumentsAccessDescription, d.Features, d.MicrofilmedCopyCount, d.DigitizedCopyCount, d.PaperCopyCount, d.NegativeFrameCount, 
                  d.PositiveFrameCount, d.OtherCopyCount, d.Transcription, d.Notes, f.NumberNumeric AS FundNumberNumeric, i.NumberNumeric AS InventoryNumberNumeric, ae.NumberNumeric AS ArchivalEntityNumberNumeric,
				  d.AvailabilityStatusCode, ast.Text as AvailabilityStatusText
FROM dbo.Documents AS d INNER JOIN
                  dbo.Archives AS a ON d.ArchiveId = a.Id INNER JOIN
                  dbo.Funds AS f ON d.FundSystemIdentifier = f.SystemIdentifier INNER JOIN
                  dbo.Inventories AS i ON d.InventorySystemIdentifier = i.SystemIdentifier INNER JOIN
                  dbo.ArchivalEntities AS ae ON d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier LEFT OUTER JOIN
                  N.DocumentDescriptionLevel AS l ON d.DescriptionLevelCode = l.Code LEFT OUTER JOIN
                  N.Status AS s ON d.StatusCode = s.Code LEFT OUTER JOIN
                  dbo.AspNetUsers AS cu ON d.CreatedBy = cu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS uu ON d.UpdatedBy = uu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS du ON d.CreatedBy = du.Id
				  LEFT JOIN N.AvailabilityStatus ast ON d.AvailabilityStatusCode = ast.Code
WHERE ae.IsSuspended = 0
GO

/****** Object:  View [dbo].[v_PublicFilmCards]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[v_PublicFilmCards]
AS
SELECT 
	fc.Id
	,fc.SystemIdentifier
	,CAST(0 as bit) as IsDraft
	,fc.InventoryNumber
	,fc.Title
	,fc.HasExternalSource
	,fc.ExternalIdentifier
	,fc.FilmSystemIdentifier
	,fc.ArchiveId
	,a.Code as ArchiveCode
	,a.Name as ArchiveName
	,fc.CreatedOn
	,fc.CreatedBy
	,n.Code CountryCode
	,fc.Deleted
FROM FilmCards fc
INNER JOIN Archives a ON fc.ArchiveId = a.Id
LEFT JOIN N.Nomenclatures n ON n.Id = fc.CountryId
GO
/****** Object:  View [dbo].[v_PublicFilms]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   view [dbo].[v_PublicFilms]
AS
SELECT 
	f.Id
	,f.SystemIdentifier
	,CAST(0 as bit) as IsDraft
	,f.InventoryNumber
	,f.HasExternalSource
	,f.ExternalIdentifier
	,f.ArchiveId
	,a.Code as ArchiveCode
	,a.Name as ArchiveName
	,f.CreatedOn
	,f.CreatedBy
	,fc.Code CountryCode
	,f.Deleted
FROM Films f
INNER JOIN Archives a ON f.ArchiveId = a.Id
LEFT JOIN N.Nomenclatures fc ON fc.Id = f.CountryId
GO
/****** Object:  View [dbo].[v_PublicFunds]    Script Date: 30.11.2022 г. 11:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_PublicFunds] AS
SELECT f.Id, f.SystemIdentifier, CAST(0 AS bit) AS IsDraft, f.ArchiveId, a.Code AS ArchiveCode, a.Name AS ArchiveName, f.CreatedOn, f.CreatedBy, cu.DisplayName AS CreatedByDisplayName, cu.UserName AS CreatedByUserName, f.UpdatedOn, 
                  f.UpdatedBy, uu.DisplayName AS UpdatedByDisplayName, uu.UserName AS UpdatedByUserName, f.Deleted, f.DeletedOn, f.DeletedBy, du.DisplayName AS DeletedByDisplayName, du.UserName AS DeletedByUserName, 
                  f.ExternalIdentifier, f.HasExternalSource, f.ExternalSourceUpdatedOn, f.NumberArray, f.Number, f.Title, f.DescriptionLevelCode, dl.Text AS DescriptionLevelText, f.TypeCode, ft.Text AS TypeText, f.StatusCode, s.Text AS StatusText, 
                  f.HasNoChronologicalScope, f.StartDateYear, f.StartDateMonth, f.StartDateDay, f.EndDateYear, f.EndDateMonth, f.EndDateDay, f.ApproxmateChronologicalScope, f.Bytes, f.LinearMeters, f.OtherMetrics, f.InventoryCount, 
                  f.ArchivalEntityCount, f.DocumentCount, f.FundCreatorTitleHistory, f.FundCreatorActivityHistory, f.FundCreatorBiographicalHistory, f.DocumentsProvider, f.DocumentsDescription, f.ValuableDocumentsInventoryCount, 
                  f.InvaluableDocumentsInventoryCount, f.DocumentsAccessDescription, f.History, f.RelatedFunds, f.Notes, f.EnrolledBytes, f.EnrolledInventoryCount, f.DeductedBytes, f.DeductedInventoryCount
FROM     dbo.Funds AS f INNER JOIN
                  dbo.Archives AS a ON f.ArchiveId = a.Id LEFT OUTER JOIN
                  N.FundDescriptionLevel AS dl ON f.DescriptionLevelCode = dl.Code LEFT OUTER JOIN
                  N.FundType AS ft ON f.TypeCode = ft.Code LEFT OUTER JOIN
                  N.Status AS s ON f.StatusCode = s.Code LEFT OUTER JOIN
                  dbo.AspNetUsers AS cu ON f.CreatedBy = cu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS uu ON f.UpdatedBy = uu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS du ON f.CreatedBy = du.Id
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PublicInventories] AS
SELECT i.Id, i.SystemIdentifier, CAST(0 AS bit) AS IsDraft, i.ArchiveId, a.Code AS ArchiveCode, a.Name AS ArchiveName, NULL AS FundDraftId, i.FundSystemIdentifier, f.Number AS FundNumber, f.HasExternalSource AS FundHasExternalSource, 
                  f.ExternalIdentifier AS FundExternalIdentifier, i.CreatedOn, i.CreatedBy, cu.DisplayName AS CreatedByDisplayName, cu.UserName AS CreatedByUserName, i.UpdatedOn, i.UpdatedBy, uu.DisplayName AS UpdatedByDisplayName, 
                  uu.UserName AS UpdatedByUserName, i.Deleted, i.DeletedOn, i.DeletedBy, du.DisplayName AS DeletedByDisplayName, du.UserName AS DeletedByUserName, i.ExternalIdentifier, i.HasExternalSource, i.ExternalSourceUpdatedOn, 
                  i.NumberArray, i.Number, i.DescriptionLevelCode, idl.Text AS DescriptionLevelText, i.StatusCode, s.Text AS StatusText, i.HasNoChronologicalScope, i.StartDateYear, i.StartDateMonth, i.StartDateDay, i.EndDateYear, i.EndDateMonth, 
                  i.EndDateDay, i.ApproxmateChronologicalScope, i.Bytes, i.LinearMeters, i.OtherMetrics, i.ArchivalEntityCount, i.DocumentCount, i.BoxCount, i.RollCount, i.AudioDocumentArchivalEntityCount, i.PhotoDocumentArchivalEntityCount, 
                  i.VideoDocumentArchivalEntityCount, i.DigitalDocumentArchivalEntityCount, i.FundCreatorTitleHistory, i.FundCreatorBiographicalHistory, i.History, i.DocumentsProvider, i.DocumentsDescription, i.DocumentsAccessDescription, 
                  i.ClassificationScheme, i.AbbreviationList, i.MicrofilmedArchivalEntityCount, i.DigitizedArchivalEntityCount, i.NegativeFrameCount, i.PositiveFrameCount, i.Notes, i.NumberNumeric, f.NumberNumeric as FundNumberNumeric,
				  ast.Text as AvailabilityStatusText, i.AvailabilityStatusCode
FROM dbo.Inventories AS i INNER JOIN
                  dbo.Archives AS a ON i.ArchiveId = a.Id INNER JOIN
                  dbo.Funds AS f ON i.FundSystemIdentifier = f.SystemIdentifier LEFT OUTER JOIN
                  N.InventoryDescriptionLevel AS idl ON i.DescriptionLevelCode = idl.Code LEFT OUTER JOIN
                  N.Status AS s ON i.StatusCode = s.Code LEFT OUTER JOIN
                  dbo.AspNetUsers AS cu ON i.CreatedBy = cu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS uu ON i.UpdatedBy = uu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS du ON i.CreatedBy = du.Id
				  LEFT JOIN N.AvailabilityStatus ast ON i.AvailabilityStatusCode = ast.Code
WHERE i.IsSuspended = 0
	AND i.DescriptionLevelCode <> 6 -- груб опис 					
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER view [dbo].[v_DocumentSizeInfo]
AS

select distinct
	D.SystemIdentifier DocumentSystemIdentifier
	, D.ArchivalEntitySystemIdentifier
	, D.InventorySystemIdentifier
	, D.FundSystemIdentifier
		
	, IsNull(D.AvailabilityStatusCode,0) DocAvailabilityStatusCode
	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledDocument
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedDocument

	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then IsNull(count(DO.Id),0) else 0 end EnrolledDigitalObjectsCount
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then IsNull(count(DO.Id),0) else 0 end DeductedDigitalObjectsCount

	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(DO.FileSize,0)),0) else 0 end EnrolledBytes
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(DO.FileSize,0)),0) else 0 end DeductedBytes

	, case 
		when IsNull(D.AvailabilityStatusCode,0) = 1 then  (
			select t2.AllSplitAndDistinct from (
				select 
					STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
					from (
						select distinct trim(element) E
						from dbo.SplitString(STRING_AGG(DO.FileType, '; '), '; ')
					) t1) t2) 
		else null end FileTypes
	, 1 IsDraft
from 
	DocumentDrafts D
left outer join DigitalObjectDrafts DO on DO.DocumentSystemIdentifier = D.SystemIdentifier
where D.Deleted = 0 and D.IsCurrent = 1
and DO.Deleted = 0 and DO.IsCurrent = 1 and DO.TypeCode = 1 -- master file
group by D.SystemIdentifier, D.ArchivalEntitySystemIdentifier, D.InventorySystemIdentifier, D.FundSystemIdentifier, D.AvailabilityStatusCode


union all

select distinct
	D.SystemIdentifier DocumentSystemIdentifier
	, D.ArchivalEntitySystemIdentifier
	, D.InventorySystemIdentifier
	, D.FundSystemIdentifier

	, IsNull(D.AvailabilityStatusCode,0) DocAvailabilityStatusCode
	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledDocument
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedDocument
	
	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then IsNull(count(DO.Id),0) else 0 end EnrolledDigitalObjectsCount
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then IsNull(count(DO.Id),0) else 0 end DeductedDigitalObjectsCount

	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(DO.FileSize,0)),0) else 0 end EnrolledBytes
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(DO.FileSize,0)),0) else 0 end DeductedBytes

	, case 
		when IsNull(D.AvailabilityStatusCode,0) = 1 then  (
			select t2.AllSplitAndDistinct from (
				select 
					STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
					from (
						select distinct trim(element) E
						from dbo.SplitString(STRING_AGG(DO.FileType, '; '), '; ')
					) t1) t2) 
		else null end FileTypes
	, 0 IsDraft
from 
	Documents D
left outer join DigitalObjects DO on DO.DocumentSystemIdentifier = D.SystemIdentifier
where D.Deleted = 0 
and DO.Deleted = 0 and DO.TypeCode = 1 -- master file
group by D.SystemIdentifier, D.ArchivalEntitySystemIdentifier, D.InventorySystemIdentifier, D.FundSystemIdentifier, D.AvailabilityStatusCode

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER view [dbo].[v_InventorySizeInfo]
AS

select distinct
	A.SystemIdentifier InventorySystemIdentifier
	, A.FundSystemIdentifier 
	
	, IsNull(A.AvailabilityStatusCode,0) InventoryAvailabilityStatusCode
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledInventory
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedInventory

	, IsNull(sum(D.EnrolledArchivalEntity),0) EnrolledArchivalEntityCount
	, IsNull(sum(D.DeductedArchivalEntity),0) DeductedArchivalEntityCount

	, IsNull(sum(D.EnrolledDocumentCount),0) EnrolledDocumentCount
	, IsNull(sum(D.DeductedDocumentCount),0) DeductedDocumentCount

	, IsNull(sum(D.EnrolledBytes),0) EnrolledBytes
	, IsNull(sum(D.DeductedBytes),0) DeductedBytes
	, (
		select t2.AllSplitAndDistinct from (
			select 
				STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
				from (
					select distinct trim(element) E
					from dbo.SplitString(STRING_AGG(D.FileTypes, '; '), '; ')
				) t1) t2) FileTypes
	, 1 IsDraft
	, 1 IsNormalInventory
from 
  InventoryDrafts A
left outer join v_ArchivalEntitySizeInfo D on D.InventorySystemIdentifier = A.SystemIdentifier
where A.Deleted = 0 and A.IsCurrent = 1 and IsNull(A.DescriptionLevelCode,'5') = '5' -- normal inventory
and D.IsDraft = 1
group by A.SystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode

union all

select distinct
	A.SystemIdentifier InventorySystemIdentifier
	, A.FundSystemIdentifier 
	
	, IsNull(A.AvailabilityStatusCode,0) InventoryAvailabilityStatusCode
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledInventory
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedInventory

	, IsNull(sum(D.EnrolledArchivalEntity),0) EnrolledArchivalEntityCount
	, IsNull(sum(D.DeductedArchivalEntity),0) DeductedArchivalEntityCount

	, IsNull(sum(D.EnrolledDocumentCount),0) EnrolledDocumentCount
	, IsNull(sum(D.DeductedDocumentCount),0) DeductedDocumentCount

	, IsNull(sum(D.EnrolledBytes),0) EnrolledBytes
	, IsNull(sum(D.DeductedBytes),0) DeductedBytes
	, (
		select t2.AllSplitAndDistinct from (
			select 
				STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
				from (
					select distinct trim(element) E
					from dbo.SplitString(STRING_AGG(D.FileTypes, '; '), '; ')
				) t1) t2) FileTypes
	, 0 IsDraft
	, 1 IsNormalInventory
from 
  Inventories A
left outer join v_ArchivalEntitySizeInfo D on D.InventorySystemIdentifier = A.SystemIdentifier
where A.Deleted = 0 and IsNull(A.DescriptionLevelCode,'5') = '5' -- normal inventory
and D.IsDraft = 0
group by A.SystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode


union all


select distinct
	A.SystemIdentifier InventorySystemIdentifier
	, A.FundSystemIdentifier 
	
	, IsNull(A.AvailabilityStatusCode,0) InventoryAvailabilityStatusCode
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledInventory
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedInventory

	, 0 EnrolledArchivalEntityCount
	, 0 DeductedArchivalEntityCount

	, 0 EnrolledDocumentCount
	, 0 DeductedDocumentCount

	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) else 0 end EnrolledBytes
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) else 0 end DeductedBytes
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then STRING_AGG(D.FileType, '; ') else null end FileTypes
	, 1 IsDraft
	, 0 IsNormalInventory
from 
  InventoryDrafts A
join PackageDocument D on D.PackageId = A.PackageBId
where A.Deleted = 0 and A.IsCurrent = 1 and A.DescriptionLevelCode = '6' -- raw inventory
and A.StatusCode in ('1', '10') -- Нов, Необработен
and D.Deleted = 0
group by A.SystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode



union all


select distinct
	A.SystemIdentifier InventorySystemIdentifier
	, A.FundSystemIdentifier 
	
	, IsNull(A.AvailabilityStatusCode,0) InventoryAvailabilityStatusCode
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledInventory
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedInventory

	, 0 EnrolledArchivalEntityCount
	, 0 DeductedArchivalEntityCount

	, 0 EnrolledDocumentCount
	, 0 DeductedDocumentCount

	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) else 0 end EnrolledBytes
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) else 0 end DeductedBytes
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then STRING_AGG(D.FileType, '; ') else null end FileTypes
	, 0 IsDraft
	, 0 IsNormalInventory
from 
  Inventories A
join PackageDocument D on D.PackageId = A.PackageBId
where A.Deleted = 0 and A.DescriptionLevelCode = '6' -- raw inventory
and A.StatusCode in ('1', '10') -- Нов, Необработен
and D.Deleted = 0
group by A.SystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER view [dbo].[v_FundSizeInfo]
AS

select distinct
	A.SystemIdentifier FundSystemIdentifier

	, IsNull(sum(D.EnrolledInventory),0) EnrolledInventoryCount
	, IsNull(sum(D.DeductedInventory),0) DeductedInventoryCount

	, IsNull(sum(D.EnrolledArchivalEntityCount),0) EnrolledArchivalEntityCount
	, IsNull(sum(D.DeductedArchivalEntityCount),0) DeductedArchivalEntityCount

	, IsNull(sum(D.EnrolledDocumentCount),0) EnrolledDocumentCount
	, IsNull(sum(D.DeductedDocumentCount),0) DeductedDocumentCount
	
	, IsNull(sum(D.EnrolledBytes),0) EnrolledBytes
	, IsNull(sum(D.DeductedBytes),0) DeductedBytes

	, (
	select t2.AllSplitAndDistinct from (
		select 
			STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
			from (
				select distinct trim(element) E
				from dbo.SplitString(STRING_AGG(D.FileTypes, '; '), '; ')
			) t1) t2) FileTypes
	, 1 IsDraft
from 
  FundDrafts A
left outer join v_InventorySizeInfo D on D.FundSystemIdentifier = A.SystemIdentifier
where A.Deleted = 0 and A.IsCurrent = 1 
and D.IsDraft = 1
group by SystemIdentifier

union all


select distinct
	A.SystemIdentifier FundSystemIdentifier

	, IsNull(sum(D.EnrolledInventory),0) EnrolledInventoryCount
	, IsNull(sum(D.DeductedInventory),0) DeductedInventoryCount

	, IsNull(sum(D.EnrolledArchivalEntityCount),0) EnrolledArchivalEntityCount
	, IsNull(sum(D.DeductedArchivalEntityCount),0) DeductedArchivalEntityCount

	, IsNull(sum(D.EnrolledDocumentCount),0) EnrolledDocumentCount
	, IsNull(sum(D.DeductedDocumentCount),0) DeductedDocumentCount
	
	, IsNull(sum(D.EnrolledBytes),0) EnrolledBytes
	, IsNull(sum(D.DeductedBytes),0) DeductedBytes

	, (
		select t2.AllSplitAndDistinct from (
			select 
				STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
				from (
					select distinct trim(element) E
					from dbo.SplitString(STRING_AGG(D.FileTypes, '; '), '; ')
				) t1) t2) FileTypes
	, 0 IsDraft
from 
  Funds A
left outer join v_InventorySizeInfo D on D.FundSystemIdentifier = A.SystemIdentifier
where A.Deleted = 0 
and D.IsDraft = 0
group by SystemIdentifier

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER view [dbo].[v_ArchivalEntitySizeInfo]
AS

select distinct
	A.SystemIdentifier ArchivalEntitySystemIdentifier
	, A.InventorySystemIdentifier
	, A.FundSystemIdentifier

	, IsNull(A.AvailabilityStatusCode,0) ArchivalEntityAvailabilityStatusCode
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledArchivalEntity
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedArchivalEntity

	, IsNull(sum(D.EnrolledDocument),0) EnrolledDocumentCount
	, IsNull(sum(D.DeductedDocument),0) DeductedDocumentCount

	, IsNull(sum(D.EnrolledBytes),0) EnrolledBytes
	, IsNull(sum(D.DeductedBytes),0) DeductedBytes
	, (
		select t2.AllSplitAndDistinct from (
			select 
				STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
				from (
					select distinct trim(element) E
					from dbo.SplitString(STRING_AGG(D.FileTypes, '; '), '; ')
				) t1) t2) FileTypes
	, 1 IsDraft
from 
	ArchivalEntityDrafts A
left outer join v_DocumentSizeInfo D on D.ArchivalEntitySystemIdentifier = A.SystemIdentifier
where A.Deleted = 0 and A.IsCurrent = 1
and D.IsDraft = 1
group by A.SystemIdentifier, A.InventorySystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode

union all

select distinct
	A.SystemIdentifier ArchivalEntitySystemIdentifier
	, A.InventorySystemIdentifier
	, A.FundSystemIdentifier

	, IsNull(A.AvailabilityStatusCode,0) ArchivalEntityAvailabilityStatusCode
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledArchivalEntity
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedArchivalEntity
	
	, IsNull(sum(D.EnrolledDocument),0) EnrolledDocumentCount
	, IsNull(sum(D.DeductedDocument),0) DeductedDocumentCount
	, IsNull(sum(D.EnrolledBytes),0) EnrolledBytes
	, IsNull(sum(D.DeductedBytes),0) DeductedBytes
	, (
		select t2.AllSplitAndDistinct from (
			select 
				STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
				from (
					select distinct trim(element) E
					from dbo.SplitString(STRING_AGG(D.FileTypes, '; '), '; ')
				) t1) t2) FileTypes
	, 0 IsDraft
from 
	ArchivalEntities A
left outer join v_DocumentSizeInfo D on D.ArchivalEntitySystemIdentifier = A.SystemIdentifier
where A.Deleted = 0 
and D.IsDraft = 0
group by A.SystemIdentifier, A.InventorySystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode

GO

commit
--rollback