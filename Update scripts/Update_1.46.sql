SET XACT_ABORT ON
GO

BEGIN TRANSACTION

update dbo._Version 
set Value = '1.46'
where Code = 'DB_VERSION'
go

update dbo._Version 
set Value = '1.1.X'
where Code = 'APP_VERSION'
go



-- ADD YOUR SCRIPTS HERE!

COMMIT 