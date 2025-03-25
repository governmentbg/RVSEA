import { IPackageDocument } from "@/models/applications";
import { PackageDocumentCreateModel, PackageDocumentUpdateModel } from "@/models/applications";
import http from "@/services/http.service";
import { appStore } from "@/store/app";

class ApplicationDocumentService {
  private url = appStore().getters.baseUrl + "/api/filmDocuments";

  getFileDownloadUrl(docId: number): string {
		return `${this.url}/download/${docId}`;
	}

  getFilmDocumentsUrl(packageId: number): string {
    return `${this.url}/listall/${packageId}`;
  }

  async displayFilmDocument(id: number): Promise<IPackageDocument> {
    const response = await http.get(`${this.url}/${id}`);
    return response.data.data;
  }

  async createFilmDocument(data: PackageDocumentCreateModel) {
    const formData = new FormData();
    formData.append("entitySystemIdentifier", data.entitySystemIdentifier!.toString());
		formData.append("entityType", data.entityType!.toString());
    formData.append("packageId", data.packageId!.toString());
		formData.append("documentTypeId", data.documentTypeId!.toString());
		formData.append("description", data.description || '');
		formData.append("file", data.file!);

    const response = await http.post(`${this.url}`, formData);
    return response;
  }

  async updateFilmDocument(data: PackageDocumentUpdateModel) {
    const formData = new FormData();
		formData.append("id", data.id!.toString());
    formData.append("entitySystemIdentifier", data.entitySystemIdentifier!.toString());
		formData.append("entityType", data.entityType!.toString());
    formData.append("packageId", data.packageId!.toString());
		formData.append("documentTypeId", data.documentTypeId!.toString());
		formData.append("description", data.description || '');
		formData.append("file", data.file!);

    const response = await http.put(`${this.url}`, formData);
    return response;
  }

  async deleteFilmDocument(id: number, entityType: string, entitySystemIdentifier: string) {
    const response = await http.delete(`${this.url}/${id}/${entityType}/${entitySystemIdentifier}`);
    return response;
  }

}

const applicationDocumentService = new ApplicationDocumentService();
export default applicationDocumentService;
