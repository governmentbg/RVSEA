SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[SearchFundsForMainSearchComponent]  
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
	@ExtendedSearch bit null = 0,
	@SearchFileContent bit null = 0,
	@FileDbName nvarchar(50) = null,
	@FileBufferDbName nvarchar(50) = null
AS
BEGIN
	DECLARE @remoteFundQuery nvarchar(max), @kwds int, @fttl int;
	
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

	SET @remoteFundQuery = '';
	SET @remoteFundQuery = 'with fresults as (';
	set @remoteFundQuery = @remoteFundQuery + '
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
		+ ',1 AS EntityTypeOrder
		, 0 as HasDigitizedDigitalObjects';

	if @SearchDrafts = 0 
		set @remoteFundQuery = @remoteFundQuery + '
			from Fund_Active as fund
		';
	else 
		set @remoteFundQuery = @remoteFundQuery + '
			from Fund_Modified as fund
		';

	if @kwds = 1 
		set @remoteFundQuery = @remoteFundQuery + '
			left join freetexttable(Fund,*,'''+ @KeyWords + ''') kwds on fund._id = kwds.[key]
		';

	if @fttl = 1 
		set @remoteFundQuery = @remoteFundQuery + '
			left join freetexttable(Fund,(Title,FundFormerNameChange), '''+ @Title + ''') fttl on fund._id = fttl.[key]
		';

	if @ArchiveGids is not null and @ArchiveGids <> '-999' 
		set @remoteFundQuery = @remoteFundQuery + '	
			where fund.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids);
	else 
		set @remoteFundQuery = @remoteFundQuery + '
			where 1 = 1'; 

	if @FundNumber is not null 
		set @remoteFundQuery = @remoteFundQuery + '
			and (fund.Number = ''' + @FundNumber + ''')
		';
	
	-- Ако е за публичната част се махат тези със статус отчислен <> 2115 статус Фонд с необр. документи <> 91
	--if @SearchDrafts = 0
	--	begin
	--		set @remoteFundQuery = @remoteFundQuery + 'and fund.StatusGid <> 2115';
	--		set @remoteFundQuery = @remoteFundQuery + 'and fund.LevelOfDescriptionGid <> 91';
	--	end
	
	-- Изключват се изрично КМФ
	set @remoteFundQuery = @remoteFundQuery + 'and fund.LevelOfDescriptionGid <> 2185';

	-- въведен е номер на фонд, но не е избрано някое от нивата на описание за фондове, така имплицитно се разбира, че нивото на описание е някое от нивата за фонд(така са го поискали в писмо)
	if @FundNumber is not null
		and not '20' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '21' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '22' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '91' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
	BEGIN
		if @SearchDrafts = 1
			begin
			set @remoteFundQuery = @remoteFundQuery + '
				and (fund.LevelOfDescriptionGid in (20,21,22,91))';
			end
		if @SearchDrafts = 0
			begin
				set @remoteFundQuery = @remoteFundQuery + '
					and (fund.LevelOfDescriptionGid in (20,21,22))';
			end
	END

	if @LevelOfDescriptionGids <> '-999'
		set @remoteFundQuery = @remoteFundQuery + 'and (fund.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )';

	if @ToDate is not null 
		set @remoteFundQuery = @remoteFundQuery + '
			and (''' + @ToDate +''' >= fund.CreationDate)
		';

	if @FromDate is not null 
		set @remoteFundQuery = @remoteFundQuery + '
			and (''' + @FromDate + ''' <= fund.CreationDate)
		';

	IF @SearchDigitalObject = 1
	BEGIN
		IF (@SearchDrafts = 1)
			set @remoteFundQuery = @remoteFundQuery + '
				AND (exists (select 1 from Document_Search_Modified doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
			';
		ELSE
			set @remoteFundQuery = @remoteFundQuery + '
				AND (exists (select 1 from Document_Search_Active doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
			';
	END
	ELSE IF @SearchDigitalObject = 0
	BEGIN
		IF (@SearchDrafts = 1)
			set @remoteFundQuery = @remoteFundQuery + '
				AND ( not exists (select 1 from Document_Search_Modified doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
			';
		ELSE
			set @remoteFundQuery = @remoteFundQuery + '
				AND ( not exists (select 1 from Document_Search_Active doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1)	)
			';
	END

	--if @SearchDigitalObject = 1 and  @SearchDrafts = 1  
	--	set @remoteFundQuery = @remoteFundQuery + '
	--		AND (exists (select 1 from Document_Search_Active doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
	--	';
	--else if @SearchDigitalObject = 1  
	--	set @remoteFundQuery = @remoteFundQuery + '
	--		AND (exists (select 1 from Document_Search_Modified doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
	--	';
	--else if @SearchDigitalObject = 0 and  @SearchDrafts = 1  
	--	set @remoteFundQuery = @remoteFundQuery + '
	--		AND ( not exists (select 1 from Document_Search_Active doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1)	)
	--	';
	--else if @SearchDigitalObject = 0  
	--	set @remoteFundQuery = @remoteFundQuery + '
	--		AND ( not exists (select 1 from Document_Search_Modified doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
	--	';

	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteFundQuery = @remoteFundQuery + '
		and ( fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	';

	set @remoteFundQuery = @remoteFundQuery + @rankFilterRemote;

	if @SearchDrafts = 1 set @remoteFundQuery=@remoteFundQuery+'),
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
	else set @remoteFundQuery=@remoteFundQuery+'),
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

	SET @remoteFundQuery = REPLACE(@remoteFundQuery, '''', '''''');

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	--if search file content exclude inventory metadata
	IF (@kwds = 1 AND @SearchFileContent <> 1)
	BEGIN
		SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsf.[KEY] as fId, null as fdId, kwdsf.[RANK] as RankKwds
			from freetexttable(Funds, *, ''' + @KeyWords + ''') kwdsf
			union 
			select null as fId, kwdsfd.[KEY] as fdId, kwdsfd.[RANK] as RankKwds  
			from freetexttable(FundDrafts, *, ''' + @KeyWords + ''') kwdsfd
		) kwds
		on (f.Id = kwds.fdId and f.IsDraft = 1) or (f.Id = kwds.fId and f.IsDraft = 0)';
	END
	--IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
	--	left join 
	--	(
	--		select kwdsf.[KEY] as fId, null as fdId, kwdsf.[RANK] as RankKwds
	--		from freetexttable(Funds, *, ''' + @KeyWords + ''') kwdsf
	--		union 
	--		select null as fId, kwdsfd.[KEY] as fdId, kwdsfd.[RANK] as RankKwds  
	--		from freetexttable(FundDrafts, *, ''' + @KeyWords + ''') kwdsfd
	--	) kwds
	--	on (f.Id = kwds.fdId and f.IsDraft = 1) or (f.Id = kwds.fId and f.IsDraft = 0)';

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
	--if searching file content exclude ranking from keywords
	IF (@SearchFileContent <> 1)
	BEGIN
		IF @kwds = 1 AND  @fttl IS NULL SET @rank = ',RankKwds as Rank';
		IF @kwds <> 1 AND @fttl = 1 SET @rank = ',RankTitle as Rank';
		IF @kwds = 1 AND @fttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';
	END
	ELSE
	BEGIN
		IF @fttl = 1 SET @rank = ',RankTitle as Rank';
	END
	--IF @kwds = 1 AND @fttl IS NULL SET @rank = ',RankKwds as Rank'; 
	--IF @kwds <> 1 AND @fttl = 1 SET @rank = ',RankTitle as Rank';
	--IF @kwds = 1 AND @fttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	DECLARE @rankKwdsGroupBy VARCHAR(MAX) = '';
	DECLARE @rankTitleGroupBy VARCHAR(MAX) = '';
	--if searching file content exclude ranking from keywords
	IF (@SearchFileContent <> 1)
	BEGIN
		IF @kwds = 1 AND @fttl IS NULL 
		BEGIN
			SET @rankFilter = ' and RankKwds > 1'; 
			SET @rankKwdsGroupBy = ',kwds.RankKwds';
		END
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
	END
	ELSE
	BEGIN
		IF @fttl = 1 
		BEGIN
			SET @rankFilter = ' and RankTitle > 1';
			SET @rankTitleGroupBy = ',ftt.RankTitle';
		END
	END
	--IF @kwds = 1 AND @fttl IS NULL
	--BEGIN
	--	 SET @rankFilter = ' and RankKwds > 1'; 
	--	 SET @rankKwdsGroupBy = ',kwds.RankKwds';
	--END
	--DECLARE @rankTitleGroupBy VARCHAR(MAX) = '';

	--IF @kwds <> 1 AND @fttl = 1 
	--BEGIN
	--	SET @rankFilter = ' and RankTitle > 1';
	--	SET @rankTitleGroupBy = ',ftt.RankTitle';
	--END

	--IF @kwds = 1 AND @fttl = 1
	--BEGIN
	--	SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';
	--	SET @rankKwdsGroupBy = ',kwds.RankKwds';
	--	SET @rankTitleGroupBy = ',ftt.RankTitle';
	--END

	--DECLARE @isSuspenedFilter VARCHAR(MAX) = '';
	--IF @SearchDrafts = 1  SET @isSuspenedFilter = '  AND f.IsSuspended = 0';

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

	--Search in file content
	DECLARE @fileContentFilter VARCHAR(MAX) = '';
	IF @SearchFileContent = 1 AND @kwds = 1
	BEGIN
		DECLARE @fileContentBufferFilter nvarchar(max) = '';
		-- add search in buffer file content
		IF @SearchDrafts = 1
		BEGIN
			SET @fileContentBufferFilter = 
				'or EXISTS(
						select fc.stream_id, ffc.[KEY], ffc.[RANK], fc.name 
						  from [' + @FileBufferDbName + '].dbo.FileContent fc
						  join FREETEXTTABLE([' + @FileBufferDbName + '].dbo.FileContent, file_stream, ''' + @KeyWords + ''') ffc on fc.stream_id = ffc.[KEY]
						 where fc.name = fcdo.Name)';
		END

		--search file content in the registered file content
		SET @fileContentFilter = 
			'AND EXISTS(
				   select fcdo.FundSystemIdentifier, fcdo.InventorySystemIdentifier, fcdo.ArchivalEntitySystemIdentifier, fcdo.DocumentSystemIdentifier, fcdo.SystemIdentifier
				   from ' + @digitalObjectsTable + ' fcdo
				  where fcdo.FundSystemIdentifier = f.SystemIdentifier
					and (
						EXISTS(
							select fc.stream_id, ffc.[KEY], ffc.[RANK], fc.name 
							  from [' + @FileDbName + '].dbo.FileContent fc
							  join FREETEXTTABLE([' + @FileDbName + '].dbo.FileContent, file_stream, '''+ @KeyWords +''') ffc on fc.stream_id = ffc.[KEY]
							 where fc.name = fcdo.Name)
						' + @fileContentBufferFilter + '
					)
				)';
	END

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

	DECLARE @localFundQuery VARCHAR(MAX) = '
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
			1 as EntityTypeOrder,
			0 as HasDigitizedDigitalObjects
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
			+ @fileContentFilter
			+ @doNotGetAnythingFilter
			--+ @isSuspenedFilter
			+ @isDeductedFilter
			+ @rankFilter;

	--DECLARE @sql VARCHAR(MAX) = '
	--	DECLARE @remoteFundsTable TABLE (
	--		EntityType nvarchar(50) NULL,
	--		SystemIdentifier uniqueidentifier NULL,
	--		ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи го чупят в такъв случай
	--		FundNumber nvarchar(256) NULL,
	--		InventoryNumber nvarchar(256) NULL,
	--		ArchivalEntityNumber nvarchar(256) NULL, 
	--		KMFNumber nvarchar(256) NULL,
	--		FilmCardNumber nvarchar(256) NULL,
	--		Title nvarchar(MAX) NULL,
	--		TypeText nvarchar(MAX) NULL,
	--		StatusText nvarchar(MAX) NULL,
	--		FundDescriptionLevelText nvarchar(MAX) NULL,
	--		InventoryDescriptionLevelText nvarchar(MAX) NULL,
	--		ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
	--		HasExternalSource BIT NOT NULL,
	--		ExternalIdentifier INT NOT NULL,
	--		FundApproximateChronologicalScope nvarchar(256) NULL,
	--		InventoryApproximateChronologicalScope nvarchar(256) NULL,
	--		ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
	--		FilmSystemIdentifier uniqueidentifier NULL,
	--		FundGid int,
	--		FundIntNumber INT NULL,
	--		InventoryIntNumber INT NULL,
	--		ArchivalEntityIntNumber INT NULL,
	--		KMFIntNumber INT NULL,
	--		FilmCardIntNumber INT NULL,
	--		Rank INT,
	--		EntityTypeOrder INT
	--	);

	--	INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteFundQuery +''');' + 

	--	'SELECT * FROM @remoteFundsTable
	--	UNION
	--	' +
	--	@localFundQuery + '
	--	GROUP BY 
	--		--f.EntityType, 
	--		f.SystemIdentifier,
	--		f.ArchiveName,
	--		f.Number,
	--		--f.InventoryNumber,
	--		--f.ArchivalEntityNumber,
	--		f.Title,
	--		--f.TypeText,
	--		--f.StatusText,
	--		--f.FundDescriptionLevelText,
	--		--f.InventoryDescriptionLevelText,
	--		f.HasExternalSource,
	--		f.ExternalIdentifier,
	--		--f.InventoryApproximateChronologicalScope,
	--		-- тези, ако ги няма, се чупи
	--		f.ArchiveId,
	--		f.TypeCode,
	--		f.StatusCode,
	--		f.DescriptionLevelCode,
	--		f.ApproxmateChronologicalScope
	--		' + @rankKwdsGroupBy + ' 
	--		' + @rankTitleGroupBy + ' 
	--		,f.NumberNumeric
	--';








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
			EntityTypeOrder INT,
			HasDigitizedDigitalObjects BIT NULL
		);

		DECLARE @localFundsTable TABLE (
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
			ExternalIdentifier INT NULL,
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

	';

	--if searching file content exclude external source rows (no file content in external source)
	IF (@SearchFileContent <> 1)
	BEGIN
		SET @sql = @sql + '
			INSERT INTO @remoteFundsTable SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @remoteFundQuery + ''' );'
	END
	
	SET @sql = @sql + '
		INSERT INTO @localFundsTable ' + @localFundQuery + '
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

	SET @sql = @sql + '
		SELECT *
		  FROM
		  (
			 SELECT *
			   FROM @remoteFundsTable
			  UNION
			 SELECT *
			   FROM @localFundsTable
		   ) funds
	';


	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
	--print @sql;
END
GO

