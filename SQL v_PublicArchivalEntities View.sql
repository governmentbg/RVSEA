SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [dbo].[v_PublicArchivalEntities] AS
	SELECT 
		ae.Id, 
		ae.SystemIdentifier, 
		CAST(0 AS bit) AS IsDraft,
		ae.ArchiveId, 
		a.Code AS ArchiveCode,
		a.Name AS ArchiveName,
		NULL AS FundDraftId,
		ae.FundSystemIdentifier,
		f.Number AS FundNumber, 
        f.HasExternalSource AS FundHasExternalSource,
		f.ExternalIdentifier AS FundExternalIdentifier,
		NULL AS InventoryDraftId, 
		ae.InventorySystemIdentifier, 
		i.Number AS InventoryNumber, 
        i.HasExternalSource AS InventoryHasExternalSource, 
		i.ExternalIdentifier AS InventoryExternalIdentifier, 
		ae.CreatedOn, 
		ae.CreatedBy, 
		cu.DisplayName AS CreatedByDisplayName, 
		cu.UserName AS CreatedByUserName, 
		ae.UpdatedOn, 
        ae.UpdatedBy, 
		uu.DisplayName AS UpdatedByDisplayName,
		uu.UserName AS UpdatedByUserName, 
		ae.Deleted, 
		ae.DeletedOn,
		ae.DeletedBy, 
		du.DisplayName AS DeletedByDisplayName, 
		du.UserName AS DeletedByUserName, 
        ae.HasExternalSource, 
		ae.ExternalIdentifier, 
		ae.ExternalSourceUpdatedOn, 
		ae.Number,
		ae.Title, 
		ae.DescriptionLevelCode, 
		l.Text AS DescriptionLevelText, 
		ae.StatusCode,
		s.Text AS StatusText, 
		ae.HasNoChronologicalScope, 
        ae.StartDateYear,
		ae.StartDateMonth, 
		ae.StartDateDay, 
		ae.EndDateYear, 
		ae.EndDateMonth, 
		ae.EndDateDay, 
		ae.ApproxmateChronologicalScope, 
		ae.Author, 
		ae.Location, 
		ae.Bytes,
		ae.SheetCount, 
		ae.TapeCount,
		ae.MicrofilmCount, 
        ae.FrameCount,
		ae.VideoTapeCount,
		ae.DigitalDeviceCount,
		ae.OtherMetrics, 
		ae.SizeCm, 
		ae.Scaling, 
		ae.Description, 
		ae.DocumentsAccessDescription, 
		ae.Features, 
		ae.Condition, 
		ae.MicrofilmedCopyCount, 
		ae.DigitizedCopyCount, 
        ae.PaperCopyCount,
		ae.NegativeFrameCount, 
		ae.PositiveFrameCount,
		ae.OtherCopyCount, 
		ae.Notes, 
		ae.EnrolledBytes, 
		ae.EnrolledDocumentCount, 
		ae.EnrolledLinearMeters, 
		ae.DeductedBytes,
		ae.DeductedDocumentCount, 
        ae.DeductedLinearMeters, 
		f.NumberNumeric as FundNumberNumeric, 
		i.NumberNumeric as InventoryNumberNumeric, 
		ae.NumberNumeric,
		ae.NumberArray,
		ast.Text as AvailabilityStatusText, 
		i.AvailabilityStatusCode,
		IsNull(
		(select top 1 HasDigitizedDigitalObjects from v_PublicDocuments doc 
		where doc.ArchivalEntitySystemIdentifier = ae.SystemIdentifier 
		and IsDraft = 0 and Deleted = 0
		and HasDigitizedDigitalObjects = 1), 0) HasDigitizedDigitalObjects

	FROM dbo.ArchivalEntities AS ae
		INNER JOIN dbo.Archives AS a ON ae.ArchiveId = a.Id 
		INNER JOIN dbo.Funds AS f ON ae.FundSystemIdentifier = f.SystemIdentifier
		INNER JOIN dbo.Inventories AS i ON ae.InventorySystemIdentifier = i.SystemIdentifier 
		LEFT OUTER JOIN N.ArchivalEntityDescriptionLevel AS l ON ae.DescriptionLevelCode = l.Code 
		LEFT OUTER JOIN N.Status AS s ON ae.StatusCode = s.Code
		LEFT OUTER JOIN dbo.AspNetUsers AS cu ON ae.CreatedBy = cu.Id 
		LEFT OUTER JOIN dbo.AspNetUsers AS uu ON ae.UpdatedBy = uu.Id 
		LEFT OUTER JOIN dbo.AspNetUsers AS du ON ae.CreatedBy = du.Id
		LEFT JOIN N.AvailabilityStatus ast ON ae.AvailabilityStatusCode = ast.Code
	WHERE f.IsSuspended = 0
	AND ae.StatusCode <> 12 --статус отчислен
GO