
CREATE PROCEDURE [dbo].[sp_GetFilmCardsCount] 
	@LinkedServer nvarchar(50),
	@FundExternalIdentifier int = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @RemoteFilmCards TABLE ( FilmCardsCount int );
	DECLARE @RemoteFilmCardsCount int = 0;
	DECLARE @sql VARCHAR(MAX);

	DECLARE @remoteFilmCardsQuery VARCHAR(MAX) = '
		SELECT
			-1 as Id
			, CAST(1 as bit) as HasExternalSource
			, ae.LGid as ExternalIdentifier
			, ae.FundLGid as FilmExternalIdentifier

		FROM ArchiveEntity_Modified AS ae
		WHERE FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50));

	SET @remoteFilmCardsQuery = REPLACE(@remoteFilmCardsQuery, '''', '''''');
	
	SET @sql = 'SELECT COUNT(*) as FilmCardsCount FROM OPENQUERY(' + @LinkedServer + ', ''' + @remoteFilmCardsQuery + ''');';
			
	INSERT INTO @RemoteFilmCards
	EXEC(@sql)

	SELECT TOP 1 @RemoteFilmCardsCount = FilmCardsCount from @RemoteFilmCards

	RETURN @RemoteFilmCardsCount
END
