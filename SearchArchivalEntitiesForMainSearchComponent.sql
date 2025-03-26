SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[SearchArchivalEntitiesForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodesInternal nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null,
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
	DECLARE @remoteAEQuery nvarchar(max), @kwds int, @kwdsAnnotated int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1;
	--set @kwdsAnnotated=0;
	--if @KeywordsUIAnnotated is not null and len(@KeywordsUIAnnotated) >=2 set @kwdsAnnotated=1;
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

	SET @remoteAEQuery = '';
	SET @remoteAEQuery = 'with fresults as (';
	set @remoteAEQuery = @remoteAEQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''archival_entity'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = ae.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		inventory.Number as InventoryNumber,
		ae.Number as ArchivalEntityNumber,
		NULL as KMFNumber,
		NULL as FilmCardNumber,
		ae.Title,
		NULL as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = ae.StatusGid) as StatusText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.LevelOfDescriptionGid) as FundDescriptionLevelText,	
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = inventory.LevelOfDescriptionGid) as InventoryDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		ae.LGid AS ExternalIdentifier,
		fund.TextDate AS FundApproximateChronologicalScope,
		inventory.TextDate AS InventoryApproximateChronologicalScope,
		ae.TextDate AS ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		NULL AS FundGid,
		fund.IntNumber as FundIntNumber,
		inventory.IntNumber AS InventoryIntNumber,
		ae.IntNumber AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		ae.Gid,
		ae.LGid'
		+ @rankRemote
		+ ',3 AS EntityTypeOrder
		, 0 as HasDigitizedDigitalObjects';

	if @SearchDrafts = 1 set @remoteAEQuery = @remoteAEQuery + '
		from ArchiveEntity_Active as ae
	';
	else set @remoteAEQuery = @remoteAEQuery + '
		from ArchiveEntity_Modified as ae
	';
	if @SearchDrafts = 1 set @remoteAEQuery = @remoteAEQuery + '
		inner join Inventory_Active inventory on inventory.LGid=ae.InventoryLGid
	';
	else set @remoteAEQuery = @remoteAEQuery + '
		inner join Inventory_Modified inventory on inventory.LGid=ae.InventoryLGid
	';
	if @SearchDrafts = 1 set @remoteAEQuery = @remoteAEQuery + '
		inner join Fund_Active fund on fund.LGid=ae.FundLGid
	';
	else set @remoteAEQuery = @remoteAEQuery + '
		inner join Fund_Modified fund on fund.LGid=ae.FundLGid
	';
	if @kwds = 1 set @remoteAEQuery = @remoteAEQuery + '
		left join freetexttable(ArchiveEntity,*, '''+ @KeyWords + ''') kwds on ae._id = kwds.[key]
	';
	if @ttl = 1 set @remoteAEQuery = @remoteAEQuery + '
		left join freetexttable(ArchiveEntity,Title, '''+ @Title + ''') fttl on ae._id = fttl.[key]
	';
	--if @kwdsAnnotated =1 set @remoteAEQuery = @remoteAEQuery + '
		--inner join ObjectNomenclature on1 on on1.ArchiveEntityGid = ae.Gid and on1._retired = ''3000-01-01''
		--inner join Nomenclature n1 on on1.NomenclatureGid = n1.Gid and n1.[Type] = ''Annotated'' and n1._retired = ''3000-01-01''
		--inner join freetexttable(Nomenclature,*,@KeywordsUIAnnotated) fts1 on n1._id = fts1.[key] ';
	if @ArchiveGids is not null and @ArchiveGids <> '-999' set @remoteAEQuery = @remoteAEQuery + '
		where ae.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else set @remoteAEQuery = @remoteAEQuery + '
		where 1 = 1
	';
	set @remoteAEQuery = @remoteAEQuery + '
		and (fund.LevelOfDescriptionGid <> 2185 or ae.LevelOfDescriptionGid <> 2371)
	';
	--if @ArchivalEntityNumber is not null set @remoteAEQuery = @remoteAEQuery + '
		--and (ae.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired = ''3000-01-01'' and [Type] = ''LevelOfDescription'' AND Code = 11)) --Арх.ед. - копия от чужди архиви
	--';
	if @FundNumber is not null set @remoteAEQuery = @remoteAEQuery + '
		and (fund.Number = ''' + @FundNumber + ''')
	';
	if @InventoryNumber is not null set @remoteAEQuery = @remoteAEQuery + '
		and (inventory.Number = ''' + @InventoryNumber + ''')
	';
	if @ArchivalEntityNumber is not null set @remoteAEQuery = @remoteAEQuery + '
		and (ae.Number = ''' + @ArchivalEntityNumber + ''')
	';
	if @ArchivalEntityNumber is not null
		and not '2174' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2373' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteAEQuery = @remoteAEQuery + '
			and (ae.LevelOfDescriptionGid in (2174,2373))
	' 
	else if @ArchivalEntityNumber is null
		and not '2174' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2373' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '-999' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteAEQuery = @remoteAEQuery + '
			and 1=2
	' 
	else if @LevelOfDescriptionGids <> '-999'
		and ('2174' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')) or '2373' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')))
		set @remoteAEQuery = @remoteAEQuery + '
			and (ae.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )
	';
	if @ToDate is not null set @remoteAEQuery = @remoteAEQuery + '
		and (''' + @ToDate +''' >= ae.CreationDate)
	';
	if @FromDate is not null set @remoteAEQuery = @remoteAEQuery + '
		and (''' + @FromDate + ''' <= ae.CreationDate)
	';
	--if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteAEQuery = @remoteAEQuery + '
	--	and ((select FundArrayGid from ' + @fundsView + ' where LGid = inventory.FundLGid) in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	--';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteAEQuery = @remoteAEQuery + '
		and (fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +') 
	'
	if @SearchDigitalObject = 1 and  @SearchDrafts = 1  set @remoteAEQuery = @remoteAEQuery + '
		AND (exists (select 1 from Document_Search_Active doc where doc.AELGid = ae.LGid and doc.HasDigitalObject = 1))
	';
	else if @SearchDigitalObject = 1  set @remoteAEQuery = @remoteAEQuery + '
		AND (exists (select 1 from Document_Search_Modified doc where doc.AELGid = ae.LGid and doc.HasDigitalObject = 1))
	';
	else if @SearchDigitalObject = 0 and  @SearchDrafts = 1  set @remoteAEQuery = @remoteAEQuery + '
		AND ( not exists (select 1 from Document_Search_Active doc where doc.AELGid = ae.LGid and doc.HasDigitalObject = 1)	)
	';
	else if @SearchDigitalObject = 0  set @remoteAEQuery = @remoteAEQuery + '
		AND (not exists (select 1 from Document_Search_Modified doc where doc.AELGid = ae.LGid and doc.HasDigitalObject = 1))
	';	
	set @remoteAEQuery = @remoteAEQuery + @rankFilterRemote;


	if @SearchDrafts = 1 set @remoteAEQuery=@remoteAEQuery+'),
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
	else set @remoteAEQuery=@remoteAEQuery+'),
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

	SET @remoteAEQuery = REPLACE(@remoteAEQuery, '''', '''''');

	DECLARE @fundsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = ae.FundSystemIdentifier';
	IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = ae.FundSystemIdentifier';

	DECLARE @inventoriesJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @inventoriesJoin = ' inner join v_Inventories i on i.SystemIdentifier = ae.InventorySystemIdentifier';
	IF @SearchDrafts = 0 SET @inventoriesJoin = ' inner join v_PublicInventories i on i.SystemIdentifier = ae.InventorySystemIdentifier';

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	--if search file content exclude AE metadata
	IF (@kwds = 1 AND @SearchFileContent <> 1)
	BEGIN
		SET @freeTextTableByKwdsJoin = ' 
			left join 
			(
				select kwdsAE.[KEY] as aeId, null as aeDId, kwdsAE.[RANK] as RankKwds
				from freetexttable(ArchivalEntities, *, ''' + @KeyWords + ''') kwdsAE
				union 
				select null as aeId, kwdsAED.[KEY] as aeDId, kwdsAED.[RANK] as RankKwds  
				from freetexttable(ArchivalEntityDrafts, *, ''' + @KeyWords + ''') kwdsAED
			) kwds
			on (ae.Id = kwds.aeDId and ae.IsDraft = 1) or (ae.Id = kwds.aeId and ae.IsDraft = 0)';
	END
	--IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
	--	left join 
	--	(
	--		select kwdsAE.[KEY] as aeId, null as aeDId, kwdsAE.[RANK] as RankKwds
	--		from freetexttable(ArchivalEntities, *, ''' + @KeyWords + ''') kwdsAE
	--		union 
	--		select null as aeId, kwdsAED.[KEY] as aeDId, kwdsAED.[RANK] as RankKwds  
	--		from freetexttable(ArchivalEntityDrafts, *, ''' + @KeyWords + ''') kwdsAED
	--	) kwds
	--	on (ae.Id = kwds.aeDId and ae.IsDraft = 1) or (ae.Id = kwds.aeId and ae.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlAE.[KEY] as aeId, null as aeDId, ttlAE.[RANK] as RankTitle   
			from freetexttable(ArchivalEntities, Title, ''' + @Title + ''') ttlAE 
			union 
			select null as aeId, ttlAEd.[KEY] as aeDId, ttlAEd.[RANK] as RankTitle   
			from freetexttable(ArchivalEntityDrafts, Title, ''' + @Title + ''') ttlAEd
		) ttl
		on (ae.Id = ttl.aeDId and ae.IsDraft = 1) or (ae.Id = ttl.aeId and ae.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	--if searching file content exclude ranking from keywords
	IF (@SearchFileContent <> 1)
	BEGIN
		IF @kwds = 1 AND  @ttl IS NULL SET @rank = ',RankKwds as Rank';
		IF @kwds <> 1 AND @ttl = 1 SET @rank = ',RankTitle as Rank';
		IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';
	END
	ELSE
	BEGIN
		IF @ttl = 1 SET @rank = ',RankTitle as Rank';
	END
	--IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	--IF @kwds <> 1 AND @ttl = 1 SET @rank = ',RankTitle as Rank';
	--IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	--if searching file content exclude ranking from keywords
	IF (@SearchFileContent <> 1)
	BEGIN
		IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
		IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
		IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';
	END
	ELSE
	BEGIN
		IF @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
	END
	--IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	--IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
	--IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';

	-- WTF? Suspended item must BE searchable!!!
	--DECLARE @isSuspenedFilter VARCHAR(MAX) = '';
	--IF @SearchDrafts = 1  SET @isSuspenedFilter = ' AND f.IsSuspended = 0 AND i.IsSuspended = 0 AND ae.IsSuspended = 0';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberFilter VARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NOT NULL SET @archivalEntityNumberFilter = ' AND ae.Number=''' + @ArchivalEntityNumber + '''';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = ae.StatusCode) <> 12';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_ArchivalEntities' ELSE SET @table = 'v_PublicArchivalEntities';

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' left join v_PublicDocuments d on d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' left join v_Documents d on d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier';

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
						 where fc.name = fcdo.Name)'
		END

		--search file content in the registered file content
		SET @fileContentFilter = 
			'AND EXISTS(
				   select fcdo.FundSystemIdentifier, fcdo.InventorySystemIdentifier, fcdo.ArchivalEntitySystemIdentifier, fcdo.DocumentSystemIdentifier, fcdo.SystemIdentifier
				   from ' + @digitalObjectsTable + ' fcdo
				  where fcdo.ArchivalEntitySystemIdentifier = ae.SystemIdentifier
					and (
						EXISTS(
							select fc.stream_id, ffc.[KEY], ffc.[RANK], fc.name 
							  from [' + @FileDbName + '].dbo.FileContent fc
							  join FREETEXTTABLE([' + @FileDbName + '].dbo.FileContent, file_stream, '''+ @KeyWords +''') ffc on fc.stream_id = ffc.[KEY]
							 where fc.name = fcdo.Name)
						' + @fileContentBufferFilter + '
					)
				)'
		
	END

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';		

	DECLARE @archivalEntityDescriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @ArchivalEntityNumber is not null and @FundDescriptionLevelCodesInternal = '-111' set @FundDescriptionLevelCodesInternal = '-999';
	if @ArchivalEntityNumber is not null and @InventoryDescriptionLevelCodesInternal = '-111' set @InventoryDescriptionLevelCodesInternal = '-999';
	if @ArchivalEntityNumber is not null and @ArchivalEntityDescriptionLevelCodesInternal = '-111' 
		set @archivalEntityDescriptionLevelCodesFilter = '' 
	else
		set @archivalEntityDescriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodesInternal + ''', '',''))) 
				OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodesInternal + ''', '',''))))
		';

	DECLARE @localAEQuery VARCHAR(MAX) = '
		SELECT
			''archival_entity'' AS EntityType,
			ae.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = i.ArchiveId) as ArchiveName,	
			f.Number as FundNumber,
			i.Number as InventoryNumber,
			ae.Number as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			ae.Title as Title,
			NULL as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = ae.StatusCode) as StatusText,
			(SELECT Text FROM [N].[FundDescriptionLevel] fdl where fdl.Code = f.DescriptionLevelCode) as FundDescriptionLevelText,
			(SELECT Text FROM [N].[InventoryDescriptionLevel] idl where idl.Code = i.DescriptionLevelCode) as InventoryDescriptionLevelText,
			(SELECT Text FROM [N].[ArchivalEntityDescriptionLevel] aedl where aedl.Code = ae.DescriptionLevelCode) as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			f.ApproxmateChronologicalScope as FundApproximateChronologicalScope,
			i.ApproxmateChronologicalScope as InventoryApproximateChronologicalScope,
			ae.ApproxmateChronologicalScope as  ArchivalEntityApproximateChronologicalScope,
			NULL as FilmSystemIdentifier,
			NULL as FundGid,
			ae.FundNumberNumeric AS FundIntNumber,
			ae.InventoryNumberNumeric AS InventoryIntNumber,
			ae.NumberNumeric AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			3 as EntityTypeOrder,
			0 as HasDigitizedDigitalObjects
		FROM ' + @table + ' ae'
		+ @inventoriesJoin +
		+ @fundsJoin + 
		+ @documentsJoin +
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE ae.ExternalIdentifier IS NULL AND ae.HasExternalSource = 0 AND ae.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (ae.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + 
			+ @archivalEntityNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundDescriptionLevel fdl where fdl.Code = f.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.InventoryDescriptionLevel idl where idl.Code = i.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(ae.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(ae.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @archivalEntityDescriptionLevelCodesFilter
			+ @doNotGetAnythingFilter
			--+ @isSuspenedFilter
			+ @digitalObjectsFilter
			+ @fileContentFilter
			+ @isDeductedFilter
			+ @rankFilter;


	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteAETable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL,
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

		DECLARE @localAETable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL,
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
			INSERT INTO @remoteAETable SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @remoteAEQuery + ''' );'
	END
	
	SET @sql = @sql + '
		INSERT INTO @localAETable ' + @localAEQuery;

	SET @sql = @sql + '
		SELECT *
		  FROM
		  (
			 SELECT *
			   FROM @remoteAETable
			  UNION
			 SELECT *
			   FROM @localAETable
		   ) archivalEntities
	';


	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO
