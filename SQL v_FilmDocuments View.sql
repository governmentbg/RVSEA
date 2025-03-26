
CREATE OR ALTER view [dbo].[v_FilmDocuments]
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


