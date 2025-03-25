


CREATE OR ALTER VIEW [dbo].[v_PublicDocuments] AS
	SELECT 
		d.Id, d.SystemIdentifier,
		CAST(0 AS bit) AS IsDraft,
		d.ArchiveId, 
		a.Code AS ArchiveCode,
		a.Name AS ArchiveName,
		NULL AS FundDraftId, 
		d.FundSystemIdentifier, 
		f.Number AS FundNumber, 
        f.NumberNumeric AS FundNumberNumeric,
		f.NumberArray as FundNumberArray,
		f.HasExternalSource AS FundHasExternalSource, 
		f.ExternalIdentifier AS FundExternalIdentifier,
		f.DescriptionLevelCode AS FundDescriptionLevelCode,
		f.StatusCode AS FundStatusCode,
		NULL AS InventoryDraftId, 
		d.InventorySystemIdentifier, 
		i.Number AS InventoryNumber, 
        i.NumberNumeric AS InventoryNumberNumeric,
		i.NumberArray AS InventoryNumberArray,
		i.HasExternalSource AS InventoryHasExternalSource,
		i.ExternalIdentifier AS InventoryExternalIdentifier,
		i.DescriptionLevelCode AS InventoryDescriptionLevelCode,
		i.StatusCode AS InventoryStatusCode,
		NULL AS ArchivalEntityDraftId, 
		d.ArchivalEntitySystemIdentifier, 
		ae.Number AS ArchivalEntityNumber, 
        ae.NumberNumeric AS ArchivalEntityNumberNumeric,
		ae.NumberArray as ArchivalEntityNumberArray,
		ae.HasExternalSource AS ArchivalEntityHasExternalSource, 
		ae.ExternalIdentifier AS ArchivalEntityExternalIdentifier,
		ae.DescriptionLevelCode AS ArchivalEntityDescriptionLevelCode,
		ae.StatusCode as ArchivalEntityStatusCode,
		d.CreatedOn,
		d.CreatedBy, 
		cu.DisplayName AS CreatedByDisplayName,
		cu.UserName AS CreatedByUserName, 
        d.UpdatedOn, 
		d.UpdatedBy, 
		uu.DisplayName AS UpdatedByDisplayName, 
		uu.UserName AS UpdatedByUserName,
		d.Deleted, 
		d.DeletedOn, 
		d.DeletedBy,
		du.DisplayName AS DeletedByDisplayName,
		du.UserName AS DeletedByUserName, 
        d.HasExternalSource, 
		d.ExternalIdentifier, 
		d.ExternalSourceUpdatedOn, 
		d.Number, 
		d.Title,
		d.DescriptionLevelCode, 
		l.Text AS DescriptionLevelText,
		d.StatusCode, 
		s.Text AS StatusText, 
		d.FileFormatCode, 
		d.HasNoChronologicalScope, 
        d.StartDateYear,
		d.StartDateMonth, 
		d.StartDateDay, 
		d.EndDateYear, 
		d.EndDateMonth, 
		d.EndDateDay, 
		d.ApproxmateChronologicalScope, 
		d.Author, 
		d.Location, 
		d.Bytes, 
		d.SheetCount,
		d.StartSheetNumber, 
		d.EndSheetNumber, 
        d.DigitalDevice,
		d.OtherMetrics,
		d.SizeCm, 
		d.Scaling,
		d.Duration, 
		d.Description, 
		d.DocumentsAccessDescription,
		d.Features,
		d.MicrofilmedCopyCount, 
		d.DigitizedCopyCount, 
		d.PaperCopyCount, 
		d.NegativeFrameCount, 
        d.PositiveFrameCount, 
		d.OtherCopyCount, 
		d.Transcription, 
		d.Notes,
		d.AvailabilityStatusCode,
		ast.Text as AvailabilityStatusText,
		case when (select IsNull(count(A.Id),0) from v_PublicDigitalObjects A 
				  where A.DocumentSystemIdentifier = d.SystemIdentifier 
				  and A.IsDraft = 0 
				  and A.IsDigitized = 1) > 0 
			 then 1 else 0 end as HasDigitizedDigitalObjects
	FROM dbo.Documents AS d 
		INNER JOIN dbo.Archives AS a ON d.ArchiveId = a.Id 
		INNER JOIN dbo.Funds AS f ON d.FundSystemIdentifier = f.SystemIdentifier
		INNER JOIN dbo.Inventories AS i ON d.InventorySystemIdentifier = i.SystemIdentifier 
		INNER JOIN dbo.ArchivalEntities AS ae ON d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier
		LEFT JOIN N.DocumentDescriptionLevel AS l ON d.DescriptionLevelCode = l.Code 
		LEFT JOIN N.Status AS s ON d.StatusCode = s.Code 
		LEFT JOIN dbo.AspNetUsers AS cu ON d.CreatedBy = cu.Id
		LEFT JOIN dbo.AspNetUsers AS uu ON d.UpdatedBy = uu.Id
		LEFT JOIN dbo.AspNetUsers AS du ON d.CreatedBy = du.Id
		LEFT JOIN N.AvailabilityStatus ast ON d.AvailabilityStatusCode = ast.Code
	WHERE f.IsSuspended = 0
	AND d.StatusCode <> 12 --статус отчислен
GO
