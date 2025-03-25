using DAA.Models.Configuration;
using DAA.Services.Notifications;
using Hangfire;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;

namespace DAA.Services.AutoTasks
{
    public class HangfireJobScheduler
    {
        public static void ScheduleRecurringJobs(IServiceProvider serviceProvider)
        {
            IOptions<HangFireJobSettings> config = serviceProvider.GetService<IOptions<HangFireJobSettings>>();
            HangFireJobSettings? settings = config?.Value;


            var taskNotificationJobMinutesInterval = settings?.TaskNotificationJobMinutesInterval ?? 5;
            // Every 5 minutes
            RecurringJob.RemoveIfExists(nameof(TaskNotificationServiceJob));
            RecurringJob.AddOrUpdate<TaskNotificationServiceJob>(nameof(TaskNotificationServiceJob),
                job => job.Run(JobCancellationToken.Null),
                $"*/{taskNotificationJobMinutesInterval} * * * *", TimeZoneInfo.Utc);


            var pureNotificationJobMinutesInterval = settings?.PureNotificationJobMinutesInterval ?? 5;
            // Every 5 minutes
            RecurringJob.RemoveIfExists(nameof(PureNotificationServiceJob));
            RecurringJob.AddOrUpdate<PureNotificationServiceJob>(nameof(PureNotificationServiceJob),
                job => job.Run(JobCancellationToken.Null),
                $"*/{pureNotificationJobMinutesInterval} * * * *", TimeZoneInfo.Utc);

            // Всяка неделя в 2АМ
            string openDataSyncIntervalExpression = $"0 2 * * 0";
            RecurringJob.RemoveIfExists(nameof(OpenDataServiceJob));
            RecurringJob.AddOrUpdate<OpenDataServiceJob>(nameof(OpenDataServiceJob),
               job => job.Run(JobCancellationToken.Null), openDataSyncIntervalExpression, TimeZoneInfo.Utc);

        }
    }
}
