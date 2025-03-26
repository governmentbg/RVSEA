USE [DAA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE IF EXISTS dbo.sp_GetArchiveEntitiesByInventoryCount
GO

CREATE PROCEDURE dbo.sp_GetArchiveEntitiesByInventoryCount
	@LinkedServer nvarchar(255) = '', 
	@InventoryIdentifier uniqueidentifier = NULL,
	@InventoryHasExternalSource bit,
	@InventoryExternalIdentifier int = NULL,
	@SearchText nvarchar(max) = NULL,
	@IncludeDeleted bit = false
AS
BEGIN
	SET NOCOUNT ON;


	DECLARE @RemoteArchivalEntities TABLE ( ArchivalEntityCount int );
	DECLARE @RemoteArchivalEntitiesCount int = 0;
	DECLARE @LocalArchivalEntitiesCount int = 0;

	DECLARE @RemoteArchivalEntitiesQuery nvarchar(max) = '';
		
	IF @InventoryHasExternalSource = 1
	BEGIN 
		SET @RemoteArchivalEntitiesQuery = CAST('' as nvarchar(max)) +
		'SELECT LGid
		   FROM [Archiving].[dbo].[ArchiveEntity_Active] ae
		  WHERE ae.InventoryLGid = ' + CAST(@InventoryExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery + ' AND Title LIKE ''''%' + @SearchText + '%'''''
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT COUNT(*) as ArchivalEntityCount FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteArchivalEntitiesQuery + ''' )';
		
		PRINT @RemoteQuery
		
		INSERT INTO @RemoteArchivalEntities
		EXEC(@RemoteQuery)

		SELECT TOP 1 @RemoteArchivalEntitiesCount = ArchivalEntityCount from @RemoteArchivalEntities

	END

	IF @InventoryIdentifier IS NOT NULL
	BEGIN
		SELECT @LocalArchivalEntitiesCount = COUNT(ae.Id)
		  FROM [dbo].[v_ArchivalEntities] ae
		 WHERE ae.InventorySystemIdentifier = @InventoryIdentifier 
		   AND ae.HasExternalSource = 0
		   AND (@IncludeDeleted = 1 OR ae.Deleted = 0)
	END

	RETURN @LocalArchivalEntitiesCount + @RemoteArchivalEntitiesCount

END