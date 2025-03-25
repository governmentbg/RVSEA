using System.Linq.Expressions;

namespace DAA.Extensions.DynamicLinq
{
    public class OrderByStringWithReflection
    {
        //A Method that receives collection, propertyName as a string and bool if it is going to be sorted descending.
        //It gets the object type, then gets the object property by which we want to order, sets it to the model, and finally creates the expression: model => model.Property
        public static IOrderedQueryable<T> OrderBy<T>(IQueryable<T> source, string propertyName, bool sortDesc)
        {
            return !sortDesc ?
                source.OrderBy(ToLambda<T>(propertyName)) :
                source.OrderByDescending(ToLambda<T>(propertyName));
        }

        public static Expression<Func<T, object>> ToLambda<T>(string propertyName)
        {
            //Getting object type
            var parameter = Expression.Parameter(typeof(T));
            //Getting object property
            var property = Expression.Property(parameter, propertyName);
            //Setting correct property to Model
            var propAsObject = Expression.Convert(property, typeof(object));
            //Creating the expression model => model.Property
            var exp = Expression.Lambda<Func<T, object>>(propAsObject, parameter);

            return exp;
        }
    }
}
