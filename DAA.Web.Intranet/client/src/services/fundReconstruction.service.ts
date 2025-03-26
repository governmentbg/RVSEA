import { ArchivalEntityShort } from "@/models/archivalEntity";
import { IFundReconstructionModel } from "@/interfaces/fundReconstruction";
import http from "@/services/http.service";
import { appStore } from "@/store/app";
import { InventoryShort } from "@/models/inventory";

class FundReconstructionService {
	private url = appStore().getters.baseUrl + "/api/fundreconstructions";

	getReconstructionsByProcessUrl(processId: number): string {
        const url = new URL(`${this.url}/list`);
		url.searchParams.append("processId", processId.toString());
		return url.toString();
	}

	async getReconstructionArchivalEntities(processId: number, target?: boolean) :Promise<Array<ArchivalEntityShort>> {
		const url = new URL(`${this.url}/process/archivalEntity/${processId}`);
		if (target) {
			url.searchParams.append("target", String(target));
		}
		
		const response = await http.get(url.toString());
		return response.data.data;
	}

	async getReconstructionInventories(processId: number, target?: boolean) :Promise<Array<InventoryShort>> {
		const url = new URL(`${this.url}/process/inventory/${processId}`);
		if (target) {
			url.searchParams.append("target", String(target));
		}
		
		const response = await http.get(url.toString());
		return response.data.data;
	}

	async getReconstructionsByProcess(
		processId: number, 
		availabilityStatus?: number
	): Promise<Array<IFundReconstructionModel>> {
		const url = new URL(`${this.url}/process/${processId}`);
		if (availabilityStatus) {
			url.searchParams.append("availabilityStatus", availabilityStatus.toString());
		}
		
		const response = await http.get(url.toString());
		return response.data.data;
	}

	async getReconstructionsByParent(
		processId: number, 
		availabilityStatus?: number, 
		inventorySysId?: string, 
		archivalEntitySysId?: string,
		target?: boolean,
	): Promise<Array<IFundReconstructionModel>> {
		const url = new URL(`${this.url}/process/byparent/${processId}`);
		if (availabilityStatus) {
			url.searchParams.append("availabilityStatus", availabilityStatus.toString());
		}
		if (inventorySysId) {
			url.searchParams.append("inventorySysId", inventorySysId);
		}
		if (archivalEntitySysId) {
			url.searchParams.append("aeSysId", archivalEntitySysId);
		}
		if (target) {
			url.searchParams.append("target", String(target));
		}
		
		const response = await http.get(url.toString());
		return response.data.data;
	}

	async createReconstruction(data: IFundReconstructionModel): Promise<number> {
		const url = new URL(`${this.url}`);
		
		const response = await http.post(url.toString(), data);
		return response.data.data;
	}

    async createReconstructions(data: Array<IFundReconstructionModel>): Promise<void> {
		const url = new URL(`${this.url}/array`);
		
		const response = await http.post(url.toString(), data);
		return response.data.data;
	}

	async createOrUpdateReconstructionsBySource(data: Array<IFundReconstructionModel>): Promise<void> {
		const url = new URL(`${this.url}/array/bySource`);
		
		const response = await http.post(url.toString(), data);
		return response;
	}

	async updateMoveFundReconstructionsByTarget(data: Array<IFundReconstructionModel>): Promise<void> {
		const url = new URL(`${this.url}/array/move/byTarget`);
		
		const response = await http.put(url.toString(), data);
		return response;
	}

	async updateMergeFundReconstructionByTarget(data: IFundReconstructionModel): Promise<void> {
		const url = new URL(`${this.url}/merge`);
		
		const response = await http.put(url.toString(), data);
		return response;
	}

	async deleteFundReconstruction(processId: number, id: number) {
		const url = new URL(`${this.url}/${id}`);
		url.searchParams.append("processId", processId.toString());
		
		const response = await http.delete(url.toString());
		return response;
	}
}

const fundReconstructionService = new FundReconstructionService();
export default fundReconstructionService;
