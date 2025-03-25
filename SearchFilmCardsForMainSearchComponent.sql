SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[SearchFilmCardsForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@KMFNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	--@KeywordsUIAnnotated nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	DECLARE @remoteQuery nvarchar(max), @kwds int, @kwdsAnnotated int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1;
	--set @kwdsAnnotated=0;
	--if @KeywordsUIAnnotated is not null and len(@KeywordsUIAnnotated) >=2 set @kwdsAnnotated=1;
	If @Title is not null and len(@Title) >= 2 set @ttl = 1
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
		''film_card'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = ae.ArchiveGid) AS ArchiveName,
		jf.Number as FundNumber,
		ji.Number as InventoryNumber,
		ae.Number as ArchivalEntityNumber,
		NULL as KMFNumber,
		ae.Number as FilmCardNumber,
		ae.Title as Title,
		NULL as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = ae.StatusGid) as StatusText,
		(select Value FROM Nomenclature n WHERE n.Gid= jf.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as FundDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= ji.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as InventoryDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		ae.LGid AS ExternalIdentifier,
		jf.TextDate AS FundApproximateChronologicalScope,
		ji.TextDate AS InventoryApproximateChronologicalScope,
		ae.TextDate AS ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		jf.Gid AS FundGid,
		jf.IntNumber as FundIntNumber,
		ji.IntNumber AS InventoryIntNumber,
		ae.IntNumber AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		ae.IntNumber AS FilmCardIntNumber,
		ae.Gid,
		ae.LGid'
		+ @rankRemote
		+ ',6 AS EntityTypeOrder
		,0 as HasDigitizedDigitalObjects';

	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		from ArchiveEntity_Active as ae
	';
	else set @remoteQuery = @remoteQuery + '
		from ArchiveEntity_Modified as ae
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Inventory_Active ji on ji.LGid=ae.InventoryLGid
	';
	else set @remoteQuery = @remoteQuery + '
		inner join Inventory_Modified ji on ji.LGid=ae.InventoryLGid
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Fund_Active jf on jf.LGid=ae.FundLGid
	';
	else set @remoteQuery = @remoteQuery + '
		inner join Fund_Modified jf on jf.LGid=ae.FundLGid
	';
	if @kwds = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(ArchiveEntity,*, '''+ @KeyWords + ''') kwds on ae._id = kwds.[key]
	';
	if @ttl = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(ArchiveEntity,Title, '''+ @Title + ''') fttl on ae._id = fttl.[key]
	';
	--if @kwdsAnnotated =1 set @remoteQuery = @remoteQuery + '
		--inner join ObjectNomenclature on1 on on1.ArchiveEntityGid = ae.Gid and on1._retired = ''3000-01-01''
		--inner join Nomenclature n1 on on1.NomenclatureGid = n1.Gid and n1.[Type] = ''Annotated'' and n1._retired = ''3000-01-01''
		--inner join freetexttable(Nomenclature,*,@KeywordsUIAnnotated) fts1 on n1._id = fts1.[key] ';
	if @ArchiveGids is not null and @ArchiveGids <> '-999' set @remoteQuery = @remoteQuery + '
		where ae.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else set @remoteQuery = @remoteQuery + '
		where 1 = 1';
	if @KMFCountriesOfOriginCodes is not null and @KMFCountriesOfOriginCodes <> '-999' set  @remoteQuery = @remoteQuery + '
		and ((select n.Value2 from Nomenclature n where n.Gid = jf.CountryGid and n.Type = ''FACountry'') in (''' + [dbo].[StringSplit3](@KMFCountriesOfOriginCodes) + '''))	
	';	
	set @remoteQuery = @remoteQuery + '
		and (jf.LevelOfDescriptionGid = 2185)
		and (ae.LevelOfDescriptionGid = 2371)
	';
	if @KMFNumber is not null or @ArchivalEntityNumber is not null and @LevelOfDescriptionGids <> '-999' set @remoteQuery = @remoteQuery + ''
	else set @remoteQuery = @remoteQuery + '
			and ((ae.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) +') or -999 in (' + @LevelOfDescriptionGids + '))
		';
	--if @ArchivalEntityNumber is not null set @remoteQuery = @remoteQuery + '
		--and (ae.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired = ''3000-01-01'' and [Type] = ''LevelOfDescription'' AND Code = 11)) --Арх.ед. - копия от чужди архиви
	--';
	if @FundNumber is not null set @remoteQuery = @remoteQuery + '
		and (jf.Number = ''' + @FundNumber + ''')
	';
	if @InventoryNumber is not null set @remoteQuery = @remoteQuery + '
		and (ji.Number = ''' + @InventoryNumber + ''')
	';
	if @ArchivalEntityNumber is not null set @remoteQuery = @remoteQuery + '
		and (ae.Number = ''' + @ArchivalEntityNumber + ''')
	';
	if @KMFNumber is not null set @remoteQuery = @remoteQuery + '
		and (ae.Number = ''' + @KMFNumber + ''')
	';
	if @ToDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @ToDate +''' >= ae.CreationDate)
	';
	if @FromDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @FromDate + ''' <= ae.CreationDate)
	';
	--if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
	--	and ((select FundArrayGid from ' + @fundsView + ' where LGid = inventory.FundLGid) in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	--';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
		and (jf.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +') 
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
			EntityTypeOrder,
			HasDigitizedDigitalObjects
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
			EntityTypeOrder,
			HasDigitizedDigitalObjects
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsFC.[KEY] as fcId, null as fcDId, kwdsFC.[RANK] as RankKwds
			from freetexttable(FilmCards, *, ''' + @KeyWords + ''') kwdsFC
			union 
			select null as fcId, kwdsFCD.[KEY] as fcDId, kwdsFCD.[RANK] as RankKwds  
			from freetexttable(FilmCardDrafts, *, ''' + @KeyWords + ''') kwdsFCD
		) kwds
		on (c.Id = kwds.fcDId and c.IsDraft = 1) or (c.Id = kwds.fcId and c.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlFC.[KEY] as fcId, null as fcDId, ttlFC.[RANK] as RankTitle   
			from freetexttable(FilmCards, Title, ''' + @Title + ''') ttlFC 
			union 
			select null as fcId, ttlFCD.[KEY] as fcDId, ttlFCD.[RANK] as RankTitle   
			from freetexttable(FilmCardDrafts, Title, ''' + @Title + ''') ttlFCD
		) ttl
		on (c.Id = ttl.fcDId and c.IsDraft = 1) or (c.Id = ttl.fcId and c.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rank = ',ttl.RankTitle as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(ttl.RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and ttl.RankTitle > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(ttl.RankTitle, 0) > 1';

	DECLARE @kmfCountriesOfOriginCodesFilter VARCHAR(MAX) = '';
	IF @KMFCountriesOfOriginCodes IS NOT NULL SET @kmfCountriesOfOriginCodesFilter = ' AND c.CountryId = ''' + @kmfCountriesOfOriginCodesFilter + '''';

	DECLARE @kmfNumberFilter VARCHAR(MAX) = '';
	IF @KMFNumber IS NOT NULL SET @kmfNumberFilter = ' AND c.FilmInventoryNumber=''' + @KMFNumber + '''';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_FilmCards' ELSE SET @table = 'v_PublicFilmCards'; -- къде е v_PublicFilmCards?

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 0 
		OR @FundNumber IS NOT NULL
		OR @InventoryNumber IS NOT NULL
		OR @ArchivalEntityNumber IS NOT NULL 
		SET @doNotGetAnythingFilter = ' AND 1 = 2' 
	ELSE SET @doNotGetAnythingFilter = '';	

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			''film_card'' AS EntityType,
			c.SystemIdentifier,
			(SELECT Name FROM Archives a where a.Id = c.ArchiveId) as ArchiveName,	
			NULL as FundNumber,
			NULL as InventoryNumber,
			NULL as ArchivalEntityNumber,
			c.FilmInventoryNumber as KMFNumber,
			c.InventoryNumber AS KMFNumber,
			c.Title as Title,
			NULL as TypeText,
			NULL as StatusText,
			NULL as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			NULL as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as  ArchivalEntityApproximateChronologicalScope,
			c.FilmSystemIdentifier,
			NULL as FundGid,
			NULL as FundIntNumber,
			NULL AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			c.FilmInventoryNumber AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			6 as EntityTypeOrder,
			0 as HasDigitizedDigitalObjects
		FROM ' + @table + ' c'
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE c.ExternalIdentifier IS NULL AND c.HasExternalSource = 0 AND c.Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (c.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(c.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(c.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @KMFCountriesOfOriginCodes + ''', '',''))) 
				OR (c.CountryCode in (select element from dbo.SplitString(''' + @KMFCountriesOfOriginCodes + ''', '',''))))'
			+ @kmfNumberFilter
			+ @doNotGetAnythingFilter
			+ @rankFilter;


	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteFilmCardsTable TABLE (
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
			EntityTypeOrder INT,
			HasDigitizedDigitalObjects BIT NULL
		);

		INSERT INTO @remoteFilmCardsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteFilmCardsTable
		UNION
		' +
		@localQuery;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
	--print @sql;
END
GO