import { IComment } from '@/interfaces/comment';
import { CommentModel } from '@/models/comment';
import http from '@/services/http.service';
import { appStore } from '@/store/app';

class CommentsService {
    private url = appStore().getters.baseUrl + '/api/comments'

    async getAll(processId: number, procedureStepId: number): Promise<IComment[]> {
        const response = await http.get(`${this.url}/getAll/${processId}/${procedureStepId}`);
        return response.data.data;
    }

    async getCommentsByStandpoint(standpointId: number): Promise<IComment[]> {
        const response = await http.get(`${this.url}/standpoint/${standpointId}`);
        return response.data.data;
    }

    async getComment(id: number): Promise<IComment> {
        const response = await http.get(`${this.url}/${id}`);
        return response.data.data;
    }

    async createComment(data: CommentModel) {
        const response = await http.post(`${this.url}`, data);
        return response.data.data;
    }

    async updateComment(data: CommentModel) {
        const response = await http.put(`${this.url}`, data);
        return response.data.data;
    }
    
    async deleteComment(id: number) {
        const response = await http.delete(`${this.url}/${id}`);
        return response;
    }
}

const commentService = new CommentsService()
export default commentService
