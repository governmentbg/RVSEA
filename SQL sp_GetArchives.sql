
DROP PROCEDURE IF EXISTS [dbo].[sp_GetArchives]
GO

CREATE PROCEDURE [dbo].[sp_GetArchives] 
	@LinkedServer nvarchar(255) = '',
	@SearchText nvarchar(255)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Query nvarchar(MAX)= '
		SELECT -1 as Id
			  ,NULL as CreatedOn
			  ,NULL as CreatedBy
			  ,NULL as UpdatedBy
			  ,NULL as UpdatedOn
			  ,CAST(0 as bit) as Deleted
			  ,NULL as DeletedBy
			  ,NULL as DeletedOn
			  ,CAST(1 as bit) as HasExternalSource
			  ,arc.Gid as ExternalIdentifier
			  ,arc.Code as Code
			  ,arc.Name as Name
			  ,arc.SortOrder as SortOrder
		  FROM [Archiving].[dbo].[Archive] arc
		 WHERE arc._retired = ''''3000-01-01 00:00:00.000''''
		   AND (arc.Name LIKE ''''%' + @SearchText + '%''''
				OR (ISNUMERIC(''''' + @SearchText + ''''') = 1  AND arc.Code = TRY_CAST(''''' + @SearchText + ''''' as int)))
	'
	DECLARE @OpenQuery nvarchar(MAX) = 'SELECT * FROM OPENQUERY(' + @LinkedServer + ', ''' + @Query + ''')'

	EXEC (@OpenQuery)
END
GO
