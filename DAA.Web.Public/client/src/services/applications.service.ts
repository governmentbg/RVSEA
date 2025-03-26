import { ApplicationCreateModel } from '@/models/applications';
import http from '@/services/http.service';
import { appStore } from '@/store/app';

class ApplicationService {
    private url = appStore().getters.baseUrl + '/api/applications';

    create(application: ApplicationCreateModel): Promise<boolean> {
        return http.post(this.url, application);
    }

    get(id: number) {
        return http.get(`${this.url}/${id}`);
    }

    delete(id: number) {
        return http.delete(`${this.url}/${id}`);
    }
}

const applicationService = new ApplicationService();
export default applicationService;
