SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.29'
where Code = 'DB_VERSION'
go

--SIgnature requests -- TODO Check if exists
CREATE TABLE dbo.SignatureRequests(
	[Id] int IDENTITY(1,1) NOT NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[Deleted] [bit] NOT NULL CONSTRAINT [DF_Deleted] DEFAULT 0,
	[DeletedBy] [uniqueidentifier] NULL,
	[DeletedOn] [datetime2](7) NULL,
	[ArchiveId] int NOT NULL,
	[ProcessId] int NOT NULL,
	[ProcessStepId] int NOT NULL,
	[ApplicationId] int NULL,
	[PackageId] int NOT NULL,
	[PackageDocumentId] int NOT NULL,
	[SigningUserId] uniqueidentifier NOT NULL,
	[Completed] bit NOT NULL CONSTRAINT [DF_Completed] DEFAULT 0,
 CONSTRAINT [PK_SignatureRequests] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


ALTER TABLE dbo.SignatureRequests  WITH CHECK ADD  CONSTRAINT [FK_SignatureRequests_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES dbo.AspNetUsers (Id)
GO

ALTER TABLE dbo.SignatureRequests CHECK CONSTRAINT [FK_SignatureRequests_CreatedBy]
GO

ALTER TABLE dbo.SignatureRequests  WITH CHECK ADD  CONSTRAINT [FK_SignatureRequests_UpdatedBy] FOREIGN KEY(UpdatedBy)
REFERENCES dbo.AspNetUsers (Id)
GO

ALTER TABLE dbo.SignatureRequests CHECK CONSTRAINT [FK_SignatureRequests_UpdatedBy]
GO


ALTER TABLE dbo.SignatureRequests  WITH CHECK ADD  CONSTRAINT [FK_SignatureRequests_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES dbo.AspNetUsers (Id)
GO

ALTER TABLE dbo.SignatureRequests CHECK CONSTRAINT [FK_SignatureRequests_DeletedBy]
GO


ALTER TABLE dbo.SignatureRequests  WITH CHECK ADD  CONSTRAINT [FK_SignatureRequests_Archive] FOREIGN KEY(ArchiveId)
REFERENCES dbo.Archives (Id)
GO

ALTER TABLE dbo.SignatureRequests CHECK CONSTRAINT [FK_SignatureRequests_Archive]
GO


ALTER TABLE dbo.SignatureRequests  WITH CHECK ADD  CONSTRAINT [FK_SignatureRequests_Process] FOREIGN KEY(ProcessId)
REFERENCES dbo.Process (Id)
GO

ALTER TABLE dbo.SignatureRequests CHECK CONSTRAINT [FK_SignatureRequests_Process]
GO

ALTER TABLE dbo.SignatureRequests  WITH CHECK ADD  CONSTRAINT [FK_SignatureRequests_ProcessTimeline] FOREIGN KEY(ProcessStepId)
REFERENCES dbo.ProcessTimeline (Id)
GO

ALTER TABLE dbo.SignatureRequests CHECK CONSTRAINT [FK_SignatureRequests_ProcessTimeline]
GO


ALTER TABLE dbo.SignatureRequests  WITH CHECK ADD  CONSTRAINT [FK_SignatureRequests_Application] FOREIGN KEY(ApplicationId)
REFERENCES dbo.EDocsCollectingApplication (Id)
GO

ALTER TABLE dbo.SignatureRequests CHECK CONSTRAINT [FK_SignatureRequests_Application]
GO

ALTER TABLE dbo.SignatureRequests  WITH CHECK ADD  CONSTRAINT [FK_SignatureRequests_Package] FOREIGN KEY(PackageId)
REFERENCES dbo.Packages (Id)
GO

ALTER TABLE dbo.SignatureRequests CHECK CONSTRAINT [FK_SignatureRequests_Package]
GO

ALTER TABLE dbo.SignatureRequests  WITH CHECK ADD  CONSTRAINT [FK_SignatureRequests_PackageDocument] FOREIGN KEY(PackageDocumentId)
REFERENCES dbo.PackageDocument (Id)
GO

ALTER TABLE dbo.SignatureRequests CHECK CONSTRAINT [FK_SignatureRequests_PackageDocument]
GO


ALTER TABLE dbo.SignatureRequests  WITH CHECK ADD  CONSTRAINT [FK_SignatureRequests_SigningUser] FOREIGN KEY(SigningUserId)
REFERENCES dbo.AspNetUsers (Id)
GO

ALTER TABLE dbo.SignatureRequests CHECK CONSTRAINT [FK_SignatureRequests_SigningUser]
GO
--END Signature requests


-- Process steps
if ((select count(id) from n.ProcessSteps where Code = 'SignatureRequest' and ProcessTypeId is null ) = 0)
	insert into n.ProcessSteps (id, ProcessTypeId, Code, Text) values (1017, NULL, 'SignatureRequest', 'Изпратени документи за е-подпис')
go

if ((select count(id) from n.ProcessSteps where Code = 'SignedDocuments' and ProcessTypeId is null ) = 0)
	insert into n.ProcessSteps (id, ProcessTypeId, Code, Text) values (1018, NULL, 'SignedDocuments', 'Подписани с е-подпис документи')
go
--END Process steps

-- Notifications
IF NOT EXISTS (SELECT 1 FROM N.NotificationType WHERE Code = 'RequestSignature')
BEGIN
	INSERT INTO N.NotificationType (Code, Text)
	VALUES ('RequestSignature', 'Изискан е-подпис върху документи')
END

IF NOT EXISTS (SELECT 1 FROM N.NotificationType WHERE Code = 'SignedDocuments')
BEGIN
	INSERT INTO N.NotificationType (Code, Text)
	VALUES ('SignedDocuments', 'Подписани с е-подпис документи')
END
GO

IF NOT EXISTS(SELECT 1 FROM Notification.NotificationTemplate WHERE NotificationTypeCode = 'RequestSignature')
BEGIN
	INSERT INTO Notification.NotificationTemplate (NotificationTypeCode, Subject, Body)
	VALUES('RequestSignature', 'Приложени документи за електронно подписване', '<p>Към #applicationType# с номер #applicationNumber# са приложени документи, които е необходимо да бъдат подписани с електронен подпис. </p>')
END
GO
--END Notifications

-- Application
IF NOT EXISTS (SELECT 1 FROM N.EDocsCollectingApplicationStatuses WHERE Id = 15)
BEGIN
	INSERT INTO N.EDocsCollectingApplicationStatuses (Text, TextEn)
	VALUES ('Подписване на документи', 'Signature request')
END
GO

IF NOT EXISTS (SELECT 1 FROM N.EDocsCollectingApplicationStatuses WHERE Id = 16)
BEGIN
	INSERT INTO N.EDocsCollectingApplicationStatuses (Text, TextEn)
	VALUES ('Подписани документи', 'Signed documents')
END
GO
--END Application

--Task templates
if not exists (select null from TaskTemplates where Title = N'Подписани с е-подпис документи')
begin 
	declare @id int

	insert into TaskTemplates(Title, Description, RelatedContentUrl)
	values(N'Подписани с е-подпис документи', '<p>Към #applicationType# с номер #applicationNumber# са приложени документи, подписани с електронен подпис.</p>', '#internalDisplayUrl#')
	set @id = SCOPE_IDENTITY()

	insert into TaskTemplatesSteps(TaskTemplate_Id, ProcessStep_Id)
	values(@id, 1018)
end 
go
--END Task templates


--ADD SCRIPTS HERE. USE GO AFTER EVERY BATCH

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[GetCardForm1]
	@LinkedServer NVARCHAR(50) = '',
	@FundIdentifier UNIQUEIDENTIFIER = NULL,
	@FundHasExternalSource bit,
	@FundExternalIdentifier int = NULL,
	@RowsOfPage INT = 5000,
	@Page INT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteInventoriesQuery nvarchar(max) = '';

	DECLARE @RemoteInventories TABLE 
	(
		Id INT NULL,
		SystemIdentifier uniqueidentifier NULL,
		LGid INT NULL,
		YearCreatedAndInventoryNumber VARCHAR(50) NULL,
		EndDates VARCHAR(50) NULL,
		InventorizedCount VARCHAR(50) NULL,
		UninventorizedCount VARCHAR(50) NULL,
		DeductedCount VARCHAR(50) NULL,
		AvailableArchivalEntitiesCountAndSize VARCHAR(50) NULL,
		MicrofilmedArchivalOfEntityCount INT NULL,
		NegativeFramesCount INT NULL,
		PositiveFramesCount INT NULL,
		PhonoDocumentsCount INT NULL,
		PhotoDocumentsCount INT NULL,
		VideoDocumentsCount INT NULL,
		DigitalDocumentCount INT NULL,
		IntNumber INT NULL,
		Number NVARCHAR(256) NULL,
		_id INT NULL,
		DocumentsCount INT NULL
	);

	DECLARE @LocalInventories TABLE 
	(
		Id INT NULL,
		SystemIdentifier uniqueidentifier NULL,
		LGid INT NULL,
		YearCreatedAndInventoryNumber VARCHAR(50) NULL,
		EndDates VARCHAR(50) NULL,
		InventorizedCount VARCHAR(50) NULL,
		UninventorizedCount VARCHAR(50) NULL,
		DeductedCount VARCHAR(50) NULL,
		AvailableArchivalEntitiesCountAndSize VARCHAR(50) NULL,
		MicrofilmedArchivalOfEntityCount INT NULL,
		NegativeFramesCount INT NULL,
		PositiveFramesCount INT NULL,
		PhonoDocumentsCount INT NULL,
		PhotoDocumentsCount INT NULL,
		VideoDocumentsCount INT NULL,
		DigitalDocumentCount INT NULL,
		IntNumber INT NULL,
		Number NVARCHAR(256) NULL,
		_id INT NULL,
		DocumentsCount INT NULL	
	); 

	IF @FundHasExternalSource = 1
	BEGIN
			SET @RemoteInventoriesQuery = CAST('' as nvarchar(max)) +
			 'SELECT
				 NULL as Id
				,CAST(NULL as uniqueidentifier) as SystemIdentifier
				,inventory.[LGid] as LGid
				,CONVERT(VARCHAR(50), YEAR(inventory.[CreationDate]), 104) + '''';'''' + ISNULL(inventory.[Number], '''''''') AS YearCreatedAndInventoryNumber
				,COALESCE
				 (
					CONVERT(VARCHAR(10), inventory.[StartDateYear], 104) + '''';'''' + CONVERT(VARCHAR(100), inventory.[EndDateYear], 104),
					CONVERT(VARCHAR(10), inventory.[StartDateYear], 104) + '''';'''',
					'''';'''' + CONVERT(VARCHAR(100), inventory.[EndDateYear], 104)
				 ) AS EndDates
				,CASE
					WHEN inventory.[LevelOfDescriptionGid] IN (2171, 2372) THEN inventory.[AECount]
					ELSE NULL
					END AS InventorizedCount,
				 CASE
					WHEN inventory.[LevelOfDescriptionGid] = 2172 THEN inventory.[AECount]
					ELSE NULL
					END AS UnInventorizedCount
				,NULL AS DeductedCount
				,CONVERT(VARCHAR(50), inventory.[AECount], 104)
							+ '''';'''' + CONVERT(VARCHAR(50), inventory.[LinearMeter], 104) AS AvailableArchivalEntitiesCountAndSize
				,inventory.[CopyMicrofilmAE] AS MicrofilmedArchivalOfEntityCount
				,inventory.[CopyNegativFrames] AS NegativeFramesCount
				,inventory.[CopyPositiveFrames] AS PositiveFramesCount
				,inventory.[AEFonoDocsCount] AS PhonoDocumentsCount
				,inventory.[AEPhotoDocsCount] AS PhotoDocumentsCount
				,inventory.[AEVideoAudioDocsCount] AS VideoDocumentsCount
				,CAST(NULL as INT) as DigitalDocumentCount
				,inventory.[IntNumber] AS IntNumber
				,inventory.[Number] as Number
				,inventory.[_id] AS _id
				,CAST(NULL as INT) as DocumentsCount

			FROM [Archiving].[dbo].[Inventory_Modified] inventory
			WHERE inventory.[FundLGid] = ' + CAST(@FundExternalIdentifier as nvarchar(50));
			DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteInventoriesQuery + ''' )';
			print @RemoteQuery
			INSERT INTO @RemoteInventories 
			exec(@RemoteQuery)
	END

	IF @FundIdentifier IS NOT NULL
	BEGIN
		INSERT INTO @LocalInventories
		SELECT
			 inventory.Id
			,inventory.SystemIdentifier as SystemIdentifier
			,NULL AS LGid
			,CONVERT(VARCHAR(50), inventory.[CreatedOn], 104) + ';' + ISNULL(inventory.[Number],'') AS YearCreatedAndInventoryNumber
			,COALESCE(
						CONVERT(VARCHAR(50), inventory.[StartDateYear], 104) + ';' + CONVERT(VARCHAR(50), inventory.[EndDateYear], 104),
						CONVERT(VARCHAR(50), inventory.[StartDateYear], 104) + ';',
						';' + CONVERT(VARCHAR(50), inventory.[EndDateYear], 104)
					) AS EndDates
			,CASE
				   WHEN inventory.[DescriptionLevelCode] <> 6 THEN CONVERT(VARCHAR(50), inventory.[ArchivalEntityCount], 10) 
					+ ';' + CONVERT(VARCHAR(50), ISNULL(dbo.ConvertBytesToMB(inventory.Bytes), 0)) + 'MB'
					ELSE NULL
					END AS InventorizedCount,
			CASE
					WHEN inventory.[DescriptionLevelCode] = 6 THEN CONVERT(VARCHAR(50), inventory.[ArchivalEntityCount], 10) 
					ELSE NULL
					END AS UnInventorizedCount
			,NULL AS DeductedCount
			,CONVERT(VARCHAR(50), inventory.ArchivalEntityCount, 104)
				+ ';' + CONVERT(VARCHAR(50), dbo.ConvertBytesToMB(ISNULL(inventory.Bytes, 0)), 104) 
				+ 'MB' AS AvailableArchivalEntitiesCountAndSize
			,NULL AS MicrofilmedArchivalOfEntityCount
			,NULL AS NegativeFramesCount
			,NULL AS PositiveFramesCount
			,NULL AS PhonoDocumentsCount
			,NULL AS PhotoDocumentsCount
			,NULL AS VideoDocumentsCount
			,inventory.[DocumentCount] AS DigitalDocumentCount
			,inventory.[NumberNumeric] AS IntNumber
			,inventory.Number AS Number
			,NULL AS _id
			,NULL AS DocumentCount
		
		FROM [dbo].[v_Inventories] inventory
		WHERE inventory.FundSystemIdentifier = @FundIdentifier 
			AND inventory.HasExternalSource = 0
			AND inventory.Deleted = 0
	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalInventories
		  UNION
		 SELECT *
		   FROM @RemoteInventories
	   ) inventories
	ORDER BY IntNumber, Number, _id
	OFFSET ((@Page - 1) * @RowsOfPage) ROWS FETCH NEXT @RowsOfPage ROWS ONLY
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER  PROCEDURE [dbo].[GetCardForm1TotalRows]
	@LinkedServer NVARCHAR(50) = '',
	@FundIdentifier UNIQUEIDENTIFIER = NULL,
	@FundHasExternalSource bit,
	@FundExternalIdentifier int = NULL,
	@RowsOfPage INT = 5000,
	@Page INT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @InternalRows BIGINT;

	DECLARE @ExternalRows BIGINT;

	DECLARE @resultTable TABLE
		(
			[Rows] INT NULL
		);
		
	IF @FundHasExternalSource = 1
	 BEGIN
		DECLARE @sql VARCHAR(MAX) = '
			DECLARE @resultTable TABLE
			(
				Rows INT NULL
			);		
				
			SET NOCOUNT ON;
			SET FMTONLY OFF;	

			DECLARE @inventoriesTable TABLE
			(
				LGid INT NULL,
				RowNumber INT NOT NULL
			);

			INSERT INTO @inventoriesTable 
				SELECT 
					LGid, 
					ROW_NUMBER() OVER(ORDER BY LGid ASC) AS RowNumber
				FROM Inventory
				WHERE FundLGid = ''' + CONVERT(VARCHAR(10), @FundExternalIdentifier) + ''' AND _retired = ''3000-01-01''
				GROUP BY LGid;

			DECLARE @Counter INT; 
			SET @Counter = 1;
			DECLARE @inventoriesCount INT = 
			( 
				SELECT COUNT(LGid) c 
				FROM @inventoriesTable
			);
			WHILE (@Counter <= @inventoriesCount)
			BEGIN
				DECLARE @currentLGid INT = 
				(
					SELECT LGid 
					FROM @inventoriesTable
					WHERE RowNumber = @Counter
				);

				INSERT INTO @resultTable
					SELECT TOP(1) 1
					FROM (
						SELECT 
							ROW_NUMBER() OVER(ORDER BY Gid ASC) AS RowNumber,
							LGid
						FROM Inventory
						WHERE LGid = @currentLGid
							AND EXISTS (SELECT 1 FROM Inventory i0 WHERE i0._retired = ''3000-01-01'' AND LGid = i0.LGid) -- няма активен процес
					) i1;
		
				INSERT INTO @resultTable
					SELECT  
						COUNT_BIG(*)
					FROM 
					(
						SELECT 
							ROW_NUMBER() OVER(ORDER BY _id ASC) AS RowNumber, 
							LGid,
							AECount,
							LinearMeter
						FROM Inventory
						WHERE LGid = @currentLGid
					) i1
					INNER JOIN 
					(
						SELECT 
							ROW_NUMBER() OVER(ORDER BY _id ASC) AS RowNumber, 
							LGid,
							AECount,
							LinearMeter
						FROM Inventory
						WHERE LGid = @currentLGid
							AND EXISTS (SELECT 1 FROM Inventory i0 WHERE i0._retired = ''3000-01-01'' AND LGid = i0.LGid) -- няма активен процес
					) i2 ON 
					i2.RowNumber=i1.RowNumber + 1 
						AND (ISNULL(i2.AECount, 0) - ISNULL(i1.AECount, 0) <> 0 OR ABS(ISNULL(i2.LinearMeter, 0) - ISNULL(i1.LinearMeter, 0)) > 0.01); 
				SET @Counter  = @Counter  + 1; 
			END

			SELECT ISNULL(SUM(CAST(Rows AS BIGINT)), 0) AS TotalRows FROM @resultTable; -- тук няма нужда от bigint, но това се очаква
		'; 

		SET @sql = REPLACE(@sql, '''', '''''');

		INSERT INTO @resultTable
		EXEC ('SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''')');

		set @ExternalRows = (SELECT top(1) [Rows] from @resultTable)

	END

	IF @FundIdentifier IS NOT NULL
		BEGIN
			SELECT @InternalRows = CAST(COUNT(SystemIdentifier) AS BIGINT)
			FROM v_Inventories
			WHERE FundSystemIdentifier= @FundIdentifier; 
		END

	SELECT ISNULL(@ExternalRows, 0) + ISNULL(@InternalRows, 0) AS  TotalRows
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetCardForm1FundDataInernal] 
	@SystemIdentifier UNIQUEIDENTIFIER = NULL,
	@RowsOfPage INT = 5000,
	@Page INT = 1
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		a.[Name] AS Archive,
		a.Code AS ArchiveCode,
		fund.Number AS Number,
		fund.Title,
		t.Text AS Type,
		convert(varchar, fund.CreatedOn, 104) AS CreationDate,
		(select Text + ';'
			from NomenclatureValues nv
			join N.Nomenclatures n1 on 
				nv.EntityType='fund' 
				and nv.Deleted=0
				and n1.Deleted=0
				and nv.NomenclatureCode='INDUSTRY_TYPE'
				and nv.EntityId=fund.Id
				and n1.Id=nv.ValueId
			FOR XML path(''), elements) as IndustryIndex,
		n1.Text as MethodOfAcquisition,
		fsi.EnrolledInventoryCount AS InventoriesCount,
		fsi.EnrolledArchivalEntityCount AS ArchivalEntitiesCount,
		fsi.EnrolledBytes AS Size
	FROM Funds as fund
	LEFT JOIN N.Nomenclatures n1 ON fund.AcquisitionMethodId = n1.Id
	LEFT JOIN v_FundSizeInfo as fsi ON fund.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
	INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
	LEFT JOIN N.FundType t ON t.Code = TypeCode 
	WHERE SystemIdentifier = @SystemIdentifier;
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[GetCardForm1FundDataExternal] 
	@LinkedServer NVARCHAR(50),
	@LGid INT = NULL,
	@RowsOfPage INT = 5000,
	@Page INT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX) = '';

	IF @LGid IS NOT NULL
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '	
			SELECT
				a.Name as Archive,
				a.Code as ArchiveCode,
				fund.Number,
				fund.Title,
				(SELECT Value FROM Nomenclature n WHERE n._retired=''3000-01-01'' AND n.Type = ''FundType'' AND n.Gid = fund.TypeGid) AS Type,
				convert(varchar, fund.CreationDate, 104) AS CreationDate,
				(
					select Value2 + '';''
					from  Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''IndustryIndex''
					FOR XML path(''''), elements
				) AS IndustryIndex,
				(select Value + '';''
					from  Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''MethodOfAcquisition''
					FOR XML path(''''), elements
				) as MethodOfAcquisition,
				fund.InvetoryCount AS InventoriesCount,
				fund.AECount AS ArchivalEntitiesCount,
				fund.LinearMeters,
				NULL AS Size
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE LGid = ''' + CONVERT(VARCHAR(10), @LGid) + ''';
		';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');	

		EXEC ('SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');')	
		RETURN;
	END
END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[GetCardForm1A]
	@LinkedServer NVARCHAR(50) = '',
	@SystemIdentifier UNIQUEIDENTIFIER = NULL,
	@HasExternalSource bit,
	@ExternalIdentifier int = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteInventoriesQuery nvarchar(max) = '';

	DECLARE @RemoteInventories TABLE 
	(
		Id INT NULL,
		SystemIdentifier uniqueidentifier NULL,
		LGid INT NULL,
		YearCreatedAndInventoryNumber VARCHAR(50) NULL,
		EndDates VARCHAR(50) NULL,
		InventorizedCount VARCHAR(50) NULL,
		UninventorizedCount VARCHAR(50) NULL,
		DeductedCount VARCHAR(50) NULL,
		AvailableArchivalEntitiesCountAndSize VARCHAR(50) NULL,
		MicrofilmedArchivalOfEntityCount INT NULL,
		NegativeFramesCount INT NULL,
		PositiveFramesCount INT NULL,
		PhonoDocumentsCount INT NULL,
		PhotoDocumentsCount INT NULL,
		VideoDocumentsCount INT NULL,
		DigitalDocumentCount INT NULL,
		IntNumber INT NULL,
		Number NVARCHAR(256) NULL,
		_id INT NULL,
		DocumentsCount INT NULL
	);

	DECLARE @LocalInventories TABLE 
	(
		Id INT NULL,
		SystemIdentifier uniqueidentifier NULL,
		LGid INT NULL,
		YearCreatedAndInventoryNumber VARCHAR(50) NULL,
		EndDates VARCHAR(50) NULL,
		InventorizedCount VARCHAR(50) NULL,
		UninventorizedCount VARCHAR(50) NULL,
		DeductedCount VARCHAR(50) NULL,
		AvailableArchivalEntitiesCountAndSize VARCHAR(50) NULL,
		MicrofilmedArchivalOfEntityCount INT NULL,
		NegativeFramesCount INT NULL,
		PositiveFramesCount INT NULL,
		PhonoDocumentsCount INT NULL,
		PhotoDocumentsCount INT NULL,
		VideoDocumentsCount INT NULL,
		DigitalDocumentCount INT NULL,
		IntNumber INT NULL,
		Number NVARCHAR(256) NULL,
		_id INT NULL,
		DocumentsCount INT NULL	
	); 

	IF @HasExternalSource = 1
	BEGIN
			SET @RemoteInventoriesQuery = CAST('' as nvarchar(max)) +
			 'SELECT
				 NULL as Id
				,CAST(NULL as uniqueidentifier) as SystemIdentifier
				,inventory.[LGid] as LGid
				,CONVERT(VARCHAR(50), YEAR(inventory.[CreationDate]), 104) + '''';'''' + ISNULL(inventory.[Number], '''''''') AS YearCreatedAndInventoryNumber
				,COALESCE
				 (
					CONVERT(VARCHAR(10), inventory.[StartDateYear], 104) + '''';'''' + CONVERT(VARCHAR(100), inventory.[EndDateYear], 104),
					CONVERT(VARCHAR(10), inventory.[StartDateYear], 104) + '''';'''',
					'''';'''' + CONVERT(VARCHAR(100), inventory.[EndDateYear], 104)
				 ) AS EndDates
				,CASE
					WHEN inventory.[LevelOfDescriptionGid] IN (2171, 2372) THEN inventory.[AECount]
					ELSE NULL
					END AS InventorizedCount,
				 CASE
					WHEN inventory.[LevelOfDescriptionGid] = 2172 THEN inventory.[AECount]
					ELSE NULL
					END AS UnInventorizedCount
				,NULL AS DeductedCount
				,CONVERT(VARCHAR(50), inventory.[AECount], 104)
							+ '''';'''' + CONVERT(VARCHAR(50), inventory.[LinearMeter], 104) AS AvailableArchivalEntitiesCountAndSize
				,inventory.[CopyMicrofilmAE] AS MicrofilmedArchivalOfEntityCount
				,inventory.[CopyNegativFrames] AS NegativeFramesCount
				,inventory.[CopyPositiveFrames] AS PositiveFramesCount
				,inventory.[AEFonoDocsCount] AS PhonoDocumentsCount
				,inventory.[AEPhotoDocsCount] AS PhotoDocumentsCount
				,inventory.[AEVideoAudioDocsCount] AS VideoDocumentsCount
				,CAST(NULL as INT) as DigitalDocumentCount
				,inventory.[IntNumber] AS IntNumber
				,inventory.[Number] as Number
				,inventory.[_id] AS _id
				,CAST(NULL as INT) as DocumentsCount

			FROM [Archiving].[dbo].[Inventory_Modified] inventory
			WHERE inventory.[LGid] = ' + CAST(@ExternalIdentifier as nvarchar(50));
			DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteInventoriesQuery + ''' )';
			print @RemoteQuery
			INSERT INTO @RemoteInventories 
			exec(@RemoteQuery)
	END

	IF @SystemIdentifier IS NOT NULL
	BEGIN
		INSERT INTO @LocalInventories
		SELECT
			 inventory.Id
			,inventory.SystemIdentifier as SystemIdentifier
			,NULL AS LGid
			,CONVERT(VARCHAR(50), inventory.[CreatedOn], 104) + ';' + ISNULL(inventory.[Number],'') AS YearCreatedAndInventoryNumber
			,COALESCE(
						CONVERT(VARCHAR(50), inventory.[StartDateYear], 104) + ';' + CONVERT(VARCHAR(50), inventory.[EndDateYear], 104),
						CONVERT(VARCHAR(50), inventory.[StartDateYear], 104) + ';',
						';' + CONVERT(VARCHAR(50), inventory.[EndDateYear], 104)
					) AS EndDates
			,CASE
				   WHEN inventory.[DescriptionLevelCode] <> 6 THEN CONVERT(VARCHAR(50), inventory.[ArchivalEntityCount], 10) 
					+ ';' + CONVERT(VARCHAR(50), ISNULL(dbo.ConvertBytesToMB(inventory.Bytes), 0)) + 'MB'
					ELSE NULL
					END AS InventorizedCount,
			CASE
					WHEN inventory.[DescriptionLevelCode] = 6 THEN CONVERT(VARCHAR(50), inventory.[ArchivalEntityCount], 10) 
					ELSE NULL
					END AS UnInventorizedCount
			,NULL AS DeductedCount
			,CONVERT(VARCHAR(50), inventory.ArchivalEntityCount, 104)
				+ ';' + CONVERT(VARCHAR(50), dbo.ConvertBytesToMB(ISNULL(inventory.Bytes, 0)), 104) 
				+ 'MB' AS AvailableArchivalEntitiesCountAndSize
			,NULL AS MicrofilmedArchivalOfEntityCount
			,NULL AS NegativeFramesCount
			,NULL AS PositiveFramesCount
			,NULL AS PhonoDocumentsCount
			,NULL AS PhotoDocumentsCount
			,NULL AS VideoDocumentsCount
			,inventory.[DocumentCount] AS DigitalDocumentCount
			,inventory.[NumberNumeric] AS IntNumber
			,inventory.Number AS Number
			,NULL AS _id
			,NULL AS DocumentCount
		
		FROM [dbo].[v_Inventories] inventory
		WHERE inventory.SystemIdentifier = @SystemIdentifier 
			AND inventory.HasExternalSource = 0
			AND inventory.Deleted = 0
	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalInventories
		  UNION
		 SELECT *
		   FROM @RemoteInventories
	   ) inventories
	ORDER BY IntNumber, Number, _id
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[v_PublicInventories] AS
	SELECT
		i.Id, i.SystemIdentifier,
		CAST(0 AS bit) AS IsDraft,
		i.ArchiveId, 
		a.Code AS ArchiveCode,
		a.Name AS ArchiveName,
		NULL AS FundDraftId,
		i.FundSystemIdentifier,
		f.Number AS FundNumber,
		f.HasExternalSource AS FundHasExternalSource,
		f.ExternalIdentifier AS FundExternalIdentifier,
		i.CreatedOn, i.CreatedBy,
		cu.DisplayName AS CreatedByDisplayName,
		cu.UserName AS CreatedByUserName,
		i.UpdatedOn, i.UpdatedBy,
		uu.DisplayName AS UpdatedByDisplayName, 
        uu.UserName AS UpdatedByUserName,
		i.Deleted, i.DeletedOn,
		i.DeletedBy,
		du.DisplayName AS DeletedByDisplayName,
		du.UserName AS DeletedByUserName,
		i.ExternalIdentifier, i.HasExternalSource,
		i.ExternalSourceUpdatedOn, 
        i.NumberArray, i.Number,
		i.DescriptionLevelCode,
		idl.Text AS DescriptionLevelText,
		i.StatusCode, s.Text AS StatusText,
		i.HasNoChronologicalScope, i.StartDateYear,
		i.StartDateMonth, i.StartDateDay,
		i.EndDateYear,
		i.EndDateMonth, 
        i.EndDateDay,
		i.ApproxmateChronologicalScope,
		i.Bytes,
		i.LinearMeters,
		i.OtherMetrics,
		i.ArchivalEntityCount,
		i.DocumentCount,
		i.BoxCount,
		i.RollCount,
		i.AudioDocumentArchivalEntityCount,
		i.PhotoDocumentArchivalEntityCount, 
        i.VideoDocumentArchivalEntityCount,
		i.DigitalDocumentArchivalEntityCount,
		i.FundCreatorTitleHistory,
		i.FundCreatorBiographicalHistory,
		i.History,
		i.DocumentsProvider,
		i.DocumentsDescription,
		i.DocumentsAccessDescription, 
        i.ClassificationScheme,
		i.AbbreviationList,
		i.MicrofilmedArchivalEntityCount,
		i.DigitizedArchivalEntityCount,
		i.NegativeFrameCount,
		i.PositiveFrameCount,
		i.Notes,
		i.NumberNumeric,
		f.NumberNumeric as FundNumberNumeric,
		ast.Text as AvailabilityStatusText,
		i.AvailabilityStatusCode
	FROM dbo.Inventories AS i 
		INNER JOIN dbo.Archives AS a ON i.ArchiveId = a.Id
		INNER JOIN dbo.Funds AS f ON i.FundSystemIdentifier = f.SystemIdentifier 
		LEFT OUTER JOIN N.InventoryDescriptionLevel AS idl ON i.DescriptionLevelCode = idl.Code
		LEFT OUTER JOIN N.Status AS s ON i.StatusCode = s.Code 
		LEFT OUTER JOIN dbo.AspNetUsers AS cu ON i.CreatedBy = cu.Id 
		LEFT OUTER JOIN dbo.AspNetUsers AS uu ON i.UpdatedBy = uu.Id
		LEFT OUTER JOIN dbo.AspNetUsers AS du ON i.CreatedBy = du.Id
		LEFT JOIN N.AvailabilityStatus ast ON i.AvailabilityStatusCode = ast.Code
	WHERE f.IsSuspended = 0
	AND i.DescriptionLevelCode <> 6 -- груб опис 	
	AND i.StatusCode <> 12 -- отчислен			
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [dbo].[v_PublicFunds] AS
	SELECT 
		f.Id,
		f.SystemIdentifier,
		CAST(0 AS bit) AS IsDraft,
		f.ArchiveId, a.Code AS ArchiveCode,
		a.Name AS ArchiveName,
		f.CreatedOn,
		f.CreatedBy,
		cu.DisplayName AS CreatedByDisplayName,
		cu.UserName AS CreatedByUserName,
		f.UpdatedOn, 
        f.UpdatedBy,
		uu.DisplayName AS UpdatedByDisplayName,
		uu.UserName AS UpdatedByUserName,
		f.Deleted,
		f.DeletedOn,
		f.DeletedBy,
		du.DisplayName AS DeletedByDisplayName,
		du.UserName AS DeletedByUserName, 
        f.ExternalIdentifier,
		f.HasExternalSource,
		f.ExternalSourceUpdatedOn,
		f.NumberArray,
		f.Number,
		f.Title,
		f.DescriptionLevelCode,
		dl.Text AS DescriptionLevelText,
		f.TypeCode,
		ft.Text AS TypeText,
		f.StatusCode,
		s.Text AS StatusText, 
        f.HasNoChronologicalScope,
		f.StartDateYear, 
		f.StartDateMonth, 
		f.StartDateDay, 
		f.EndDateYear,
		f.EndDateMonth, 
		f.EndDateDay, 
		f.ApproxmateChronologicalScope, 
		f.Bytes,
		f.LinearMeters,
		f.OtherMetrics,
		f.InventoryCount, 
        f.ArchivalEntityCount, 
		f.DocumentCount,
		f.FundCreatorTitleHistory,
		f.FundCreatorActivityHistory,
		f.FundCreatorBiographicalHistory, 
		f.DocumentsProvider, 
		f.DocumentsDescription, 
		f.ValuableDocumentsInventoryCount, 
        f.InvaluableDocumentsInventoryCount, 
		f.DocumentsAccessDescription,
		f.History, 
		f.RelatedFunds,
		f.Notes,
		f.EnrolledBytes, 
		f.EnrolledInventoryCount,
		f.DeductedBytes,
		f.DeductedInventoryCount,
		f.NumberNumeric
	FROM dbo.Funds AS f 
		INNER JOIN dbo.Archives AS a ON f.ArchiveId = a.Id
		LEFT OUTER JOIN N.FundDescriptionLevel AS dl ON f.DescriptionLevelCode = dl.Code 
		LEFT OUTER JOIN N.FundType AS ft ON f.TypeCode = ft.Code 
		LEFT OUTER JOIN N.Status AS s ON f.StatusCode = s.Code 
		LEFT OUTER JOIN dbo.AspNetUsers AS cu ON f.CreatedBy = cu.Id 
		LEFT OUTER JOIN dbo.AspNetUsers AS uu ON f.UpdatedBy = uu.Id 
		LEFT OUTER JOIN dbo.AspNetUsers AS du ON f.CreatedBy = du.Id
	WHERE f.IsSuspended = 0
	AND f.DescriptionLevelCode <> 2 -- фонд с необработени документи	
	AND f.StatusCode <> 12 -- Отчислен	
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [dbo].[v_PublicArchivalEntities] AS
	SELECT 
		ae.Id, 
		ae.SystemIdentifier, 
		CAST(0 AS bit) AS IsDraft,
		ae.ArchiveId, 
		a.Code AS ArchiveCode,
		a.Name AS ArchiveName,
		NULL AS FundDraftId,
		ae.FundSystemIdentifier,
		f.Number AS FundNumber, 
        f.HasExternalSource AS FundHasExternalSource,
		f.ExternalIdentifier AS FundExternalIdentifier,
		NULL AS InventoryDraftId, 
		ae.InventorySystemIdentifier, 
		i.Number AS InventoryNumber, 
        i.HasExternalSource AS InventoryHasExternalSource, 
		i.ExternalIdentifier AS InventoryExternalIdentifier, 
		ae.CreatedOn, 
		ae.CreatedBy, 
		cu.DisplayName AS CreatedByDisplayName, 
		cu.UserName AS CreatedByUserName, 
		ae.UpdatedOn, 
        ae.UpdatedBy, 
		uu.DisplayName AS UpdatedByDisplayName,
		uu.UserName AS UpdatedByUserName, 
		ae.Deleted, 
		ae.DeletedOn,
		ae.DeletedBy, 
		du.DisplayName AS DeletedByDisplayName, 
		du.UserName AS DeletedByUserName, 
        ae.HasExternalSource, 
		ae.ExternalIdentifier, 
		ae.ExternalSourceUpdatedOn, 
		ae.Number,
		ae.Title, 
		ae.DescriptionLevelCode, 
		l.Text AS DescriptionLevelText, 
		ae.StatusCode,
		s.Text AS StatusText, 
		ae.HasNoChronologicalScope, 
        ae.StartDateYear,
		ae.StartDateMonth, 
		ae.StartDateDay, 
		ae.EndDateYear, 
		ae.EndDateMonth, 
		ae.EndDateDay, 
		ae.ApproxmateChronologicalScope, 
		ae.Author, 
		ae.Location, 
		ae.Bytes,
		ae.SheetCount, 
		ae.TapeCount,
		ae.MicrofilmCount, 
        ae.FrameCount,
		ae.VideoTapeCount,
		ae.DigitalDeviceCount,
		ae.OtherMetrics, 
		ae.SizeCm, 
		ae.Scaling, 
		ae.Description, 
		ae.DocumentsAccessDescription, 
		ae.Features, 
		ae.Condition, 
		ae.MicrofilmedCopyCount, 
		ae.DigitizedCopyCount, 
        ae.PaperCopyCount,
		ae.NegativeFrameCount, 
		ae.PositiveFrameCount,
		ae.OtherCopyCount, 
		ae.Notes, 
		ae.EnrolledBytes, 
		ae.EnrolledDocumentCount, 
		ae.EnrolledLinearMeters, 
		ae.DeductedBytes,
		ae.DeductedDocumentCount, 
        ae.DeductedLinearMeters, 
		f.NumberNumeric as FundNumberNumeric, 
		i.NumberNumeric as InventoryNumberNumeric, 
		ae.NumberNumeric, 
		ast.Text as AvailabilityStatusText, 
		i.AvailabilityStatusCode
	FROM dbo.ArchivalEntities AS ae
		INNER JOIN dbo.Archives AS a ON ae.ArchiveId = a.Id 
		INNER JOIN dbo.Funds AS f ON ae.FundSystemIdentifier = f.SystemIdentifier
		INNER JOIN dbo.Inventories AS i ON ae.InventorySystemIdentifier = i.SystemIdentifier 
		LEFT OUTER JOIN N.ArchivalEntityDescriptionLevel AS l ON ae.DescriptionLevelCode = l.Code 
		LEFT OUTER JOIN N.Status AS s ON ae.StatusCode = s.Code
		LEFT OUTER JOIN dbo.AspNetUsers AS cu ON ae.CreatedBy = cu.Id 
		LEFT OUTER JOIN dbo.AspNetUsers AS uu ON ae.UpdatedBy = uu.Id 
		LEFT OUTER JOIN dbo.AspNetUsers AS du ON ae.CreatedBy = du.Id
		LEFT JOIN N.AvailabilityStatus ast ON ae.AvailabilityStatusCode = ast.Code
	WHERE f.IsSuspended = 0
	AND ae.StatusCode <> 12 --статус отчислен
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [dbo].[v_PublicDocuments] AS
	SELECT 
		d.Id, d.SystemIdentifier,
		CAST(0 AS bit) AS IsDraft,
		d.ArchiveId, 
		a.Code AS ArchiveCode,
		a.Name AS ArchiveName,
		NULL AS FundDraftId, 
		d.FundSystemIdentifier, 
		f.Number AS FundNumber, 
        f.HasExternalSource AS FundHasExternalSource, 
		f.ExternalIdentifier AS FundExternalIdentifier,
		NULL AS InventoryDraftId, 
		d.InventorySystemIdentifier, 
		i.Number AS InventoryNumber, 
        i.HasExternalSource AS InventoryHasExternalSource,
		i.ExternalIdentifier AS InventoryExternalIdentifier,
		NULL AS ArchivalEntityDraftId, 
		d.ArchivalEntitySystemIdentifier, 
		ae.Number AS ArchivalEntityNumber, 
        ae.HasExternalSource AS ArchivalEntityHasExternalSource, 
		ae.ExternalIdentifier AS ArchivalEntityExternalIdentifier,
		d.CreatedOn,
		d.CreatedBy, 
		cu.DisplayName AS CreatedByDisplayName,
		cu.UserName AS CreatedByUserName, 
        d.UpdatedOn, 
		d.UpdatedBy, 
		uu.DisplayName AS UpdatedByDisplayName, 
		uu.UserName AS UpdatedByUserName,
		d.Deleted, 
		d.DeletedOn, 
		d.DeletedBy,
		du.DisplayName AS DeletedByDisplayName,
		du.UserName AS DeletedByUserName, 
        d.HasExternalSource, 
		d.ExternalIdentifier, 
		d.ExternalSourceUpdatedOn, 
		d.Number, 
		d.Title,
		d.DescriptionLevelCode, 
		l.Text AS DescriptionLevelText,
		d.StatusCode, 
		s.Text AS StatusText, 
		d.FileFormatCode, 
		d.HasNoChronologicalScope, 
        d.StartDateYear,
		d.StartDateMonth, 
		d.StartDateDay, 
		d.EndDateYear, 
		d.EndDateMonth, 
		d.EndDateDay, 
		d.ApproxmateChronologicalScope, 
		d.Author, 
		d.Location, 
		d.Bytes, 
		d.SheetCount,
		d.StartSheetNumber, 
		d.EndSheetNumber, 
        d.DigitalDevice,
		d.OtherMetrics,
		d.SizeCm, 
		d.Scaling,
		d.Duration, 
		d.Description, 
		d.DocumentsAccessDescription,
		d.Features,
		d.MicrofilmedCopyCount, 
		d.DigitizedCopyCount, 
		d.PaperCopyCount, 
		d.NegativeFrameCount, 
        d.PositiveFrameCount, 
		d.OtherCopyCount, 
		d.Transcription, 
		d.Notes,
		f.NumberNumeric AS FundNumberNumeric,
		i.NumberNumeric AS InventoryNumberNumeric,
		ae.NumberNumeric AS ArchivalEntityNumberNumeric,
		d.AvailabilityStatusCode,
		ast.Text as AvailabilityStatusText
	FROM dbo.Documents AS d 
		INNER JOIN dbo.Archives AS a ON d.ArchiveId = a.Id 
		INNER JOIN dbo.Funds AS f ON d.FundSystemIdentifier = f.SystemIdentifier
		INNER JOIN dbo.Inventories AS i ON d.InventorySystemIdentifier = i.SystemIdentifier 
		INNER JOIN dbo.ArchivalEntities AS ae ON d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier
		LEFT OUTER JOIN N.DocumentDescriptionLevel AS l ON d.DescriptionLevelCode = l.Code 
		LEFT OUTER JOIN N.Status AS s ON d.StatusCode = s.Code 
		LEFT OUTER JOIN dbo.AspNetUsers AS cu ON d.CreatedBy = cu.Id
		LEFT OUTER JOIN dbo.AspNetUsers AS uu ON d.UpdatedBy = uu.Id
		LEFT OUTER JOIN dbo.AspNetUsers AS du ON d.CreatedBy = du.Id
		LEFT JOIN N.AvailabilityStatus ast ON d.AvailabilityStatusCode = ast.Code
	WHERE f.IsSuspended = 0
	AND ae.StatusCode <> 12 --статус отчислен
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetAllPublicDescriptionLevels]
	@LinkedServer nvarchar(50),
	@ResultType int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql NVARCHAR(MAX);

	DECLARE @FinalPart NVARCHAR(max) = 'ORDER BY CASE
											WHEN SortOrder = 1 AND [Label] LIKE ''Фонд'' THEN 1
											WHEN SortOrder = 1 AND [Label] LIKE ''Фонд с н%'' THEN 2
											WHEN SortOrder = 1 AND [Label] LIKE ''Ч%'' THEN 3
											WHEN SortOrder = 1 AND [Label] LIKE ''С%'' THEN 4
											WHEN SortOrder = 1 AND [Label] LIKE ''К%'' THEN 5
											WHEN SortOrder = 2 AND [Label] LIKE ''И%'' THEN 6
											WHEN SortOrder = 2 AND [Label] LIKE ''Г%'' THEN 7
											WHEN SortOrder = 2 AND [Label] LIKE ''С%'' THEN 8
											WHEN SortOrder = 3 AND [Label] LIKE ''А%'' THEN 9
											WHEN SortOrder = 3 AND [Label] LIKE ''С%'' THEN 10
											WHEN SortOrder = 4 THEN 11
										END ASC
										OFFSET 0 ROWS'

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remote NVARCHAR(MAX) = '
		SELECT * FROM (SELECT  CAST(Gid as varchar(10)) as Code
	   ,[Value] as Label
	   ,CAST(1 as bit) as HasExternalSource
	   ,1 as SortOrder
  FROM [Archiving].[dbo].[Nomenclature]
 WHERE [Type] = ''LevelOfDescription'' AND [Title] NOT LIKE ''%Inventory%'' AND [Title] NOT LIKE ''%Entit%'' AND [Code] <> 4 AND [Title] NOT LIKE ''%Document%'') as f1
 UNION ALL
SELECT  CAST(Gid as varchar(10)) as Code
	   ,[Value] as Label
	   ,CAST(1 as bit) as HasExternalSource
	   ,2 as SortOrder
  FROM [Archiving].[dbo].[Nomenclature]
 WHERE [Type] = ''LevelOfDescription'' AND [Code] <> 6 AND [Title] LIKE ''%Inventory%''
 UNION ALL
SELECT  CAST(Gid as varchar(10)) as Code
	   ,[Value] as Label
	   ,CAST(1 as bit) as HasExternalSource
	   ,3 as SortOrder
  FROM [Archiving].[dbo].[Nomenclature]
 WHERE [Type] = ''LevelOfDescription'' AND [Title] LIKE ''%Entit%''
 UNION ALL
SELECT  CAST(Gid as varchar(10)) as Code
	   ,[Value] as Label
	   ,CAST(1 as bit) as HasExternalSource
	   ,4 as SortOrder
  FROM [Archiving].[dbo].[Nomenclature]
 WHERE [Type] = ''LevelOfDescription'' AND [Title] LIKE ''%Document%''
		'
		SET @remote = REPLACE(@remote, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @local NVARCHAR(MAX) = '
SELECT  ''fund_'' + CAST(Code as varchar(10)) as Code
	   ,[Text] as Label
	   ,CAST(0 as bit) as HasExternalSource
	   ,1 as SortOrder
  FROM N.FundDescriptionLevel f WHERE f.Code <> 2
 UNION ALL
SELECT TOP 1 ''film_0'' as Code
	   ,''КМФ'' as Label
	   ,CAST(0 as bit) as HasExternalSource
	   ,1 as SortOrder
  FROM N.FundDescriptionLevel
  UNION ALL
SELECT TOP 1 ''fc_0'' as Code
	   ,''КМФ картон'' as Label
	   ,CAST(0 as bit) as HasExternalSource
	   ,1 as SortOrder
  FROM N.FundDescriptionLevel
  UNION ALL
SELECT  ''inv_'' + CAST(Code as varchar(10)) as Code
	   ,[Text] as Label
	   ,CAST(0 as bit) as HasExternalSource
	   ,2 as SortOrder
  FROM N.InventoryDescriptionLevel i WHERE i.Code <> 6 
 UNION ALL
SELECT  ''ae_'' + CAST(Code as varchar(10)) as Code
	   ,[Text] as Label
	   ,CAST(0 as bit) as HasExternalSource
	   ,3 as SortOrder
  FROM N.ArchivalEntityDescriptionLevel
 UNION ALL
SELECT  ''doc_'' + CAST(Code as varchar(10)) as Code
	   ,[Text] as Label
	   ,CAST(0 as bit) as HasExternalSource
	   ,4 as SortOrder
  FROM N.DocumentDescriptionLevel
		'
	END

	IF @ResultType = 1
	BEGIN

	DECLARE @rT NVARCHAR(max) = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remote + ''')';
	DECLARE @lT NVARCHAR(max) = 'SELECT * FROM (' + @local + ') as t';

	DECLARE @both NVARCHAR(max) = '
	SELECT * FROM (' + @rT + ' UNION ALL ' + @lT + ') as bt ' + @FinalPart

	SET @sql = 'SELECT [Code], [Label], [HasExternalSource] FROM (' + @both + ') as t';

	END

	IF @ResultType = 2
	BEGIN
			SET @sql = 'SELECT [Code], [Label], [HasExternalSource] FROM (SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remote + ''') as rt ' + @FinalPart + ') as t';
	END

	IF @ResultType = 3
	BEGIN
			SET @sql ='SELECT [Code], [Label], [HasExternalSource] FROM ( SELECT * FROM (' + @local + ') as lt ' + @FinalPart + ') as t';
	END

	EXEC (@sql);
END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[SearchFundsForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@DescriptionLevelCodesInternal nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	DECLARE @remoteQuery nvarchar(max), @kwds int, @fttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1
	if @Title is not null and len(@Title) >= 2 set @fttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @fttl IS NULL SET @rankRemote = ',kwds.[Rank] as Rank'; 
	IF @kwds <> 1 AND @fttl = 1 SET @rankRemote = ',fttl.[Rank] as Rank';
	IF @kwds = 1 AND @fttl = 1 SET @rankRemote = ',(isnull(kwds.[Rank], 0) + isnull(fttl.[Rank], 0)) as Rank';

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 AND @fttl IS NULL SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 
	IF @kwds <> 1 AND @fttl = 1 SET @rankFilterRemote = ' and fttl.[Rank] > 1';
	IF @kwds = 1 AND @fttl = 1 SET @rankFilterRemote = ' and isnull(kwds.[Rank], 0) > 1 and isnull(fttl.[Rank], 0) > 1';

	SET @remoteQuery = '';
	SET @remoteQuery = 'with fresults as (';
	set @remoteQuery = @remoteQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''fund'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = fund.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		NULL as InventoryNumber,
		NULL as ArchivalEntityNumber,
		NULL as KMFNumber,
		NULL as FilmCardNumber,
		fund.Title,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.TypeGid) as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.StatusGid) as StatusText,
		(select Value FROM Nomenclature n WHERE n.Gid= fund.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as FundDescriptionLevelText,		
		NULL as InventoryDescriptionLevelText,
		NULL as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		fund.LGid AS ExternalIdentifier,
		fund.TextDate as FundApproximateChronologicalScope,
		NULL as InventoryApproximateChronologicalScope,
		NULL as ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		fund.Gid AS FundGid,
		fund.IntNumber as FundIntNumber,
		NULL AS InventoryIntNumber,
		NULL AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		fund.Gid,
		fund.LGid'
		+ @rankRemote
		+ ',1 AS EntityTypeOrder';

	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		from Fund_Active as fund
	'
	else set @remoteQuery = @remoteQuery + '
		from Fund_Modified as fund
	';
	if @kwds = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(Fund,*,'''+ @KeyWords + ''') kwds on fund._id = kwds.[key]
	';
	if @fttl = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(Fund,(Title,FundFormerNameChange), '''+ @Title + ''') fttl on fund._id = fttl.[key]
	';
	if @ArchiveGids is not null and @ArchiveGids <> '-999' set @remoteQuery = @remoteQuery + '
		where fund.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else set @remoteQuery = @remoteQuery + '
		where 1 = 1'; 
	if @FundNumber is not null set @remoteQuery = @remoteQuery + '
		and (fund.Number = ''' + @FundNumber + ''')
	';

	-- Ако е за публичната част се махат тези със статус отчислен <> 2115 статус Фонд с необр. документи <> 91
	if @SearchDrafts = 0
		begin
			set @remoteQuery = @remoteQuery + 'and fund.StatusGid <> 2115';
			set @remoteQuery = @remoteQuery + 'and fund.LevelOfDescriptionGid <> 91';
		end
	
	set @remoteQuery = @remoteQuery + 'and fund.LevelOfDescriptionGid <> 2185';
	-- въведен е номер на фонд, но не е избрано някое от нивата на описание за фондове, така имплицитно се разбира, че нивото на описание е някое от нивата за фонд(така са го поискали в писмо)
	if @FundNumber is not null
		and not '20' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '21' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '22' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '91' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		if @SearchDrafts = 1
			begin
			set @remoteQuery = @remoteQuery + '
				and (fund.LevelOfDescriptionGid in (20,21,22,91))' 
			end
		if @SearchDrafts = 0
			begin
				set @remoteQuery = @remoteQuery + '
					and (fund.LevelOfDescriptionGid in (20,21,22))' 
			end
	-- не работеше винаги и връщаше всички нива на описание а не само избраните ????? 
	 if @LevelOfDescriptionGids <> '-999'
		set @remoteQuery = @remoteQuery + 'and (fund.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )';

	if @ToDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @ToDate +''' >= fund.CreationDate)
	';
	if @FromDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @FromDate + ''' <= fund.CreationDate)
	';
	if @SearchDigitalObject = 1 and  @SearchDrafts = 1  set @remoteQuery = @remoteQuery + '
		AND (exists (select 1 from Document_Search_Active doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
	';
	else if @SearchDigitalObject = 1  set @remoteQuery = @remoteQuery + '
		AND (exists (select 1 from Document_Search_Modified doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
	';
	else if @SearchDigitalObject = 0 and  @SearchDrafts = 1  set @remoteQuery = @remoteQuery + '
		AND ( not exists (select 1 from Document_Search_Active doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1)	)
	';
	else if @SearchDigitalObject = 0  set @remoteQuery = @remoteQuery + '
		AND ( not exists (select 1 from Document_Search_Modified doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
	';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
		and ( fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	';
	set @remoteQuery = @remoteQuery + @rankFilterRemote;

	if @SearchDrafts = 1 set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,	
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = fresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131	)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,	
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsf.[KEY] as fId, null as fdId, kwdsf.[RANK] as RankKwds
			from freetexttable(Funds, *, ''' + @KeyWords + ''') kwdsf
			union 
			select null as fId, kwdsfd.[KEY] as fdId, kwdsfd.[RANK] as RankKwds  
			from freetexttable(FundDrafts, *, ''' + @KeyWords + ''') kwdsfd
		) kwds
		on (f.Id = kwds.fdId and f.IsDraft = 1) or (f.Id = kwds.fId and f.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @fttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select fttf.[KEY] as fId, null as fdId, fttf.[RANK] as RankTitle   
			from freetexttable(Funds, (Title,FundCreatorTitleHistory), ''' + @Title + ''') fttf 
			union 
			select null as fId, fttfd.[KEY] as fdId, fttfd.[RANK] as RankTitle   
			from freetexttable(FundDrafts, (Title,FundCreatorTitleHistory), ''' + @Title + ''') fttfd
		) ftt
		on (f.Id = ftt.fdId and f.IsDraft = 1) or (f.Id = ftt.fId and f.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @fttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @fttl = 1 SET @rank = ',RankTitle as Rank';
	IF @kwds = 1 AND @fttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	DECLARE @rankKwdsGroupBy VARCHAR(MAX) = '';
	IF @kwds = 1 AND @fttl IS NULL
	BEGIN
		 SET @rankFilter = ' and RankKwds > 1'; 
		 SET @rankKwdsGroupBy = ',kwds.RankKwds';
	END
	DECLARE @rankTitleGroupBy VARCHAR(MAX) = '';
	IF @kwds <> 1 AND @fttl = 1 
	BEGIN
		SET @rankFilter = ' and RankTitle > 1';
		SET @rankTitleGroupBy = ',ftt.RankTitle';
	END
	IF @kwds = 1 AND @fttl = 1
	BEGIN
		SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';
		SET @rankKwdsGroupBy = ',kwds.RankKwds';
		SET @rankTitleGroupBy = ',ftt.RankTitle';
	END

	DECLARE @isSuspenedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 1  SET @isSuspenedFilter = '  AND f.IsSuspended = 0';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber IS NOT NULL SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' left join v_PublicDocuments d on d.FundSystemIdentifier = f.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' left join v_Documents d on d.FundSystemIdentifier = f.SystemIdentifier';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = f.StatusCode) <> 12';

	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	IF @SearchDrafts = 1 SET @digitalObjectsTable = 'v_DigitalObjects';
	DECLARE @digitalObjectsFilter VARCHAR(MAX) = '';
	IF @SearchDigitalObject = 1 SET @digitalObjectsFilter = ' and (exists(select 1 from ' + @digitalObjectsTable  + ' do 
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0'
			+ @suspended +
		'))';
	IF @SearchDigitalObject = 0 SET @digitalObjectsFilter = ' and (not exists(select 1 from ' + @digitalObjectsTable  + ' do
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0
		))';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Funds' ELSE SET @table = 'v_PublicFunds';

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';

	DECLARE @descriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @FundNumber is not null and @DescriptionLevelCodesInternal = '-111' 
		set @descriptionLevelCodesFilter = '' 
	else
		set @descriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @DescriptionLevelCodesInternal + ''', '',''))) 
				OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''' + @DescriptionLevelCodesInternal + ''', '',''))))
		';

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			''fund'' AS EntityType,
			f.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = f.ArchiveId) as ArchiveName,
			f.Number as FundNumber,
			NULL as InventoryNumber,
			NULL as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			f.Title,
			(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as StatusText,
			(SELECT Text FROM [N].[FundDescriptionLevel] dl where dl.Code = f.DescriptionLevelCode) as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			f.ApproxmateChronologicalScope as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as ArchivalEntityApproximateChronologicalScope,
			f.SystemIdentifier as FilmSystemIdentifier,
			NULL as FundGid,
			f.NumberNumeric AS FundIntNumber,
			NULL AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			1 as EntityTypeOrder
		FROM ' + @table + ' f'
		+ @freeTextTableByTitleJoin + 
		+ @freeTextTableByKwdsJoin + 
		+ @documentsJoin + '
		WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR (f.NumberArray in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (f.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @fundNumberFilter + '
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @descriptionLevelCodesFilter
			+ @digitalObjectsFilter
			+ @doNotGetAnythingFilter
			+ @isSuspenedFilter
			+ @isDeductedFilter
			+ @rankFilter;

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteFundsTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи го чупят в такъв случай
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL, 
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NOT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteFundsTable
		UNION
		' +
		@localQuery + '
		GROUP BY 
			--f.EntityType, 
			f.SystemIdentifier,
			f.ArchiveName,
			f.Number,
			--f.InventoryNumber,
			--f.ArchivalEntityNumber,
			f.Title,
			--f.TypeText,
			--f.StatusText,
			--f.FundDescriptionLevelText,
			--f.InventoryDescriptionLevelText,
			f.HasExternalSource,
			f.ExternalIdentifier,
			--f.InventoryApproximateChronologicalScope,
			-- тези, ако ги няма, се чупи
			f.ArchiveId,
			f.TypeCode,
			f.StatusCode,
			f.DescriptionLevelCode,
			f.ApproxmateChronologicalScope
			' + @rankKwdsGroupBy + ' 
			' + @rankTitleGroupBy + ' 
			,f.NumberNumeric
	';

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
	--print @sql;
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[SearchInventoriesForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	DECLARE @remoteQuery nvarchar(max), @kwds int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1
	if @Title is not null and len(@Title) >= 2 set @ttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rankRemote = ',kwds.[Rank] as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankRemote = ',fttl.[Rank] as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rankRemote = ',(isnull(kwds.[Rank], 0) + isnull(fttl.[Rank], 0)) as Rank';

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilterRemote = ' and fttl.[Rank] > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilterRemote = ' and isnull(kwds.[Rank], 0) > 1 and isnull(fttl.[Rank], 0) > 1';

	SET @remoteQuery = '';
	SET @remoteQuery = 'with fresults as (';
	set @remoteQuery = @remoteQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''inventory'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = inventory.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		inventory.Number as InventoryNumber,
		NULL as ArchivalEntityNumber,
		NULL as KMFNumber,
		NULL as FilmCardNumber,
		fund.Title as Title,
		NULL as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = inventory.StatusGid) as StatusText,
		(select Value FROM Nomenclature n WHERE n.Gid= fund.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as FundDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= inventory.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as InventoryDescriptionLevelText,	
		NULL as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		inventory.LGid AS ExternalIdentifier,
		fund.TextDate AS FundApproximateChronologicalScope,
		inventory.TextDate AS InventoryApproximateChronologicalScope,
		NULL as ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		fund.Gid AS FundGid,
		fund.IntNumber as FundIntNumber,
		inventory.IntNumber AS InventoryIntNumber,
		NULL AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		inventory.Gid,
		inventory.LGid'
		+ @rankRemote
		+ ',2 AS EntityTypeOrder';

	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		from Inventory_Active as inventory
	'
	else set @remoteQuery = @remoteQuery + '
		from Inventory_Modified as inventory
	';
	if @kwds = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(Inventory,*, '''+ @KeyWords + ''') kwds on inventory._id = kwds.[key]
	';
	if @ttl = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(Inventory,FundCreatorNameChanges, '''+ @Title + ''') fttl on inventory._id = fttl.[key]
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Fund_Active fund on inventory.FundLGid = fund.LGid
	'
	if @SearchDrafts = 0 set @remoteQuery = @remoteQuery + '
		inner join Fund_Modified fund on inventory.FundLGid = fund.LGid
	'
	if @ArchiveGids is not null and @ArchiveGids <> '-999' set @remoteQuery = @remoteQuery + '
		where inventory.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else set @remoteQuery = @remoteQuery + '
		where 1 = 1';
	if @KMFCountriesOfOriginCodes is not null and @KMFCountriesOfOriginCodes <> '-999' set  @remoteQuery = @remoteQuery + '
		and ((select n.Value2 from Nomenclature n where n.Gid = fund.CountryGid and n.Type = ''FACountry'') in (''' + [dbo].[StringSplit3](@KMFCountriesOfOriginCodes) + '''))
		and (fund.LevelOfDescriptionGid = 2185 )
		and (inventory.LevelOfDescriptionGid = 2369 )
	';
	if @InventoryNumber is not null set @remoteQuery = @remoteQuery + '
		and (inventory.Number = ''' + @InventoryNumber + ''')
	';
	if @FundNumber is not null set @remoteQuery = @remoteQuery + '
		and (fund.Number = ''' + @FundNumber + ''')
	';
	--if @FundLevelOfDescriptionGids is not null and @FundLevelOfDescriptionGids <> '-999' set @remoteQuery = @remoteQuery + '
		--and (fund.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@FundLevelOfDescriptionGids) + ' )
	--';
	-- въведен е номер на опис, но не е избрано някое от нивата на описание за описи, така имплицитно се разбира, че нивото на описание е някое от нивата за опис(така са го поискали в писмо)
	if @InventoryNumber is not null  
		and not '2171' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2172' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2372' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteQuery = @remoteQuery + '
			and (inventory.LevelOfDescriptionGid in (2171,2172,2372))
	' 
	else if @InventoryNumber is null and @FundNumber is null
		and not '2171' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2172' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2372' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteQuery = @remoteQuery + '
			and 1=2
	' 
	else if @LevelOfDescriptionGids <> '-999'
		and ('2171' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')) 
			or '2172' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
			or '2372' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')))
		set @remoteQuery = @remoteQuery + '
			and (inventory.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )
	';
	-- Грубите описи да са видими само в служебната част на системата
	if @SearchDrafts = 0 set @remoteQuery = @remoteQuery + '
		and (inventory.LevelOfDescriptionGid <> 2172)
		and (inventory.StatusGid <> 2115)
	';
	if @ToDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @ToDate +''' >= inventory.CreationDate)
	';
	if @FromDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @FromDate + ''' <= inventory.CreationDate)
	';
	--if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
	--	and ((select FundArrayGid from ' + @fundsView + ' where LGid = inventory.FundLGid) in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	--';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
		and (fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +') 
	';
	set @remoteQuery = @remoteQuery + @rankFilterRemote;

	if @SearchDrafts = 1 set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = fresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131	)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,	
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @fundsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = i.FundSystemIdentifier';
	IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = i.FundSystemIdentifier';

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsI.[KEY] as iId, null as iDId, kwdsI.[RANK] as RankKwds
			from freetexttable(Inventories, *, ''' + @KeyWords + ''') kwdsI
			union 
			select null as iId, kwdsID.[KEY] as iDId, kwdsID.[RANK] as RankKwds  
			from freetexttable(InventoryDrafts, *, ''' + @KeyWords + ''') kwdsID
		) kwds
		on (i.Id = kwds.iDId and i.IsDraft = 1) or (i.Id = kwds.iId and i.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlI.[KEY] as iId, null as iDId, ttlI.[RANK] as RankTitle   
			from freetexttable(Inventories, FundCreatorTitleHistory, ''' + @Title + ''') ttlI 
			union 
			select null as iId, ttlId.[KEY] as iDId, ttlId.[RANK] as RankTitle   
			from freetexttable(InventoryDrafts, FundCreatorTitleHistory, ''' + @Title + ''') ttlId
		) ttl
		on (i.Id = ttl.iDId and i.IsDraft = 1) or (i.Id = ttl.iId and i.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rank = ',RankTitle as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';

	DECLARE @isSuspenedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 1  SET @isSuspenedFilter = '  AND f.IsSuspended = 0 AND i.IsSuspended = 0';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @roughInventoriesFilter VARCHAR(MAX) = '';
	-- Грубите описи да са видими само в служебната част на системата
	IF @SearchDrafts = 0 SET @roughInventoriesFilter = ' AND i.DescriptionLevelCode <> ''6''';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = i.StatusCode) <> 12';

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' left join v_PublicDocuments d on d.InventorySystemIdentifier = i.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' left join v_Documents d on d.InventorySystemIdentifier = i.SystemIdentifier';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';

	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	IF @SearchDrafts = 1 SET @digitalObjectsTable = 'v_DigitalObjects';
	DECLARE @digitalObjectsFilter VARCHAR(MAX) = '';
	IF @SearchDigitalObject = 1 SET @digitalObjectsFilter = ' and (exists(select 1 from ' + @digitalObjectsTable  + ' do 
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0'
			+ @suspended +
		'))';
	IF @SearchDigitalObject = 0 SET @digitalObjectsFilter = ' and (not exists(select 1 from ' + @digitalObjectsTable  + ' do
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0
		))';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Inventories' ELSE SET @table = 'v_PublicInventories';

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';

	DECLARE @inventoryDescriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @InventoryNumber is not null and @FundDescriptionLevelCodesInternal = '-111' set @FundDescriptionLevelCodesInternal = '-999';
	if @InventoryNumber is not null and @InventoryDescriptionLevelCodesInternal = '-111' 
		set @inventoryDescriptionLevelCodesFilter = '' 
	else
		set @inventoryDescriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))) 
				OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))))
		';

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			''inventory'' AS EntityType,
			i.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = i.ArchiveId) as ArchiveName,	
			f.Number as FundNumber,
			i.Number as InventoryNumber,
			NULL as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			NULL as Title,
			NULL as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = i.StatusCode) as StatusText,
			(SELECT Text FROM [N].[FundDescriptionLevel] fdl where fdl.Code = f.DescriptionLevelCode) as FundDescriptionLevelText,
			(SELECT Text FROM [N].[InventoryDescriptionLevel] idl where idl.Code = i.DescriptionLevelCode) as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			f.ApproxmateChronologicalScope as FundApproximateChronologicalScope,
			i.ApproxmateChronologicalScope as InventoryApproximateChronologicalScope,
			NULL as ArchivalEntityApproximateChronologicalScope,
			NULL as FilmSystemIdentifier,
			NULL as FundGid,
			i.FundNumberNumeric AS FundIntNumber,
			i.NumberNumeric AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			2 as EntityTypeOrder
		FROM ' + @table + ' i'
		+ @fundsJoin + 
		+ @documentsJoin +
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE i.ExternalIdentifier IS NULL AND i.HasExternalSource = 0 AND i.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (i.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundDescriptionLevel fdl where fdl.Code = f.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(i.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(i.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @inventoryDescriptionLevelCodesFilter
			+ @doNotGetAnythingFilter
			+ @isSuspenedFilter
			+ @roughInventoriesFilter
			+ @digitalObjectsFilter
			+ @isDeductedFilter
			+ @rankFilter;

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteInventoriesTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи го чупят в такъв случай	
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL,
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NOT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT
		);

		INSERT INTO @remoteInventoriesTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteInventoriesTable
		UNION
		' +
		@localQuery;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[GetCardForm1FundDataInernal] 
	@SystemIdentifier UNIQUEIDENTIFIER = NULL,
	@RowsOfPage INT = 5000,
	@Page INT = 1
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		a.[Name] AS Archive,
		a.Code AS ArchiveCode,
		fund.Number AS Number,
		fund.Title,
		t.Text AS Type,
		convert(varchar, fund.CreatedOn, 104) AS CreationDate,
		(select Text + ';'
			from NomenclatureValues nv
			join N.Nomenclatures n1 on 
				nv.EntityType='fund' 
				and nv.Deleted=0
				and n1.Deleted=0
				and nv.NomenclatureCode='INDUSTRY_TYPE'
				and nv.EntityId=fund.Id
				and n1.Id=nv.ValueId
			FOR XML path(''), elements) as IndustryIndex,
		n1.Text as MethodOfAcquisition,
		fsi.EnrolledInventoryCount AS InventoriesCount,
		fsi.EnrolledArchivalEntityCount AS ArchivalEntitiesCount,
		fsi.EnrolledBytes AS Size
	FROM v_Funds as fund
	LEFT JOIN N.Nomenclatures n1 ON fund.AcquisitionMethodId = n1.Id
	LEFT JOIN v_FundSizeInfo as fsi ON fund.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
	INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
	LEFT JOIN N.FundType t ON t.Code = TypeCode 
	WHERE SystemIdentifier = @SystemIdentifier;
END
GO

----------------------------------------------------------
--	THE SCRIPT IS CLOSED - USE THE NEW ONE!
----------------------------------------------------------

commit