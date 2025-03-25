USE [DAA]
GO

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

