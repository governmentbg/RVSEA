
CREATE OR ALTER view [dbo].[v_Tasks]
AS
SELECT 
	   t.Id
	  ,t.ProcessId
	  ,pt.Name as ProcessTypeName
	  ,t.StepId
	  ,stt.Text as StepTypeName
      ,t.Title
	  ,t.Description

	  ,t.AssignedToUserId
	  ,au.DisplayName as AssignedToDisplayName
	  ,au.UserName as AssignedToUserName

      ,t.EndDate
      ,t.RelatedEntityId
	  ,t.RelatedEntitySystemIdentifier
	  ,t.RelatedEntityType
      ,t.RelatedContentUrl

      ,t.StatusCode
	  ,s.Text as StatusName

	  ,t.CreatedOn
	  ,t.CreatedBy
	  ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,t.UpdatedOn
	  ,t.UpdatedBy
	  ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
	  ,t.Deleted
	  ,t.DeletedOn
	  ,t.DeletedBy
	  ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
	  
	  ,t.NotificationType
	  ,n.Text as NotificationTypeName
	  
    FROM Tasks t
	LEFT JOIN Process p on p.Id = t.ProcessId
	LEFT JOIN N.ProcessTypes pt on pt.Id = p.ProcessTypeId
	LEFT JOIN ProcessTimeline st on st.Id = t.StepId
	LEFT JOIN N.ProcessSteps stt on stt.Id = st.StepTypeId
	JOIN N.TaskStatus s on s.Code = t.StatusCode
	LEFT JOIN N.NotificationType n on n.Code = t.NotificationType
	LEFT JOIN AspNetUsers cu ON t.CreatedBy = cu.Id
	LEFT JOIN AspNetUsers uu ON t.UpdatedBy = uu.Id
	LEFT JOIN AspNetUsers du ON t.CreatedBy = du.Id
    LEFT JOIN AspNetUsers au ON t.AssignedToUserId = au.Id
   
GO


