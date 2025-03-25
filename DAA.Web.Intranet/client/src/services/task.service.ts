import { ITask } from '@/interfaces/task';
import http from '@/services/http.service';
import { appStore } from '@/store/app';
import { GridOptions } from '@/models/grid';

class TaskService {
    private url = appStore().getters.baseUrl + '/api/tasks';

    getMyTasksUrl(): string {
        return `${this.url}/my`;
    }

    async getMy(options: GridOptions) {
        const url = new URL(`${this.url}/my`);
        const response = await http.post(url.toString(), options);
        return response.data.data;
    }

    getAssignedByMeUrl(): string {
        return `${this.url}/assignedByMe`;
    }

    async display(taskId: number): Promise<ITask> {
        const response = await http.get(`${this.url}/${taskId}`);
        return response.data.data;
    }

    async getMyNewTasksCount() {
        const response = await http.get(`${this.url}/getMyNewTasksCount`);
        return response.data.data;
    }

    // async cancel(taskId: number) {
    //   const response = await http.delete(`${this.url}/${taskId}`);
    //   return response;
    // }
}

const taskService = new TaskService();
export default taskService;
