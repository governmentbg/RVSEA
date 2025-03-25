USE [master]
GO

CREATE DATABASE [DAA.AdjunctFiles]
CONTAINMENT = NONE
ON PRIMARY ( NAME = N'DAA.AdjunctFiles', FILENAME = N'D:\Database.SQL2019\DAA.AdjunctFiles.mdf', SIZE = 51200KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10240KB ), 
FILEGROUP [FILESTREAM_GROUP] CONTAINS FILESTREAM ( NAME = N'fsAdjunctFiles', FILENAME = N'D:\DAA\adjunctfiles' , MAXSIZE = UNLIMITED)
LOG ON ( NAME = N'DAA.AdjunctFiles_Log', FILENAME = N'D:\Database.SQL2019\DAA.AdjunctFiles_log.ldf' , SIZE = 51200KB , MAXSIZE = 2048GB , FILEGROWTH = 10240KB )
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
BEGIN
	EXEC [DAA.AdjunctFiles].[dbo].[sp_fulltext_database] @action = 'enable'
END
GO

--SELECT DB_NAME(database_id) dbname, non_transacted_access, non_transacted_access_desc  
--    FROM sys.database_filestream_options
--ORDER BY dbname
--GO

--SELECT DB_NAME ( database_id ) dbname, directory_name  
--    FROM sys.database_filestream_options
--ORDER BY dbname
--GO

ALTER DATABASE [DAA.AdjunctFiles]  
SET FILESTREAM ( NON_TRANSACTED_ACCESS = FULL, DIRECTORY_NAME = N'DAAAdjunctFiles' )
GO


USE [DAA.AdjunctFiles]
GO

IF OBJECT_ID('dbo.FileContent', 'U') IS NOT NULL
  DROP TABLE dbo.FileContent
GO

CREATE TABLE dbo.FileContent AS FILETABLE
WITH
(
	FILETABLE_DIRECTORY = 'FileContent',
	FILETABLE_COLLATE_FILENAME = Cyrillic_General_CI_AS,
	FILETABLE_PRIMARY_KEY_CONSTRAINT_NAME = PK_FileContent,
	FILETABLE_STREAMID_UNIQUE_CONSTRAINT_NAME = UI_FileContent_StreamId,
	FILETABLE_FULLPATH_UNIQUE_CONSTRAINT_NAME = UI_FileContent_FullPath

)
GO

----View all objects for all filetables, unsorted  
--SELECT * FROM sys.filetable_system_defined_objects;  
--GO  
  
----View sorted list with friendly names  
--SELECT OBJECT_NAME(parent_object_id) AS 'FileTable', OBJECT_NAME(object_id) AS 'System-defined Object'  
--    FROM sys.filetable_system_defined_objects  
--    ORDER BY FileTable, 'System-defined Object';  
--GO


USE [DAA.AdjunctFiles]
GO

CREATE OR ALTER view [dbo].[v_FileContent]
AS
SELECT fc.stream_id
      ,fc.name
	  ,CONCAT(FileTableRootPath(), fc.file_stream.GetFileNamespacePath()) AS unc_path
      ,fc.file_type
      ,fc.cached_file_size
      ,fc.creation_time
      ,fc.last_write_time
      ,fc.last_access_time
      ,fc.is_directory
      ,fc.is_offline
      ,fc.is_hidden
      ,fc.is_readonly
      ,fc.is_archive
      ,fc.is_system
      ,fc.is_temporary
	  ,fc.file_stream
  FROM dbo.FileContent fc
GO
