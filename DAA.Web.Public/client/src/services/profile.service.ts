import { appStore } from '@/store/app';
import http from '@/services/http.service';
import { UserProfileModel } from '@/models/profile';

const aStore = appStore();
class UserProfileService {
    private rootUrl: string = `${aStore.getters.baseUrl}/api/account`;

    public async updateProfile(model: UserProfileModel) {
        return await http.post(`${this.rootUrl}`, model);
    }

    public async getProfile(): Promise<UserProfileModel> {
        return await http.get(`${this.rootUrl}/userProfile`).then((res) => res.data.data);
    }

    async updateUser(data: UserProfileModel) {
        const response = await http.put(`${this.rootUrl}/profile/edit`, data);
        return response;
    }
}

const userProfileService = new UserProfileService();
export default userProfileService;
