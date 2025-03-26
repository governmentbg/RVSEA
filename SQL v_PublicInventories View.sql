SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[v_PublicInventories] AS
SELECT i.Id, i.SystemIdentifier, CAST(0 AS bit) AS IsDraft, i.ArchiveId, a.Code AS ArchiveCode, a.Name AS ArchiveName, NULL AS FundDraftId, i.FundSystemIdentifier, f.Number AS FundNumber, f.HasExternalSource AS FundHasExternalSource, 
                  f.ExternalIdentifier AS FundExternalIdentifier, i.CreatedOn, i.CreatedBy, cu.DisplayName AS CreatedByDisplayName, cu.UserName AS CreatedByUserName, i.UpdatedOn, i.UpdatedBy, uu.DisplayName AS UpdatedByDisplayName, 
                  uu.UserName AS UpdatedByUserName, i.Deleted, i.DeletedOn, i.DeletedBy, du.DisplayName AS DeletedByDisplayName, du.UserName AS DeletedByUserName, i.ExternalIdentifier, i.HasExternalSource, i.ExternalSourceUpdatedOn, 
                  i.NumberArray, i.Number, i.DescriptionLevelCode, idl.Text AS DescriptionLevelText, i.StatusCode, s.Text AS StatusText, i.HasNoChronologicalScope, i.StartDateYear, i.StartDateMonth, i.StartDateDay, i.EndDateYear, i.EndDateMonth, 
                  i.EndDateDay, i.ApproxmateChronologicalScope, i.Bytes, i.LinearMeters, i.OtherMetrics, i.ArchivalEntityCount, i.DocumentCount, i.BoxCount, i.RollCount, i.AudioDocumentArchivalEntityCount, i.PhotoDocumentArchivalEntityCount, 
                  i.VideoDocumentArchivalEntityCount, i.DigitalDocumentArchivalEntityCount, i.FundCreatorTitleHistory, i.FundCreatorBiographicalHistory, i.History, i.DocumentsProvider, i.DocumentsDescription, i.DocumentsAccessDescription, 
                  i.ClassificationScheme, i.AbbreviationList, i.MicrofilmedArchivalEntityCount, i.DigitizedArchivalEntityCount, i.NegativeFrameCount, i.PositiveFrameCount, i.Notes, i.NumberNumeric, f.NumberNumeric as FundNumberNumeric
FROM     dbo.Inventories AS i INNER JOIN
                  dbo.Archives AS a ON i.ArchiveId = a.Id INNER JOIN
                  dbo.Funds AS f ON i.FundSystemIdentifier = f.SystemIdentifier LEFT OUTER JOIN
                  N.InventoryDescriptionLevel AS idl ON i.DescriptionLevelCode = idl.Code LEFT OUTER JOIN
                  N.Status AS s ON i.StatusCode = s.Code LEFT OUTER JOIN
                  dbo.AspNetUsers AS cu ON i.CreatedBy = cu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS uu ON i.UpdatedBy = uu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS du ON i.CreatedBy = du.Id
GO