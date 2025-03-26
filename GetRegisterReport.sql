USE [DAA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[GetRegisterReport] 
	@StatusGids nvarchar(max) = null,
	@ArchiveGids nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = NULL,
	@RegisteredTo nvarchar(100) = null,
	@DocLGid nvarchar(max) = null,
	@RowsOfPage int = 50,
	@Page int = 1
AS
BEGIN
	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX) = 
		'SELECT
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = (SELECT LevelOfDescriptionGid from Fund_Modified f where f.LGid = doc.FundLGid)) as LevelOfDescription,
				''Process.aspx?type=Document&agid='' + cast(doc.ArchiveGid as nvarchar(255)) + ''&flgid='' + cast(doc.FundLGid as nvarchar(255)) + ''&ilgid='' + cast(doc.InventoryLGid as nvarchar(255)) + ''&aelgid='' + cast(doc.AELGid as nvarchar(255)) + ''&dlgid=''+ cast(doc.LGid as nvarchar(255)) as Link123,
				''Линк'' as Link2,
			(select Name from archive where _retired = ''3000-01-01'' and Gid = doc.ArchiveGid) ArchiveName,
			(select CAST(Code as nvarchar(10)) from archive where _retired = ''3000-01-01'' and Gid = doc.ArchiveGid) ArchiveCode,
			LGid,
			(SELECT Number from Fund_Modified f where f.LGid = doc.FundLGid) as FundNumber,
			(SELECT Number from Inventory_Modified i where i.LGid = doc.InventoryLGid) as InvNumber,
			(SELECT Number from ArchiveEntity_Modified ae where ae.LGid = doc.AELGid) as AENumber,
			(
				select ln1.ListFrom + '' - '' + ln1.ListTo + ''; ''
				from  ListNumber ln1	
				where ln1._retired=''3000-01-01'' 
					and ln1.DocumentGid = doc.Gid 
				FOR XML path(''''), elements
			) as ListNumbers,
			doc.Title,
			doc.TextDate as ChronologicalScope,
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = doc.StatusGid) as DocStatus,
			convert(varchar, doc.DOCreationDate, 104) as DOCreationDate,
			COUNT(img.Gid) as ImageCount,
			SUM(isnull(img.ByteLenght, 0)) as BytesCount,
			case when  exists (select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.HasDigitalObject = 1 
			and d1.RowStatusGid = 71 
			and isnull(d1.DigitalObjectDeleted, 0) = 0)  then ''Активен'' else ''Заличен'' end as DOStatus,
			doc.DOCreationAuthor,
			(
				SELECT convert(varchar, MAX(x.ReturnDate1), 104)
				FROM
				(
					select 
						pr.ReturnDate as ReturnDate1
						from Document d inner join
						(
							select
								p57.ModifiedBy as ModifiedBy57,
								p58.ModifiedBy as ModifiedBy58,
								p57._created as ReturnDate,
								x.Gid
							from
							(
								select p1.Gid, MAX(p1._id) as _id1, MAX(p2._id) as _id2 from Process p1
								inner join Process p2 on p2.Gid = p1.Gid and p2.StepGid = 2158
								where p1.StepGid = 2157 and p1._id >p2._id
								group by p1.gid
							) x
							inner join Process p57 on p57._id = x._id1
							inner join Process p58 on p58._id = x._id2
						) pr 
					on d.ProcessGid = pr.Gid
				where
					ISNULL(d.HasDigitalObject, 0) = 1
					AND d.LGid = doc.LGid
				group by d.ArchiveGid, d.LGid, pr.ModifiedBy58, pr.ReturnDate, pr.ModifiedBy57) as x
			) as returnDate,
			(
				select convert(varchar, max(pr.ReturnDate), 104) 
				from Document d inner join
				(
					select
						p57.ModifiedBy as ModifiedBy57,
						p58.ModifiedBy as ModifiedBy58,
						p57._created as ReturnDate,
						x.Gid
					from
					(
						select p1.Gid, MIN(p1._id) as _id1, MIN(p2._id) as _id2 from Process p1
						inner join Process p2 on p2.Gid = p1.Gid and p2.StepGid = 2158
						where p1.StepGid = 2157 and p1._id > p2._id
						group by p1.gid
					) x
					inner join Process p57 on p57._id = x._id1
					inner join Process p58 on p58._id = x._id2
				) pr 
				on d.ProcessGid = pr.Gid and d.LGid=doc.LGid 
			) as returndate1,
			(
				select convert(varchar, max(p.ModifiedOn), 104)  
				from Document d
				inner join Process p on p._retired = ''3000-01-01'' and p.Gid = d.ProcessGid and p.TypeGid = 2124 and p.StepGid = 75
				where  d.LGid = doc.lgid
			) as datanapresuzdavane,
			(
				select convert(varchar, max(p.ModifiedOn), 104)  
				from Document d
				inner join Process p on p._retired = ''3000-01-01'' and p.Gid = d.ProcessGid and p.TypeGid = 2123 and p.StepGid = 75
				where  d.LGid = doc.lgid
			) as datanapriemanenadigitalniqobekt,
			(select n.Value + '', ''
				from Nomenclature n
				inner join ObjectNomenclature objn on n.Gid = objn.NomenclatureGid and objn._retired = ''3000-01-01'' and objn.DocumentGid = doc.Gid
				where 
				n._retired = ''3000-01-01''
				and n.[Type] = ''Annotated''
				FOR XML path(''''), elements
			) as AnnotatedList,
			doc.CreationDate
		FROM
			Document_Modified doc
			left outer join [Image] img on doc.Gid = img.DocumentGid and img._retired = ''3000-01-01''
		WHERE
			doc._retired = ''3000-01-01''
			AND ISNULL(doc.HasDigitalObject, 0) = 1
			AND (''' + COALESCE(cast(@DocLGid as varchar(100)), 'null') + ''' = ''null'' OR doc.LGid = ''' + COALESCE(cast(@DocLGid as varchar(100)), 'null') + ''')
			AND (''' + COALESCE(cast(@RegisteredFrom as varchar(100)), 'null') + ''' = ''null'' OR cast(doc.DOCreationDate as date) >= cast(''' + COALESCE(cast(@RegisteredFrom as varchar(100)), 'null') + ''' as datetime2))
			AND (''' + COALESCE(cast(@RegisteredTo as varchar(100)), 'null') + ''' = ''null'' OR cast(doc.DOCreationDate as date) <= cast(''' + COALESCE(cast(@RegisteredTo as varchar(100)), 'null') + ''' as datetime2))
			AND ((''active'' in (select element from dbo.SplitString(''' + cast(@StatusGids as varchar(100)) + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1 and isnull(DigitalObjectDeleted, 0) = 0))
				OR (''deleted'' in (select element from dbo.SplitString(''' + cast(@StatusGids as varchar(100)) + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1 and isnull(DigitalObjectDeleted, 0) = 1))
				OR (''-999'' in (select element from dbo.SplitString(''' + cast(@StatusGids as varchar(4)) + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1)))
			AND doc.ArchiveGid in (select element from dbo.SplitString(''' + cast(@ArchiveGids as varchar(100)) + ''', '',''))
		group by 
			doc.LGid, 
			doc.ArchiveGid, 
			doc.CreationDate, 
			doc.Title, 
			doc.StatusGid, 
			doc.DigitalObjectDeleted, 
			doc.DigitalObjectDeleted, 
			doc.DOCreationDate, 
			doc.FundLGid, 
			doc.InventoryLGid, 
			doc.AELGid, 
			doc.Gid,
			doc.StartDateDay,
			doc.StartDateMonth,
			doc.StartDateYear,
			doc.EndDateDay,
			doc.EndDateMonth,
			doc.EndDateYear,
			doc.TextDate,
			doc.DOCreationAuthor
		ORDER BY  ArchiveCode, doc.LGid ASC
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY';

	set @sql = REPLACE(@sql, '''', '''''');
	declare @result varchar(max) = 'SELECT * FROM openquery(ARCHIVING_PLEVEN, ''' + @sql +''')';
	exec (@result);
END
GO