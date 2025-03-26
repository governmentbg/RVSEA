
alter PROCEDURE [dbo].[sp_GetFilmCards] 
	@LinkedServer nvarchar(50),
	@PageSize int = 10,
	@PageNumber int = 1,
	@FundGid int = 0,
	@ArchiveEntityGid int = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteFilmCardsQuery nvarchar(max) = '';
    DECLARE @RemoteFilmCards TABLE 
	(
		Id int
		, HasExternalSource bit		
		, ExternalIdentifier int
		, FilmExternalIdentifier int
		, InventoryNumber nvarchar(50)
		, CountryName nvarchar(255)
		, CountryCode nvarchar(255)
		, Title nvarchar(max)
		, City nvarchar(256)
		, DocumentsCypher nvarchar(2000)
		, ArchiveOriginals nvarchar(2000)
		, StartDateDay int
		, StartDateMonth int
		, StartDateYear int
		, EndDateDay int
		, EndDateMonth int
		, EndDateYear int
		, AproximateDate nvarchar(256)
		, FilmingExtentName nvarchar(max)
		, FramesCount int
		, MicrofilmNegativeCount int
		, MicrofilmPositiveCount int
		, PhotoCopy int
		, DigitalCopy int
		, Other nvarchar(256)
		, Notes nvarchar(max)
		, DocumentsFormat nvarchar(2000)
		, DocumentsCharacteristics nvarchar(max)
		, ArchiveCode int
		, ArchiveName nvarchar(255)
		, Source nvarchar(256)
		, Languages nvarchar(max)
	);
	

		SET @RemoteFilmCardsQuery = CAST('' as nvarchar(max)) +
		'SELECT
			-1 as Id
			, CAST(1 as bit) as HasExternalSource
			, ae.LGid as ExternalIdentifier
			, ae.FundLGid as FilmExternalIdentifier
			, ae.Number AS InventoryNumber
			, (
				SELECT Value3
				FROM  Nomenclature n
				WHERE n.Gid = (SELECT CountryGid FROM Fund_Modified f WHERE f.LGid = ae.FundLGid)
					AND n._retired = ''3000-01-01'' AND n.Type=''FACountry''
			) AS CountryName
			, (
				SELECT Value2
				FROM  Nomenclature n
				WHERE n.Gid = (SELECT CountryGid FROM Fund_Modified f WHERE f.LGid = ae.FundLGid)
					AND n._retired=''3000-01-01'' AND n.Type=''FACountry''
			) AS CountryCode
			, ae.Title
			, ae.City
			, ae.ChyperOfDocuments AS DocumentsCypher
			, ae.ArchiveOriginal AS ArchiveOriginals
			, ae.StartDateDay
			, ae.StartDateMonth
			, ae.StartDateYear
			, ae.EndDateDay
			, ae.EndDateMonth
			, ae.EndDateYear
			, ae.TextDate AS AproximateDate
			, (SELECT Value FROM Nomenclature n WHERE n._retired = ''3000-01-01'' AND n.Type=''FALevelOfCapture'' AND ae.LevelOfCaptureGid = n.Gid) AS FilmingExtentName
			, ae.FramesCount
			, ae.CopyNegativFrames AS MicrofilmNegativeCount
			, ae.CopyPositiveFrames AS MicrofilmPositiveCount
			, ae.CopyXerox AS PhotoCopy
			, ae.CopyDigital AS DigitalCopy
			, ae.CopyOther AS Other
			, ae.Note AS Notes
			, ae.Format AS DocumentsFormat
			, ae.DocumentProperties AS DocumentsCharacteristics
			, (select Code from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveCode
			, (select Name from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveName
			, (select CreationAuthor from [Archiving].[dbo].Fund_Modified a where a.LGid = ae.FundLGid and a._retired = ''3000-01-01 00:00:00.000'') as Source
			,(
				SELECT STRING_AGG(Value, ''; '') 
				FROM Nomenclature n
				INNER JOIN ObjectNomenclature on1 on n.Gid = on1.NomenclatureGid
				WHERE n._retired = ''3000-01-01'' 
					AND on1._retired = ''3000-01-01''
					AND on1.ArchiveEntityGid = ae.LGid 
					AND n.Type = ''FALanguage''
			) AS Languages

		FROM ArchiveEntity_Modified AS ae'

		if IsNull(@ArchiveEntityGid, 0) > 0
		begin 
			set @RemoteFilmCardsQuery = @RemoteFilmCardsQuery + '
			WHERE ae.LGid = ' + CAST(@ArchiveEntityGid as nvarchar(50));			
		end
		else 
		begin 
			set @RemoteFilmCardsQuery = @RemoteFilmCardsQuery + '
			WHERE FundLGid = ' + CAST(@FundGid as nvarchar(50));
		end



		SET @RemoteFilmCardsQuery = REPLACE(@RemoteFilmCardsQuery, '''', '''''');

		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteFilmCardsQuery + ''' )';
		
		INSERT INTO @RemoteFilmCards 
		EXEC(@RemoteQuery)

			
	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @RemoteFilmCards
	   ) inventories
	ORDER BY ExternalIdentifier
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
	
END
