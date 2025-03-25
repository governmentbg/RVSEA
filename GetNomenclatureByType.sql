USE [DAA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_GetNomenclatureByType] 
	@LinkedServer nvarchar(255) = '',
	@Type nvarchar(255) = ''
AS
BEGIN
	SET NOCOUNT ON;

	declare @name varchar(50) = 'Value';	
	if @Type = 'IndustryIndex' set @name  ='Value2'

	declare @sql varchar(max) =
		'SELECT 
			Gid,
			' + @name + ' as Name
		FROM '  + @LinkedServer + '.[Archiving].[dbo].[Nomenclature]
		WHERE _retired = ''3000-01-01 00:00:00.000'' AND Type = ''' + @Type + '''';

	exec (@sql);
END
