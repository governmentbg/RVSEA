
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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
      ,fd.AcquisitionMethodId
	  ,acq.Code as AcquisitionMethodCode
	  ,acq.Text as AcquisitionMethodText
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
    LEFT JOIN N.Nomenclatures acq ON fd.AcquisitionMethodId = acq.Id
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
	  ,f.AcquisitionMethodId
	  ,acq.Code as AcquisitionMethodCode
	  ,acq.Text as AcquisitionMethodText
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
	LEFT JOIN N.Nomenclatures acq ON f.AcquisitionMethodId = acq.Id
	LEFT JOIN AspNetUsers cu ON f.CreatedBy = cu.Id
	LEFT JOIN AspNetUsers uu ON f.UpdatedBy = uu.Id
	LEFT JOIN AspNetUsers du ON f.CreatedBy = du.Id
   WHERE fd.id is null
GO