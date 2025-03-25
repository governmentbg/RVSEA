SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.34'
where Code = 'DB_VERSION'
go

 IF EXISTS (SELECT 1 FROM N.FundArray WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='А')
  BEGIN
  UPDATE N.FundArray SET ExternalIdentifier=2020, HasExternalSource=1 where Code='А' and Text='А'
  END

  GO
  
  IF EXISTS (SELECT 1 FROM N.FundArray WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='Б')
  BEGIN
  UPDATE N.FundArray SET ExternalIdentifier=2021, HasExternalSource=1 where Code='Б' and Text='Б'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.FundArray WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='В')
  BEGIN
  UPDATE N.FundArray SET ExternalIdentifier=2022, HasExternalSource=1 where Code='В' and Text='В'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.FundArray WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='Без индекс')
  BEGIN
  UPDATE N.FundArray SET ExternalIdentifier=2121, HasExternalSource=1 where Code='Без индекс' and Text='Без индекс'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.FundArray WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='К')
  BEGIN
  UPDATE N.FundArray SET ExternalIdentifier=2023, HasExternalSource=1 where Code='К' and Text='К'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.FundType WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='1' and [Text]='Групов')
  BEGIN
  UPDATE N.FundType SET ExternalIdentifier=27, HasExternalSource=1 where Code='1' and [Text]='Групов'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.FundType WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='2' and [Text]='Колекция')
  BEGIN
  UPDATE N.FundType SET ExternalIdentifier=29, HasExternalSource=1 where Code='2' and [Text]='Колекция'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.FundType WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='3' and [Text]='Личен произход')
  BEGIN
  UPDATE N.FundType SET ExternalIdentifier=28, HasExternalSource=1 where Code='3' and [Text]='Личен произход'
  END

  GO
  
  IF EXISTS (SELECT 1 FROM N.FundType WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='6' and [Text]='Учрежденски')
  BEGIN
  UPDATE N.FundType SET ExternalIdentifier=26, HasExternalSource=1 where Code='6' and [Text]='Учрежденски'
  END

  GO
 

 IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'ExternalIdentifier'
          AND Object_ID = Object_ID(N'N.Nomenclatures'))
BEGIN
    ALTER TABLE N.Nomenclatures
    ADD ExternalIdentifier int  NULL
END

GO

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'HasExternalSource'
          AND Object_ID = Object_ID(N'N.Nomenclatures'))
BEGIN
    ALTER TABLE N.Nomenclatures
    ADD HasExternalSource bit NOT NULL DEFAULT 0
END

GO

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'ExternalSourceUpdatedOn'
          AND Object_ID = Object_ID(N'N.Nomenclatures'))
BEGIN
    ALTER TABLE N.Nomenclatures
    ADD ExternalSourceUpdatedOn datetime2 NULL
END

GO

  IF EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='1' and [Text]='Д (дарение)')
  BEGIN
  UPDATE N.Nomenclatures SET ExternalIdentifier=2117, HasExternalSource=1 where Code='1' and [Text]='Д (дарение)'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='2' and [Text]='К (срещу възнаграждение)')
  BEGIN
  UPDATE N.Nomenclatures SET ExternalIdentifier=2118, HasExternalSource=1 where Code='2' and [Text]='К (срещу възнаграждение)'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='3' and [Text]='П (приет/комплектуване)')
  BEGIN
  UPDATE N.Nomenclatures SET ExternalIdentifier=2116, HasExternalSource=1 where Code='3' and [Text]='П (приет/комплектуване)'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='0101' and [Text]='Централно държавно управление')
  BEGIN
  UPDATE N.Nomenclatures SET ExternalIdentifier=117, HasExternalSource=1 where Code='0101' and [Text]='Централно държавно управление'
  END

 GO

  IF EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='0102' and [Text]='Местно държавно управление')
  BEGIN
  UPDATE N.Nomenclatures SET ExternalIdentifier=118, HasExternalSource=1 where Code='0102' and [Text]='Местно държавно управление'
  END
  GO


  IF EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='0104' and [Text]='Съдебни и юридически учреждения')
  BEGIN
  UPDATE N.Nomenclatures SET ExternalIdentifier=120, HasExternalSource=1 where Code='0104' and [Text]='Съдебни и юридически учреждения'
  END

  GO


  IF EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='0105' and [Text]='Отбрана и охрана на държавната безопасност')
  BEGIN
  UPDATE N.Nomenclatures SET ExternalIdentifier=121, HasExternalSource=1 where Code='0105' and [Text]='Отбрана и охрана на държавната безопасност'
  END
  GO

  IF EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='0103' and [Text]='Управление на кооперативни организации')
  BEGIN
  UPDATE N.Nomenclatures SET ExternalIdentifier=119, HasExternalSource=1 where Code='0103' and [Text]='Управление на кооперативни организации'
  END
  GO

      IF EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='0201' and [Text]='Политически организации')
  BEGIN
  UPDATE N.Nomenclatures SET ExternalIdentifier=122, HasExternalSource=1 where Code='0201' and [Text]='Политически организации'
  END

  GO

      IF EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='0202' and [Text]='Обществени организации')
  BEGIN
  UPDATE N.Nomenclatures SET ExternalIdentifier=123, HasExternalSource=1 where Code='0202' and [Text]='Обществени организации'
  END
GO


   IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'ExternalIdentifier'
          AND Object_ID = Object_ID(N'N.ProcessTypes'))
BEGIN
    ALTER TABLE N.ProcessTypes
    ADD ExternalIdentifier int  NULL
END

GO

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'HasExternalSource'
          AND Object_ID = Object_ID(N'N.ProcessTypes'))
BEGIN
    ALTER TABLE N.ProcessTypes
    ADD HasExternalSource bit NOT NULL DEFAULT 0
END

GO

    IF EXISTS (SELECT 1 FROM N.ProcessTypes WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='AddInventory' and [Name]='Регистриране на пореден опис')
  BEGIN
  UPDATE N.ProcessTypes SET ExternalIdentifier=210, HasExternalSource=1 where Code='AddInventory' and [Name]='Регистриране на пореден опис'
  END

  GO

      IF EXISTS (SELECT 1 FROM N.ProcessTypes WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='AddRawInventory' and [Name]='Регистриране на опис с необработени документи')
  BEGIN
  UPDATE N.ProcessTypes SET ExternalIdentifier=211, HasExternalSource=1 where Code='AddRawInventory' and [Name]='Регистриране на опис с необработени документи'
  END

  GO

      IF EXISTS (SELECT 1 FROM N.ProcessTypes WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='FilmRegisterData' and [Name]='Регистриране на копия от чужди архиви')
  BEGIN
  UPDATE N.ProcessTypes SET ExternalIdentifier=2127, HasExternalSource=1 where Code='FilmRegisterData' and [Name]='Регистриране на копия от чужди архиви'
  END

  GO
      IF EXISTS (SELECT 1 FROM N.ProcessTypes WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='AddDocument' and [Name]='Добавяне на документ')
  BEGIN
  UPDATE N.ProcessTypes SET ExternalIdentifier=2377, HasExternalSource=1 where Code='AddDocument' and [Name]='Добавяне на документ'
  END

  GO

      IF EXISTS (SELECT 1 FROM N.ProcessTypes WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='PreparationOfADigitalObject' and [Name]='Изготвяне на дигитален обект')
  BEGIN
  UPDATE N.ProcessTypes SET ExternalIdentifier=2123, HasExternalSource=1 where Code='PreparationOfADigitalObject' and [Name]='Изготвяне на дигитален обект'
  END

  GO

      IF EXISTS (SELECT 1 FROM N.ProcessTypes WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='Deduction' and [Name]='Отчисляване')
  BEGIN
  UPDATE N.ProcessTypes SET ExternalIdentifier=215, HasExternalSource=1 where Code='Deduction' and [Name]='Отчисляване'
  END

  GO

      IF EXISTS (SELECT 1 FROM N.ProcessTypes WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='EditData' and [Name]='Редакция')
  BEGIN
  UPDATE N.ProcessTypes SET ExternalIdentifier=2129, HasExternalSource=1 where Code='EditData' and [Name]='Редакция'
  END

  GO

      IF EXISTS (SELECT 1 FROM N.ProcessTypes WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='RefineData' and [Name]='Усъвършенстване')
  BEGIN
  UPDATE N.ProcessTypes SET ExternalIdentifier=214, HasExternalSource=1 where Code='RefineData' and [Name]='Усъвършенстване'
  END

  GO

      IF EXISTS (SELECT 1 FROM N.ProcessTypes WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='EditFundData' and [Name]='Промяна в наименованието на фонда')
  BEGIN
  UPDATE N.ProcessTypes SET ExternalIdentifier=217, HasExternalSource=1 where Code='EditFundData' and [Name]='Промяна в наименованието на фонда'
  END

  GO

      IF EXISTS (SELECT 1 FROM N.ProcessTypes WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='AddRawInventoryRaw' and [Name]='Регистриране на опис с необработени документи')
  BEGIN
  UPDATE N.ProcessTypes SET ExternalIdentifier=211, HasExternalSource=1 where Code='AddRawInventoryRaw' and [Name]='Регистриране на опис с необработени документи'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.ProcessTypes WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='AddFundAndInventory' and [Name]='Регистриране на нов фонд с обработени документи')
  BEGIN
  UPDATE N.ProcessTypes SET ExternalIdentifier=208, HasExternalSource=1 where Code='AddFundAndInventory' and [Name]='Регистриране на нов фонд с обработени документи'
  END

  GO

  
  IF EXISTS (SELECT 1 FROM N.ProcessTypes WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='AddRawFundAndRawInventory' and [Name]='Регистриране на нов фонд с необработени документи/ЧП/Спомен')
  BEGIN
  UPDATE N.ProcessTypes SET ExternalIdentifier=209, HasExternalSource=1 where Code='AddRawFundAndRawInventory' and [Name]='Регистриране на нов фонд с необработени документи/ЧП/Спомен'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.ProcessTypes WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='ProcessRawFundWithRawInventory' and [Name]='Обработка на необработени постъпления')
  BEGIN
  UPDATE N.ProcessTypes SET ExternalIdentifier=220, HasExternalSource=1 where Code='ProcessRawFundWithRawInventory' and [Name]='Обработка на необработени постъпления'
  END

  GO

    IF EXISTS (SELECT 1 FROM N.ProcessTypes WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='ReconstructFundData' and [Name]='Пресъставяне')
  BEGIN
  UPDATE N.ProcessTypes SET ExternalIdentifier=216, HasExternalSource=1 where Code='ReconstructFundData' and [Name]='Пресъставяне'
  END

  GO

    IF EXISTS (SELECT 1 FROM N.ProcessTypes WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='ProcessFundWithRawInventory' and [Name]='Обработка на необработени постъпления')
  BEGIN
  UPDATE N.ProcessTypes SET ExternalIdentifier=220, HasExternalSource=1 where Code='ProcessFundWithRawInventory' and [Name]='Обработка на необработени постъпления'
  END

  GO

      IF EXISTS (SELECT 1 FROM N.Status WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='1' and [Text]='Нов')
  BEGIN
  UPDATE N.Status SET ExternalIdentifier=11, HasExternalSource=1 where Code='1' and [Text]='Нов'
  END

  GO

      IF EXISTS (SELECT 1 FROM N.Status WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='10' and [Text]='Необработен')
  BEGIN
  UPDATE N.Status SET ExternalIdentifier=192, HasExternalSource=1 where Code='10' and [Text]='Необработен'
  END

  GO

  
  IF EXISTS (SELECT 1 FROM N.Status WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='11' and [Text]='Променено наименование')
  BEGIN
  UPDATE N.Status SET ExternalIdentifier=223, HasExternalSource=1 where Code='11' and [Text]='Променено наименование'
  END

  GO
  
  IF EXISTS (SELECT 1 FROM N.Status WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='12' and [Text]='Отчислен')
  BEGIN
  UPDATE N.Status SET ExternalIdentifier=2115, HasExternalSource=1 where Code='12' and [Text]='Отчислен'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.Status WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='13' and [Text]='Обработен')
  BEGIN
  UPDATE N.Status SET ExternalIdentifier=2120, HasExternalSource=1 where Code='13' and [Text]='Обработен'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.Status WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='14' and [Text]='Преместен')
  BEGIN
  UPDATE N.Status SET ExternalIdentifier=2241, HasExternalSource=1 where Code='14' and [Text]='Преместен'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.Status WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='2' and [Text]='Регистриран')
  BEGIN
  UPDATE N.Status SET ExternalIdentifier=12, HasExternalSource=1 where Code='2' and [Text]='Регистриран'
  END

  GO

  
  IF EXISTS (SELECT 1 FROM N.Status WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='3' and [Text]='Усъвършенстван')
  BEGIN
  UPDATE N.Status SET ExternalIdentifier=13, HasExternalSource=1 where Code='3' and [Text]='Усъвършенстван'
  END

  GO

  
  IF EXISTS (SELECT 1 FROM N.Status WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='4' and [Text]='Заличен')
  BEGIN
  UPDATE N.Status SET ExternalIdentifier=14, HasExternalSource=1 where Code='4' and [Text]='Заличен'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.Status WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='5' and [Text]='Възстановен')
  BEGIN
  UPDATE N.Status SET ExternalIdentifier=15, HasExternalSource=1 where Code='5' and [Text]='Възстановен'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.Status WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='6' and [Text]='Пререгистриран')
  BEGIN
  UPDATE N.Status SET ExternalIdentifier=16, HasExternalSource=1 where Code='6' and [Text]='Пререгистриран'
  END

  GO

  
  IF EXISTS (SELECT 1 FROM N.Status WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='7' and [Text]='Редактиран')
  BEGIN
  UPDATE N.Status SET ExternalIdentifier=17, HasExternalSource=1 where Code='7' and [Text]='Редактиран'
  END

  GO


  IF EXISTS (SELECT 1 FROM N.Status WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='8' and [Text]='Пресъставен')
  BEGIN
  UPDATE N.Status SET ExternalIdentifier=18, HasExternalSource=1 where Code='8' and [Text]='Пресъставен'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.Status WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='9' and [Text]='Пресъздаден')
  BEGIN
  UPDATE N.Status SET ExternalIdentifier=19, HasExternalSource=1 where Code='9' and [Text]='Пресъздаден'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.DocumentDescriptionLevel WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='1' and [Text]='Документ')
  BEGIN
  UPDATE N.DocumentDescriptionLevel SET ExternalIdentifier=2173, HasExternalSource=1 where Code='1' and [Text]='Документ'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.ArchivalEntityDescriptionLevel WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='1' and [Text]='Архивна единица')
  BEGIN
  UPDATE N.ArchivalEntityDescriptionLevel SET ExternalIdentifier=2174, HasExternalSource=1 where Code='1' and [Text]='Архивна единица'
  END

  GO
    
  IF EXISTS (SELECT 1 FROM N.ArchivalEntityDescriptionLevel WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='2' and [Text]='Служебна архивна единица')
  BEGIN
  UPDATE N.ArchivalEntityDescriptionLevel SET ExternalIdentifier=2373, HasExternalSource=1 where Code='2' and [Text]='Служебна архивна единица'
  END

  GO

    
  IF EXISTS (SELECT 1 FROM N.InventoryDescriptionLevel WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='5' and [Text]='Инвентарен опис')
  BEGIN
  UPDATE N.InventoryDescriptionLevel SET ExternalIdentifier=2171, HasExternalSource=1 where Code='5' and [Text]='Инвентарен опис'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.InventoryDescriptionLevel WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='6' and [Text]='Груб опис')
  BEGIN
  UPDATE N.InventoryDescriptionLevel SET ExternalIdentifier=2172, HasExternalSource=1 where Code='6' and [Text]='Груб опис'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.FundDescriptionLevel WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='1' and [Text]='Фонд')
  BEGIN
  UPDATE N.FundDescriptionLevel SET ExternalIdentifier=20, HasExternalSource=1 where Code='1' and [Text]='Фонд'
  END

  GO

      
  IF EXISTS (SELECT 1 FROM N.FundDescriptionLevel WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='3' and [Text]='Спомен')
  BEGIN
  UPDATE N.FundDescriptionLevel SET ExternalIdentifier=22, HasExternalSource=1 where Code='3' and [Text]='Спомен'
  END

  GO

  IF EXISTS (SELECT 1 FROM N.FundDescriptionLevel WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='4' and [Text]='ЧП')
  BEGIN
  UPDATE N.FundDescriptionLevel SET ExternalIdentifier=21, HasExternalSource=1 where Code='4' and [Text]='ЧП'
  END

  GO

      
  IF EXISTS (SELECT 1 FROM N.FundDescriptionLevel WHERE ExternalIdentifier is null and HasExternalSource=0 and Code='2' and [Text]='Фонд с необработени документи')
  BEGIN
  UPDATE N.FundDescriptionLevel SET ExternalIdentifier=91, HasExternalSource=1 where Code='2' and [Text]='Фонд с необработени документи'
  END

  GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'N' 
                 AND  TABLE_NAME = 'FilmDescriptionLevel'))
				 BEGIN
CREATE TABLE [N].[FilmDescriptionLevel](
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[SortOrder] [int] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL default 0,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_FilmDescriptionLevel] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END

GO

IF NOT EXISTS (SELECT 1 FROM N.FilmDescriptionLevel WHERE Code = '1')
BEGIN
	INSERT INTO N.FilmDescriptionLevel (Code, [Text],[ExternalIdentifier],[HasExternalSource])
	VALUES ('1', 'КМФ',2185,1)	 
END
GO

  IF NOT EXISTS (SELECT 1 FROM N.FilmDescriptionLevel WHERE Code = '2')
BEGIN
	INSERT INTO N.FilmDescriptionLevel (Code, [Text],[ExternalIdentifier],[HasExternalSource])
	VALUES('-1','Архивна единица (КМФ)', 2371,1) 
END
GO


--  IF  EXISTS (SELECT 1 FROM N.FilmDescriptionLevel WHERE Code = '2')
--BEGIN
--	update N.FilmDescriptionLevel set Code = '-1' where  Code = '2'
	
--END
--GO

  IF NOT EXISTS (SELECT 1 FROM N.FilmDescriptionLevel WHERE Code = '-2')
BEGIN
	INSERT INTO N.FilmDescriptionLevel (Code, [Text],[SortOrder],[ExternalIdentifier],[HasExternalSource])
	VALUES ('-2', 'Инвентарен номер (КМФ)',2,2369,1)	 
END
GO

  IF  EXISTS (SELECT 1 FROM N.FilmDescriptionLevel WHERE Code = '-1')
BEGIN
	update  N.FilmDescriptionLevel set [SortOrder] =3 where Code='-1'
	 
END
GO



IF  EXISTS (SELECT 1 FROM N.FilmDescriptionLevel WHERE Code = '1')
BEGIN
	update  N.FilmDescriptionLevel set [SortOrder] =1 where Code='1'
	 
END
GO

IF NOT EXISTS (SELECT 1 FROM N.FilmDescriptionLevel WHERE Code = '2')
BEGIN
	INSERT INTO N.FilmDescriptionLevel (Code, [Text],[SortOrder])
	VALUES ('2', 'КМФ картон',4)	 
END
GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[sp_GetRegisterOfDigitizedDocumentsReport]
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null,
	@RegisteredFrom datetime2(7) = null,
	@RegisteredTo datetime2(7) = null
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка

	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by ArchiveSortOrder, FundNumber, InventoryNumber, ArchiveEntityNumber -- ако се добавят FundIntNumber, InventoryIntNumber, ArchivalEntityIntNumber бави твърде много
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT 
			''document'' as DocumentLink, -- Link_todo
			(select CAST(a.Code as nvarchar(10)) from archive as a where _retired = ''3000-01-01'' and Gid = d.ArchiveGid) as ArchiveCode,
			a.Name as ArchiveName,
			CAST(d.Gid as nvarchar(256)) as SystemId,
			(select n.Value FROM Nomenclature as n where _retired = ''3000-01-01'' and Gid = (SELECT LevelOfDescriptionGid from Fund_Modified f where f.LGid = d.FundLGid)) as LevelOfDescription,
			(select top 1 Number from Fund_Modified f where f.LGid = d.FundLGid) as FundNumber,
			(select i.Number from Inventory_Modified as i where i.LGid = d.InventoryLGid) as InventoryNumber,
			(select ae.Number from ArchiveEntity_Modified as ae where ae.LGid = d.AELGid) as ArchiveEntityNumber,
			CAST(d.Title as nvarchar(256)) as Title,
			convert(varchar, d.DOCreationDate, 104) as DocCreationDate,
			(select n.Value + '', ''
				from Nomenclature n
				inner join ObjectNomenclature objn on n.Gid = objn.NomenclatureGid and objn._retired = ''3000-01-01'' and objn.DocumentGid = d.Gid
				where 
				n._retired = ''3000-01-01''
				and n.[Type] = ''Annotated''
				FOR XML path(''''), elements) as Themes,
			(select n.Value FROM Nomenclature as n where _retired = ''3000-01-01'' and Gid = d.StatusGid) as DocStatus,
			(select top(1) convert(varchar, img.CreatedOn, 104) from Image as img where d.Gid = img.DocumentGid and img._retired = ''3000-01-01'') as CreationDateDO,
			0 as RecordsCountDO,
			NULL as Duration,
			(
				select convert(varchar, max(p.ModifiedOn), 104)  
				from Document doc
				inner join Process p on p._retired = ''3000-01-01'' and p.Gid = doc.ProcessGid and p.TypeGid = 2124 and p.StepGid = 75
				where doc.LGid = d.lgid
			) as DigitalObjectRecreationDate,
			CAST(0 as bigint) as BytesDO, -- това по тяхно искане не трябва да се отчита
			case when isnull(d.DigitalObjectDeleted, 0) = 0 then ''Активен'' else ''Заличен'' end as StatusDO,
			d.DOCreationAuthor as Operator,
			NULL as CorrectionReturnDate,
			NULL as FinalCorrectionDate,
			(
				select convert(varchar, max(p.ModifiedOn), 104)  
				from Document doc
				inner join Process p on p._retired = ''3000-01-01'' and p.Gid = doc.ProcessGid and p.TypeGid = 2123 and p.StepGid = 75
				where doc.LGid = d.lgid
			) as DigitalObjectAcceptanceDate,
			(select top 1 IntNumber from Fund_Modified f where f.LGid = d.FundLGid) as FundIntNumber,
			(select i.IntNumber from Inventory_Modified as i where i.LGid = d.InventoryLGid) as InventoryIntNumber,
			(select ae.IntNumber from ArchiveEntity_Modified as ae where ae.LGid = d.AELGid) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder
		FROM Document_Modified as d
		INNER JOIN Archive a ON a.Gid = d.ArchiveGid AND a._retired = ''3000-01-01''
		--inner join Fund_Modified f on f.LGid = d.FundLGid
		--inner join Inventory_Modified i on i.LGid = d.InventoryLGid
		--inner join ArchiveEntity_Modified ae on ae.LGid = d.AELGid
		LEFT OUTER JOIN [Image] img on d.Gid = img.DocumentGid and img._retired = ''3000-01-01''
		WHERE ISNULL(d.HasDigitalObject, 0) = 1
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) '

		IF (@RegisteredFrom IS NOT NULL)
		BEGIN
			SET @remoteQuery += 'AND cast(d.DOCreationDate as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
		END

		IF(@RegisteredTo IS NOT NULL)
		BEGIN
			SET @remoteQuery +='AND cast(d.DOCreationDate as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
		END
		
		SET @remoteQuery += ' GROUP BY
			d.LGid, 
			d.ArchiveGid, 
			d.CreationDate, 
			d.Title, 
			d.StatusGid, 
			d.DigitalObjectDeleted, 
			d.DigitalObjectDeleted, 
			d.DOCreationDate, 
			d.FundLGid, 
			d.InventoryLGid, 
			d.AELGid, 
			d.Gid,
			d.StartDateDay,
			d.StartDateMonth,
			d.StartDateYear,
			d.EndDateDay,
			d.EndDateMonth,
			d.EndDateYear,
			d.TextDate,
			d.DOCreationAuthor,
			a.Name,
			a.SortOrder--,
			--f.Number,
			--i.Number,
			--ae.Number
		'
			  
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		--DECLARE @localQuery VARCHAR(MAX) = '
		--SELECT 
		--	''document'' as DocumentLink,
		--	CAST((select a.Code FROM [Archives] as a where a.Id = ArchiveId) as nvarchar(256)) as ArchiveCode,
		--	a.Name as ArchiveName,
		--	CAST(d.SystemIdentifier as nvarchar(256)) as SystemId,
		--	(select fdl.Text FROM [N].[FundDescriptionLevel] as fdl where fdl.Code = (select f.DescriptionLevelCode FROM Funds f where f.SystemIdentifier = d.FundSystemIdentifier)) as LevelOfDescription,
		--	CAST((select f.Number FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as nvarchar(256)) as FundNumber,
		--	CAST((select i.Number FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as nvarchar(256)) as InventoryNumber,
		--	CAST((select ae.Number FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as nvarchar(256)) as ArchiveEntityNumber,
		--	CAST(d.Title as nvarchar(256)) as Title,
		--	convert(varchar, d.CreatedOn, 104) as DocCreationDate,
		--	NULL as Themes,
		--	(select s.Text from N.Status as s where s.Code = d.StatusCode) as DocStatus,
		--	CAST((select top(1) convert(varchar, do.CreatedOn, 104) from DigitalObjects as do where do.DocumentSystemIdentifier = d.SystemIdentifier) as nvarchar(50)) as CreationDateDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
		--	d.DigitizedCopyCount as RecordsCountDO,
		--	CAST(d.Duration as nvarchar(256)) as Duration,
		--	NULL as DigitalObjectRecreationDate,
		--	isnull(dsi.EnrolledBytes, 0) as BytesDO,
		--	(select top(1) n.Text from N.Nomenclatures as n join DigitalObjects as do on n.Id = do.StatusCode where do.DocumentSystemIdentifier = d.SystemIdentifier and n.Deleted = 0) as StatusDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
		--	NULL as Operator,
		--	NULL as CorrectionReturnDate,
		--	NULL as FinalCorrectionDate,
		--	NULL as DigitalObjectAcceptanceDate,
		--	CAST((select f.NumberNumeric FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as nvarchar(256)) as FundIntNumber,
		--	CAST((select i.NumberNumeric FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as nvarchar(256)) as InventoryIntNumber,
		--	CAST((select ae.NumberNumeric FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as nvarchar(256)) as ArchivalEntityIntNumber,
		--	a.SortOrder as ArchiveSortOrder
		--FROM Documents as d
		--INNER JOIN Archives a ON a.Id = d.ArchiveId AND a.Deleted = 0
		--LEFT JOIN v_DocumentSizeInfo dsi ON dsi.DocumentSystemIdentifier = d.SystemIdentifier AND dsi.IsDraft = 0
		--WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
		--	  AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
		--	  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
		--	  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
		--	  AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[StartDateYear], d.[StartDateMonth], d.[StartDateDay]) as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
		--	  AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[EndDateYear], d.[EndDateMonth], d.[EndDateDay]) as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))'

		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT 
			''document'' as DocumentLink,
			CAST((select a.Code FROM [Archives] as a where a.Id = ArchiveId) as nvarchar(256)) as ArchiveCode,
			a.Name as ArchiveName,
			CAST(d.SystemIdentifier as nvarchar(256)) as SystemId,
			(select fdl.Text FROM [N].[FundDescriptionLevel] as fdl where fdl.Code = (select f.DescriptionLevelCode FROM Funds f where f.SystemIdentifier = d.FundSystemIdentifier)) as LevelOfDescription,
			CAST((select f.Number FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as nvarchar(256)) as FundNumber,
			CAST((select i.Number FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as nvarchar(256)) as InventoryNumber,
			CAST((select ae.Number FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as nvarchar(256)) as ArchiveEntityNumber,
			CAST(d.Title as nvarchar(256)) as Title,
			convert(varchar, d.CreatedOn, 104) as DocCreationDate,
			NULL as Themes,
			(select s.Text from N.Status as s where s.Code = d.StatusCode) as DocStatus,
			CAST((select top(1) convert(varchar, do.CreatedOn, 104) from DigitalObjects as do where do.DocumentSystemIdentifier = d.SystemIdentifier) as nvarchar(50)) as CreationDateDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
			d.DigitizedCopyCount as RecordsCountDO,
			CAST(d.Duration as nvarchar(256)) as Duration,
			NULL as DigitalObjectRecreationDate,
			isnull(dsi.EnrolledBytes, 0) as BytesDO,
			(select top(1) n.Text from N.Nomenclatures as n join DigitalObjects as do on n.Id = do.StatusCode where do.DocumentSystemIdentifier = d.SystemIdentifier and n.Deleted = 0) as StatusDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
			NULL as Operator,
			NULL as CorrectionReturnDate,
			NULL as FinalCorrectionDate,
			NULL as DigitalObjectAcceptanceDate,
			CAST((select f.NumberNumeric FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as nvarchar(256)) as FundIntNumber,
			CAST((select i.NumberNumeric FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as nvarchar(256)) as InventoryIntNumber,
			CAST((select ae.NumberNumeric FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as nvarchar(256)) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder
		FROM Documents as d
		INNER JOIN Archives a ON a.Id = d.ArchiveId AND a.Deleted = 0
		LEFT JOIN v_DocumentSizeInfo dsi ON dsi.DocumentSystemIdentifier = d.SystemIdentifier AND dsi.IsDraft = 0
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
			  AND exists(select 1 from DigitalObjects do where d.SystemIdentifier = do.DocumentSystemIdentifier and do.Deleted = 0 and do.IsDigitized =1)
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
			  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))) '
		

		IF (@RegisteredFrom IS NOT NULL)
		BEGIN
			SET @localQuery += 'AND cast(d.CreatedOn as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
		END

		IF(@RegisteredTo IS NOT NULL)
		BEGIN
			SET @localQuery +='AND cast(d.CreatedOn as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
		END

	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteDigitizedDocumentsTable TABLE (
				DocumentLink nvarchar(MAX) NULL,
				ArchiveCode nvarchar(256) NOT NULL,
				ArchiveName nvarchar(256) NOT NULL,
				SystemId nvarchar(256) NULL,
				LevelOfDescription nvarchar(MAX) NULL,
				FundNumber nvarchar(256) NULL,
				InventoryNumber nvarchar(256) NULL,
				ArchiveEntityNumber nvarchar(256) NULL,
				Title nvarchar(256) NULL,
				DocCreationDate nvarchar(50) NULL,
				Themes nvarchar(MAX) NULL,
				DocStatus nvarchar(MAX) NULL,
				CreationDateDO nvarchar(50) NULL,
				RecordsCountDO int NULL,
				Duration nvarchar(256) NULL,
				DigitalObjectRecreationDate nvarchar(50) NULL,
				BytesDO bigint NULL,
				StatusDO nvarchar(MAX) NULL,
				Operator nvarchar(MAX) NULL,
				CorrectionReturnDate nvarchar(50) NULL,
				FinalCorrectionDate nvarchar(50) NULL,
				DigitalObjectAcceptanceDate nvarchar(50) NULL,
				FundIntNumber INT NULL,
				InventoryIntNumber INT NULL,
				ArchivalEntityIntNumber INT NULL,
				ArchiveSortOrder int null
			);

			INSERT INTO @remoteDigitizedDocumentsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteDigitizedDocumentsTable
			UNION
			' +
			@localQuery + @sqlFinalPart;	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + @sqlFinalPart +''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery + @sqlFinalPart;
	END

	EXEC (@sql);
END
GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER PROCEDURE [dbo].[GetRegisterOfDigitalObjectsPublicReportSummary] 
	@LinkedServer nvarchar(50),
    @ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@DigitalObjectStatuses VARCHAR(MAX) = NULL,
	@ArchiveCodes nvarchar(10) = null,
	@RegisteredFrom datetime2(7) = NULL,
	@RegisteredTo datetime2(7) = null,
	@DocLGid int = null,
	@SystemIdentifier nvarchar(50) = null	
AS
BEGIN
  -- Екипът реши да се взима Duration от Document, а не от DocumentObject, където няма такава колона
	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
	DECLARE @remoteQuery VARCHAR(MAX) = 
		'SELECT
			ISNULL(COUNT(*), 0) TotalRows,
			CAST(0 AS BIGINT) as TotalBytesCount, -- по искане на клиента не се отчита
			CAST(0 AS BIGINT) as TotalDuration,
			CAST(SUM(isnull(x.ImageCount, 0)) AS BIGINT) as TotalImageCount
			--,SUM(isnull(x.DOs, 0)) as TotalDOs
			FROM
			(
				SELECT 
					SUM(isnull(img.ByteLenght, 0)) as BytesCount,
					COUNT_BIG(img.Gid) as ImageCount,
					COUNT_BIG(distinct doc.LGid) as DOs
				FROM
				    Document_Active doc -- в ИСДА ползват Document_Active за тази справка
					left outer join [Image] img on doc.Gid = img.DocumentGid and img._retired = ''3000-01-01''
				WHERE
					ISNULL(doc.HasDigitalObject, 0) = 1 '

	IF (@DocLGId IS NOT NULL)
	BEGIN
		SET @remoteQuery += 'AND doc.LGid = ' + cast(@DocLGid as nvarchar(50)) + ' '
	END
	IF (@RegisteredFrom IS NOT NULL)
	BEGIN
		SET @remoteQuery += 'AND cast(doc.DOCreationDate as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
	END

	IF(@RegisteredTo IS NOT NULL)
	BEGIN
		SET @remoteQuery +='AND cast(doc.DOCreationDate as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
	END				
	
	SET @remoteQuery += '
					AND ((''-999'' in (select element from dbo.SplitString(''' + @DigitalObjectStatuses + ''', '',''))) 
						OR ((isnull(doc.DigitalObjectDeleted, 0) = 0) and 1 in (select element from dbo.SplitString(''' + @DigitalObjectStatuses + ''', '','')))
						OR ((isnull(doc.DigitalObjectDeleted, 0) = 1) and 2 in (select element from dbo.SplitString(''' + @DigitalObjectStatuses + ''', '',''))))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=doc.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
					group by doc.LGid, doc.ArchiveGid, doc.CreationDate, doc.Title, doc.StatusGid, doc.DigitalObjectDeleted, doc.DigitalObjectDeleted, doc.DOCreationDate
				) x';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT 
				ISNULL(SUM(DOsPerDocument), 0) TotalRows,
				CAST(SUM(BytesCountPerDocument) AS BIGINT) AS TotalBytesCount,
				CAST(SUM(DurationPerDocument) AS BIGINT) AS TotalDuration,
				NULL AS TotalImageCount
				--,count(DOsPerDocument) AS TotalDOs
			from
			(
				SELECT
					COUNT(do.SystemIdentifier) AS DOsPerDocument,
					MAX(d.Bytes) AS BytesCountPerDocument,
					MAX(d.Duration) AS DurationPerDocument
				FROM DigitalObjects do
				INNER JOIN Archives a ON a.Id = do.ArchiveId AND a.Deleted = 0
				INNER JOIN Documents d ON d.SystemIdentifier = do.DocumentSystemIdentifier AND do.Deleted = 0 AND do.IsDigitized = 1
				WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
						AND (''' + COALESCE(@SystemIdentifier, 'null') + ''' = ''null'' OR CAST(do.SystemIdentifier AS nvarchar(50)) = ''' + COALESCE(@SystemIdentifier, 'null') + ''')
						--AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
						AND do.TypeCode = 1 -- master
						AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
							OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
						AND (''' + @DigitalObjectStatuses + ''' = ''-999'' 
							OR do.Deleted = 0 AND 1 IN (SELECT element FROM dbo.SplitString(''' + @DigitalObjectStatuses + ''', '',''))
							OR do.Deleted = 1 AND 2 IN (SELECT element FROM dbo.SplitString(''' + @DigitalObjectStatuses + ''', '','')))
						AND (select convert(varchar(4), Code, 104) from N.Status s where s.Code = do.StatusCode) <> ''12'' '

		IF (@RegisteredFrom IS NOT NULL)
		BEGIN
			SET @localQuery += 'AND cast(do.CreatedOn as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
		END

		IF(@RegisteredTo IS NOT NULL)
		BEGIN
			SET @localQuery +='AND cast(do.CreatedOn as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
		END

		SET @localQuery += '
				group by d.SystemIdentifier
			) x			
			';
	END

	declare @sql varchar(max);

	IF @ResultType = 1
    BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE ( 
				TotalRows int,
				TotalBytesCount bigint NULL,
				TotalDuration bigint NULL,
				TotalImageCount bigint NULL
				-- ,TotalDOs bigint NULL -- Понеже не се знае дали се иска да се покажат всички диг. обекти, дори да не са уникални или само уникалните, махам колоната
			);

			INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows, sum(u.TotalBytesCount) as TotalBytesCount, sum(u.TotalDuration) as TotalDuration, sum(u.TotalImageCount) as TotalImageCount
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteTable
					UNION
					' +
					@localQuery + ') lf) u';
    END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
	END

	IF @ResultType = 3
    BEGIN
		SET @sql = @localQuery;
	END

  exec (@sql);
END
GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE or alter PROCEDURE [dbo].[GetRegisterOfDigitalObjectsPublicReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@DigitalObjectStatuses VARCHAR(MAX) = NULL,
	@ArchiveCodes nvarchar(10) = null,
	@RegisteredFrom datetime2(7) = NULL,
	@RegisteredTo datetime2(7) = null,
	@DocLGid int = null,
	@SystemIdentifier nvarchar(50) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
	
AS
BEGIN
SET NOCOUNT ON;
	-- Екипът реши да се взима Duration от Document, а не от DocumentObject, където няма такава колона

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by ArchiveSortOrder, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchivalEntityIntNumber, ArchiveEntityNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
	DECLARE @remoteQuery VARCHAR(MAX) = 
		'SELECT
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = (SELECT LevelOfDescriptionGid from Fund_Modified f where f.LGid = doc.FundLGid)) as LevelOfDescription,
			--''http://212.122.187.196:84/Process.aspx?type=Document&agid='' + cast(doc.ArchiveGid as nvarchar(255)) + ''&flgid='' + cast(doc.FundLGid as nvarchar(255)) + ''&ilgid='' + cast(doc.InventoryLGid as nvarchar(255)) + ''&aelgid='' + cast(doc.AELGid as nvarchar(255)) + ''&dlgid=''+ cast(doc.LGid as nvarchar(255)) as DocumentLink,
			a.Name as ArchiveName,
			(select CAST(Code as nvarchar(10)) from archive where _retired = ''3000-01-01'' and Gid = doc.ArchiveGid) ArchiveCode,
			CAST(doc.LGid AS nvarchar(50)) as SystemId,
			CAST(1 AS BIT) as HasExternalSource,
			(SELECT TOP 1 Number from Fund_Modified f where f.LGid = doc.FundLGid) as FundNumber,
			(SELECT Number from Inventory_Modified i where i.LGid = doc.InventoryLGid) as InventoryNumber,
			(SELECT Number from ArchiveEntity_Modified ae where ae.LGid = doc.AELGid) as ArchiveEntityNumber,
			(
				select ln1.ListFrom + '' - '' + ln1.ListTo + ''; ''
				from  ListNumber ln1	
				where ln1._retired=''3000-01-01'' and ln1.DocumentGid = doc.Gid 
				FOR XML path(''''), elements
			) as ListNumbers,
			doc.Title as DocumentTitle,
			doc.TextDate as ChronologicalScope,
			--(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = doc.StatusGid) as DocStatus, -- отпада по искане на ДАА
			convert(varchar, doc.DOCreationDate, 104) as DigitalObjectCreationDate,
			COUNT(img.Gid) as ImageCount,
			SUM(isnull(img.ByteLenght, 0)) as BytesCount,
			null as Duration,
			--case when isnull(DigitalObjectDeleted, 0) = 0 then ''Активен'' else ''Заличен'' end as DigitalObjectStatus, -- отпада по искане на ДАА
			--(
				--select convert(varchar, max(p.ModifiedOn), 104)  
				--from Document d
				--inner join Process p on p._retired = ''3000-01-01'' and p.Gid = d.ProcessGid and p.TypeGid = 2124 and p.StepGid = 75
				--where  d.LGid = doc.lgid
			--) as ModifiedOn,  -- отпада по искане на ДАА
			(SELECT TOP 1 IntNumber from Fund_Modified f where f.LGid = doc.FundLGid) as FundIntNumber,
			(SELECT IntNumber from Inventory_Modified i where i.LGid = doc.InventoryLGid) as InventoryIntNumber,
			(SELECT IntNumber from ArchiveEntity_Modified ae where ae.LGid = doc.AELGid) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder
		FROM
			Document_Active doc -- в ИСДА ползват Document_Active за тази справка
			INNER JOIN Archive a ON a.Gid = doc.ArchiveGid AND a._retired = ''3000-01-01''
			LEFT OUTER JOIN [Image] img ON doc.Gid = img.DocumentGid AND img._retired = ''3000-01-01''
		WHERE
			ISNULL(doc.HasDigitalObject, 0) = 1 '

			IF (@DocLGId IS NOT NULL)
			BEGIN
				SET @remoteQuery += 'AND doc.LGid = ' + cast(@DocLGid as nvarchar(50)) + ' '
			END
			IF (@RegisteredFrom IS NOT NULL)
			BEGIN
				SET @remoteQuery += 'AND cast(doc.DOCreationDate as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
			END

			IF(@RegisteredTo IS NOT NULL)
			BEGIN
				SET @remoteQuery +='AND cast(doc.DOCreationDate as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
			END
			
			SET @remoteQuery += '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @DigitalObjectStatuses + ''', '',''))) 
				OR ((isnull(doc.DigitalObjectDeleted, 0) = 0) and 1 in (select element from dbo.SplitString(''' + @DigitalObjectStatuses + ''', '','')))
				OR ((isnull(doc.DigitalObjectDeleted, 0) = 1) and 2 in (select element from dbo.SplitString(''' + @DigitalObjectStatuses + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
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
		a.Name,
		a.SortOrder';
   
	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			--(SELECT Text FROM [N].[DocumentDescriptionLevel] dl where dl.Code = DescriptionLevelCode) as LevelOfDescription,
			(SELECT Text FROM [N].[FundDescriptionLevel] fdl where fdl.Code = (SELECT DescriptionLevelCode FROM Funds f where f.SystemIdentifier = do.FundSystemIdentifier)) as LevelOfDescription,
			--'''' as DocumentLink,
			a.Name as ArchiveName,
			a.Code as ArchiveCode,
			CAST(d.SystemIdentifier AS nvarchar(50)) as SystemId,
			CAST(0 AS BIT) as HasExternalSource,
			(SELECT Number FROM Funds f where f.SystemIdentifier = do.FundSystemIdentifier) as FundNumber,
			(SELECT Number FROM Inventories i where i.SystemIdentifier = do.InventorySystemIdentifier) as InventoryNumber,
			(SELECT Number FROM ArchivalEntities ae where ae.SystemIdentifier = do.ArchivalEntitySystemIdentifier) as ArchiveEntityNumber,
			(CAST(d.StartSheetNumber AS nvarchar(50)) + '' - '' + CAST(d.EndSheetNumber AS nvarchar(50))) as ListNumbers, -- различава се от ИСДА; има ли нужда от таква стойност в СЕА?
			d.Title as DocumentTitle,
			d.ApproxmateChronologicalScope as ChronologicalScope,
			-- (SELECT Text FROM [N].[Status] s where s.Code = StatusCode) as DocStatus, -- отпада по искане на ДАА
			convert(varchar, do.CreatedOn, 104) as DigitalObjectCreationDate,
			NULL as ImageCount, -- нямаме снимки при нас
			do.FileSize as BytesCount,
			d.Duration,
			-- NULL as DigitalObjectStatus, -- отпада по искане на ДАА
			-- convert(nvarchar,UpdatedOn, 104) as ModifiedOn, -- отпада по искане на ДАА
			(SELECT NumberNumeric FROM Funds f where f.SystemIdentifier = do.FundSystemIdentifier) as FundIntNumber,
			(SELECT NumberNumeric FROM Inventories i where i.SystemIdentifier = do.InventorySystemIdentifier) as InventoryIntNumber,
			(SELECT NumberNumeric FROM ArchivalEntities ae where ae.SystemIdentifier = do.ArchivalEntitySystemIdentifier) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder 
		FROM DigitalObjects do
		INNER JOIN Archives a ON a.Id = do.ArchiveId AND a.Deleted = 0
		INNER JOIN Documents d ON d.SystemIdentifier = do.DocumentSystemIdentifier AND do.Deleted = 0 AND do.IsDigitized = 1 
		INNER JOIN N.Status s ON s.Code = do.StatusCode AND s.Code <> 12
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0
				AND (''' + COALESCE(@SystemIdentifier, 'null') + ''' = ''null'' OR CAST(do.SystemIdentifier AS nvarchar(50)) = ''' + COALESCE(@SystemIdentifier, 'null') + ''')
				--AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
				AND do.TypeCode = 1 -- master
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND (''' + @DigitalObjectStatuses + ''' = ''-999'' 
					OR do.Deleted = 0 AND 1 IN (SELECT element FROM dbo.SplitString(''' + @DigitalObjectStatuses + ''', '',''))
					OR do.Deleted = 1 AND 2 IN (SELECT element FROM dbo.SplitString(''' + @DigitalObjectStatuses + ''', '',''))) '

		IF (@RegisteredFrom IS NOT NULL)
		BEGIN
			SET @localQuery += 'AND cast(do.CreatedOn as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
		END

		IF(@RegisteredTo IS NOT NULL)
		BEGIN
			SET @localQuery +='AND cast(do.CreatedOn as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
		END
	END
	--
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1
	BEGIN
		 SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				LevelOfDescription nvarchar(MAX) NULL,
				--DocumentLink nvarchar(MAX) NULL,
				ArchiveName nvarchar(256) NOT NULL,
				ArchiveCode int NOT NULL,
				SystemId nvarchar(50) NOT NULL,
				HasExternalSource BIT NOT NULL,
				FundNumber nvarchar(256) NULL,
				InventoryNumber nvarchar(256) NULL,
				ArchiveEntityNumber nvarchar(256) NULL,
				ListNumbers nvarchar(MAX) NULL,
				DocumentTitle nvarchar(MAX) NULL,
				ChronologicalScope nvarchar(256) NULL, 
				-- DocStatus nvarchar(MAX) NULL, -- отпада по искане на ДАА
				DigitalObjectCreationDate nvarchar(50) NULL,
				ImageCount bigint NULL,
				BytesCount bigint NULL,
				Duration int NULL,
				-- DigitalObjectStatus nvarchar(50) NULL, -- отпада по искане на ДАА
				-- ModifiedOn varchar(50) NULL, -- отпада по искане на ДАА
				FundIntNumber int null,
				InventoryIntNumber int null,
				ArchivalEntityIntNumber int null,
				ArchiveSortOrder int null
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteFundsTable
			UNION
			' +
			@localQuery + @sqlFinalPart;
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + @sqlFinalPart +''');';
	END

	IF @ResultType = 3
	BEGIN
    SET @sql = @localQuery + '
		order by ArchiveSortOrder, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchivalEntityIntNumber, ArchiveEntityNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';
	END

  EXEC (@sql);
END
GO


  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0702' and [Text]='Автомобилен транспорт')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(148, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0702', 'Автомобилен транспорт', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1603' and [Text]='Битово обслужване')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(182, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1603', 'Битово обслужване', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1305' and [Text]='Висше образование')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(171, 1, (select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1305', 'Висше образование', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0704' and [Text]='Воден транспорт')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(150, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0704', 'Воден транспорт', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0705' and [Text]='Въздушен транспорт')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(151, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0705', 'Въздушен транспорт', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0902' and [Text]='Външна търговия')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(157, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0902', 'Външна търговия', 0, 0, 0)
  END
  GO

  --IF EXISTS (SELECT 1 FROM N.Nomenclatures WHERE Code='0901' and [Text]='Външна търговия')
  --BEGIN
  --update N.Nomenclatures set ExternalIdentifier = 156, Code='0902' where  Code='0901' and [Text]='Външна търговия'
					
  --END
  --GO

  --IF EXISTS (SELECT 1 FROM N.Nomenclatures WHERE Code='0902' and [Text]='Външна търговия')
  --BEGIN
  --update N.Nomenclatures set ExternalIdentifier = 157  where  Code='0902' and [Text]='Външна търговия'
					
  --END
  --GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0901' and [Text]='Вътрешна търговия')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(156, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0901', 'Вътрешна търговия', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0600' and [Text]='Горско стопанство')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(146, 1, (select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0600', 'Горско стопанство', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0707' and [Text]='Градски пътнически транспорт')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(153, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0707', 'Градски пътнически транспорт', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1004' and [Text]='Други видове дейности на материалното производство')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(163, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1004', 'Други видове дейности на материалното производство', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0708' and [Text]='Други видове транспортна дейност')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(154, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0708', 'Други видове транспортна дейност', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1306' and [Text]='Други дейности в областта на образованието')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(172, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1306', 'Други дейности в областта на образованието', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1000' and [Text]='Други отрасли на материалното производство')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(2013, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1000', 'Други отрасли на материалното производство', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0318' and [Text]='Други отрасли на промишлеността')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(140, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0318', 'Други отрасли на промишлеността', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0310' and [Text]='Дърводобив и дървообработваща промишленост')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(134, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0310', 'Дърводобив и дървообработваща промишленост', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0307' and [Text]='Електротехническа и електронна промишленост')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(131, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0307', 'Електротехническа и електронна промишленост', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0701' and [Text]='Железопътен транспорт')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(147, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0701', 'Железопътен транспорт', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0502' and [Text]='Животновъдство')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(144, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0502', 'Животновъдство', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1601' and [Text]='Жилищно стопанство')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(180, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1601', 'Жилищно стопанство', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1600' and [Text]='Жилищно-комунално и битово обслужване')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(2019, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1600', 'Жилищно-комунално и битово обслужване', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1102' and [Text]='Застрахователни организации и учреждения')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(165, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1102', 'Застрахователни организации и учреждения', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1501' and [Text]='Здравеопазване')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(176, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1501', 'Здравеопазване', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1500' and [Text]='Здравеопазване, социално осигуряване, физкултура и туризъм')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(2018, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1500', 'Здравеопазване, социално осигуряване, физкултура и туризъм', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0904' and [Text]='Изкупуване на селскостопански продукти')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(159, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0904', 'Изкупуване на селскостопански продукти', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1402' and [Text]='Изкуство')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(175, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1402', 'Изкуство', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0302' and [Text]='Каменовъглена промишленост')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(126, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0302', 'Каменовъглена промишленост', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0315' and [Text]='Кожарска, кожухарска и обувна промишленост')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(137, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0315', 'Кожарска, кожухарска и обувна промишленост', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1602' and [Text]='Комунално стопанство')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(181, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1602', 'Комунално стопанство', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1401' and [Text]='Култура')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(174, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1401', 'Култура', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1400' and [Text]='Култура и изкуство')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(2017, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1400', 'Култура и изкуство', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0706' and [Text]='Магистрални тръбопроводи, газопроводи')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(152, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0706', 'Магистрални тръбопроводи, газопроводи', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0903' and [Text]='Материално-техническо снабдяване')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(158, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0903', 'Материално-техническо снабдяване', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0306' and [Text]='Машиностроителна и металообработваща промишленост')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(130, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0306', 'Машиностроителна и металообработваща промишленост', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0102' and [Text]='Местно държавно управление')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(118, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0102', 'Местно държавно управление', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1003' and [Text]='Механизирана и автоматизирана обработка на данни и информационно обслужване')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(162, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1003', 'Механизирана и автоматизирана обработка на данни и информационно обслужване', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1201' and [Text]='Научни изследвания')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(166, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1201', 'Научни изследвания', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1200' and [Text]='Научно-изследователска дейност')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(2015, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1200', 'Научно-изследователска дейност', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0303' and [Text]='Нефтодобив и газодобивна промишленост')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(127, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0303', 'Нефтодобив и газодобивна промишленост', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1300' and [Text]='Образование')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(2016, 1, (select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1300', 'Образование', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0202' and [Text]='Обществени организации')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(123, 1, (select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0202', 'Обществени организации', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0200' and [Text]='Обществено-политическа дейност')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(2007, 1, (select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0200', 'Обществено-политическа дейност', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1302' and [Text]='Общо образование')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(168, 1, (select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1302', 'Общо образование', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0105' and [Text]='Отбрана и охрана на държавната безопасност')
  BEGIN 
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(121, 1, (select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0105', 'Отбрана и охрана на държавната безопасност', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1503' and [Text]='Отдих и туризъм')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(178, 1, (select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1503', 'Отдих и туризъм', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0316' and [Text]='Полиграфическа промишленост')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(138, 1, (select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0316', 'Полиграфическа промишленост', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0201' and [Text]='Политически организации')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(122, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0201', 'Политически организации', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1304' and [Text]='Полувисше образование')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(170, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1304', 'Полувисше образование', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1301' and [Text]='Предучилищно образование')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(167, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1301', 'Предучилищно образование', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1307' and [Text]='Преквалификация и повишаване квалификацията на кадрите')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(173, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1307', 'Преквалификация и повишаване квалификацията на кадрите', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1002' and [Text]='Програмна индустрия')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(161, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1002', 'Програмна индустрия', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0402' and [Text]='Проектантска дейност за обслужване на строителството')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(142, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0402', 'Проектантска дейност за обслужване на строителството', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1001' and [Text]='Проектантски работи')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(160, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1001', 'Проектантски работи', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0301' and [Text]='Производство на електроенергия, топлоенергия, енергоснабдяване')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(125, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0301', 'Производство на електроенергия, топлоенергия, енергоснабдяване', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0300' and [Text]='Промишленост')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(2008, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0300', 'Промишленост', 0, 0, 0)
  END
  GO
  
 IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0309' and [Text]='Промишленост за строителни материали')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(133, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0309', 'Промишленост за строителни материали', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0703' and [Text]='Пътно стопанство')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(149, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0703', 'Пътно стопанство', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0501' and [Text]='Растениевъдство')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(143, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0501', 'Растениевъдство', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0203' and [Text]='Религиозни организации')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(124, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0203', 'Религиозни организации', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0500' and [Text]='Селско стопанство')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(2010, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0500', 'Селско стопанство', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0503' and [Text]='Селскостопански производствени услуги')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(145, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0503', 'Селскостопански производствени услуги', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1502' and [Text]='Социално осигуряване')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(177, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1502', 'Социално осигуряване', 0, 0, 0)
  END
  GO

 IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1303' and [Text]='Средно професионално-техническо и средно специално образование')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(169, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1303', 'Средно професионално-техническо и средно специално образование', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0401' and [Text]='Строително-монтажни работи')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(141, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0401', 'Строително-монтажни работи', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0400' and [Text]='Строителство')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(2009, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0400', 'Строителство', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0312' and [Text]='Стъкларска и порцелано-фаянсова промишленост')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(2329, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0312', 'Стъкларска и порцелано-фаянсова промишленост', 0, 0, 0)
  END
  GO

 IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0104' and [Text]='Съдебни и юридически учреждения')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(120, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0104', 'Съдебни и юридически учреждения', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0800' and [Text]='Съобщения')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(155, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0800', 'Съобщения', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0313' and [Text]='Текстилна и трикотажна промишленост')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(2327, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0313', 'Текстилна и трикотажна промишленост', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0700' and [Text]='Транспорт')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(2011, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0700', 'Транспорт', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0900' and [Text]='Търговия, материално-техническо снабдяване и изкупуване')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(2012, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0900', 'Търговия, материално-техническо снабдяване и изкупуване', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0100' and [Text]='Управление')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(2006, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0100', 'Управление', 0, 0, 0)
  END
  GO
  
 IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0103' and [Text]='Управление на кооперативни организации')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(119, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0103', 'Управление на кооперативни организации', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1504' and [Text]='Физкултура и спорт')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(179, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1504', 'Физкултура и спорт', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1100' and [Text]='Финанси, кредит и застраховка')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(2014, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1100', 'Финанси, кредит и застраховка', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1101' and [Text]='Финансово-кредитни организации и учреждения')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(164, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1101', 'Финансово-кредитни организации и учреждения', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0308' and [Text]='Химическа, нефтопреработваща, каучукова, фармацевтична, парфюмерийна промишленост')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(132, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0308', 'Химическа, нефтопреработваща, каучукова, фармацевтична, парфюмерийна промишленост', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='1604' and [Text]=	'Хотелиерско стопанство')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(183, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '1604', 'Хотелиерско стопанство', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0317' and [Text]='Хранително-вкусова промишленост')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(139, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0317', 'Хранително-вкусова промишленост', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0305' and [Text]='Цветна металургия (вкл.добив на руди)')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(129, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0305', 'Цветна металургия (вкл.добив на руди)', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0311' and [Text]='Целулозно-хартиена промишленост')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(135, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0311', 'Целулозно-хартиена промишленост', 0, 0, 0)
  END
  GO


 IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0304' and [Text]='Черна металургия (вкл.добив на руди)')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(128, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0304', 'Черна металургия (вкл.добив на руди)', 0, 0, 0)
  END
  GO

  IF NOT EXISTS (SELECT 1 FROM N.Nomenclatures WHERE ExternalIdentifier is not null and HasExternalSource=1 and Code='0314' and [Text]='Шивашка промишленост')
  BEGIN
  INSERT INTO N.Nomenclatures (ExternalIdentifier, HasExternalSource,ParentId, Code,[Text], Deleted, Inactive, Locked)
						VALUES(136, 1,(select Id from N.Nomenclatures where [Text]='Индекс на отраслова схема'), '0314','Шивашка промишленост', 0, 0, 0)
  END
  GO


-- REDIRECT RAW PACKAGES APPLICATION

if not exists (select null from N.ProcessSteps where Id = 1021)
begin 
	insert into N.ProcessSteps(Id, Code, Text, AllowTaskTemplate)
	values(1021, 'SendForRedirect', N'За пренасочване към друг архив', 1)
end
go

if not exists (select null from N.ProcessSteps where Id = 1022)
begin 
	insert into N.ProcessSteps(Id, Code, Text, AllowTaskTemplate)
	values(1022, 'Redirected', N'Пренасочен към друг архив', 1)
end
go


if not exists (select null from TaskTemplates T join TaskTemplatesSteps S on S.TaskTemplate_Id = T.Id where S.ProcessStep_Id = 1021)
begin 
	declare @templateId int

	insert into TaskTemplates(Title, Description, RelatedContentUrl)
	values(N'Пренасочване към друг архив', N'<p>Възложена Ви е задача за пренасочване към друг архив на разглеждането на пакети. </p>', '#displayUrl#')
	
	set @templateId = SCOPE_IDENTITY()

	insert into TaskTemplatesSteps(TaskTemplate_Id, ProcessStep_Id)
	values(@templateId, 1021)
end
go


if not exists (select null from TaskTemplates T join TaskTemplatesSteps S on S.TaskTemplate_Id = T.Id where S.ProcessStep_Id = 1022)
begin 
	declare @templateId int

	insert into TaskTemplates(Title, Description, RelatedContentUrl)
	values(N'Пренасочени пакети', N'<p>Възложена Ви е задача за разглеждане на пакети, пренасочени от архив #redirectArchiveName#. </p>', '#displayUrl#')
	
	set @templateId = SCOPE_IDENTITY()

	insert into TaskTemplatesSteps(TaskTemplate_Id, ProcessStep_Id)
	values(@templateId, 1022)
end
go


if not exists (select null from N.EDocsCollectingApplicationStatuses where Text = N'Пренасочено към друг архив')
begin 
	insert into N.EDocsCollectingApplicationStatuses(Text, TextEn)
	values(N'Пренасочено към друг архив', 'Redirected to another archive')
end 
go


if not exists (select null from sys.columns where Name = N'IsFromRedirect' and Object_ID = Object_ID(N'dbo.EDocsCollectingApplication'))
begin
	alter table dbo.EDocsCollectingApplication add IsFromRedirect bit constraint DF_EDocsCollectingApplication_IsFromRedirect default 0
end 
go

if not exists (select null from sys.columns where Name = N'RedirectApplicationId' and Object_ID = Object_ID(N'dbo.EDocsCollectingApplication'))
begin
	alter table dbo.EDocsCollectingApplication add RedirectApplicationId int constraint FK_EDocsCollectingApplication_RedirectApplication foreign key references dbo.EDocsCollectingApplication (Id)
end 
go


if not exists (select null from N.NotificationType where Code = 'RedirectedApplication')
begin 
	insert into N.NotificationType(Code, Text)
	values('RedirectedApplication', N'Пренасочено заявление')
end 
go

if not exists (select null from Notification.NotificationTemplate where NotificationTypeCode = 'RedirectedApplication')
begin 
	insert into Notification.NotificationTemplate(NotificationTypeCode, Subject, Body)
	values('RedirectedApplication', N'Пренасочено заявление', N'<p>Вашето #applicationType# с номер #applicationNumber# от #applicationDate# беше пренасочено за разглеждане към архив #redirectArchiveName#</p>')
end 
go


if not exists (select null from sys.columns where Name = N'IsSystem' and Object_ID = Object_ID(N'dbo.EDocsCollectingApplication'))
begin
	alter table dbo.EDocsCollectingApplication add IsSystem bit constraint DF_EDocsCollectingApplication_IsSystem default 0
end 
go


-- END REDIRECT





--Digital Objects
ALTER TABLE DigitalObjectDrafts
ALTER COLUMN Name nvarchar(255)
GO

ALTER TABLE DigitalObjects
ALTER COLUMN Name nvarchar(255)
GO
--END Digital Objects

--SEARCH
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[MainSearchComponent]
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
	@DocumentDescriptionLevelCodesInternal nvarchar(256) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на ArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@KMFNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@EntityType nvarchar(250) = null,
	@ExtendedSearch bit = 0,
	@SearchFileContent bit null = 0,
	@FileDbName nvarchar(50) = null,
	@FileBufferDbName nvarchar(50) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	declare @offset int = (@Page - 1) * @RowsOfPage;

	DECLARE @resultColumnsDeclaration VARCHAR(MAX) = '
		EntityType nvarchar(50) NULL,
		SystemIdentifier uniqueidentifier NULL,
		ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи на фондове го чупят в такъв случай
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
		[Rank] INT NULL,
		EntityTypeOrder INT
	';

	DECLARE @resultColumns VARCHAR(MAX) = '
		EntityType, 
		SystemIdentifier,
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
		FilmSystemIdentifier,
		FundGid,
		FundIntNumber,
		InventoryIntNumber,
		ArchivalEntityIntNumber,
		KMFIntNumber,
		FilmCardIntNumber,
		[Rank],
		EntityTypeOrder
	';

	DECLARE @keyWordsColumn VARCHAR(MAX) = '';
	IF @KeyWords IS NULL SET @keyWordsColumn = 'NULL' 
	ELSE SET @keyWordsColumn = '''' + @KeyWords + '''';

	DECLARE @toDateColumn VARCHAR(MAX) = '';
	IF @ToDate IS NULL SET @toDateColumn = 'NULL' 
	ELSE SET @toDateColumn = '''' + @ToDate + '''';

	DECLARE @fromDateColumn VARCHAR(MAX) = '';
	IF @FromDate IS NULL SET @fromDateColumn = 'NULL' 
	ELSE SET @fromDateColumn = '''' + @FromDate + '''';

	DECLARE @titleColumn VARCHAR(MAX) = '';
	IF @Title IS NULL SET @titleColumn = 'NULL' 
	ELSE SET @titleColumn = '''' + @Title + '''';

	DECLARE @fundNumberColumn VARCHAR(MAX) = '';
	IF @FundNumber IS NULL SET @fundNumberColumn = 'NULL' 
	ELSE SET @fundNumberColumn = '''' + @FundNumber + '''';

	DECLARE @inventoryNumberColumn VARCHAR(MAX) = '';
	IF @InventoryNumber IS NULL SET @inventoryNumberColumn = 'NULL' 
	ELSE SET @inventoryNumberColumn = '''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberColumn VARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NULL SET @archivalEntityNumberColumn = 'NULL' 
	ELSE SET @archivalEntityNumberColumn = '''' + @ArchivalEntityNumber + '''';

	DECLARE @kmfNumberColumn VARCHAR(MAX) = '';
	IF @KMFNumber IS NULL SET @kmfNumberColumn = 'NULL' 
	ELSE SET @kmfNumberColumn = '''' + @KMFNumber + '''';

	DECLARE @searchDigitalObjectColumn VARCHAR(MAX) = '';
	IF @SearchDigitalObject IS NULL SET @searchDigitalObjectColumn = 'NULL' 
	ELSE SET @searchDigitalObjectColumn = convert(varchar(1), @searchDigitalObject, 104);

	DECLARE @searchDraftsColumn VARCHAR(MAX) = '';
	IF @SearchDrafts IS NULL SET @searchDraftsColumn = 'NULL' 
	ELSE SET @searchDraftsColumn = convert(varchar(1), @SearchDrafts, 104);

	DECLARE @extendedSearchColumn VARCHAR(MAX) = '';
	IF @ExtendedSearch IS NULL SET @extendedSearchColumn = 'NULL' 
	ELSE SET @extendedSearchColumn = convert(varchar(1), @ExtendedSearch, 104);

	DECLARE @entityTypesArr TABLE (element VARCHAR(50) NULL); 
	INSERT INTO @entityTypesArr SELECT element from dbo.SplitString(@EntityType, ',');

	DECLARE @fundsInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalFunds BIT = 0;
	IF 'fund' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFunds = 1;
	IF  @InventoryNumber IS NULL 
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL 
		AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999' OR @InventoryDescriptionLevelCodesInternal='-111')
		AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999' OR @ArchivalEntityDescriptionLevelCodesInternal='-111')
		AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999'  OR @DocumentDescriptionLevelCodesInternal='-111')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') SET @fundsInsert = '
			INSERT INTO @funds EXEC [dbo].[SearchFundsForMainSearchComponent] 
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@FundNumber = ' + @fundNumberColumn + ',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@DescriptionLevelCodesInternal  = ''' + @FundDescriptionLevelCodesInternal + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@FundArraysInternal = ''' + @FundArraysInternal + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFunds) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
		';

	DECLARE @inventoriesInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalIventories BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfInventory TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfInventory (Gid) VALUES (2171),(2172),(2369); -- нива на описание за опис от ИСДА

	IF 'inventory' IN (SELECT element FROM @entityTypesArr) SET @includeLocalIventories = 1;
	IF (@FundNumber IS NOT NULL
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL
		AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
		AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999')
		AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfInventory INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) 
		OR @InventoryNumber IS NOT NULL
		OR EXISTS(SELECT Code FROM N.InventoryDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@InventoryDescriptionLevelCodesInternal, ',')))
		
		SET @inventoriesInsert = '
			INSERT INTO @inventories EXEC [dbo].[SearchInventoriesForMainSearchComponent] 
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@FundNumber = ' + @fundNumberColumn + ',
				@InventoryNumber = ' + @inventoryNumberColumn + ',
				@KMFCountriesOfOriginCodes  = ''' + @KMFCountriesOfOriginCodes + ''',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@FundDescriptionLevelCodesInternal = ''' + @FundDescriptionLevelCodesInternal + ''',
				@InventoryDescriptionLevelCodesInternal = ''' + @InventoryDescriptionLevelCodesInternal + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@FundArraysInternal = ''' + @FundArraysInternal + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalIventories) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
		';

	DECLARE @archivalEntitiesInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalArchivalEntities BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfArchivalEntities TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfArchivalEntities (Gid) VALUES (2174),(2373); -- нива на описание за АЕ от ИСДА
	IF 'archival_entity' IN (SELECT element FROM @entityTypesArr) SET @includeLocalArchivalEntities = 1;
	IF (@FundNumber IS NOT NULL --AND @ArchivalEntityNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL)
		AND @KMFNumber IS NULL
		AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
		AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999')
		AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')) 
		OR @ArchivalEntityNumber IS NOT NULL
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfArchivalEntities INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) -- 3493 от DevOps
		OR EXISTS(SELECT Code FROM N.ArchivalEntityDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@ArchivalEntityDescriptionLevelCodesInternal, ',')))
	SET @archivalEntitiesInsert = '
		INSERT INTO @archivalEntities EXEC [dbo].[SearchArchivalEntitiesForMainSearchComponent] 
			@LinkedServer = ''' + @LinkedServer + ''',
			@SearchDrafts = ' + @searchDraftsColumn + ',
			@ArchiveGids = ''' + @ArchiveGids + ''',
			@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
			@FundNumber = ' + @fundNumberColumn + ',
			@InventoryNumber = ' + @inventoryNumberColumn + ',
			@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
			@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
			@FundDescriptionLevelCodesInternal = ''' + @FundDescriptionLevelCodesInternal + ''',
			@InventoryDescriptionLevelCodesInternal = ''' + @InventoryDescriptionLevelCodesInternal + ''',
			@ArchivalEntityDescriptionLevelCodesInternal = ''' + @ArchivalEntityDescriptionLevelCodesInternal + ''',
			@ToDate = ' + @toDateColumn + ',
			@FromDate = ' + @fromDateColumn + ',
			@FundArrayGids = ''' + @FundArrayGids + ''',
			@FundArraysInternal = ''' + @FundArraysInternal + ''',
			@Title = ' + @titleColumn + ',
			@KeyWords = ' + @keyWordsColumn + ',		
			@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
			@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalArchivalEntities) + ',
			@ExtendedSearch = ' + @extendedSearchColumn + ',
			@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
			@FileDbName = ''' + @FileDbName + ''',
			@FileBufferDbName = ''' + @FileBufferDbName + ''';
	';

	DECLARE @documentsInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalDocuments BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfDocuments TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfDocuments (Gid) VALUES (2173); -- ниво на описание за документ от ИСДА
	IF 'document' IN (SELECT element FROM @entityTypesArr) SET @includeLocalDocuments = 1;
	IF 
		-- това условие е било сложено нарочно, но искат да отпадне 
		--@FundNumber IS NULL AND @InventoryNumber IS NULL AND @ArchivalEntityNumber IS NULL
		--AND 
		(@KMFNumber IS NULL
		AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
		AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999')
		AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfDocuments INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) -- 3493 от DevOps
		OR EXISTS(SELECT Code FROM N.DocumentDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@DocumentDescriptionLevelCodesInternal, ',')))
	SET @documentsInsert = '
		INSERT INTO @documents EXEC [dbo].[SearchDocumentsForMainSearchComponent] 
			@LinkedServer = ''' + @LinkedServer + ''',
			@SearchDrafts = ' + @searchDraftsColumn + ',
			@ArchiveGids = ''' + @ArchiveGids + ''',
			@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
			@FundNumber = ' + @fundNumberColumn + ',
			@InventoryNumber = ' + @inventoryNumberColumn + ',
			@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
			@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
			@FundDescriptionLevelCodesInternal = ''' + @FundDescriptionLevelCodesInternal + ''',
			@InventoryDescriptionLevelCodesInternal = ''' + @InventoryDescriptionLevelCodesInternal + ''',
			@ArchivalEntityDescriptionLevelCodesInternal = ''' + @ArchivalEntityDescriptionLevelCodesInternal + ''',
			@DocumentDescriptionLevelCodesInternal = ''' + @DocumentDescriptionLevelCodesInternal + ''',
			@ToDate = ' + @toDateColumn + ',
			@FromDate = ' + @fromDateColumn + ',
			@FundArrayGids = ''' + @FundArrayGids + ''',
			@FundArraysInternal = ''' + @FundArraysInternal + ''',
			@Title = ' + @titleColumn + ',
			@KeyWords = ' + @keyWordsColumn + ',		
			@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
			@IncludeLocalRecords = ' + convert(nvarchar(1), @includeLocalDocuments) + ',
			@ExtendedSearch = ' + @extendedSearchColumn + ',
			@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
			@FileDbName = ''' + @FileDbName + ''',
			@FileBufferDbName = ''' + @FileBufferDbName + ''';
		';

	DECLARE @filmsInsert VARCHAR(MAX) = ''; 
	DECLARE @includeLocalFilms BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfFilms TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfFilms (Gid) VALUES (2185); -- ниво на описание КМФ
	IF 'film' IN (SELECT element FROM @entityTypesArr) 
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilms INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) 
		SET @includeLocalFilms = 1;
	IF @FundNumber IS NULL 
		AND @InventoryNumber IS NULL
		AND @ArchivalEntityNumber IS NULL 
		AND @Title IS NULL SET @filmsInsert = '
			INSERT INTO @films EXEC [dbo].[SearchKMFForMainSearchComponent]
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@KMFNumber = ' + @kmfNumberColumn + ',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@KMFCountriesOfOriginCodes = ''' + @KMFCountriesOfOriginCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@KeyWords = ' + @keyWordsColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFilms, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @filmCardsInsert VARCHAR(MAX) = ''; 	
	DECLARE @includeLocalFilmCards BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfFilmCards TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfFilmCards (Gid) VALUES (2371); -- ниво на описание Архивна единица (КМФ)
	IF 'film_card' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFilmCards = 1;
	IF (NOT ((@FundNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL AND @KMFNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL AND @KMFNumber IS NULL)))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilmCards INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ',')))
		--OR NOT ((@FundNumber IS NOT NULL AND @KMFNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @KMFNumber IS NULL)) 
		SET @filmCardsInsert = '
			INSERT INTO @filmCards EXEC [dbo].[SearchFilmCardsForMainSearchComponent]
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@FundNumber  = ' + @fundNumberColumn + ',
				@InventoryNumber = ' + @inventoryNumberColumn + ',
				@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
				@KMFNumber = ' + @kmfNumberColumn + ',
				@KMFCountriesOfOriginCodes = ''' + @KMFCountriesOfOriginCodes + ''',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFilmCards, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
		';

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @funds TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @inventories TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @archivalEntities TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @documents TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @films TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @filmCards TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @result TABLE ('
			+ @resultColumnsDeclaration +
		');'

		+ @fundsInsert + 
		+ @inventoriesInsert + 
		+ @archivalEntitiesInsert + 	
		+ @documentsInsert + 
		+ @filmsInsert +
		+ @filmCardsInsert + '

		INSERT INTO @result SELECT * FROM
			(
				SELECT ' + @resultColumns + ' FROM @funds

				UNION
		
				SELECT ' + @resultColumns + ' FROM @inventories

				UNION

				SELECT ' + @resultColumns + ' FROM @archivalEntities

				UNION

				SELECT ' + @resultColumns + ' FROM @documents

				UNION

				SELECT ' + @resultColumns + ' FROM @films	

				UNION

				SELECT ' + @resultColumns + ' FROM @filmCards
			) x

		
		SELECT
			EntityType, 
			SystemIdentifier,
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
			FilmSystemIdentifier,
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			(SELECT COUNT(0) FROM @result) TotalRows,
			[Rank],
			EntityTypeOrder
		FROM @result
		ORDER BY 
			EntityTypeOrder,
			[Rank] DESC,                                                                                                                               
			ArchiveName ASC,  -- колоните с ...Int... представляват числото от номера
            FundIntNumber ASC,
			KMFIntNumber ASC,
            FundNumber ASC,
            InventoryIntNumber ASC,
            InventoryNumber ASC,
            ArchivalEntityIntNumber ASC,
            ArchivalEntityNumber ASC,
			FilmCardIntNumber ASC
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY
		';

	EXEC (@sql);
END
GO



CREATE OR ALTER PROCEDURE [dbo].[MainSearchComponentInternal]
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@FundDescriptionLevelCodes nvarchar(256) = null,
	@InventoryDescriptionLevelCodes nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodes nvarchar(256) = null,
	@DocumentDescriptionLevelCodes nvarchar(256) = null,
	@FundArrays nvarchar(max) = null,
	@KMFNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@EntityType nvarchar(250) = null,
	@ExtendedSearch bit = 0,
	@SearchFileContent bit null = 0,
	@FileDbName nvarchar(50) = null,
	@FileBufferDbName nvarchar(50) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	declare @offset int = (@Page - 1) * @RowsOfPage;

	DECLARE @resultColumnsDeclaration VARCHAR(MAX) = '
		EntityType nvarchar(50) NULL,
		SystemIdentifier uniqueidentifier NULL,
		ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи на фондове го чупят в такъв случай
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
		[Rank] INT NULL,
		EntityTypeOrder INT
	';

	DECLARE @resultColumns VARCHAR(MAX) = '
		EntityType, 
		SystemIdentifier,
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
		FilmSystemIdentifier,
		FundGid,
		FundIntNumber,
		InventoryIntNumber,
		ArchivalEntityIntNumber,
		KMFIntNumber,
		FilmCardIntNumber,
		[Rank],
		EntityTypeOrder
	';

	DECLARE @keyWordsColumn VARCHAR(MAX) = '';
	IF @KeyWords IS NULL SET @keyWordsColumn = 'NULL' 
	ELSE SET @keyWordsColumn = '''' + @KeyWords + '''';

	DECLARE @toDateColumn VARCHAR(MAX) = '';
	IF @ToDate IS NULL SET @toDateColumn = 'NULL' 
	ELSE SET @toDateColumn = '''' + @ToDate + '''';

	DECLARE @fromDateColumn VARCHAR(MAX) = '';
	IF @FromDate IS NULL SET @fromDateColumn = 'NULL' 
	ELSE SET @fromDateColumn = '''' + @FromDate + '''';

	DECLARE @titleColumn VARCHAR(MAX) = '';
	IF @Title IS NULL SET @titleColumn = 'NULL' 
	ELSE SET @titleColumn = '''' + @Title + '''';

	DECLARE @fundNumberColumn VARCHAR(MAX) = '';
	IF @FundNumber IS NULL SET @fundNumberColumn = 'NULL' 
	ELSE SET @fundNumberColumn = '''' + @FundNumber + '''';

	DECLARE @inventoryNumberColumn VARCHAR(MAX) = '';
	IF @InventoryNumber IS NULL SET @inventoryNumberColumn = 'NULL' 
	ELSE SET @inventoryNumberColumn = '''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberColumn VARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NULL SET @archivalEntityNumberColumn = 'NULL' 
	ELSE SET @archivalEntityNumberColumn = '''' + @ArchivalEntityNumber + '''';

	DECLARE @kmfNumberColumn VARCHAR(MAX) = '';
	IF @KMFNumber IS NULL SET @kmfNumberColumn = 'NULL' 
	ELSE SET @kmfNumberColumn = '''' + @KMFNumber + '''';

	DECLARE @searchDigitalObjectColumn VARCHAR(MAX) = '';
	IF @SearchDigitalObject IS NULL SET @searchDigitalObjectColumn = 'NULL' 
	ELSE SET @searchDigitalObjectColumn = convert(varchar(1), @searchDigitalObject, 104);

	DECLARE @searchDraftsColumn VARCHAR(MAX) = '';
	IF @SearchDrafts IS NULL SET @searchDraftsColumn = 'NULL' 
	ELSE SET @searchDraftsColumn = convert(varchar(1), @SearchDrafts, 104);

	DECLARE @extendedSearchColumn VARCHAR(MAX) = '';
	IF @ExtendedSearch IS NULL SET @extendedSearchColumn = 'NULL' 
	ELSE SET @extendedSearchColumn = convert(varchar(1), @ExtendedSearch, 104);

	--DECLARE @keywordsUIAnnotatedColumn VARCHAR(MAX) = '';
	--IF @KeywordsUIAnnotated IS NULL SET @keywordsUIAnnotatedColumn = 'NULL' 
	--ELSE SET @keywordsUIAnnotatedColumn = convert(varchar(1), @KeywordsUIAnnotated, 104);

	DECLARE @entityTypesArr TABLE (element VARCHAR(50) NULL); 
	INSERT INTO @entityTypesArr SELECT element from dbo.SplitString(@EntityType, ',');

	DECLARE @fundsInsert VARCHAR(MAX) = '';
	IF (@InventoryNumber IS NULL 
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL
		AND(@InventoryDescriptionLevelCodes IS NULL OR @InventoryDescriptionLevelCodes='-999')
		AND(@ArchivalEntityDescriptionLevelCodes IS NULL OR @ArchivalEntityDescriptionLevelCodes='-999')
		AND(@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999')
		AND(@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		OR (EXISTS(SELECT Code FROM N.FundDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@FundDescriptionLevelCodes, ',')))
		AND @InventoryNumber IS NULL 
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL
		AND(@InventoryDescriptionLevelCodes IS NULL OR @InventoryDescriptionLevelCodes='-999' OR @InventoryDescriptionLevelCodes='-111')
		AND(@ArchivalEntityDescriptionLevelCodes IS NULL OR @ArchivalEntityDescriptionLevelCodes='-999' OR @ArchivalEntityDescriptionLevelCodes='-111')
		AND(@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999' OR @DocumentDescriptionLevelCodes='-111')
		AND(@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		--OR (EXISTS(SELECT Code FROM N.FundDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@FundDescriptionLevelCodes, ','))) AND @FundNumber IS NOT NULL)
		AND 'fund' IN (SELECT element FROM @entityTypesArr) SET @fundsInsert = '
			INSERT INTO @funds EXEC [dbo].[SearchFundsForMainSearchComponentInternal] 
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveCodes = ''' + @ArchiveCodes + ''',
				@FundNumber = ' + @fundNumberColumn + ',
				@DescriptionLevelCodes  = ''' + @FundDescriptionLevelCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FundArrays = ''' + @FundArrays + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
	';

	DECLARE @inventoriesInsert VARCHAR(MAX) = ''; --NULL AND @InventoryNumber IS NULL)  
	IF (@FundNumber IS NOT NULL
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL
		AND(@FundDescriptionLevelCodes IS NULL OR @FundDescriptionLevelCodes='-999')
		AND(@ArchivalEntityDescriptionLevelCodes IS NULL OR @ArchivalEntityDescriptionLevelCodes='-999')
		AND(@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') 
		AND 'inventory' IN (SELECT element FROM @entityTypesArr))
		OR (@InventoryNumber IS NOT NULL
		AND @ArchivalEntityNumber IS NULL 
		AND(@FundDescriptionLevelCodes IS NULL OR @FundDescriptionLevelCodes='-999' OR @FundDescriptionLevelCodes='-111')
		AND(@ArchivalEntityDescriptionLevelCodes IS NULL OR @ArchivalEntityDescriptionLevelCodes='-999' OR @ArchivalEntityDescriptionLevelCodes='-111')
		AND(@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999' OR @DocumentDescriptionLevelCodes='-111')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999' OR @KMFCountriesOfOriginCodes='-111'))
		OR EXISTS(SELECT Code FROM N.InventoryDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@InventoryDescriptionLevelCodes, ',')))
		SET @inventoriesInsert = '
			INSERT INTO @inventories EXEC [dbo].[SearchInventoriesForMainSearchComponentInternal] 
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveCodes = ''' + @ArchiveCodes + ''',
				@FundNumber = ' + @fundNumberColumn + ',
				@InventoryNumber = ' + @inventoryNumberColumn + ',
				@KMFCountriesOfOriginCodes  = ''' + @KMFCountriesOfOriginCodes + ''',
				@FundDescriptionLevelCodes = ''' + @FundDescriptionLevelCodes + ''',
				@InventoryDescriptionLevelCodes = ''' + @InventoryDescriptionLevelCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrays = ''' + @FundArrays + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@ExtendedSearch = ' + @extendedSearchColumn  + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
		';

	DECLARE @archivalEntitiesInsert VARCHAR(MAX) = '';
	IF ((@FundNumber IS NOT NULL OR @InventoryNumber IS NOT NULL)
		AND @KMFNumber IS NULL
		AND (@FundDescriptionLevelCodes IS NULL OR @FundDescriptionLevelCodes='-999')
		AND (@InventoryDescriptionLevelCodes IS NULL OR @InventoryDescriptionLevelCodes='-999')
		AND (@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
		AND 'archival_entity' IN (SELECT element FROM @entityTypesArr))
		OR (@ArchivalEntityNumber IS NOT NULL
		AND @KMFNumber IS NULL
		AND (@FundDescriptionLevelCodes IS NULL OR @FundDescriptionLevelCodes='-999')
		AND (@InventoryDescriptionLevelCodes IS NULL OR @InventoryDescriptionLevelCodes='-999')
		AND (@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		OR EXISTS(SELECT Code FROM N.ArchivalEntityDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@ArchivalEntityDescriptionLevelCodes, ',')))
	SET @archivalEntitiesInsert = '
		INSERT INTO @archivalEntities EXEC [dbo].[SearchArchivalEntitiesForMainSearchComponentInternal] 
			@LinkedServer = ''' + @LinkedServer + ''',
			@SearchDrafts = ' + @searchDraftsColumn + ',
			@ArchiveCodes = ''' + @ArchiveCodes + ''',
			@FundNumber = ' + @fundNumberColumn + ',
			@InventoryNumber = ' + @inventoryNumberColumn + ',
			@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
			@FundDescriptionLevelCodes = ''' + @FundDescriptionLevelCodes + ''',
			@InventoryDescriptionLevelCodes = ''' + @InventoryDescriptionLevelCodes + ''',
			@ArchivalEntityDescriptionLevelCodes = ''' + @ArchivalEntityDescriptionLevelCodes + ''',
			@ToDate = ' + @toDateColumn + ',
			@FromDate = ' + @fromDateColumn + ',
			@FundArrays = ''' + @FundArrays + ''',
			@Title = ' + @titleColumn + ',
			@KeyWords = ' + @keyWordsColumn + ',		
			@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
			@ExtendedSearch = ' + @extendedSearchColumn + ',
			@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
			@FileDbName = ''' + @FileDbName + ''',
			@FileBufferDbName = ''' + @FileBufferDbName + ''';
	';

	DECLARE @documentsInsert VARCHAR(MAX) = '';
	IF 
		-- това условие е било сложено нарочно, но искат да отпадне 
		--@FundNumber IS NULL AND @InventoryNumber IS NULL AND @ArchivalEntityNumber IS NULL
		--AND 
		(@KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		OR EXISTS(SELECT Code FROM N.DocumentDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@DocumentDescriptionLevelCodes, ',')))
	SET @documentsInsert = '
		INSERT INTO @documents EXEC [dbo].[SearchDocumentsForMainSearchComponentInternal] 
			@LinkedServer = ''' + @LinkedServer + ''',
			@SearchDrafts = ' + @searchDraftsColumn + ',
			@ArchiveCodes = ''' + @ArchiveCodes + ''',
			@FundNumber = ' + @fundNumberColumn + ',
			@InventoryNumber = ' + @inventoryNumberColumn + ',
			@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
			@FundDescriptionLevelCodes = ''' + @FundDescriptionLevelCodes + ''',
			@InventoryDescriptionLevelCodes = ''' + @InventoryDescriptionLevelCodes + ''',
			@ArchivalEntityDescriptionLevelCodes = ''' + @ArchivalEntityDescriptionLevelCodes + ''',
			@DocumentDescriptionLevelCodes = ''' + @DocumentDescriptionLevelCodes + ''',
			@ToDate = ' + @toDateColumn + ',
			@FromDate = ' + @fromDateColumn + ',
			@FundArrays = ''' + @FundArrays + ''',
			@Title = ' + @titleColumn + ',
			@KeyWords = ' + @keyWordsColumn + ',		
			@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
			@ExtendedSearch = ' + @extendedSearchColumn + ',
			@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
			@FileDbName = ''' + @FileDbName + ''',
			@FileBufferDbName = ''' + @FileBufferDbName + ''';
	';

	DECLARE @filmsInsert VARCHAR(MAX) = ''; 
	IF @FundNumber IS NULL 
		AND @InventoryNumber IS NULL
		AND @ArchivalEntityNumber IS NULL 
		AND 'film' IN (SELECT element FROM @entityTypesArr) SET @filmsInsert = '
			INSERT INTO @films EXEC [dbo].[SearchKMFForMainSearchComponentInternal]
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveCodes = ''' + @ArchiveCodes + ''',
				@KMFNumber = ' + @kmfNumberColumn + ',
				@KMFCountriesOfOriginCodes = ''' + @KMFCountriesOfOriginCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @filmCardsInsert VARCHAR(MAX) = ''; 	
	IF @FundNumber IS NULL 
		AND @InventoryNumber IS NULL 
		AND 'film_card' IN (SELECT element FROM @entityTypesArr) SET @filmCardsInsert = '
			INSERT INTO @filmCards EXEC [dbo].[SearchFilmCardsForMainSearchComponentInternal]
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveCodes = ''' + @ArchiveCodes + ''',
				@KMFNumber = ' + @kmfNumberColumn + ',
				@KMFCountriesOfOriginCodes = ''' + @KMFCountriesOfOriginCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				--@KeywordsUIAnnotated =  + @keywordsUIAnnotatedColumn + 	
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @funds TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @inventories TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @archivalEntities TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @documents TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @films TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @filmCards TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @result TABLE ('
			+ @resultColumnsDeclaration +
		');'

		+ @fundsInsert + 
		+ @inventoriesInsert + 
		+ @archivalEntitiesInsert + 
		+ @documentsInsert + 
		+ @filmsInsert +
		+ @filmCardsInsert + '

		INSERT INTO @result SELECT * FROM
			(
				SELECT ' + @resultColumns + ' FROM @funds

				UNION
		
				SELECT ' + @resultColumns + ' FROM @inventories

				UNION

				SELECT ' + @resultColumns + ' FROM @archivalEntities

				UNION

				SELECT ' + @resultColumns + ' FROM @documents

				UNION

				SELECT ' + @resultColumns + ' FROM @films	

				UNION

				SELECT ' + @resultColumns + ' FROM @filmCards
			) x

		
		SELECT
			EntityType, 
			SystemIdentifier,
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
			FilmSystemIdentifier,
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			(SELECT COUNT(0) FROM @result) TotalRows,
			[Rank],
			EntityTypeOrder
		FROM @result
		ORDER BY 
			EntityTypeOrder,
			[Rank] DESC,
			ArchiveName ASC,  -- колоните с ...Int... представляват числото от номера
            FundIntNumber ASC,
			KMFIntNumber ASC,
            FundNumber ASC,
            InventoryIntNumber ASC,
            InventoryNumber ASC,
            ArchivalEntityIntNumber ASC,
            ArchivalEntityNumber ASC,
			FilmCardIntNumber ASC
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY
		';

	EXEC (@sql);
END
GO



CREATE OR ALTER PROCEDURE [dbo].[SearchDocumentsForMainSearchComponent]  
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
	@DocumentDescriptionLevelCodesInternal nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	--@KeywordsUIAnnotated nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0,
	@SearchFileContent bit null = 0,
	@FileDbName nvarchar(50) = null,
	@FileBufferDbName nvarchar(50) = null
AS
BEGIN
	DECLARE @remoteDocumentsQuery nvarchar(max), @kwds int, @kwdsAnnotated int, @ttl int;
	
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

	SET @remoteDocumentsQuery = '';
	SET @remoteDocumentsQuery = 'with dresults as (';
	set @remoteDocumentsQuery = @remoteDocumentsQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''document'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = doc.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		inventory.Number as InventoryNumber,
		ae.Number as ArchivalEntityNumber,
		NULL as KMFNumber,
		NULL as FilmCardNumber,
		doc.Title,
		NULL as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = doc.StatusGid) as StatusText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.LevelOfDescriptionGid) as FundDescriptionLevelText,	
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = inventory.LevelOfDescriptionGid) as InventoryDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		doc.LGid AS ExternalIdentifier,
		NULL AS FundApproximateChronologicalScope,
		NULL AS InventoryApproximateChronologicalScope,
		NULL AS ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		NULL AS FundGid,
		fund.IntNumber as FundIntNumber,
		inventory.IntNumber AS InventoryIntNumber,
		ae.IntNumber AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		doc.Gid,
		doc.LGid'
		+ @rankRemote
		+ ',4 AS EntityTypeOrder';

	if @SearchDrafts = 1 set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		from Document_Active as doc
	';
	else set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		from Document_Modified as doc
	';
	if @SearchDrafts = 1 set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		inner join ArchiveEntity_Search_Active ae on ae.LGid=doc.AELGid
	';
	else set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		inner join ArchiveEntity_Search_Modified ae on ae.LGid=doc.AELGid
	';
	if @SearchDrafts = 1 set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		inner join Inventory_Search_Active inventory on inventory.LGid=doc.InventoryLGid
	';
	else set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		inner join Inventory_Search_Modified inventory on inventory.LGid=doc.InventoryLGid
	';
	if @SearchDrafts = 1 set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		inner join Fund_Search_Active fund on fund.LGid=doc.FundLGid
	';
	else set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		inner join Fund_Search_Modified fund on fund.LGid=doc.FundLGid
	';
	if @kwds = 1 set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		left join freetexttable(Document,*, '''+ @KeyWords + ''') kwds on doc._id = kwds.[key]
	';
	if @ttl = 1 set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		left join freetexttable(Document,Title, '''+ @Title + ''') fttl on doc._id = fttl.[key]
	';
	--if @kwdsAnnotated =1 set @sql = @sql + '
    --inner join ObjectNomenclature on1 on on1.DocumentGid = doc.Gid and on1._retired = ''3000-01-01''
	--inner join Nomenclature n1 on on1.NomenclatureGid = n1.Gid and n1.[Type] = ''Annotated'' and n1._retired = ''3000-01-01''
	--inner join freetexttable(Nomenclature,*,@KeywordsUIAnnotated) fts1 on n1._id = fts1.[key] '
	if @ArchiveGids is not null and @ArchiveGids <> '-999' set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		where doc.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		where 1 = 1
	';
	--if @ArchivalEntityNumber is not null set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		--and (ae.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired = ''3000-01-01'' and [Type] = ''LevelOfDescription'' AND Code = 11)) --Арх.ед. - копия от чужди архиви
	--';
	if @FundNumber is not null set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		and (fund.Number = ''' + @FundNumber + ''')
	';
	if @InventoryNumber is not null set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		and (inventory.Number = ''' + @InventoryNumber + ''')
	';
	if @ArchivalEntityNumber is not null set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		and (ae.Number = ''' + @ArchivalEntityNumber + ''')
	';
	if @LevelOfDescriptionGids is not null and @LevelOfDescriptionGids <> '-999' set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		and (doc.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )
	';
	if @ToDate is not null set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		and (''' + @ToDate +''' >= doc.CreationDate)
	';
	if @FromDate is not null set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		and (''' + @FromDate + ''' <= doc.CreationDate)
	';
	--if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteDocumentsQuery = @remoteDocumentsQuery + '
	--	and ((select FundArrayGid from ' + @fundsView + ' where LGid = inventory.FundLGid) in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	--';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		and (fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +') 
	'

	if @SearchDigitalObject = 1 set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		AND doc.HasDigitalObject = 1
	';
	else if @SearchDigitalObject = 0  set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		AND doc.HasDigitalObject = 0
	';
	set @remoteDocumentsQuery = @remoteDocumentsQuery + @rankFilterRemote;

	if @SearchDrafts = 1 set @remoteDocumentsQuery=@remoteDocumentsQuery+'),
		dresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from dresults)
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
		from dresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = dresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteDocumentsQuery=@remoteDocumentsQuery+'),
		dresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from dresults)
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
		from dresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteDocumentsQuery = REPLACE(@remoteDocumentsQuery, '''', '''''');



	--DECLARE @fundsJoin VARCHAR(MAX) = '';
	--IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = d.FundSystemIdentifier';
	--IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = d.FundSystemIdentifier';

	--DECLARE @inventoriesJoin VARCHAR(MAX) = '';
	--IF @SearchDrafts = 1 SET @inventoriesJoin = ' inner join v_Inventories i on i.SystemIdentifier = d.InventorySystemIdentifier';
	--IF @SearchDrafts = 0 SET @inventoriesJoin = ' inner join v_PublicInventories i on i.SystemIdentifier = d.InventorySystemIdentifier';

	--DECLARE @archivalEntitiesJoin VARCHAR(MAX) = '';
	--IF @SearchDrafts = 1 SET @archivalEntitiesJoin = ' inner join v_ArchivalEntities ae on ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier';
	--IF @SearchDrafts = 0 SET @archivalEntitiesJoin = ' inner join v_PublicArchivalEntities ae on ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier';

	--Fix must be if drafts or no drafts
	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	--if search file content exclude document metadata
	IF (@kwds = 1 AND @SearchFileContent <> 1)
	BEGIN
		SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsD.[KEY] as dId, null as dDId, kwdsD.[RANK] as RankKwds
			from freetexttable(Documents, *, ''' + @KeyWords + ''') kwdsD
			union 
			select null as dId, kwdsDD.[KEY] as dDId, kwdsDD.[RANK] as RankKwds  
			from freetexttable(DocumentDrafts, *, ''' + @KeyWords + ''') kwdsDD
		) kwds
		on (d.Id = kwds.dDId and d.IsDraft = 1) or (d.Id = kwds.dId and d.IsDraft = 0)';
	END

	--Fix must be if drafts or no drafts
	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlD.[KEY] as dId, null as dDId, ttlD.[RANK] as RankTitle   
			from freetexttable(Documents, Title, ''' + @Title + ''') ttlD 
			union 
			select null as dId, ttlDd.[KEY] as dDId, ttlDd.[RANK] as RankTitle   
			from freetexttable(DocumentDrafts, Title, ''' + @Title + ''') ttlDd
		) ttl
		on (d.Id = ttl.dDId and d.IsDraft = 1) or (d.Id = ttl.dId and d.IsDraft = 0)';

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
	

	-- WTF? Suspended item must BE searchable!!!
	--DECLARE @isSuspendedFilter VARCHAR(MAX) = '';
	--IF @SearchDrafts = 1  SET @isSuspendedFilter = '  AND f.IsSuspended = 0 AND i.IsSuspended = 0  AND ae.IsSuspended = 0 and d.IsSuspended = 0';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	--IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND d.FundNumber=''' + @FundNumber + '''';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	--IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND d.InventoryNumber=''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberFilter VARCHAR(MAX) = '';
	--IF @ArchivalEntityNumber IS NOT NULL SET @archivalEntityNumberFilter = ' AND ae.Number=''' + @ArchivalEntityNumber + '''';
	IF @ArchivalEntityNumber IS NOT NULL SET @archivalEntityNumberFilter = ' AND d.ArchivalEntityNumber=''' + @ArchivalEntityNumber + '''';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND d.StatusCode <> 12';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Documents' ELSE SET @table = 'v_PublicDocuments';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';
	
	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	--IF @SearchDrafts = 0 SET @digitalObjectsTable = 'v_PublicDigitalObjects';
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
				  where fcdo.DocumentSystemIdentifier = d.SystemIdentifier
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
	


	--WTF???
	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';		

	DECLARE @localDocumentsQuery VARCHAR(MAX) = '
		SELECT
			''document'' AS EntityType,
			d.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = d.ArchiveId) as ArchiveName,	
			d.FundNumber as FundNumber,
			d.InventoryNumber as InventoryNumber,
			d.ArchivalEntityNumber as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			d.Title as Title,
			NULL as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = d.StatusCode) as StatusText,
			NULL as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			NULL as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as  ArchivalEntityApproximateChronologicalScope,
			NULL as FilmSystemIdentifier,
			NULL as FundGid,
			d.FundNumberNumeric AS FundIntNumber,
			d.InventoryNumberNumeric AS InventoryIntNumber,
			d.ArchivalEntityNumberNumeric AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			4 as EntityTypeOrder
		FROM ' + @table + ' d'
		--+ @fundsJoin + 
		--+ @inventoriesJoin +
		--+ @archivalEntitiesJoin +
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR (d.FundNumberArray in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (d.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + 
			+ @archivalEntityNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))) 
				OR (d.FundDescriptionLevelCode in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))) 
				OR (d.InventoryDescriptionLevelCode in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodesInternal + ''', '',''))) 
				OR (d.ArchivalEntityDescriptionLevelCode in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @DocumentDescriptionLevelCodesInternal + ''', '',''))) 
				OR (d.DescriptionLevelCode in (select element from dbo.SplitString(''' + @DocumentDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(d.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(d.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @doNotGetAnythingFilter
			--+ @isSuspendedFilter
			+ @digitalObjectsFilter
			+ @fileContentFilter
			+ @isDeductedFilter
			+ @rankFilter;


	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteDocumentsTable TABLE (
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
			EntityTypeOrder INT
		);

		DECLARE @localDocumentsTable TABLE (
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
			EntityTypeOrder INT
		);

	';

	--if searching file content exclude external source rows (no file content in external source)
	IF (@SearchFileContent <> 1)
	BEGIN
		SET @sql = @sql + '
			INSERT INTO @remoteDocumentsTable SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @remoteDocumentsQuery + ''' );'
	END
	
	SET @sql = @sql + '
		INSERT INTO @localDocumentsTable ' + @localDocumentsQuery;

	SET @sql = @sql + '
		SELECT *
		  FROM
		  (
			 SELECT *
			   FROM @remoteDocumentsTable
			  UNION
			 SELECT *
			   FROM @localDocumentsTable
		   ) documents
	';

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');


	EXEC (@sql);
END
GO



CREATE OR ALTER PROCEDURE [dbo].[SearchDocumentsForMainSearchComponentInternal]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@FundDescriptionLevelCodes nvarchar(256) = null,
	@InventoryDescriptionLevelCodes nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodes nvarchar(256) = null,
	@DocumentDescriptionLevelCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrays nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@ExtendedSearch bit null = 0,
	@SearchFileContent bit null = 0,
	@FileDbName nvarchar(50) = null,
	@FileBufferDbName nvarchar(50) = null
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @kwds int, @kwdsAnnotated int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1;
	--set @kwdsAnnotated=0;
	--if @KeywordsUIAnnotated is not null and len(@KeywordsUIAnnotated) >=2 set @kwdsAnnotated=1;
	-------------------------------------------------------------------------

	DECLARE @fundsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = d.FundSystemIdentifier';
	IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = d.FundSystemIdentifier';

	DECLARE @inventoriesJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @inventoriesJoin = ' inner join v_Inventories i on i.SystemIdentifier = d.InventorySystemIdentifier';
	IF @SearchDrafts = 0 SET @inventoriesJoin = ' inner join v_PublicInventories i on i.SystemIdentifier = d.InventorySystemIdentifier';

	DECLARE @archivalEntitiesJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @archivalEntitiesJoin = ' inner join v_ArchivalEntities ae on ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier';
	IF @SearchDrafts = 0 SET @archivalEntitiesJoin = ' inner join v_PublicArchivalEntities ae on ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier';

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	--if search file content exclude document metadata
	IF (@kwds = 1 and @SearchFileContent <> 1 )
	BEGIN
		SET @freeTextTableByKwdsJoin = ' 
			left join 
			(
				select kwdsD.[KEY] as dId, null as dDId, kwdsD.[RANK] as RankKwds
				from freetexttable(Documents, *, ''' + @KeyWords + ''') kwdsD
				union 
				select null as dId, kwdsDD.[KEY] as dDId, kwdsDD.[RANK] as RankKwds  
				from freetexttable(DocumentDrafts, *, ''' + @KeyWords + ''') kwdsDD
			) kwds
			on (d.Id = kwds.dDId and d.IsDraft = 1) or (d.Id = kwds.dId and d.IsDraft = 0)';
	END

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlD.[KEY] as dId, null as dDId, ttlD.[RANK] as RankTitle   
			from freetexttable(Documents, Title, ''' + @Title + ''') ttlD 
			union 
			select null as dId, ttlDd.[KEY] as dDId, ttlDd.[RANK] as RankTitle   
			from freetexttable(DocumentDrafts, Title, ''' + @Title + ''') ttlDd
		) ttl
		on (d.Id = ttl.dDId and d.IsDraft = 1) or (d.Id = ttl.dId and d.IsDraft = 0)';

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

	-- WTF?? Suspended items are searchable when searching drafts
	--DECLARE @isSuspendedFilter VARCHAR(MAX) = '';
	--IF @SearchDrafts = 1  SET @isSuspendedFilter = '  AND f.IsSuspended = 0 AND i.IsSuspended = 0  AND ae.IsSuspended = 0 and d.IsSuspended = 0';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberFilter VARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NOT NULL SET @archivalEntityNumberFilter = ' AND ae.Number=''' + @ArchivalEntityNumber + '''';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = d.StatusCode) <> 12';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Documents' ELSE SET @table = 'v_PublicDocuments';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject = 1 SET @suspended= ' and do.IsSuspended = 0';
	
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
				  where fcdo.DocumentSystemIdentifier = d.SystemIdentifier
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

	DECLARE @sql VARCHAR(MAX) = '
		SELECT
			''document'' AS EntityType,
			d.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = d.ArchiveId) as ArchiveName,	
			f.Number as FundNumber,
			i.Number as InventoryNumber,
			ae.Number as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			d.Title as Title,
			NULL as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = d.StatusCode) as StatusText,
			NULL as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			NULL as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as  ArchivalEntityApproximateChronologicalScope,
			NULL as FilmSystemIdentifier,
			NULL as FundGid,
			d.FundNumberNumeric AS FundIntNumber,
			d.InventoryNumberNumeric AS InventoryIntNumber,
			d.ArchivalEntityNumberNumeric AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			4 as EntityTypeOrder
		FROM ' + @table + ' d'
		+ @fundsJoin + 
		+ @inventoriesJoin +
		+ @archivalEntitiesJoin +
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (d.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + 
			+ @archivalEntityNumberFilter + 
			+ @isDeductedFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodes + ''', '',''))) 
				OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodes + ''', '',''))) 
				OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodes + ''', '',''))) 
				OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @DocumentDescriptionLevelCodes + ''', '',''))) 
				OR (d.DescriptionLevelCode in (select element from dbo.SplitString(''' + @DocumentDescriptionLevelCodes + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(d.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(d.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			--+ @isSuspendedFilter
			+ @digitalObjectsFilter
			+ @fileContentFilter
			+ @rankFilter;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');


	EXEC (@sql);
END
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
		+ ',3 AS EntityTypeOrder';

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
			EntityTypeOrder
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
			3 as EntityTypeOrder
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
			EntityTypeOrder INT
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
			EntityTypeOrder INT
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



CREATE OR ALTER PROCEDURE [dbo].[SearchArchivalEntitiesForMainSearchComponentInternal]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@FundDescriptionLevelCodes nvarchar(256) = null,
	@InventoryDescriptionLevelCodes nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrays nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@ExtendedSearch bit null = 0,
	@SearchFileContent bit null = 0,
	@FileDbName nvarchar(50) = null,
	@FileBufferDbName nvarchar(50) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @kwds int, @kwdsAnnotated int, @ttl int;
	
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

	DECLARE @fundsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = ae.FundSystemIdentifier';
	IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = ae.FundSystemIdentifier';

	DECLARE @inventoriesJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @inventoriesJoin = ' inner join v_Inventories i on i.SystemIdentifier = ae.InventorySystemIdentifier';
	IF @SearchDrafts = 0 SET @inventoriesJoin = ' inner join v_PublicInventories i on i.SystemIdentifier = ae.InventorySystemIdentifier';

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	--if search file content exclude document metadata
	IF (@kwds = 1 and @SearchFileContent <> 1 )
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
	--IF @SearchDrafts = 1  SET @isSuspenedFilter = '  AND f.IsSuspended = 0 AND i.IsSuspended = 0 AND ae.IsSuspended = 0';

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

	DECLARE @archivalEntityDescriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @ArchivalEntityNumber is not null and @FundDescriptionLevelCodes = '-111' set @FundDescriptionLevelCodes = '-999';
	if @ArchivalEntityNumber is not null and @InventoryDescriptionLevelCodes = '-111' set @InventoryDescriptionLevelCodes = '-999';
	if @ArchivalEntityNumber is not null and @ArchivalEntityDescriptionLevelCodes = '-111' 
		set @archivalEntityDescriptionLevelCodesFilter = '' 
	else
		set @archivalEntityDescriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodes + ''', '',''))) 
				OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodes + ''', '',''))))
		';

	DECLARE @sql VARCHAR(MAX) = '
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
			3 as EntityTypeOrder
		FROM ' + @table + ' ae'
		+ @inventoriesJoin +
		+ @fundsJoin + 
		+ @documentsJoin +
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE ae.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (ae.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + 
			+ @archivalEntityNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodes + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundDescriptionLevel fdl where fdl.Code = f.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodes + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.InventoryDescriptionLevel idl where idl.Code = i.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodes + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(ae.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(ae.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @archivalEntityDescriptionLevelCodesFilter
			--+ @isSuspenedFilter
			+ @digitalObjectsFilter
			+ @fileContentFilter
			+ @isDeductedFilter
			+ @rankFilter;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO



CREATE OR ALTER PROCEDURE [dbo].[SearchInventoriesForMainSearchComponent]  
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
	DECLARE @remoteInventoryQuery nvarchar(max), @kwds int, @ttl int;
	
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

	SET @remoteInventoryQuery = '';
	SET @remoteInventoryQuery = 'with fresults as (';
	set @remoteInventoryQuery = @remoteInventoryQuery + '
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

	if @SearchDrafts = 0 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			from Inventory_Active as inventory
		';
	else 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			from Inventory_Modified as inventory
		';

	if @kwds = 1 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			left join freetexttable(Inventory,*, '''+ @KeyWords + ''') kwds on inventory._id = kwds.[key]
		';

	if @ttl = 1 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			left join freetexttable(Inventory,FundCreatorNameChanges, '''+ @Title + ''') fttl on inventory._id = fttl.[key]
		';

	if @SearchDrafts = 0 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			inner join Fund_Active fund on inventory.FundLGid = fund.LGid
		';

	if @SearchDrafts = 1 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			inner join Fund_Modified fund on inventory.FundLGid = fund.LGid
		';

	if @ArchiveGids is not null and @ArchiveGids <> '-999' 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
		where inventory.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
		where 1 = 1';

	if (@KMFCountriesOfOriginCodes is not null and @KMFCountriesOfOriginCodes <> '-999')
		set  @remoteInventoryQuery = @remoteInventoryQuery + '
			and ((select n.Value2 from Nomenclature n where n.Gid = fund.CountryGid and n.Type = ''FACountry'') in (''' + [dbo].[StringSplit3](@KMFCountriesOfOriginCodes) + '''))
			and (fund.LevelOfDescriptionGid = 2185 )
			and (inventory.LevelOfDescriptionGid = 2369 )
		';

	if @InventoryNumber is not null 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			and (inventory.Number = ''' + @InventoryNumber + ''')
		';

	if @FundNumber is not null 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			and (fund.Number = ''' + @FundNumber + ''')
		';

	--if @FundLevelOfDescriptionGids is not null and @FundLevelOfDescriptionGids <> '-999' set @remoteInventoryQuery = @remoteInventoryQuery + '
		--and (fund.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@FundLevelOfDescriptionGids) + ' )
	--';
	
	if @InventoryNumber is not null  
		and not '2171' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2172' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2372' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			and (inventory.LevelOfDescriptionGid in (2171,2172,2372))
		';
	else if @InventoryNumber is null and @FundNumber is null
		and not '2171' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2172' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2372' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2369' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			and 1=2
		';
	else if @LevelOfDescriptionGids <> '-999'
		and ('2171' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')) 
			or '2172' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
			or '2372' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
			or '2369' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')))
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			and (inventory.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )
		';

	-- Грубите описи да са видими само в служебната част на системата
	--if @SearchDrafts = 0 
	--	set @remoteInventoryQuery = @remoteInventoryQuery + '
	--	and (inventory.LevelOfDescriptionGid <> 2172)
	--	and (inventory.StatusGid <> 2115)
	--';

	if @ToDate is not null set @remoteInventoryQuery = @remoteInventoryQuery + '
		and (''' + @ToDate +''' >= inventory.CreationDate)
	';
	if @FromDate is not null set @remoteInventoryQuery = @remoteInventoryQuery + '
		and (''' + @FromDate + ''' <= inventory.CreationDate)
	';
	--if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteInventoryQuery = @remoteInventoryQuery + '
	--	and ((select FundArrayGid from ' + @fundsView + ' where LGid = inventory.FundLGid) in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	--';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteInventoryQuery = @remoteInventoryQuery + '
		and (fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +') 
	';
	set @remoteInventoryQuery = @remoteInventoryQuery + @rankFilterRemote;

	if @SearchDrafts = 1 set @remoteInventoryQuery=@remoteInventoryQuery+'),
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
	else set @remoteInventoryQuery=@remoteInventoryQuery+'),
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

	SET @remoteInventoryQuery = REPLACE(@remoteInventoryQuery, '''', '''''');

	DECLARE @fundsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = i.FundSystemIdentifier';
	IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = i.FundSystemIdentifier';

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	--if search file content exclude inventory metadata
	IF (@kwds = 1 AND @SearchFileContent <> 1)
	BEGIN
		SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsI.[KEY] as iId, null as iDId, kwdsI.[RANK] as RankKwds
			from freetexttable(Inventories, *, ''' + @KeyWords + ''') kwdsI
			union 
			select null as iId, kwdsID.[KEY] as iDId, kwdsID.[RANK] as RankKwds  
			from freetexttable(InventoryDrafts, *, ''' + @KeyWords + ''') kwdsID
		) kwds
		on (i.Id = kwds.iDId and i.IsDraft = 1) or (i.Id = kwds.iId and i.IsDraft = 0)';
	END
	--IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
	--	left join 
	--	(
	--		select kwdsI.[KEY] as iId, null as iDId, kwdsI.[RANK] as RankKwds
	--		from freetexttable(Inventories, *, ''' + @KeyWords + ''') kwdsI
	--		union 
	--		select null as iId, kwdsID.[KEY] as iDId, kwdsID.[RANK] as RankKwds  
	--		from freetexttable(InventoryDrafts, *, ''' + @KeyWords + ''') kwdsID
	--	) kwds
	--	on (i.Id = kwds.iDId and i.IsDraft = 1) or (i.Id = kwds.iId and i.IsDraft = 0)';

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
	--IF @SearchDrafts = 1  SET @isSuspenedFilter = '  AND f.IsSuspended = 0 AND i.IsSuspended = 0';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';
	
	---??? Грубите описи са изключени още на ниво v_PublicInventories
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
				  where fcdo.InventorySystemIdentifier = i.SystemIdentifier
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

	DECLARE @localInventoryQuery VARCHAR(MAX) = '
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
			--+ @isSuspenedFilter
			+ @roughInventoriesFilter
			+ @digitalObjectsFilter
			+ @fileContentFilter
			+ @isDeductedFilter
			+ @rankFilter;



		DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteInventoriesTable TABLE (
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
			EntityTypeOrder INT
		);

		DECLARE @localInventoriesTable TABLE (
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
			EntityTypeOrder INT
		);

	';

	--if searching file content exclude external source rows (no file content in external source)
	IF (@SearchFileContent <> 1)
	BEGIN
		SET @sql = @sql + '
			INSERT INTO @remoteInventoriesTable SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @remoteInventoryQuery + ''' );'
	END
	
	SET @sql = @sql + '
		INSERT INTO @localInventoriesTable ' + @localInventoryQuery;

	SET @sql = @sql + '
		SELECT *
		  FROM
		  (
			 SELECT *
			   FROM @remoteInventoriesTable
			  UNION
			 SELECT *
			   FROM @localInventoriesTable
		   ) inventories
	';


	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	PRINT (@sql);

	EXEC (@sql);
END
GO



CREATE OR ALTER PROCEDURE [dbo].[SearchInventoriesForMainSearchComponentInternal]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@FundDescriptionLevelCodes nvarchar(256) = null,
	@InventoryDescriptionLevelCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrays nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@ExtendedSearch bit null = 0,
	@SearchFileContent bit null = 0,
	@FileDbName nvarchar(50) = null,
	@FileBufferDbName nvarchar(50) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @kwds int, @ttl int;
	
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

	DECLARE @fundsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = i.FundSystemIdentifier';
	IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = i.FundSystemIdentifier';

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	--if search file content exclude inventory metadata
	IF (@kwds = 1 AND @SearchFileContent <> 1)
	BEGIN
		SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsI.[KEY] as iId, null as iDId, kwdsI.[RANK] as RankKwds
			from freetexttable(Inventories, *, ''' + @KeyWords + ''') kwdsI
			union 
			select null as iId, kwdsID.[KEY] as iDId, kwdsID.[RANK] as RankKwds  
			from freetexttable(InventoryDrafts, *, ''' + @KeyWords + ''') kwdsID
		) kwds
		on (i.Id = kwds.iDId and i.IsDraft = 1) or (i.Id = kwds.iId and i.IsDraft = 0)';
	END
	--IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
	--	left join 
	--	(
	--		select kwdsI.[KEY] as iId, null as iDId, kwdsI.[RANK] as RankKwds
	--		from freetexttable(Inventories, *, ''' + @KeyWords + ''') kwdsI
	--		union 
	--		select null as iId, kwdsID.[KEY] as iDId, kwdsID.[RANK] as RankKwds  
	--		from freetexttable(InventoryDrafts, *, ''' + @KeyWords + ''') kwdsID
	--	) kwds
	--	on (i.Id = kwds.iDId and i.IsDraft = 1) or (i.Id = kwds.iId and i.IsDraft = 0)';

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
	--IF @SearchDrafts = 1  SET @isSuspenedFilter = '  AND f.IsSuspended = 0 AND i.IsSuspended = 0';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = i.StatusCode) <> 12';

	--Грубите описи са филтрирани още на ниво v_PublicInventories!
	DECLARE @roughInventoriesFilter VARCHAR(MAX) = '';
	-- Грубите описи да са видими само в служебната част на системата
	IF @SearchDrafts = 0 SET @roughInventoriesFilter = ' AND i.DescriptionLevelCode <> ''6''';

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
				  where fcdo.InventorySystemIdentifier = i.SystemIdentifier
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


	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Inventories' ELSE SET @table = 'v_PublicInventories';

	DECLARE @inventoryDescriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @InventoryNumber is not null and @FundDescriptionLevelCodes = '-111' set @FundDescriptionLevelCodes = '-999';
	if @InventoryNumber is not null and @InventoryDescriptionLevelCodes = '-111' 
		set @inventoryDescriptionLevelCodesFilter = '' 
	else
		set @inventoryDescriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodes + ''', '',''))) 
				OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodes + ''', '',''))))
		';

	DECLARE @sql VARCHAR(MAX) = '
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
		WHERE i.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (i.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodes + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundDescriptionLevel fdl where fdl.Code = f.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodes + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(i.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(i.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @inventoryDescriptionLevelCodesFilter
			---+ @isSuspenedFilter
			+ @roughInventoriesFilter
			+ @digitalObjectsFilter
			+ @fileContentFilter
			+ @isDeductedFilter
			+ @rankFilter;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
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
		+ ',1 AS EntityTypeOrder';

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
	ELSE
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
			EntityTypeOrder
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
			EntityTypeOrder INT
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
			EntityTypeOrder INT
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



CREATE OR ALTER PROCEDURE [dbo].[SearchFundsForMainSearchComponentInternal]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@DescriptionLevelCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrays nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@ExtendedSearch bit null = 0,
	@SearchFileContent bit null = 0,
	@FileDbName nvarchar(50) = null,
	@FileBufferDbName nvarchar(50) = null
AS
BEGIN
	SET NOCOUNT ON;

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
	IF @FundNumber IS NOT NULL 
		SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

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

	DECLARE @descriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @FundNumber is not null and @DescriptionLevelCodes = '-111' 
		set @descriptionLevelCodesFilter = '' 
	else
		set @descriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @DescriptionLevelCodes + ''', '',''))) 
				OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''' + @DescriptionLevelCodes + ''', '',''))))
		';

	DECLARE @sql VARCHAR(MAX) = '
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
		+ @freeTextTableByTitleJoin 
		+ @freeTextTableByKwdsJoin 
		+ @documentsJoin + '
		WHERE f.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))) 
				OR (f.NumberArray in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (f.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) )'
			+ @fundNumberFilter + '
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @descriptionLevelCodesFilter
			+ @digitalObjectsFilter
			+ @fileContentFilter
			--+ @isSuspenedFilter
			+ @isDeductedFilter
			+ @rankFilter 
			+ '
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
END
GO

--END SEARCH

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetArchiveEntitiesByInventoryPublic]
	@LinkedServer nvarchar(255) = '', 
	@InventoryIdentifier uniqueidentifier = NULL,
	@InventoryHasExternalSource bit,
	@InventoryExternalIdentifier int = NULL,
	@SearchText nvarchar(max) = NULL,
	@SearchNumber nvarchar(max) = NULL,
	@IncludeDeleted bit = false,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @RemoteArchivalEntitiesQuery nvarchar(max) = '';
    DECLARE @RemoteArchivalEntities TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,IntNumber int
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,TapeCount int
		,MicrofilmCount int 
		,FrameCount int
		,VideoTapeCount int
		,DigitalDeviceCount int 
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Location nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,Features nvarchar(max)
		,Notes nvarchar(max)
		,Description nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,EnrolledDocumentCount int
        ,EnrolledLinearMeters float
        ,DeductedDocumentCount int
        ,DeductedLinearMeters float
		,SheetCount int
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,NumberArray  nvarchar(250) null
	);

	DECLARE @LocalArchivalEntities TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,IntNumber int
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,TapeCount int
		,MicrofilmCount int 
		,FrameCount int
		,VideoTapeCount int
		,DigitalDeviceCount int 
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Location nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,Features nvarchar(max)
		,Notes nvarchar(max)
		,Description nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,EnrolledDocumentCount int
        ,EnrolledLinearMeters float
        ,DeductedDocumentCount int
        ,DeductedLinearMeters float
		,SheetCount int
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,NumberArray  nvarchar(250) null
	);

	IF @InventoryHasExternalSource = 1
	BEGIN 

		SET @RemoteArchivalEntitiesQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
		,CAST(NULL as uniqueidentifier) as SystemIdentifier
		,CAST(1 as bit) as HasExternalSource
		,ae.[LGid] as ExternalIdentifier
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
		,CAST(1 as bit) as InventoryHasExternalSource
		,(select LGid from [Archiving].[dbo].Inventory_Active i where i.LGid = ae.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryExternalIdentifier
		,(select Number from [Archiving].[dbo].Inventory_Active i where i.LGid = ae.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryNumber
		,CAST(1 as bit) as FundHasExternalSource
		,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = ae.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
		,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = ae.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
		,(select Code from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
		,(select Name from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
		,ae.[Number] as Number
		,ae.[IntNumber] as IntNumber ' + '
		,ae.[Title] as Title
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
		,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
		,ae.[TextDate] as ApproximateChronologicalScope
		,ae.[MagnetTapesCount] as TapeCount
		,ae.[MicrofilmsCount] as MicrofilmCount
		,ae.[FramesCount] as FrameCount
		,ae.[VideoTapesCount] as VideoTapeCount 
		,ae.[ElectrCount] as DigitalDeviceCount
		,ae.[CopyMicrofilm] as MicrofilmedCopyCount
		,ae.[CopyDigital] as DigitizedCopyCount
		,ae.[PaperCount] as PaperCopyCount
		,ae.[CopyNegativFrames] as NegativeFrameCount
		,ae.[CopyPositiveFrames] as PositiveFrameCount
		,ae.[CopyOther] as OtherCopyCount
		,ae.[DimensionInCentimeters] as SizeCm
		,ae.[ExtentOther] as OtherMetrics
		,ae.[PlaceOfCreation] as Location ' + '
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
		,ae.[AccessConditions] as DocumentsAccessDescription
		,ae.[DocumentProperties] as Features
		,ae.[Note] as Notes
		,ae.[ExtendedContentDescription] as Description
		,ae.[StartDateYear] as StartDateYear
		,ae.[StartDateMonth] as StartDateMonth
		,ae.[StartDateDay] as StartDateDay
		,ae.[EndDateYear] as EndDateYear
		,ae.[EndDateMonth] as EndDateMonth
		,ae.[EndDateDay] as EndDateDay
		,ae.[IsNoDate] as HasNoChronologicalScope
		,ae.[AveilabilityDocumentsCountAssigned] as EnrolledDocumentCount
        ,ae.[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters 
        ,ae.[AveilabilityDocumentsCountDeducted] as DeductedDocumentCount
        ,ae.[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
		,ae.PaperCount as SheetCount
		,ae.[CreationDate] as CreatedOn
		,ae.[CreationAuthor] as CreatedByDisplayName
		,ae.[ModificationDate] as UpdatedOn
		,ae.[ModificationAuthor] as UpdatedByDisplayName
		,null as NumberArray
	FROM [Archiving].[dbo].[ArchiveEntity_Active] ae
	WHERE ae.InventoryLGid = ' + CAST(@InventoryExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
		BEGIN
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  ' AND (ae.Title LIKE ''''%' + @SearchText + '%'''' OR ae.Number LIKE ''''%' + @SearchText + '%'''')'
		END;
		
		IF @SearchNumber IS NOT NULL
		BEGIN
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  'AND (ae.Number LIKE ''''' + @SearchNumber + ''''')'
			--(ae.Number LIKE ' + @SearchNumber + ')'
		END;
	

		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteArchivalEntitiesQuery + ''' )';
		
		INSERT INTO @RemoteArchivalEntities 
		EXEC(@RemoteQuery)	
	END

	IF @InventoryIdentifier IS NOT NULL
	BEGIN

		INSERT INTO @LocalArchivalEntities
		SELECT	 ae.Id
				,ae.SystemIdentifier as SystemIdentifier
				,ae.HasExternalSource
				,ae.ExternalIdentifier
				,ae.StatusCode
				,ae.StatusText
				,ae.InventoryHasExternalSource
				,ae.InventoryExternalIdentifier
				,ae.InventoryNumber
				,ae.FundHasExternalSource
				,ae.FundExternalIdentifier
				,ae.FundNumber
				,ae.ArchiveCode
				,ae.ArchiveName
				,ae.Number as Number
				,NULL as IntNumber
				,ae.Title
				,ae.DescriptionLevelCode
				,ae.DescriptionLevelText
				,ae.AvailabilityStatusCode
				,ae.AvailabilityStatusText
				,ae.ApproxmateChronologicalScope
				,ae.TapeCount
				,ae.MicrofilmCount
				,ae.FrameCount
				,ae.VideoTapeCount
				,ae.DigitalDeviceCount
				,ae.MicrofilmedCopyCount
				,ae.DigitizedCopyCount
				,ae.PaperCopyCount
				,ae.NegativeFrameCount
				,ae.PositiveFrameCount
				,ae.OtherCopyCount
				,ae.SizeCm
				,ae.OtherMetrics
				,ae.Location
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
				,ae.DocumentsAccessDescription
				,ae.Features
				,ae.Notes
				,ae.Description
				,ae.StartDateYear
				,ae.StartDateMonth
				,ae.StartDateDay
				,ae.EndDateYear
				,ae.EndDateMonth
				,ae.EndDateDay
				,ae.HasNoChronologicalScope
				,ae.EnrolledDocumentCount
				,ae.EnrolledLinearMeters
				,ae.DeductedDocumentCount
				,ae.DeductedLinearMeters
				,ae.SheetCount
				,ae.CreatedOn as CreatedOn
				,ae.CreatedByDisplayName as CreatedByDisplayName
				,ae.UpdatedOn as UpdatedOn
				,ae.UpdatedBy as UpdatedByDisplayName
				,ae.NumberArray as NumberArray
	     FROM [dbo].[v_PublicArchivalEntities] ae
	    WHERE ae.InventorySystemIdentifier = @InventoryIdentifier 
		  AND ae.HasExternalSource = 0
		  AND ae.Deleted = 0
		  AND (@SearchText IS NULL OR (ae.Title LIKE '%'+ @SearchText +'%' OR ae.Number LIKE '%'+ @SearchText +'%'))
		  AND (@IncludeDeleted = 1 OR ae.Deleted = 0)
	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalArchivalEntities
		  UNION
		 SELECT *
		   FROM @RemoteArchivalEntities
	   ) ArchivalEntities
	ORDER BY IntNumber, NumberArray
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END
GO


----------------------------------------------------------
--	THE SCRIPT IS CLOSED - USE THE NEW ONE!
----------------------------------------------------------
commit