

--SCRIPT CLOSED! USE THE NEXT ONE!


SET XACT_ABORT ON
GO

BEGIN TRANSACTION

update dbo._Version 
set Value = '1.45'
where Code = 'DB_VERSION'
go

update dbo._Version 
set Value = '1.1.35.2'
where Code = 'APP_VERSION'
go



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[v_ApiPublicDigitalObjects]
AS

SELECT do.Id
      ,do.SystemIdentifier
	  ,do.ArchiveId
      ,a.Code as ArchiveCode
	  ,a.[Name] as ArchiveName
      ,do.FundSystemIdentifier
      ,f.Number as FundNumber
      ,do.InventorySystemIdentifier
	  ,i.Number as InventoryNumber
      ,do.ArchivalEntitySystemIdentifier
	  ,ae.Number as ArchivalEntityNumber
	  ,do.DocumentSystemIdentifier
	  ,d.Number as DocumentNumber
      ,do.CreatedOn
      ,do.CreatedBy
	  ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  , d.Title
	  , d.ApproxmateChronologicalScope
	  , d.[Location]
	  , d.[Description]
      ,do.SourceName
      ,do.FileType
	  ,do.FileSize

  FROM dbo.DigitalObjects do
  JOIN dbo.Archives a ON do.ArchiveId = a.Id
  JOIN dbo.Funds f ON do.FundSystemIdentifier = f.SystemIdentifier
  JOIN dbo.Inventories i ON do.InventorySystemIdentifier = i.SystemIdentifier
  JOIN dbo.ArchivalEntities ae ON do.ArchivalEntitySystemIdentifier = ae.SystemIdentifier 
  JOIN dbo.Documents d ON do.DocumentSystemIdentifier = d.SystemIdentifier
  LEFT JOIN dbo.AspNetUsers cu ON do.CreatedBy = cu.Id
 WHERE do.IsSuspended = 0
   AND do.TypeCode <> 1 --Само демо и производни образи
   AND do.Deleted = 0
   AND do.IsSuspended = 0
   AND do.IsDigitized = 1
   AND IsNull(do.AvailabilityStatusCode,1) = 1 /*Зачисляване*/
   AND do.StatusCode not in (4/*Заличен*/, 12 /*Отчислен*/, 10 /*Необработен*/)


GO


--SCRIPT CLOSED! USE THE NEXT ONE!

COMMIT 