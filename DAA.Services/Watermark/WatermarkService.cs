using DAA.Data;
using DAA.FileUtils;
using DAA.Services.Files;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System.Drawing.Imaging;

namespace DAA.Services.Watermark
{

    public class WatermarkService : BaseService, IWatermarkService
    {
        private readonly IFileService _fileService;

        public WatermarkService(
            IFileService fileService,
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer = null, ILogger logger = null)
            : base(context, localizer, logger)
        {
            _fileService = fileService;
        }

        public async Task<Tuple<string, string>> AddWatermark(IFormFile model, string systemFileName)
        {
            if (Consts.IsImageExtension(Path.GetExtension(model.FileName)))
            {
                MemoryStream srcStream = new();
                MemoryStream stream = new();

                await model.CopyToAsync(srcStream);
                string fileExt = Path.GetExtension(model.FileName);
                string fileName = Path.GetFileNameWithoutExtension(systemFileName);

                //TODO Да се добави всички ползвани формати..
                switch (fileExt)
                {
                    case ".png":
                        WatermarkUtil.AddWatermark(srcStream, stream, ImageFormat.Png);
                        break;
                    case ".jpeg":
                        WatermarkUtil.AddWatermark(srcStream, stream, ImageFormat.Jpeg);
                        break;
                    case ".tiff":
                        WatermarkUtil.AddWatermark(srcStream, stream, ImageFormat.Tiff);
                        break;
                    default:
                        // da se izbere defalt 
                        WatermarkUtil.AddWatermark(srcStream, stream, ImageFormat.Png);
                        break;
                }

                try
                {
                    string watermarkFileName = Path.GetFileNameWithoutExtension(fileName) + $".wm.{fileExt}";
                    stream.Position = 0;
                    string watermarkUncPath = (string)(await _fileService.UploadFileAsync(watermarkFileName, stream, 0)).Data!;

                    return new Tuple<string, string>(watermarkFileName, watermarkUncPath);
                }
                catch (Exception)
                {
                    throw new Exception(_localizer.GetString("Error_ExecutingAction"));
                }
            }
            else
            {
                // защо е необходимо да се хвърля грешка тук, при това самата тя с грешен текст?
                //throw new Exception(_localizer.GetString("Error_FileFormatCheckResult"));
                return null;
            }
        }
    }
}
