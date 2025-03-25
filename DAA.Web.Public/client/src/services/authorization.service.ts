import http from '@/services/http.service';
import { appStore } from '@/store/app';

class AuthorizationService {
    private url = appStore().getters.baseUrl + '/api/authorization';

    async authorizeAdmin() : Promise<boolean> {
        const response = await http.post(`${this.url}/admin/authorize`, null);
        return response.data;
    }   

    async authorize(model: any) : Promise<boolean> {
            const response = await http.post(`${this.url}/authorize`, model);
            return response.data;
    }
}

const authorizationService = new AuthorizationService()
export default authorizationService;