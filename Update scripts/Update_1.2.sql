SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.2'
where Code = 'DB_VERSION'


-- add scripts here

ALTER TABLE dbo.EPKReports
DROP COLUMN IF EXISTS FundName
GO

ALTER TABLE dbo.EPKReports
DROP COLUMN IF EXISTS Date
GO

ALTER TABLE dbo.EPKReports
DROP COLUMN IF EXISTS AuthorName
GO

ALTER TABLE dbo.EPKReports
DROP COLUMN IF EXISTS AuthorPosition
GO

ALTER TABLE dbo.EPKReports
DROP COLUMN IF EXISTS EntityLink
GO

ALTER TABLE dbo.EPKReports
DROP COLUMN IF EXISTS LinkTitle
GO

IF OBJECT_ID('dbo.EPKReports.About') IS NOT NULL 
    EXEC sp_rename 'dbo.EPKReports.About', 'Title', 'COLUMN'
GO

IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'About'
          AND Object_ID = Object_ID(N'dbo.EPKReports'))
    EXEC sp_rename 'dbo.EPKReports.About', 'Title', 'COLUMN'
GO

IF OBJECT_ID('dbo.PK__EPKRepor__3214EC07302CAA0A') IS NOT NULL 
    EXEC sp_rename 'dbo.PK__EPKRepor__3214EC07302CAA0A', 'PK_CommissionReports', 'OBJECT'
GO

IF OBJECT_ID('dbo.FK__EPKReport__Creat__77FFC2B3') IS NOT NULL 
    EXEC sp_rename 'dbo.FK__EPKReport__Creat__77FFC2B3', 'FK_CommissionReports_CreatedBy', 'OBJECT'
GO

IF OBJECT_ID('dbo.FK__EPKReport__Delet__78F3E6EC') IS NOT NULL 
    EXEC sp_rename 'dbo.FK__EPKReport__Delet__78F3E6EC', 'FK_CommissionReports_DeletedBy', 'OBJECT'
GO

IF OBJECT_ID('dbo.FK__EPKReport__Delet__78F3E6EC') IS NOT NULL 
    EXEC sp_rename 'dbo.FK__EPKReport__Delet__78F3E6EC', 'FK_CommissionReports_DeletedBy', 'OBJECT'
GO

IF OBJECT_ID('dbo.FK__EPKReport__Updat__79E80B25') IS NOT NULL 
    EXEC sp_rename 'dbo.FK__EPKReport__Updat__79E80B25', 'FK_CommissionReports_UpdatedBy', 'OBJECT'
GO

IF OBJECT_ID('dbo.FK__EPKReport__Proce__6D823440') IS NOT NULL 
    EXEC sp_rename 'dbo.FK__EPKReport__Proce__6D823440', 'FK_CommissionReports_Process', 'OBJECT'
GO

IF OBJECT_ID('dbo.DF__EPKReport__Delet__26A5A303') IS NOT NULL 
    EXEC sp_rename 'dbo.DF__EPKReport__Delet__26A5A303', 'DF_EPKReport_Deleted', 'OBJECT'
GO

IF OBJECT_ID('dbo.DF__EPKReport__isFin__6E765879') IS NOT NULL 
BEGIN
	ALTER TABLE dbo.EPKReports DROP CONSTRAINT [DF__EPKReport__isFin__6E765879]
	
	ALTER TABLE dbo.EPKReports ADD CONSTRAINT [DF_EPKReport_IsDraft]  DEFAULT ((1)) FOR [IsDraft]
END
GO



commit