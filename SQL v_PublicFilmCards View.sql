USE [DAA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER view [dbo].[v_PublicFilmCards]
AS
SELECT 
	fc.Id
	,fc.SystemIdentifier
	,CAST(0 as bit) as IsDraft
	,fc.InventoryNumber
	,f.InventoryNumber as FilmInventoryNumber
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
LEFT JOIN Films f on fc.FilmSystemIdentifier = f.SystemIdentifier
LEFT JOIN N.Nomenclatures n ON n.Id = fc.CountryId
GO
