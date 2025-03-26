using DAA.Data;
using DAA.Models.Archives;
using DAA.Models.Configuration;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;
using System.Text;
using System.Text.Json;

namespace DAA.Services.OpenData
{
    public class OpenDataService : BaseService, IOpenDataService
    {
        private readonly IHttpClientFactory _httpFactory;
        private readonly OpenDataSettings _settings;

        public OpenDataService(ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IOptions<OpenDataSettings> settingsConfig,
            IHttpClientFactory httpFactory)
            : base(context, localizer)
        {
            _settings = settingsConfig?.Value ?? throw new ArgumentNullException(nameof(settingsConfig), nameof(OpenDataSettings));
            _httpFactory = httpFactory ?? throw new ArgumentNullException(nameof(httpFactory));
        }

        public async Task<string> Sync(CancellationToken cancellationToken)
        {

            StringBuilder sb = new StringBuilder();
            sb.AppendLine(await SyncAudioVisualDocuments(cancellationToken));

            return sb.ToString();
        }

        private async Task<string> SyncAudioVisualDocuments(CancellationToken cancellationToken)
        {
            string? resourceUri = _settings.Datasets.FirstOrDefault(x => (x.Code ?? "").Equals("AudioVisualDocuments", StringComparison.OrdinalIgnoreCase))?.ResourceUri;
            if (string.IsNullOrWhiteSpace(resourceUri))
            {
                throw new ArgumentNullException(nameof(resourceUri));
            }

            var list = await _context.VApiPublicDigitalObjects
                .ToListAsync(cancellationToken);

            var data = new
            {
                api_key = _settings.ApiKey,
                resource_uri = resourceUri,
                extension_format = "json",
                data = new
                {
                    headers = new string[] {
                        "Код на архив",
                        "Име на архив",
                        "Номер на фонд",
                        "Номер на инвентарен опис",
                        "Номер на архивна единица",
                        "Дата на създаване",
                        "Създадено от",
                        "Номер на документ",
                        "Заглавие на документ",
                        "Приблизителна дата",
                        "Място на създаване",
                        "Описание",
                        "Име на файл",
                        "Файлов формат",
                        "Обем в МВ",
                    },
                    rows = list.Select(x => new
                    {
                        ArchiveCode = x.ArchiveCode.ToString(),
                        x.ArchiveName,
                        FundNumber = x.FundNumber ?? "",
                        InventoryNumber = x.InventoryNumber ?? "",
                        ArchivalEntityNumber = x.ArchivalEntityNumber ?? "",
                        CreatedOn = x.CreatedOn.HasValue ? x.CreatedOn.Value.ToLocalTime().ToString("dd.MM.yyyy HH:MM:ss") : "",
                        Creator = x.CreatedByDisplayName ?? "",
                        DocumentNumber = x.DocumentNumber ?? "",
                        Title = x.Title ?? "",
                        ApproxmateChronologicalScope = x.ApproxmateChronologicalScope ?? "",
                        Location = x.Location ?? "",
                        Description = x.Description ?? "",
                        SourceName = x.SourceName ?? "",
                        FileType = x.FileType ?? "",
                        FileSize = decimal.Round(x.FileSize / 1024, 2, MidpointRounding.AwayFromZero).ToString("0.00"),
                    })
                }
            };

            using StringContent jsonContent = new StringContent(JsonSerializer.Serialize(data), Encoding.UTF8, "application/json");
            using var httpClient = _httpFactory.CreateClient("openData");
            using HttpResponseMessage response = await httpClient.PostAsync("updateResourceData", jsonContent);
            string jsonResponse = await response.Content.ReadAsStringAsync();

            return jsonResponse;
        }
    }
}
