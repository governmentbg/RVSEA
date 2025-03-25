
DROP PROCEDURE IF EXISTS dbo.sp_GetFundInventoriesCount
GO

CREATE PROCEDURE dbo.sp_GetFundInventoriesCount
	@LinkedServer nvarchar(255) = '', 
	--@FundIdentifier int = NULL,
	@FundIdentifier uniqueidentifier = NULL,
	@FundHasExternalSource bit,
	@FundExternalIdentifier int = NULL
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @RemoteInventories TABLE ( InventoryCount int );
	DECLARE @RemoteInventoriesCount int = 0;
	DECLARE @LocalInventoriesCount int = 0;

	DECLARE @RemoteInventoriesQuery nvarchar(max) = '';
    
	IF @FundHasExternalSource = 1
	BEGIN 
		SET @RemoteInventoriesQuery = CAST('' as nvarchar(max)) +
		'SELECT inventory.[LGid]
		  FROM [Archiving].[dbo].[Inventory_Active] inventory
		 WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50)) + '';

		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT COUNT(*) as InventoryCount FROM OPENQUERY(' +  @LinkedServer + ', ''SELECT inventory.[LGid]
		  FROM [Archiving].[dbo].[Inventory_Active] inventory
		 WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50)) + ''' )';
		
		INSERT INTO @RemoteInventories
		EXEC(@RemoteQuery)

		SELECT TOP 1 @RemoteInventoriesCount = InventoryCount from @RemoteInventories

	END

	IF @FundIdentifier IS NOT NULL
	BEGIN
		--SELECT @LocalInventoriesCount = COUNT(inventory.Id)
		--  FROM [dbo].[Inventories] inventory
		-- --WHERE inventory.FundId = @FundIdentifier 
		-- WHERE inventory.FundSystemIdentifier = @FundIdentifier 
		--   AND inventory.HasExternalSource = 0
		--   AND inventory.Deleted = 0
		SELECT @LocalInventoriesCount = COUNT(inventory.Id)
		  FROM [dbo].[v_Inventories] inventory
		 WHERE inventory.FundSystemIdentifier = @FundIdentifier 
		   AND inventory.HasExternalSource = 0
		   AND inventory.Deleted = 0
	END

	RETURN @LocalInventoriesCount + @RemoteInventoriesCount
END
GO