using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Models.Films;
using DAA.Models.Tasks;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TaskEntity = DAA.Data.Task;

namespace DAA.Extensions.Models
{
    public static class TaskExtensions
    {
        public static IQueryable<VTask> FilterBySearchText(this IQueryable<VTask> query, string searchText)
        {
            //практиката показвам че ToUpper е по-бързо
            searchText = searchText.ToUpper();

            return query
                .Where(predicate =>
                       (!String.IsNullOrEmpty(predicate.Title) && predicate.Title.ToUpper().Contains(searchText))
                     || (!String.IsNullOrEmpty(predicate.ProcessTypeName) && predicate.ProcessTypeName.ToUpper().Contains(searchText))
                     || (!String.IsNullOrEmpty(predicate.StepTypeName) && predicate.StepTypeName.ToUpper().Contains(searchText))
                     || (!String.IsNullOrEmpty(predicate.NotificationTypeName) && predicate.NotificationTypeName.ToUpper().Contains(searchText))
                     );
        }



        public static TaskEntity ToEntity(this TaskModel model)
        {
            if (model == null)
            {
                return null;
            }


            TaskEntity entity = new TaskEntity
            {
                ProcessId = model.ProcessId,
                StepId = model.StepId,
                NotificationType = model.NotificationType != Shared.NotificationType.None ? model.NotificationType : null,
                Title = model.Title,
                Description = model.Description,
                AssignedToUserId = model.AssignedToUserId,
                AssignedToRoleId = model.AssignedToRoleId,
                EndDate = model.EndDate,
                RelatedEntityId = model.RelatedEntityId,
                RelatedEntitySystemIdentifier = model.RelatedEntitySystemIdentifier,
                RelatedEntityType = model.RelatedEntityType,
                RelatedContentUrl = model.RelatedContentUrl,
                StatusCode = model.StatusCode!,
            };

            return entity;
        }


    }
}
