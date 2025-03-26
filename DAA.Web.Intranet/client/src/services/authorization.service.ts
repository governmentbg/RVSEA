import http from '@/services/http.service';
import { appStore } from '@/store/app';

class AuthorizationService {
    private url = appStore().getters.baseUrl + '/api/authorization';
  
    async getUserRoles() :Promise<Array<string>> {
        const response = await http.post(`${this.url}/roles`,null);
        return response.data.data;
    }
}

const authorizationService = new AuthorizationService()
export default authorizationService;