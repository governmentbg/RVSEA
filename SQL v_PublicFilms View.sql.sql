USE [DAA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER view [dbo].[v_PublicFilms]
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
	,n.Code CountryCode
	,f.Deleted
FROM Films f
INNER JOIN Archives a ON f.ArchiveId = a.Id
LEFT JOIN N.Nomenclatures n ON n.Id = f.CountryId
GO