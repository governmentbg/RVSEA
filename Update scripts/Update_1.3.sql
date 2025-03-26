SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.3'
where Code = 'DB_VERSION'

-- add scripts here

IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'SessionAgendaItemId'
          AND Object_ID = Object_ID(N'dbo.SessionAgendaStandpoints'))
BEGIN
    ALTER TABLE dbo.SessionAgendaStandpoints
	ALTER COLUMN SessionAgendaItemId int NULL
END

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'ReportId'
          AND Object_ID = Object_ID(N'dbo.SessionAgendaStandpoints'))
BEGIN
    ALTER TABLE dbo.SessionAgendaStandpoints
	ADD ReportId int NULL
END
GO

IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'ReportId'
          AND Object_ID = Object_ID(N'dbo.SessionAgendaStandpoints'))
BEGIN
update sas
   set sas.ReportId = a.ReportId
  from SessionAgendaStandpoints sas
  join SessionAgenda a on sas.SessionAgendaItemId = a.Id
END
GO

IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'ReportId'
          AND Object_ID = Object_ID(N'dbo.SessionAgendaStandpoints'))
BEGIN
    ALTER TABLE dbo.SessionAgendaStandpoints
	ALTER COLUMN ReportId int NOT NULL
END
GO

IF OBJECT_ID('dbo.FK_SessionAgendaStandpoint_CommissionReport') IS NOT NULL 
    ALTER TABLE dbo.SessionAgendaStandpoints DROP CONSTRAINT [FK_SessionAgendaStandpoint_CommissionReport]
GO

ALTER TABLE [dbo].[SessionAgendaStandpoints]  WITH CHECK ADD CONSTRAINT [FK_SessionAgendaStandpoint_CommissionReport] FOREIGN KEY([ReportId])
REFERENCES [dbo].[EPKReports] ([Id])

ALTER TABLE [dbo].[SessionAgendaStandpoints] CHECK CONSTRAINT [FK_SessionAgendaStandpoint_CommissionReport]
GO

IF OBJECT_ID('dbo.FK_Sessions_Archive') IS NOT NULL 
	ALTER TABLE dbo.Sessions DROP CONSTRAINT FK_Sessions_Archive
GO

ALTER TABLE dbo.Sessions  WITH CHECK ADD CONSTRAINT FK_Sessions_Archive FOREIGN KEY(ArchiveId)
REFERENCES dbo.Archives (Id)

ALTER TABLE dbo.Sessions CHECK CONSTRAINT FK_Sessions_Archive
GO

IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'AssignedToChairmanId'
          AND Object_ID = Object_ID(N'dbo.Sessions'))
    EXEC sp_rename 'dbo.Sessions.AssignedToChairmanId', 'ChairmanId', 'COLUMN'
GO

IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'AssignedToSecretarId'
          AND Object_ID = Object_ID(N'dbo.Sessions'))
    EXEC sp_rename 'dbo.Sessions.AssignedToSecretarId', 'SecretaryId', 'COLUMN'
GO

IF OBJECT_ID('dbo.FK__Sessions__Sessio__2917FB5A') IS NOT NULL 
    EXEC sp_rename 'dbo.FK__Sessions__Sessio__2917FB5A', 'FK_Sessions_SessionType', 'OBJECT'
GO

IF OBJECT_ID('dbo.FK__Sessions__Assign__2DDCB077') IS NOT NULL 
    EXEC sp_rename 'dbo.FK__Sessions__Assign__2DDCB077', 'FK_Sessions_Chairman', 'OBJECT'
GO

IF OBJECT_ID('dbo.FK__Sessions__Assign__2ED0D4B0') IS NOT NULL 
    EXEC sp_rename 'dbo.FK__Sessions__Assign__2ED0D4B0', 'FK_Sessions_Secretary', 'OBJECT'
GO

commit