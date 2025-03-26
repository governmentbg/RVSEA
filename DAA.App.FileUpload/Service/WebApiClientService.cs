using DAA.Models.Configuration;
using DAA.Models.FileUploadApp;
using DAA.Models.Identity;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Security.Policy;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using System.Web;
using static System.Net.WebRequestMethods;

namespace DAA.App.FileUpload.Service
{
    public static class WebApiClientService
    {
        private static bool _useWindowsAuthentication = true;
        private static string? _userName;
        private static string? _password;

        [Obsolete]
        private static HttpClient? _client;
        private static HttpClient Client
        {
            get
            {
#pragma warning disable CS0612 // Obsolete
                if (_client == null)
                {
                    Uri uri = new Uri(Settings.WebServiceBaseAddress);
                    CredentialCache credentialCache = new CredentialCache();
                    if (!_useWindowsAuthentication)
                    {
                        credentialCache.Add(uri, "Negotiate", new NetworkCredential(_userName, _password));
                    }
                    _client = new HttpClient(new HttpClientHandler()
                    {
                        PreAuthenticate = true,
                        Credentials = credentialCache,

                        // Windows Authentication
                        UseDefaultCredentials = _useWindowsAuthentication,
                    })
                    {
                        BaseAddress = uri,
                        Timeout = TimeSpan.FromSeconds(600),
                    };
                }
                return _client;
            }
            set
            {
                _client = value;
#pragma warning restore CS0612 // Obsolete
            }
        }

        private static string? _token;
        public static async Task<bool> Authenticate()
        {
            if (await AuthenticateHelp())
            {
                AuthorizeResultModel result = await GetModel<AuthorizeResultModel>(Settings.AuthorizeUrl, null);
                if (result.Success)
                {
                    Settings.CanQueueEd = true; // result.CanQueueEd;
                    Settings.CanQueueFund = true; // result.CanQueueFund;
                    Settings.CanQueueKmf = true; // result.CanQueueKmf;
                    Settings.CanQueueRaw = true; // result.CanQueueRaw;
                    Settings.AppSettings = result.AppSettings;
                    return true;
                }
            }
            return false;
        }

        private static async Task<bool> AuthenticateHelp()
        {
            _useWindowsAuthentication = true;
            AuthenticateResultModel? result = null;
            try
            {
                // в продукионна среда има някакъв проблем - за Unauthorized се чака около 2+ минути, затова директно ще искам име и парола
                throw new UnauthorizedAccessException();
                //result = await PostModel<QueueItemModel/*произволен тип, ще подавам null*/, AuthenticateResultModel>(Settings.AuthenticateUrl, null);
            }
            catch (UnauthorizedAccessException)
            {
                LoginForm loginForm = new LoginForm();
                if (Settings.WebServiceBaseAddress.Contains("apptest.kontrax.bg"))
                {
                    loginForm.usernameTextBox.Text = Settings.UserNameAppTest;
                    loginForm.passwordTextBox.Text = Settings.PasswordAppTest;
                }
                if (Settings.WebServiceBaseAddress.Contains("localhost"))
                {
                    loginForm.usernameTextBox.Text = Settings.UserNameLocalhost;
                    loginForm.passwordTextBox.Text = Settings.PasswordLocalhost;
                }
                if (loginForm.ShowDialog() == DialogResult.OK)
                {
                    // нулирам клиента, за да се създаде нов, който да се автентицира с име и парола, а не с WindowsAuth
                    //TODO:  да се записва в променлива, че клиентът трябва да се пресъздаде или да се изнесе клиентът в отделен клас
#pragma warning disable CS0612 // Obsolete
                    _client = null;
#pragma warning restore CS0612 // Obsolete
                    _useWindowsAuthentication = false;
                    _userName = loginForm.usernameTextBox.Text;
                    _password = loginForm.passwordTextBox.Text;

                    try
                    {
                        result = await PostModel<QueueItemModel/*произволен тип, ще подавам null*/, AuthenticateResultModel>(Settings.AuthenticateUrl, null);
                    }
                    catch
                    {
                        // по-надолу се проверява result и връща false
                        //return false;
                    }
                }
            }

            if (result != null && result.Success)
            {
                _token = result.Data?.Token;
                return true;
            }
            else
            {
                return false;
            }
        }

        public static async Task<string[]> GetAllowedFileExtensions()
        {
            return (await GetModel<GetExtensionsResultModel>(Settings.GetExtensionsUrl, null)).Items;
        }

        public static async Task<QueueItemModel[]> ListQueue(string computerName)
        {
            return (await GetModel<ListQueueResultModel>(
                Settings.ListQueueUrl,
                new KeyValuePair<string, string?>[]
                {
                    new (nameof(computerName), computerName)
                })
            ).Items;
        }
        public static async Task<bool> DocumentExists(ProcessKind? processKind, Guid? documentId)
        {
            _ = processKind ?? throw new ArgumentNullException(nameof(processKind));
            _ = documentId ?? throw new ArgumentNullException(nameof(documentId));

            return (await GetModel<DocumentExistsResultModel>(
                Settings.DocumentExistsUrl,
                new KeyValuePair<string, string?>[]
                {
                    new (nameof(processKind), processKind.Value.ToString()),
                    new (nameof(documentId), documentId.Value.ToString())
                })
            ).Exists;
        }
        public static async Task<bool> FileExists(ProcessKind? processKind, FileKind? fileKind, Guid? documentId, int? currentQueueId, string fileName)
        {
            _ = processKind ?? throw new ArgumentNullException(nameof(processKind));
            _ = documentId ?? throw new ArgumentNullException(nameof(documentId));

            return (await GetModel<DocumentExistsResultModel>(
                Settings.FileExistsUrl,
                new KeyValuePair<string, string?>[]
                {
                    new (nameof(processKind), processKind.Value.ToString()),
                    new (nameof(fileKind), fileKind != null ? fileKind.Value.ToString() : ""),
                    new (nameof(documentId), documentId.Value.ToString()),
                    new (nameof(currentQueueId), currentQueueId.ToString()),
                    new (nameof(fileName), fileName),
                })
            ).Exists;
        }


        public static async Task<CodeNameModel[]> MastersForDocument(Guid? documentId)
        {
            _ = documentId ?? throw new ArgumentNullException(nameof(documentId));

            return (await GetModel<MastersForDocumentResultModel>(
                Settings.MastersForDocumentUrl,
                new KeyValuePair<string, string?>[]
                {
                    new (nameof(documentId), documentId.Value.ToString())
                })
            ).Items;
        }

        public static async Task<AddToQueueResultModel> AddToQueue(QueueItemModel model)
        {
            return await PostModel<QueueItemModel, AddToQueueResultModel>(Settings.AddToQueueUrl, model);
        }

        public static async Task<AddToQueueResultModel> UpdateQueue(QueueItemModel model)
        {
            return await PostModel<QueueItemModel, AddToQueueResultModel>(Settings.UpdateQueueUrl, model);
        }

        public static async Task<OperationResultModel> DeleteFromQueue(int id)
        {
            return await PostModel<QueueItemIdModel, OperationResultModel>(Settings.DeleteFromQueueUrl, new QueueItemIdModel(id));
        }

        public static async Task<QueueItemResultModel> ValidateAndFinish(int queueItemId)
        {
            return await PostModel<QueueItemIdModel, QueueItemResultModel>(Settings.ValidateAndFinishUrl, new QueueItemIdModel(queueItemId));
        }


        public static async Task<bool> UploadFile/*WBuffer*/(int queueItemId, string filenameWPath, string remoteFileName, long fromPosition, Func<UploadProgressModel, Task<bool>> onProgress)
        {
            const int bufferSize = 10 * 1024 * 1024;
            byte[] buffer = new byte[bufferSize];
            FileStream file = System.IO.File.OpenRead(filenameWPath);

            long offset = fromPosition;
            file.Seek(offset, SeekOrigin.Begin);

            int bytesRead = file.Read(buffer, 0, buffer.Length);
            while (bytesRead != 0)
            {

                ByteArrayContent byteArrayContent = new ByteArrayContent(buffer, 0, bytesRead);
                byteArrayContent.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");

                MultipartFormDataContent content = new MultipartFormDataContent
                {
                    { new StringContent(queueItemId.ToString()), "id" },
                    { new StringContent(offset.ToString()), "offset" },
                    { new StringContent(bytesRead.ToString()), "length" },
                    { byteArrayContent, "file", remoteFileName },
                };
                HttpResponseMessage response = await Client.PostAsync(Settings.UploadFileUrl, content);
                await HandleResponse<OperationResultModel>(response);

                offset += bytesRead;

                UploadProgressModel progressModel = new()
                {
                    Id = queueItemId,
                    Position = offset,
                    Status = JobStatus.Running
                };
                if (!await onProgress(progressModel))
                {
                    progressModel.Status = JobStatus.Stopped;
                    await onProgress(progressModel);
                    break;
                }

                bytesRead = file.Read(buffer, 0, buffer.Length);
            }

            return true;
        }

        public static async Task<bool> UploadFileAll(string filename)
        {
            //const int bufferSize = 10240000;
            //byte[] buffer = new byte[bufferSize];
            string requestUri = "/api/DigitalObjects/upload";
            FileStream file = System.IO.File.OpenRead(filename);
            StreamContent streamContent = new StreamContent(file);

            // MediaTypeHeaderValue.Parse("multipart/form-data");
            // new MediaTypeHeaderValue("multipart/form-data"); -> не се bind-ва на сървъра - Bad Request
            streamContent.Headers.ContentType = MediaTypeHeaderValue.Parse("multipart/form-data");
            ByteArrayContent byteArrayContent = new ByteArrayContent(new byte[] { });
            MultipartFormDataContent content = new MultipartFormDataContent
            {
                { new StringContent(0.ToString()), "offset" },
                { new StringContent(file.Length.ToString()), "length" },
                {  streamContent, "file", Path.GetFileName(filename) },
            };

            content.Headers.ContentType = MediaTypeHeaderValue.Parse("multipart/form-data");
            content.Headers.ContentDisposition = new ContentDispositionHeaderValue("form-data");

            HttpResponseMessage response = await Client.PostAsync(requestUri, streamContent);
            //using var request = new HttpRequestMessage(HttpMethod.Post, requestUri)
            //{
            //    Content = content
            //};
            //request.Headers.ExpectContinue = true;
            //HttpResponseMessage response = await client.SendAsync(request);
            //HttpResponseMessage response = await client.PostAsync(requestUri, content);
            response.EnsureSuccessStatusCode();



            //using MemoryStream ms = new MemoryStream();
            //ms.SetLength(bufferSize);
            //long offset = 0;
            //while (file.Position < file.Length)
            //{
            //    file.CopyTo(ms, bufferSize);
            //    ms.Position = 0;
            //    MultipartFormDataContent content = new MultipartFormDataContent
            //    {
            //        { new StringContent(offset.ToString()), "offset" },
            //        { new StringContent(ms.Length.ToString()), "length" },
            //        { new StreamContent(ms), "file", Path.GetFileName(filename) },
            //    };
            //    HttpResponseMessage response = await client.PostAsync(requestUri, null);
            //    response.EnsureSuccessStatusCode();

            //    offset += ms.Length;
            //    ms.Position = 0;
            //    ms.SetLength(0);
            //}

            return true;
        }

        private static async Task<TResult> GetModel<TResult>(string actionUrl, KeyValuePair<string, string?>[]? parameters)
            where TResult : OperationResultModel
        {
            try
            {
                NameValueCollection query = HttpUtility.ParseQueryString(string.Empty);
                if (parameters != null)
                {
                    foreach (KeyValuePair<string, string?> parameter in parameters)
                    {
                        query[parameter.Key] = parameter.Value;
                    }
                }
                UriBuilder uriBuilder = new UriBuilder(Client.BaseAddress + actionUrl);
                uriBuilder.Query = query.ToString();
                string url = uriBuilder.ToString();

                HttpResponseMessage response = await Client.GetAsync(url);
                return await HandleResponse<TResult>(response);
            }
            catch (Exception e)
            {
                throw new Exception($"GetModel({actionUrl}) {e.Message}", e);
            }
        }

        private static async Task<TResult> PostModel<TModel, TResult>(string url, TModel? model)
            where TResult : OperationResultModel, new()
        {
            try
            {
                // това правело chunked request, който може би? не се поддържа от webapi контролера ми
                //HttpResponseMessage response = await Client.PostAsJsonAsync(url, model);
                StringContent? content = null;
                if (model != null)
                {
                    string jsonStr = JsonConvert.SerializeObject(model);
                    content = new StringContent(jsonStr, Encoding.UTF8, "application/json");
                }
                HttpResponseMessage response = await Client.PostAsync(url, content);
                return await HandleResponse<TResult>(response);
            }
            //catch (UnauthorizedAccessException e)
            catch (Exception e) when (e is UnauthorizedAccessException || e is TaskCanceledException)
            {
                throw new UnauthorizedAccessException($"PostModel({url}) {e.Message}", e);
            }
            catch (Exception e)
            {
                //throw new Exception($"PostModel({url}) {e.Message}", e);
                return new TResult()
                {
                    Success = false,
                    Message = $"PostModel({url}) {e.Message}"
                };
            }
        }

        private static async Task<TResult> HandleResponse<TResult>(HttpResponseMessage response)
            where TResult : OperationResultModel
        {
            if (!response.IsSuccessStatusCode)
            {
                string errorMessage = await response.Content.ReadAsStringAsync();
                throw response.StatusCode == HttpStatusCode.Unauthorized ?
                    new UnauthorizedAccessException() :
                    new Exception($"{response.StatusCode}: {errorMessage}");
            }
            string resultStr = await response.Content.ReadAsStringAsync();
            TResult? result = Newtonsoft.Json.JsonConvert.DeserializeObject<TResult>(resultStr) ??
                throw new Exception($"Грешка при десериализиране на отговора: {resultStr}.");
            if (!result.Success)
            {
                throw new Exception($"Върнат резултат неуспех: {result.Message}");
            }

            return result;
        }
    }
}
