-- ОСновни данни
USE DAA
GO

CREATE FULLTEXT CATALOG ftc_DAA 
WITH ACCENT_SENSITIVITY = ON
AS DEFAULT
GO

--DROP FULLTEXT CATALOG ftc_DAA
--GO

--Фондове
CREATE FULLTEXT INDEX ON dbo.Funds
(  
    ApproxmateChronologicalScope,
	DocumentsAccessDescription,
	DocumentsDescription,
	DocumentsProvider,
	FundCreatorActivityHistory,
	FundCreatorBiographicalHistory,
	FundCreatorTitleHistory,
	History,
	Notes,
	Number,
	RelatedFunds,
	Title
)  
KEY INDEX PK_Funds ON ftc_DAA  
WITH CHANGE_TRACKING AUTO  
GO

CREATE FULLTEXT INDEX ON dbo.FundDrafts
(  
    ApproxmateChronologicalScope,
	DocumentsAccessDescription,
	DocumentsDescription,
	DocumentsProvider,
	FundCreatorActivityHistory,
	FundCreatorBiographicalHistory,
	FundCreatorTitleHistory,
	History,
	Notes,
	Number,
	RelatedFunds,
	Title
)  
KEY INDEX PK_FundDrafts ON ftc_DAA  
WITH CHANGE_TRACKING AUTO  
GO

-- Описи
CREATE FULLTEXT INDEX ON dbo.Inventories
(  
	AbbreviationList,
    ApproxmateChronologicalScope,
	ClassificationScheme,
	DocumentsAccessDescription,
	DocumentsDescription,
	DocumentsProvider,
	FundCreatorBiographicalHistory,
	FundCreatorTitleHistory,
	History,
	Notes,
	Number
)  
KEY INDEX PK_Inventories ON ftc_DAA  
WITH CHANGE_TRACKING AUTO  
GO

CREATE FULLTEXT INDEX ON dbo.InventoryDrafts
(  
    AbbreviationList,
    ApproxmateChronologicalScope,
	ClassificationScheme,
	DocumentsAccessDescription,
	DocumentsDescription,
	DocumentsProvider,
	FundCreatorBiographicalHistory,
	FundCreatorTitleHistory,
	History,
	Notes,
	Number
)  
KEY INDEX PK_InventoryDrafts ON ftc_DAA  
WITH CHANGE_TRACKING AUTO  
GO


--Архивни единици
CREATE FULLTEXT INDEX ON dbo.ArchivalEntities
(  
    ApproxmateChronologicalScope,
	Author,
	Condition,
	Description,
	DocumentsAccessDescription,
	Features,
	Location,
	Notes,
	Number,
	Title
)  
KEY INDEX PK_ArchivalEntities ON ftc_DAA  
WITH CHANGE_TRACKING AUTO  
GO

CREATE FULLTEXT INDEX ON dbo.ArchivalEntityDrafts
(  
    ApproxmateChronologicalScope,
	Author,
	Condition,
	Description,
	DocumentsAccessDescription,
	Features,
	Location,
	Notes,
	Number,
	Title
)  
KEY INDEX PK_ArchivalEntityDrafts ON ftc_DAA  
WITH CHANGE_TRACKING AUTO  
GO

--Документи
CREATE FULLTEXT INDEX ON dbo.Documents
(  
    ApproxmateChronologicalScope,
	Author,
	Description,
	DocumentsAccessDescription,
	Features,
	Location,
	Notes,
	Number,
	Title,
	Transcription
)  
KEY INDEX PK_Documents ON ftc_DAA  
WITH CHANGE_TRACKING AUTO  
GO

CREATE FULLTEXT INDEX ON dbo.DocumentDrafts
(  
    ApproxmateChronologicalScope,
	Author,
	Description,
	DocumentsAccessDescription,
	Features,
	Location,
	Notes,
	Number,
	Title,
	Transcription
)  
KEY INDEX PK_DocumentDrafts ON ftc_DAA  
WITH CHANGE_TRACKING AUTO  
GO

-- Филми КМФ
CREATE FULLTEXT INDEX ON dbo.Films
(  
	Notes
)  
KEY INDEX PK_Film ON ftc_DAA  
WITH CHANGE_TRACKING AUTO  
GO

CREATE FULLTEXT INDEX ON dbo.FilmDrafts
(  
	Notes
)  
KEY INDEX PK_FilmDrafts ON ftc_DAA  
WITH CHANGE_TRACKING AUTO  
GO

-- Филмови картони
CREATE FULLTEXT INDEX ON dbo.FilmCards
(  
	City,
	DocumentsCypher,
	Title,
	ArchiveOriginals,
	Notes,
	AproximateDate,
	InventoryNumber,
	DocumentsCharacteristics
)  
KEY INDEX PK_FilmCards ON ftc_DAA  
WITH CHANGE_TRACKING AUTO  
GO

CREATE FULLTEXT INDEX ON dbo.FilmCardDrafts
(  
	City,
	DocumentsCypher,
	Title,
	ArchiveOriginals,
	Notes,
	AproximateDate,
	InventoryNumber,
	DocumentsCharacteristics
)  
KEY INDEX PK_FilmCardDrafts ON ftc_DAA  
WITH CHANGE_TRACKING AUTO  
GO

--DROP FULLTEXT INDEX ON dbo.Funds
--GO






--Файлове на ценнни електронни документи
USE [DAA.Files]
GO


CREATE FULLTEXT CATALOG ftc_DAA_Files 
WITH ACCENT_SENSITIVITY = ON
AS DEFAULT
GO

--DROP FULLTEXT CATALOG ftc_DAA_Files
--GO

--Файлове
CREATE FULLTEXT INDEX ON dbo.FileContent
(  
    file_stream TYPE COLUMN file_type
)  
KEY INDEX UI_FileContent_StreamId ON ftc_DAA_Files  
WITH CHANGE_TRACKING AUTO  
GO

--DROP FULLTEXT INDEX ON dbo.FileContent
--GO





-- Файлове в буфера
USE [DAA.BufferFiles]
GO


CREATE FULLTEXT CATALOG ftc_DAA_BufferFiles 
WITH ACCENT_SENSITIVITY = ON
AS DEFAULT
GO

--DROP FULLTEXT CATALOG ftc_DAA_BufferFiles
--GO

--Файлове
CREATE FULLTEXT INDEX ON dbo.FileContent
(  
    file_stream TYPE COLUMN file_type
)  
KEY INDEX UI_FileContent_StreamId ON ftc_DAA_BufferFiles  
WITH CHANGE_TRACKING AUTO  
GO

--DROP FULLTEXT INDEX ON dbo.FileContent
--GO






select *
FROM sys.fulltext_catalogs


SELECT OBJECT_NAME(i.object_id) as table_name
	,i.is_enabled
	,i.change_tracking_state
	,i.has_crawl_completed
	,i.crawl_type
	,c.name as fulltext_catalog_name   
FROM sys.fulltext_indexes i, sys.fulltext_catalogs c   
WHERE i.fulltext_catalog_id = c.fulltext_catalog_id

SELECT * FROM sys.fulltext_semantic_language_statistics_database;  
GO