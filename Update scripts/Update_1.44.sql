


--SCRIPT CLOSED! USE THE NEXT ONE!

SET XACT_ABORT ON
GO

BEGIN TRANSACTION

update dbo._Version 
set Value = '1.44'
where Code = 'DB_VERSION'
go

update dbo._Version 
set Value = '1.1.35.1'
where Code = 'APP_VERSION'
go


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
		--select t2.AllSplitAndDistinct from (
		--	select 
		--		STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
		--		from (
		--			select distinct trim(element) E
		--			from dbo.SplitString(STRING_AGG(D.FileTypes, '; '), '; ')
		--		) t1) t2
		(select STRING_AGG(d2.FileType, '; ') from (select distinct TRIM(d1.value) FileType from string_split(STRING_AGG(cast(D.FileTypes as nvarchar(max)), ';'), ';') d1) d2)
	  ) FileTypes
	, 1 IsDraft
	, 1 IsNormalInventory
	, sum(IsNull(D.TextDocsCount,0)) TextDocsCount
	, sum(IsNull(D.GraphicalDocsCount,0)) GraphicalDocsCount

from 
  InventoryDrafts A
left outer join v_ArchivalEntitySizeInfo D on D.InventorySystemIdentifier = A.SystemIdentifier
where A.Deleted = 0 and A.IsCurrent = 1 and IsNull(A.DescriptionLevelCode,'5') = '5' -- normal inventory
and (D.InventorySystemIdentifier is null or D.IsDraft = 1)
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
		--select t2.AllSplitAndDistinct from (
		--	select 
		--		STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
		--		from (
		--			select distinct trim(element) E
		--			from dbo.SplitString(STRING_AGG(D.FileTypes, '; '), '; ')
		--		) t1) t2
		(select STRING_AGG(d2.FileType, '; ') from (select distinct TRIM(d1.value) FileType from string_split(STRING_AGG(cast(D.FileTypes as nvarchar(max)), ';'), ';') d1) d2)
	  ) FileTypes
	, 0 IsDraft
	, 1 IsNormalInventory
	, sum(IsNull(D.TextDocsCount,0)) TextDocsCount
	, sum(IsNull(D.GraphicalDocsCount,0)) GraphicalDocsCount

from 
  Inventories A
left outer join v_ArchivalEntitySizeInfo D on D.InventorySystemIdentifier = A.SystemIdentifier
where A.Deleted = 0 and IsNull(A.DescriptionLevelCode,'5') = '5' -- normal inventory
and (D.InventorySystemIdentifier is null or D.IsDraft = 0)
group by A.SystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode


union all


select distinct
	A.SystemIdentifier InventorySystemIdentifier
	, A.FundSystemIdentifier 
	
	, IsNull(A.AvailabilityStatusCode,0) InventoryAvailabilityStatusCode
	-- 13.04.23 - do not count raw inventories as enrolled or deducted
	--, case when IsNull(A.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledInventory
	--, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedInventory
	, 0 as EnrolledInventory
	, 0 as DeductedInventory

	, 0 EnrolledArchivalEntityCount
	, 0 DeductedArchivalEntityCount

	-- 13.04.23 - files count expected as document count
	--, 0 EnrolledDocumentCount
	--, 0 DeductedDocumentCount
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then IsNull(count(D.Id), 0) else 0 end EnrolledDocumentCount
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then IsNull(count(D.Id), 0) else 0 end DeductedDocumentCount

	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) else 0 end EnrolledBytes
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) else 0 end DeductedBytes
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 
		then 
			--STRING_AGG(D.FileType, '; ') --8000 bytes error
			(select STRING_AGG(pdft.FileType, '; ') from (select distinct d1.value FileType from string_split(STRING_AGG(cast(D.FileType as nvarchar(max)), ';'), ';') d1) pdft)
		else null 
	  end FileTypes
	, 1 IsDraft
	, 0 IsNormalInventory
	, 0 TextDocsCount
	, 0 GraphicalDocsCount

from 
  InventoryDrafts A
join PackageDocument D on D.PackageId = A.PackageBId
where A.Deleted = 0 and A.IsCurrent = 1 and (A.DescriptionLevelCode = '6' OR A.DescriptionLevelCode = '12') -- raw inventory
and A.StatusCode in ('1', '2', '10') -- Нов, Регистриран, Необработен
and D.Deleted = 0
group by A.SystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode

union all

select distinct
	A.SystemIdentifier InventorySystemIdentifier
	, A.FundSystemIdentifier 
	
	, IsNull(A.AvailabilityStatusCode,0) InventoryAvailabilityStatusCode
	-- 13.04.23 - do not count raw inventories as enrolled or deducted
	--, case when IsNull(A.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledInventory
	--, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedInventory
	, 0 as EnrolledInventory
	, 0 as DeductedInventory

	, 0 EnrolledArchivalEntityCount
	, 0 DeductedArchivalEntityCount

	-- 13.04.23 - files count expected as document count
	--, 0 EnrolledDocumentCount
	--, 0 DeductedDocumentCount
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then IsNull(count(D.Id), 0) else 0 end EnrolledDocumentCount
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then IsNull(count(D.Id), 0) else 0 end DeductedDocumentCount

	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) else 0 end EnrolledBytes
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) else 0 end DeductedBytes
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 
		then 
			--STRING_AGG(D.FileType, '; ') -- 8000 bytes error
			--STRING_AGG(CAST(D.FileType as nvarchar(max)), '; ')
			--(select STRING_AGG(dft.FileType, '; ') from (select distinct ddd.FileType from PackageDocument ddd where ddd.PackageId = A.PackageBId and ddd.Deleted = 0) dft)
			(select STRING_AGG(pdft.FileType, '; ') from (select distinct d1.value FileType from string_split(STRING_AGG(cast(D.FileType as nvarchar(max)), ';'), ';') d1) pdft)
		else null 
	  end FileTypes
	, 0 IsDraft
	, 0 IsNormalInventory
	, 0 TextDocsCount
	, 0 GraphicalDocsCount
from 
  Inventories A
join PackageDocument D on D.PackageId = A.PackageBId
where A.Deleted = 0 and (A.DescriptionLevelCode = '6' OR A.DescriptionLevelCode = '12') -- raw inventory
and A.StatusCode in ('1', '2', '10') -- Нов, Регистриран, Необработен
and D.Deleted = 0
group by A.SystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode --, A.PackageBId
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   view [dbo].[v_FundSizeInfo]
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
		--select t2.AllSplitAndDistinct from (
		--	select 
		--		STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
		--		from (
		--			select distinct trim(element) E
		--			from dbo.SplitString(STRING_AGG(D.FileTypes, '; '), '; ')
		--		) t1) t2
		(select STRING_AGG(d2.FileType, '; ') from (select distinct TRIM(d1.value) FileType from string_split(STRING_AGG(cast(D.FileTypes as nvarchar(max)), ';'), ';') d1) d2)
	  ) FileTypes
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
		--select t2.AllSplitAndDistinct from (
		--	select 
		--		STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
		--		from (
		--			select distinct trim(element) E
		--			from dbo.SplitString(STRING_AGG(D.FileTypes, '; '), '; ')
		--		) t1) t2
		(select STRING_AGG(d2.FileType, '; ') from (select distinct TRIM(d1.value) FileType from string_split(STRING_AGG(cast(D.FileTypes as nvarchar(max)), ';'), ';') d1) d2)
	  ) FileTypes
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

	,IsNull(sum(IsNull(D.EnrolledDuration,0)),0) EnrolledDuration
	,IsNull(sum(IsNull(D.DeductedDuration,0)),0) DeductedDuration
	, (
		--select t2.AllSplitAndDistinct from (
		--	select 
		--		STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
		--		from (
		--			select distinct trim(element) E
		--			from dbo.SplitString(STRING_AGG(D.FileTypes, '; '), '; ')
		--		) t1) t2
		(select STRING_AGG(d2.FileType, '; ') from (select distinct TRIM(d1.value) FileType from string_split(STRING_AGG(cast(D.FileTypes as nvarchar(max)), ';'), ';') d1) d2)
	  ) FileTypes
	, 1 IsDraft
	, IsNull(A.TextDocsCount, 0) TextDocsCount
	, IsNull(A.GraphicalDocsCount, 0) GraphicalDocsCount
from 
	ArchivalEntityDrafts A
left outer join v_DocumentSizeInfo D on D.ArchivalEntitySystemIdentifier = A.SystemIdentifier
where A.Deleted = 0 and A.IsCurrent = 1
and (D.ArchivalEntitySystemIdentifier is null or D.IsDraft = 1)
group by A.SystemIdentifier, A.InventorySystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode, A.TextDocsCount, A.GraphicalDocsCount

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
	, IsNull(sum(IsNull(D.EnrolledDuration,0)),0) EnrolledDuration
	, IsNull(sum(IsNull(D.DeductedDuration,0)),0) DeductedDuration
	, (
		--select t2.AllSplitAndDistinct from (
		--	select 
		--		STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
		--		from (
		--			select distinct trim(element) E
		--			from dbo.SplitString(STRING_AGG(D.FileTypes, '; '), '; ')
		--		) t1) t2
		(select STRING_AGG(d2.FileType, '; ') from (select distinct TRIM(d1.value) FileType from string_split(STRING_AGG(cast(D.FileTypes as nvarchar(max)), ';'), ';') d1) d2)
	  ) FileTypes
	, 0 IsDraft
	, IsNull(A.TextDocsCount, 0) TextDocsCount
	, IsNull(A.GraphicalDocsCount, 0) GraphicalDocsCount
from 
	ArchivalEntities A
left outer join v_DocumentSizeInfo D on D.ArchivalEntitySystemIdentifier = A.SystemIdentifier
where A.Deleted = 0 
and (D.ArchivalEntitySystemIdentifier is null or D.IsDraft = 0)
group by A.SystemIdentifier, A.InventorySystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode, A.TextDocsCount, A.GraphicalDocsCount
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

	-- for master files
	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then IsNull(count(case when DO.TypeCode = 1 then DO.Id end),0) else 0 end EnrolledDigitalObjectsCount
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then IsNull(count(case when DO.TypeCode = 1 then DO.Id end),0) else 0 end DeductedDigitalObjectsCount

	-- for master files
	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(case when DO.TypeCode = 1 then DO.FileSize end,0)),0) else 0 end EnrolledBytes
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(case when DO.TypeCode = 1 then DO.FileSize end,0)),0) else 0 end DeductedBytes

	-- for master files
	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(case when DO.TypeCode = 1 then DO.Duration end,0)),0) else 0 end EnrolledDuration
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(case when DO.TypeCode = 1 then DO.Duration end,0)),0) else 0 end DeductedDuration

	-- for all files
	, case 
		when IsNull(D.AvailabilityStatusCode,0) = 1 
		then 
		(
			--select t2.AllSplitAndDistinct from (
			--	select 
			--		STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
			--		from (
			--			select distinct trim(element) E
			--			from dbo.SplitString(STRING_AGG(DO.FileType, '; '), '; ')
			--		) t1) t2
			(select STRING_AGG(d2.FileType, '; ') from (select distinct TRIM(d1.value) FileType from string_split(STRING_AGG(cast(DO.FileType as nvarchar(max)), ';'), ';') d1) d2)
		) 
		else null end FileTypes
	, 1 IsDraft
	, IsNull(D.TextDocsCount, 0) TextDocsCount
	, IsNull(D.GraphicalDocsCount, 0) GraphicalDocsCount
from 
	DocumentDrafts D
left outer join DigitalObjectDrafts DO on DO.DocumentSystemIdentifier = D.SystemIdentifier
where D.Deleted = 0 and D.IsCurrent = 1
and (DO.Id is null or (DO.Deleted = 0 and DO.IsCurrent = 1)) 
group by D.SystemIdentifier, D.ArchivalEntitySystemIdentifier, D.InventorySystemIdentifier, D.FundSystemIdentifier, D.AvailabilityStatusCode, D.TextDocsCount, D.GraphicalDocsCount


union all

select distinct
	D.SystemIdentifier DocumentSystemIdentifier
	, D.ArchivalEntitySystemIdentifier
	, D.InventorySystemIdentifier
	, D.FundSystemIdentifier

	, IsNull(D.AvailabilityStatusCode,0) DocAvailabilityStatusCode
	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledDocument
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedDocument
	
	-- for master files
	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then IsNull(count(case when DO.TypeCode = 1 then DO.Id end),0) else 0 end EnrolledDigitalObjectsCount
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then IsNull(count(case when DO.TypeCode = 1 then DO.Id end),0) else 0 end DeductedDigitalObjectsCount

	-- for master files
	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(case when DO.TypeCode = 1 then DO.FileSize end,0)),0) else 0 end EnrolledBytes
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(case when DO.TypeCode = 1 then DO.FileSize end,0)),0) else 0 end DeductedBytes

	-- for master files
	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(case when DO.TypeCode = 1 then DO.Duration end,0)),0) else 0 end EnrolledDuration
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(case when DO.TypeCode = 1 then DO.Duration end,0)),0) else 0 end DeductedDuration

	-- for all files
	, case 
		when IsNull(D.AvailabilityStatusCode,0) = 1 
		then  
		(
			--select t2.AllSplitAndDistinct from (
			--	select 
			--		STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
			--		from (
			--			select distinct trim(element) E
			--			from dbo.SplitString(STRING_AGG(DO.FileType, '; '), '; ')
			--		) t1) t2
			(select STRING_AGG(d2.FileType, '; ') from (select distinct TRIM(d1.value) FileType from string_split(STRING_AGG(cast(DO.FileType as nvarchar(max)), ';'), ';') d1) d2)
		) 
		else null end FileTypes
	, 0 IsDraft
	, IsNull(D.TextDocsCount, 0) TextDocsCount
	, IsNull(D.GraphicalDocsCount, 0) GraphicalDocsCount
from 
	Documents D
left outer join DigitalObjects DO on DO.DocumentSystemIdentifier = D.SystemIdentifier
where D.Deleted = 0 
and (DO.Id is null or (DO.Deleted = 0)) 
group by D.SystemIdentifier, D.ArchivalEntitySystemIdentifier, D.InventorySystemIdentifier, D.FundSystemIdentifier, D.AvailabilityStatusCode, D.TextDocsCount, D.GraphicalDocsCount
GO



--SCRIPT CLOSED! USE THE NEXT ONE!

COMMIT 