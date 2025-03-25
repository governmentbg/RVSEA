import { IPackageATemplate, PackageATemplateCreateModel, PackageATemplateUpdateModel } from "@/models/packageATemplates";
import http from "@/services/http.service";
import { appStore } from "@/store/app";

class PackageATemplateService {
	private url = appStore().getters.baseUrl + "/api/PackageATemplates";

	getFileDownloadUrl(id: number): string {
		return `${this.url}/download/${id}`;
	}

	get(id: number): Promise<IPackageATemplate[]> {
		return http.get(`${this.url}/${id}`).then(response => response.data.data);
	}
	create(data: PackageATemplateCreateModel): Promise<number> {
		const fd = new FormData();
		fd.append("procedureId", data.procedureId!.toString());
		fd.append("description", data.description || '');
		fd.append("required", data.required.toString());
		fd.append("title", data.title);
		fd.append("file", data.file!);

		return http.post(`${this.url}`, fd).then(response => response.data.data);
	}
	update(data: PackageATemplateUpdateModel) {
		const fd = new FormData();
		fd.append("id", data.id.toString());
		fd.append("description", data.description || '');
		fd.append("required", data.required.toString());
		fd.append("title", data.title);
		
		if (data.file != null && data.file.size > 0) {
			fd.append("file", data.file!);
		}

		return http.put(`${this.url}`, fd);
	}
	delete(id: number) {
		return http.delete(`${this.url}/${id}`);
	}

	getTemplate(id: number): Promise<IPackageATemplate> {
		return http.get(`${this.url}/template/${id}`).then(response => response.data.data);
	}
}

const packageATemplateService = new PackageATemplateService();
export default packageATemplateService;
