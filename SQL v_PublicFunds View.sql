USE [DAA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[v_PublicFunds] AS
SELECT f.Id, f.SystemIdentifier, CAST(0 AS bit) AS IsDraft, f.ArchiveId, a.Code AS ArchiveCode, a.Name AS ArchiveName, f.CreatedOn, f.CreatedBy, cu.DisplayName AS CreatedByDisplayName, cu.UserName AS CreatedByUserName, f.UpdatedOn, 
                  f.UpdatedBy, uu.DisplayName AS UpdatedByDisplayName, uu.UserName AS UpdatedByUserName, f.Deleted, f.DeletedOn, f.DeletedBy, du.DisplayName AS DeletedByDisplayName, du.UserName AS DeletedByUserName, 
                  f.ExternalIdentifier, f.HasExternalSource, f.ExternalSourceUpdatedOn, f.NumberArray, f.Number, f.Title, f.DescriptionLevelCode, dl.Text AS DescriptionLevelText, f.TypeCode, ft.Text AS TypeText, f.StatusCode, s.Text AS StatusText, 
                  f.HasNoChronologicalScope, f.StartDateYear, f.StartDateMonth, f.StartDateDay, f.EndDateYear, f.EndDateMonth, f.EndDateDay, f.ApproxmateChronologicalScope, f.Bytes, f.LinearMeters, f.OtherMetrics, f.InventoryCount, 
                  f.ArchivalEntityCount, f.DocumentCount, f.FundCreatorTitleHistory, f.FundCreatorActivityHistory, f.FundCreatorBiographicalHistory, f.DocumentsProvider, f.DocumentsDescription, f.ValuableDocumentsInventoryCount, 
                  f.InvaluableDocumentsInventoryCount, f.DocumentsAccessDescription, f.History, f.RelatedFunds, f.Notes, f.EnrolledBytes, f.EnrolledInventoryCount, f.DeductedBytes, f.DeductedInventoryCount, f.NumberNumeric
FROM     dbo.Funds AS f INNER JOIN
                  dbo.Archives AS a ON f.ArchiveId = a.Id LEFT OUTER JOIN
                  N.FundDescriptionLevel AS dl ON f.DescriptionLevelCode = dl.Code LEFT OUTER JOIN
                  N.FundType AS ft ON f.TypeCode = ft.Code LEFT OUTER JOIN
                  N.Status AS s ON f.StatusCode = s.Code LEFT OUTER JOIN
                  dbo.AspNetUsers AS cu ON f.CreatedBy = cu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS uu ON f.UpdatedBy = uu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS du ON f.CreatedBy = du.Id
GO
