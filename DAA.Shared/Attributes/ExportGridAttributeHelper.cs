using System.Reflection;

namespace DAA.Shared.Attributes
{
    public static class ExportGridAttributeHelper
    {
        public static MemberInfo? GetGridHeaderProperty<T>()
        {
            // Оригиналният код е закоментиран. Като тествах, той водеше до това заявката да не връща нищо.
            // За това скалъпих алтернативно решение за Where клаузата.
            MemberInfo? member = typeof(T)
                .GetProperties()
                .Where(p => //p.GetCustomAttributes(typeof(ExportGridAttribute), true)
                        (bool?)p.CustomAttributes.FirstOrDefault(x => x.AttributeType.Name == "ExportGridAttribute")?.ConstructorArguments[0].Value! == true
                        //.Where(ca => ((ExportGridAttribute)ca).IsColumnHeader)
                        //.Any()
                        )
                .FirstOrDefault();

            return member;
        }

        public static MemberInfo? GetGridColumnTypeProperty<T>()
        {
            MemberInfo? member = typeof(T)
                .GetProperties()
                .Where(p => //p.GetCustomAttributes(typeof(ExportGridAttribute), true)
                        (bool?)p.CustomAttributes.FirstOrDefault(x => x.AttributeType.Name == "ExportGridAttribute")?.ConstructorArguments[2].Value! == true
                        //.Where(ca => ((ExportGridAttribute)ca).IsColumnType)
                        //.Any()
                        )
                .FirstOrDefault();

            return member;
        }

        public static MemberInfo? GetGridDataProperty<T>()
        {
            MemberInfo? member = typeof(T)
                .GetProperties()
                .Where(p => //p.GetCustomAttributes(typeof(ExportGridAttribute), true)
                        (bool?)p.CustomAttributes.FirstOrDefault(x => x.AttributeType.Name == "ExportGridAttribute")?.ConstructorArguments[1].Value! == true
                        //.Where(ca => ((ExportGridAttribute)ca).IsColumnDataPropertyName)
                        //.Any()
                        )
                .FirstOrDefault();

            return member;
        }
    }
}
