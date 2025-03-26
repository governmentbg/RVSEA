using DAA.Models;
using System.Linq.Dynamic.Core;

namespace DAA.Extensions.DynamicLinq
{
    public static class QueryableExtensions
    {
        public static IQueryable<T> Filter<T>(IQueryable<T> queryable, Filter filter, List<object> errors)
        {
            if (filter != null && filter.Logic != null)
            {
                // Pretreatment some work
                filter = PreliminaryWork(filter);

                // Collect a flat list of all filters
                var filters = filter.All().Where(x => x.Value != null).ToList();
                if (!filters.Any())
                {
                    return queryable.Where(x => false); // return nothing
                }

                // Get all filter values as array (needed by the Where method of Dynamic Linq)
                // Set values to lower case. Needed for case invariant text search

                var values = filters.Select(f => f.Value).ToArray();
                for (int i = 0; i < values.Length; i++)
                {
                    if (values[i] == null)
                    {
                        continue;
                    }

                    if (values[i].GetType() == typeof(string))
                    {
                        values[i] = values[i].ToString().ToLower();
                    }

                }

                string predicate;
                try
                {
                    // Create a predicate expression e.g. Field1 = @0 And Field2 > @1
                    predicate = filter.ToExpression(typeof(T), filters);
                }
                catch (Exception ex)
                {
                    errors.Add(ex.Message);
                    return queryable;
                }

                //predicate = "((name != null && name.ToLower().Contains(@0)))";
                // Use the Where method of Dynamic Linq to filter the data
                queryable = queryable.Where(predicate, values);
            }

            return queryable;
        }


        public static IQueryable<T> FilterWithFields<T>(IQueryable<T> queryable, Filter filter, List<object> errors)
        {
            if (filter != null && filter.Logic != null)
            {
                // Pretreatment some work
                filter = PreliminaryWork(filter);

                // Collect a flat list of all filters
                var filters = filter.All().Where(x => x.Value != null).ToList();

                // Get all filter values as array (needed by the Where method of Dynamic Linq)
                // Set values to lower case. Needed for case invariant text search

                var values = filters.Select(f => f.Value).ToArray();
                for (int i = 0; i < values.Length; i++)
                {
                    if (values[i] == null)
                    {
                        continue;
                    }

                    if (values[i].GetType() == typeof(string))
                    {
                        values[i] = values[i].ToString().ToLower();
                    }

                }

                string predicate;
                try
                {
                    // Create a predicate expression e.g. Field1 = @0 And Field2 > @1
                    predicate = filter.ToExpressionTest(typeof(T), filters);
                }
                catch (Exception ex)
                {
                    errors.Add(ex.Message);
                    return queryable;
                }

                //predicate = "((name != null && name.ToLower().Contains(@0)))";
                // Use the Where method of Dynamic Linq to filter the data
                queryable = queryable.Where(predicate, values);
            }

            return queryable;
        }

        /// <summary>
        /// Pretreatment of specific datetime condition and disallowed value type 
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        private static Filter PreliminaryWork(Filter filter)
        {
            if (filter.Filters != null && filter.Filters.Count() > 0 && filter.Logic != null)
            {
                var newFilters = new List<Filter>();
                foreach (var f in filter.Filters)
                {
                    newFilters.Add(PreliminaryWork(f));
                }

                filter.Filters = newFilters;
            }

            // Used when the datetime's operator value is eq and local time is 00:00:00 
            if (filter.Value is System.DateTime utcTime && filter.Operator == "==")
            {
                // Copy the time from the filter
                //var datetimeValue = utcTime.ToLocalTime();
                var datetimeValue = utcTime;
                var localDatetimeValue = utcTime.ToLocalTime();
                if (localDatetimeValue.Date < datetimeValue.Date)
                {
                    localDatetimeValue = datetimeValue;
                }


                //Филтърът е само по дата. Филтрираме всички за дадената дата т.е   >= date && < date.AddDays(1)
                var newFilter = new Filter { Logic = "and" };
                var filtersList = new List<Filter>
                {
                    // Instead of comparing for exact equality, we compare as greater than the start of the day...
                    new Filter
                    {
                        Field = filter.Field,
                        Filters = filter.Filters,
                        Value = new System.DateTime(datetimeValue.Year, datetimeValue.Month, datetimeValue.Day, 0, 0, 0),
                        Operator = "gte"
                    },
                    // ...and less than the end of that same day (we're making an additional filter here)
                    new Filter
                    {
                        Field = filter.Field,
                        Filters = filter.Filters,
                        Value = new System.DateTime(localDatetimeValue.Year, localDatetimeValue.Month, localDatetimeValue.Day, 23, 59, 59),
                        Operator = "lte"
                    }
                };

                newFilter.Filters = filtersList;

                return newFilter;
            }


            // When we have a decimal value it gets converted to double and the query will break
            if (filter.Value is double)
            {
                filter.Value = Convert.ToDecimal(filter.Value);
            }

            return filter;
        }


        /// <summary>
        /// Applies data processing (paging, sorting, filtering) over IQueryable using Dynamic Linq.
        /// </summary>
        /// <typeparam name="T">The type of the IQueryable.</typeparam>
        /// <param name="queryable">The IQueryable which should be processed.</param>
        /// <param name="take">Specifies items per page.</param>
        /// <param name="page">Specifies the wanted page.</param>
        /// <param name="sortBy">Specifies field to sort by.</param>
        /// <param name="sortDesc">True if sort is descending</param>
        /// <param name="filter">Specifies the current filter.</param>
        /// <returns>A DataSourceResponseModel object populated from the processed IQueryable.</returns>
        public static QueryResponseModel<T> ToQueryResult<T>(this IQueryable<T> queryable, int take, int page, string sortBy, bool sortDesc, Filter filter)
        {
            var errors = new List<object>();

            // Filter the data 
            if (filter != null && filter.Filters.Count() > 0)
                queryable = Filter(queryable, filter, errors);

            // Sort the data
            queryable = Sort(queryable, sortBy, sortDesc);

            // Calculate the total number of records (needed for paging)            
            var total = queryable.Count();

            // Finally page the data
            if (take > 0)
            {
                queryable = Page(queryable, take, page);
            }

            var result = new QueryResponseModel<T>
            {
                TotalCount = total,
                Query = queryable
            };

            //Set errors if any
            if (errors.Any())
            {
                result.Errors = errors;
            }

            return result;
        }


        public static QueryResponseModel<T> ToQueryResultWithFields<T>(this IQueryable<T> queryable, int take, int page, string sortBy, string sortByType, bool sortDesc, Filter filter)
        {
            var errors = new List<object>();

            // Filter the data 
            if (filter != null && filter.Filters.Count() > 0)
                queryable = FilterWithFields(queryable, filter, errors);

            // Sort the data
            queryable = SortWithFields(queryable, sortBy, sortByType, sortDesc);

            // Calculate the total number of records (needed for paging)            
            var total = queryable.Count();

            // Finally page the data
            if (take > 0)
            {
                queryable = Page(queryable, take, page);
            }

            var result = new QueryResponseModel<T>
            {
                TotalCount = total,
                Query = queryable
            };

            //Set errors if any
            if (errors.Any())
            {
                result.Errors = errors;
            }

            return result;
        }

        private static IQueryable<T> Page<T>(IQueryable<T> queryable, int take, int page)
        {
            return queryable.Skip((page - 1) * take).Take(take);
        }

        private static IQueryable<T> Sort<T>(IQueryable<T> queryable, string sortBy, bool sortDesc)
        {
            if (!String.IsNullOrWhiteSpace(sortBy))
                return OrderByStringWithReflection.OrderBy(queryable, sortBy, sortDesc);
            else
                return queryable;
        }

        private static IQueryable<T> SortWithFields<T>(IQueryable<T> queryable, string sortBy, string sortByType, bool sortDesc)
        {
            if (!String.IsNullOrWhiteSpace(sortBy))
            {
                var s = sortBy.Split('.');
                bool sortByField = s[0] == "field";

                if (sortByField)
                {
                    string fieldId = s[1];
                    string expr = $"x => x.Fields.FirstOrDefault(f => f.Id == {fieldId}).Value";
                    switch (sortByType)
                    {
                        case "date":
                            expr = $"x => x.Fields.FirstOrDefault(f => f.Id == {fieldId}).ValueDate";
                            break;
                        case "boolean":
                            expr = $"x => x.Fields.FirstOrDefault(f => f.Id == {fieldId}).ValueBool";
                            break;
                        default:
                            break;
                    }
                    return sortDesc ? queryable.OrderBy($"{expr} DESC") : queryable.OrderBy(expr);
                }

                return OrderByStringWithReflection.OrderBy(queryable, sortBy, sortDesc);
            }
            else
                return queryable;
        }

        public static QueryResponseModel<T> SortAndFilter<T>(this IQueryable<T> listQuery, DataSourceRequestModel request)
        {
            QueryResponseModel<T> result = listQuery.ToQueryResult(request.ItemsPerPage, request.Page, request.SortBy, request.SortDesc, request.Filter);
            return result;
        }

        public static QueryResponseModel<T> SortAndFilterWithFields<T>(this IQueryable<T> listQuery, DataSourceRequestModel request)
        {
            QueryResponseModel<T> result = listQuery.ToQueryResultWithFields(request.ItemsPerPage, request.Page, request.SortBy, request.SortByType, request.SortDesc, request.Filter);

            return result;
        }

    }
}
