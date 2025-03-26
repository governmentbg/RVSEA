using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.FileUploadApp
{
    public class OperationResultModel
    {
        public bool Success { get; set; }
        public string? Message { get; set; }
        public static OperationResultModel SuccessResult()
        {
            return new OperationResultModel(true, null);
        }

        public OperationResultModel() { }

        public static OperationResultModel FailResult(string message)
        {
            return new OperationResultModel(false, message);
        }

        public OperationResultModel(bool success, string? message)
        {
            Success = success;
            Message = message;
        }
    }
}
