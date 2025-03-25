import { IDataTableOptions } from "@/interfaces/dataTable";
import { IUINotification } from "@/interfaces/notification";
import http from "@/services/http.service";
import { appStore } from "@/store/app";

class NotificationService {
    private url = appStore().getters.baseUrl + "/api/notifications";

    async list(data: IDataTableOptions) {
        const response = await http.post(`${this.url}/list`, data);
        return response.data;
    }

    async markAsSeen(id: number) {
        const response = await http.put(`${this.url}/markAsSeen/${id}`, null);
        return response;
      }

    async getUnseenNotifications() : Promise<IUINotification[]> {
        const response = await http.get(`${this.url}/getUnseenNotifications`);
        return response.data.data;
    }
}

const service = new NotificationService();
export default service;
