using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.FileUtils
{
    public static class Consts
    {
        public static Dictionary<FileType, string> SupportedFileExtensions = new()
        {
            // ; накрая е съществена, търся по съвпадение на ".разширение;" защото иначе не различавам примерно разширенията doc и docx
            { FileType.DocumentHtml, "*.htm;*.html;"},
            { FileType.DocumentXml, "*.xml;"},
            { FileType.DocumentPdf, "*.pdf;"},
            { FileType.DocumentMs, "*.doc;*.xls;*.ppt;"},
            { FileType.DocumentMsX, "*.docx;*.xlsx;*.pptx;"},
            { FileType.Image, "*.tiff;*.png;*.jpg;*.jpeg;"},
            { FileType.Audio, "*.wave;*.wav;*.mp3;"},
            { FileType.Video, "*.mpg;*.mpeg2;*.mp4;*.avi;"},
            { FileType.Other, "*.rar;*.iso;*.txt;"},
        };
        public static bool IsImageExtension(string extension)
        {
            return SupportedFileExtensions[FileType.Image].Contains(extension.ToLower());
        }
    }
}
