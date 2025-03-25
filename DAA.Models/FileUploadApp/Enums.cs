using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.FileUploadApp
{
    [JsonConverter(typeof(StringEnumConverter))]
    public enum ProcessKind 
    { 
        None, 
        Kmf, // КМФ
        Fund, // АВД
        Ed, // ЕА
        Raw // Груб опис
    }

    [JsonConverter(typeof(StringEnumConverter))]
    public enum FileKind { None, Master, Derivative, Demo }

    [JsonConverter(typeof(StringEnumConverter))]
    public enum FileActionType { None, Edit, Delete, Upload, UploadStop, Info, AddDerivative, AddDemo }

    public enum JobStatus { None, Idle, Running, StopSignalled, Stopped }

    public static class EnumUtil
    {
        public static CodeT ToEnum<CodeT>(this string text)
            where CodeT : struct
        {
            CodeT code;
            if (!Enum.TryParse(text, true, out code))
            {
                throw new FormatException(string.Format("Код {0} не се поддържа от enum {1}.", text, typeof(CodeT).Name));
            }
            return code;
        }
        public static CodeT? ToEnumNullable<CodeT>(this string? text)
            where CodeT : struct
        {
            if (!string.IsNullOrWhiteSpace(text))
            {
                return text.ToEnum<CodeT>();
            }
            else
            {
                return null;
            }
        }
    }
}
