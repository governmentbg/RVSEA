using System.Collections.Generic;

namespace DAA.Services.ApplicationStore
{
    public class ApplicationStoreService : IApplicationStoreService
    {
        private Dictionary<string, string> _applicationBaseUrl = new();
        private Dictionary<string, string> _certificateEmail = new();

        public string? GetApplicationBaseUrl(string requestId)
        {
            if (_applicationBaseUrl.TryGetValue(requestId, out string? url))
            {
                return url;
            }

            return null;
        }

        public void SetApplicationBaseUrl(string requestId, string? url)
        {
            _applicationBaseUrl[requestId] = url!;
        }


        public string? GetEmail(string requestId)
        {
            if (_certificateEmail.TryGetValue(requestId, out string? email))
            {
                return email;
            }

            return null;
        } 

        public void SetEmail(string requestId, string? email)
        {
            _certificateEmail[requestId] = email!;
        }
        

        public void Clear(string requestId)
        {
            if (_applicationBaseUrl.ContainsKey(requestId))
            {
                _applicationBaseUrl.Remove(requestId);
            }
            
            if (_certificateEmail.ContainsKey(requestId))
            {
                _certificateEmail.Remove(requestId);
            }
        }
    }
}
