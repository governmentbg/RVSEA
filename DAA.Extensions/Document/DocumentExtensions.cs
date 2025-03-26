
using DAA.Models.Documents;

namespace DAA.Extensions.Document
{
    public static class DocumentExtensions
	{
		public static IEnumerable<DocumentOfListDisplayModel> FilterByFilterString(this IEnumerable<DocumentOfListDisplayModel> query, string filterKeyWord)
		{
			return query
			  .Where(predicate => predicate.Title.ToLower().Contains(filterKeyWord.ToLower())).ToList();

		}
	}
}
