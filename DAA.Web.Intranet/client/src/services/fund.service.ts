import { IFund, IFundDraft } from '@/interfaces/fund';
import { IProcess } from '@/interfaces/process';
import { FundShort } from '@/models/fund';
import http from '@/services/http.service';
import { appStore } from '@/store/app';
import { AxiosResponse } from 'axios';

class FundService {
    private url = appStore().getters.baseUrl + '/api/funds';

    getFundsUrl(): string {
        return `${this.url}/listall`;
    }

    async displayFund(sysId?: string, hasExternalSource?: boolean, externalIdentifier?: number): Promise<IFund> {
        const url = new URL(`${this.url}/${sysId ?? ''}`);
        if (hasExternalSource) {
            url.searchParams.append('hasExternalSource', hasExternalSource.toString());
        }
        if (hasExternalSource && externalIdentifier) {
            url.searchParams.append('externalIdentifier', externalIdentifier.toString());
        }
        const response = await http.get(url.toString());
        return response.data.data;
    }

    async createFund(data: IFundDraft, isCreate?: boolean): Promise<AxiosResponse> {
        const url = new URL(`${this.url}`);

        if (isCreate) {
            url.searchParams.append('isCreate', isCreate.toString());
        }

        const response = await http.post(url.toString(), data);
        return response;
    }

    async updateFund(data: IFundDraft) {
        const response = await http.put(`${this.url}`, data);
        return response;
    }

    async deleteFund(sysId: string) {
        const response = await http.delete(`${this.url}/${sysId}`);
        return response;
    }

    async deleteFundDraft(id: number) {
        const response = await http.delete(`${this.url}/draft/${id}`);
        return response;
    }

    async getFundsShort(searchText: string, archiveCode: number): Promise<FundShort> {
        const response = await http.get(`${this.url}/search?text=${searchText}&archiveCode=${archiveCode}`);
        return response.data.data.result;
    }

    async getCurrentActiveProcess(sysId: string): Promise<IProcess> {
        const response = await http.get(`${this.url}/processes/current/${sysId}`);
        return response.data.data;
    }

    getFundPublicUserReviewsUrl(systemIdentifier?: string) {
        const url = new URL(`${this.url}/fundPublicUsersReviews/${systemIdentifier ?? ''}`);
        return url.toString();
    }
}

const fundService = new FundService();
export default fundService;
