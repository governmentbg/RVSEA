using DAA.Models.FileUploadApp;
using MVsDotNetAMSIClient.Contracts;

namespace DAA.FileUtils
{
    [Serializable]
    public class AmsiNotAvailableException : Exception
    {
        public AmsiNotAvailableException() { }

        public AmsiNotAvailableException(string message)
            : base(message) { }

        public AmsiNotAvailableException(string message, Exception inner)
            : base(message, inner) { }
    }


    public static class AntivirusUtil
    {
        // https://github.com/MirekVales/MVsDotNetAMSIClient
        //scanResult
        //{MVsDotNetAMSIClient.Contracts.ScanResult}
        //    ContentInfo: {MVsDotNetAMSIClient.Contracts.ScanResultContentInfo}
        //    DetectionEngineInfo: {MVsDotNetAMSIClient.Contracts.ScanResultEngineInfo}
        //    DetectionResultInfo: {MVsDotNetAMSIClient.Contracts.ScanResultDetectionInfo}
        //    IsSafe: true
        //    Result: NotDetected
        //    ResultDetail: null
        //    TimeStamp: {12.11.2022 г. 14:08:08}

        //scanResult.ContentInfo
        //{MVsDotNetAMSIClient.Contracts.ScanResultContentInfo}
        //    ContentByteSize: 8965885
        //    ContentFileType: Unknown
        //    ContentHash: "4d2f089aa8d80c41351eeabfad88f8a7"
        //    ContentName: "D:\\Install\\novaPDF Professional Desktop  v7.2.351.rar"
        //    ContentType: File

        //scanResult.DetectionEngineInfo
        //{MVsDotNetAMSIClient.Contracts.ScanResultEngineInfo}
        //    ClientProcessAppName: "DAA.App.FileUpload (1480)"
        //    ClientProcessUsername: "KONTRAX\\sgenov"
        //    DetectionEngine: WindowsDefender
        //    EnvironmentMachineName: "SGENOV"
        //    EnvironmentOSDescription: "Microsoft Windows 10.0.19044"

        //scanResult.DetectionResultInfo
        //{MVsDotNetAMSIClient.Contracts.ScanResultDetectionInfo}
        //    ElapsedTime: {00:00:04.2420952}
        //    EngineResultDetail: null
        //    MalwareID: null
        //    ThreatLevel: 0

        // With test virus:
        
        //scanResult
        //{MVsDotNetAMSIClient.Contracts.ScanResult}
        //    ContentInfo: {MVsDotNetAMSIClient.Contracts.ScanResultContentInfo}
        //    DetectionEngineInfo: {MVsDotNetAMSIClient.Contracts.ScanResultEngineInfo}
        //    DetectionResultInfo: {MVsDotNetAMSIClient.Contracts.ScanResultDetectionInfo}
        //    IsSafe: false
        //    Result: IdentifiedAsMalware
        //    ResultDetail: null
        //    TimeStamp: {12.11.2022 г. 15:03:09}

        //scanResult.DetectionResultInfo
        //{MVsDotNetAMSIClient.Contracts.ScanResultDetectionInfo}
        //    ElapsedTime: {00:00:01.1350638}
        //    EngineResultDetail: {MVsDotNetAMSIClient.Contracts.WindowsDefenderDetail}
        //    MalwareID: 32768
        //    ThreatLevel: 1

        //scanResult.DetectionResultInfo.EngineResultDetail
        //{MVsDotNetAMSIClient.Contracts.WindowsDefenderDetail}
        //    CategoryID: 42
        //    CategoryName: "Virus"
        //    EngineVersion: "AM: 1.1.19800.4, NIS: 1.1.19800.4"
        //    EventID: 1116
        //    FWLink: "https://go.microsoft.com/fwlink/?linkid=37020&name=Virus:DOS/EICAR_Test_File&threatid=2147519003&enterprise=1"
        //    ProductVersion: "4.18.2210.6"
        //    SecurityIntelligenceVersion: "AV: 1.379.203.0, AS: 1.379.203.0, NIS: 1.379.203.0"
        //    SeverityID: 5
        //    SeverityName: "Severe"
        //    StatusCode: 1
        //    StatusDescription: ""
        //    ThreatID: "2147519003"
        //    ThreatName: "Virus:DOS/EICAR_Test_File"


        public static AntivirusResultModel Scan(string fileName)
        {
            //TODO: да се връща резултат и при успех - OperationResultModel

            // Test file
            //ScanResult scanResult = new MVsDotNetAMSIClient.Scan().String(EICARTestData.EICARZippedBase64, "TestFile");

            AntivirusResultModel result = new AntivirusResultModel();

            try
            {
                MVsDotNetAMSIClient.Scan scanClient = new();
                if (!scanClient.IsAvailable())
                {
                    result.Checked = false;
                    result.AntivirusEngineAvailable = false;
                    result.Message = "Грешка при проверка за вируси: AMSI интерфейсът не е достъпен.";
                }
                else
                {
                    result.AntivirusEngineAvailable = true;

                    ScanResult scanResult = scanClient.File(fileName);
                    result.EngineInfo = scanResult.DetectionEngineInfo?.DetectionEngine.ToString();

                    MVsDotNetAMSIClient.Contracts.Enums.DetectionResult[] scanErrorResults = new[]
                    {
                        MVsDotNetAMSIClient.Contracts.Enums.DetectionResult.Unknown,
                        //MVsDotNetAMSIClient.Contracts.Enums.DetectionResult.Clean,
                        //MVsDotNetAMSIClient.Contracts.Enums.DetectionResult.NotDetected,
                        MVsDotNetAMSIClient.Contracts.Enums.DetectionResult.BlockedByAdministrator,
                        //MVsDotNetAMSIClient.Contracts.Enums.DetectionResult.IdentifiedAsMalware,
                        MVsDotNetAMSIClient.Contracts.Enums.DetectionResult.FileBlocked,
                        MVsDotNetAMSIClient.Contracts.Enums.DetectionResult.FileRejected,
                        MVsDotNetAMSIClient.Contracts.Enums.DetectionResult.FileNotExists,
                        MVsDotNetAMSIClient.Contracts.Enums.DetectionResult.ApplicationError
                    };

                    if (scanErrorResults.Contains(scanResult.Result))
                    {
                        result.Checked = false;
                        result.Message = $"Грешка при проверка за вируси: {scanResult.Result} - {scanResult.ResultDetail}.";
                    }
                    else
                    {
                        result.Checked = true;

                        if (!scanResult.IsSafe)
                        {
                            string message = $"Файлът съдържа вирус! {scanResult.Result}, MalwareId: {scanResult.DetectionResultInfo?.MalwareID}";
                            IScanResultDetail? scanResultDetail = scanResult.DetectionResultInfo?.EngineResultDetail;
                            if (scanResultDetail != null && scanResultDetail is WindowsDefenderDetail)
                            {
                                message += $" ThreatName: {((WindowsDefenderDetail)scanResultDetail).ThreatName}";
                            }

                            result.IsVirus = true;
                            result.Message = message;
                        }
                        else
                        {
                            result.IsVirus = false;
                        }
                    }
                }

                result.Success = true;
            }
            catch (Exception e)
            {
                result.Success = false;
                result.Message = $"Грешка при проверка за вируси: {e.GetType()}-{e.Message}";
            }

            return result;
        }
    }
}
