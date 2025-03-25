import { IArchive } from '@/interfaces/archive';
import http from '@/services/http.service';
import { appStore } from '@/store/app';

class ArchiveService {
    private url = appStore().getters.baseUrl + '/api/archives';

    getArchivesUrl(): string {
        return `${this.url}/listall`;
    }
    async displayArchive(id: number): Promise<IArchive> {
        const response = await http.get(`${this.url}/${id}`);
        return response.data.data;
    }
    async createArchive(data: IArchive) {
        const response = await http.post(`${this.url}`, data);
        return response;
    }
    async updateArchive(data: IArchive) {
        const response = await http.put(`${this.url}`, data);
        return response;
    }
    async deleteArchive(id: number) {
        const response = await http.delete(`${this.url}/${id}`);
        return response;
    }
    async getArchivesFromExternalSource(searchText: string) {
        const response = await http.get(`${this.url}/external?searchText=${searchText}`);
        return response.data.data;
    }
    async getDiroctorNameByArchiveId(id: number) {
        const response = await http.get(`${this.url}/getArchiveDirectorName?id=${id}`);
        return response.data.data;
    }
}

const archiveService = new ArchiveService();
export default archiveService;
