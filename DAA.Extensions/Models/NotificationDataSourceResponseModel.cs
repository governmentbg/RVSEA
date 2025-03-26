using DAA.Extensions.DynamicLinq;

namespace DAA.Extensions.Models
{
    public class NotificationDataSourceResponseModel<T> : DataSourceResponseModel<T>
    {
        public int TotalUnseen { get; set; }
    }
}
