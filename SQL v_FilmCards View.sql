CREATE OR ALTER  view [dbo].[v_FilmCards]
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
	  ,fid.InventoryNumber as FilmInventoryNumber
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
	LEFT JOIN FilmDrafts fid on fd.FilmSystemIdentifier = fid.SystemIdentifier and fid.IsCurrent = 1
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
	  ,fi.InventoryNumber as FilmInventoryNumber
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
	LEFT JOIN Films fi on f.FilmSystemIdentifier = fi.SystemIdentifier
	LEFT JOIN FilmCardDrafts fd on f.SystemIdentifier = fd.SystemIdentifier and fd.IsCurrent = 1
	LEFT JOIN N.Nomenclatures nc ON nc.Id = f.CountryId
	LEFT JOIN N.Nomenclatures ne ON ne.Id = f.FilmingExtentId
	LEFT JOIN AspNetUsers cu ON f.CreatedBy = cu.Id
	LEFT JOIN AspNetUsers uu ON f.UpdatedBy = uu.Id
	LEFT JOIN AspNetUsers du ON f.CreatedBy = du.Id
   WHERE fd.id is null
GO
