using System.Reflection;

namespace DAA.Extensions.DynamicLinq
{
    /// <summary>
    /// Represents a filter expression of the custom grid.
    /// </summary>
    public class Filter
    {
        /// <summary>
        /// Gets or sets the name of the sorted field (property). Set to <c>null</c> if the <c>Filters</c> property is set.
        /// </summary>
        public string? Field { get; set; }

        /// <summary>
        /// Gets or sets the filtering operator. Set to <c>null</c> if the <c>Filters</c> property is set.
        /// </summary>
        public string? Operator { get; set; }

        /// <summary>
        /// Gets or sets the filtering value. Set to <c>null</c> if the <c>Filters</c> property is set.
        /// </summary>
        public object? Value { get; set; }

        /// <summary>
        /// Gets or sets the filtering logic. Can be set to "or" or "and". Set to <c>null</c> unless <c>Filters</c> is set.
        /// </summary>
        public string? Logic { get; set; }

        /// <summary>
        /// Gets or sets the child filter expressions. Set to <c>null</c> if there are no child expressions.
        /// </summary>
        public IEnumerable<Filter>? Filters { get; set; }

        /// <summary>
        /// Mapping of custom grid filtering operators to Dynamic Linq
        /// </summary>
        private static readonly IDictionary<string, string> Operators = new Dictionary<string, string>
        {
            {"==", "=="},
            {"<", "<"},
            {">", ">"},
            {"/", "StartsWith"},
            {"~", "Contains"},
            {"lte", "<="},
            {"gte", ">="},
        };

        /// <summary>
        /// Get a flattened list of all child filter expressions.
        /// </summary>
        public IList<Filter> All()
        {
            var filters = new List<Filter>();
            Collect(filters);

            return filters;
        }

        private void Collect(IList<Filter> filters)
        {
            if (Filters != null && Filters.Any())
            {
                foreach (var filter in Filters)
                {
                    filter.Collect(filters);
                }
            }
            else
            {
                filters.Add(this);
            }
        }

        /// <summary>
        /// Converts the filter expression to a predicate suitable for Dynamic Linq e.g. "Field1 = @1 and Field2.Contains(@2)"
        /// </summary>
        /// <param name="filters">A list of flattened filters.</param>
        public string ToExpression(Type type, IList<Filter> filters)
        {
            if (Filters != null && Filters.Any())
            {
                return "(" + string.Join(" " + Logic + " ", Filters.Select(filter => filter.ToExpression(type, filters)).ToArray()) + ")";
            }

            int index = filters.IndexOf(this);
            Operators.TryGetValue(Operator, out string comparison);

            var typeProperties = type.GetRuntimeProperties();
            var currentPropertyType = typeProperties.FirstOrDefault(f => f.Name.Equals(Field, StringComparison.OrdinalIgnoreCase))?.PropertyType;


            if (comparison == "StartsWith" || comparison == "Contains")
            {
                if (currentPropertyType == typeof(string))
                    return string.Format("({0} != null && {0}.ToLower().{1}(@{2}))", Field, comparison, index);
                else
                    return string.Format("({0} != null && {0}.ToString().{1}(@{2}))", Field, comparison, index);
            }

            return string.Format("{0} {1} @{2}", Field, comparison, index);
        }

        /// <summary>
        /// Converts the filter expression to a predicate suitable for Dynamic Linq e.g. "Field1 = @1 and Field2.Contains(@2)"
        /// </summary>
        /// <param name="filters">A list of flattened filters.</param>
        public string ToExpressionTest(Type type, IList<Filter> filters)
        {
            if (Filters != null && Filters.Any())
            {
                return "(" + string.Join(" " + Logic + " ", Filters.Select(filter => filter.ToExpressionTest(type, filters)).ToArray()) + ")";
            }

            int index = filters.IndexOf(this);
            Operators.TryGetValue(Operator, out string comparison);


            var s = Field.Split('.');
            bool sortByField = s[0] == "field";

            if (sortByField)
            {
                string fieldId = s[1];
                string expr = $"Fields.FirstOrDefault(f => f.Id == {fieldId}).Value";
                Field = expr;
            }

            var typeProperties = type.GetRuntimeProperties();
            var currentPropertyType = typeProperties.FirstOrDefault(f => f.Name.Equals(Field, StringComparison.OrdinalIgnoreCase))?.PropertyType;


            if (comparison == "StartsWith" || comparison == "Contains")
            {
                return string.Format("({0} != null && {0}.{1}(@{2}))", Field, comparison, index);
            }

            return string.Format("{0} {1} @{2}", Field, comparison, index);
        }
    }
}
