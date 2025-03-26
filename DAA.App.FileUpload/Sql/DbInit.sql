Create Table FileUploadQueue(
	Id int Not Null Identity(1, 1),
	UserId uniqueidentifier Not Null,
	ComputerName varchar(256) Not Null,
	LocalFileName nvarchar(2000) Not Null,
	Checksum varchar(100) Not Null,
	FileName nvarchar(2000) Not Null,
	ProcessKindCode varchar(20) Not Null, -- Process 1, Process 2
	FileKindCode varchar(20), -- Master, Demo, Small
	DocumentId uniqueidentifier Not Null,
	MasterDocumentId uniqueidentifier, 
	Notes nvarchar(2000),
	Size bigint Not Null,
	Position bigint Not Null,
	Finished bit Not Null,
	DbFileName nvarchar(2000) Not Null,
	UncFileName nvarchar(2000),

	ChecksumCheckResult bit,
	FileFormatCheckResult bit,
	AntivirusCheckResult bit,
	AntivirusCheckInfo nvarchar(2000),
	FileInfo nvarchar(2000),
	ErrorMessage nvarchar(2000),

	Constraint Pk_FileUploadQueue Primary Key(Id)
);


