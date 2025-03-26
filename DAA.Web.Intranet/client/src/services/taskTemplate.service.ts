import { ITaskTemplate, TaskTemplateCreateModel, TaskTemplateUpdateModel } from "@/models/taskTemplate"
import http from "@/services/http.service";
import { appStore } from "@/store/app";

class TaskTemplateService {
	private url = appStore().getters.baseUrl + "/api/TaskTemplates";

	get(id: number): Promise<ITaskTemplate[]> {
		return http.get(`${this.url}/${id}`).then(response => response.data.data);
	}

    create(data: TaskTemplateCreateModel): Promise<number> {
		return http.post(`${this.url}`, data).then(response => response.data.data);
	}

	update(data: TaskTemplateUpdateModel) {
		return http.put(`${this.url}`, data).then(response => response.data.data);
	}

	getTemplate(id: number): Promise<ITaskTemplate> {
		return http.get(`${this.url}/template/${id}`).then(response => response.data.data);
	}
}

const taskTemplateService = new TaskTemplateService();
export default taskTemplateService;
