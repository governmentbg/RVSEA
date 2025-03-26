/* eslint-disable @typescript-eslint/no-explicit-any */
import { IUserInfo, IRegistrationReaderModel, IChangeUserPassword } from '@/interfaces/userInfo';
import { DataTable } from '@/models/dataTable';
import http from '@/services/http.service';
import { appStore } from '@/store/app';

class UserService {
    private url = appStore().getters.baseUrl + '/api/users';

    getUsersUrl(): string {
        return `${this.url}/list`;
    }
    getAdminsUrl(): string {
        return `${this.url}/admins/list`;
    }
    getAllUsersUrl(): string {
        return `${this.url}/listall`;
    }
    getAllAdminsUrl(): string {
        return `${this.url}/admins/listall`;
    }
    getUsersByTypeUrl(userType: string) {
        return `${this.url}/list/${userType}`;
    }
    getUsersByProfileTypeUrl(profileType: string) {
        return `${this.url}/list/profileType/${profileType}`;
    }
    async allUsers(model: any): Promise<DataTable<IUserInfo>> {
        const response = await http.post(`${this.url}/listall`, model);
        return response.data;
    }
    async allUsersBySearchText(searchText: string): Promise<Array<IUserInfo>> {
        const url = new URL(`${this.url}/searchall`);
        if (searchText) {
            url.searchParams.append('searchText', searchText);
        }
        const response = await http.get(url.toString());
        return response.data;
    }
    async users(model: any): Promise<DataTable<IUserInfo>> {
        const response = await http.post(`${this.url}/list`, model);
        return response.data;
    }
    async displayUser(id: string): Promise<IUserInfo> {
        const response = await http.get(`${this.url}/userInfo/${id}`);
        return response.data.data;
    }

    async displayUserReader(id: string): Promise<IUserInfo> {
        const response = await http.get(`${this.url}/reader/${id}`);
        return response.data.data;
    }
    async createAdmin(id: string) {
        const response = await http.post(`${this.url}/admins/${id}`, null);
        return response;
    }
    async createUser(data: IUserInfo) {
        const response = await http.post(`${this.url}`, data);
        return response;
    }
    async updateUser(data: IUserInfo) {
        const response = await http.put(`${this.url}`, data);
        return response;
    }
    async deleteUser(id: string) {
        const response = await http.delete(`${this.url}/${id}`);
        return response;
    }
    async deleteAdmin(id: string) {
        const response = await http.delete(`${this.url}/admins/${id}`);
        return response;
    }
    async resetUserPassword(data: IUserInfo) {
        const response = await http.post(`${this.url}/resetPassword`, data);
        return response;
    }

    async createReaderUser(data: IRegistrationReaderModel) {
        const response = await http.post(`${this.url}`, data);
        return response;
    }
    async changeUserPassword(data: IChangeUserPassword) {
        const response = await http.post(`${this.url}/changePassword`, data);
        return response;
    }

    async sendAgainConfirmedMail(id: string) {
        const response = await http.put(`${this.url}/sendAgainConfirmedMail`, id);
        return response;
    }
}

const userService = new UserService();
export default userService;
