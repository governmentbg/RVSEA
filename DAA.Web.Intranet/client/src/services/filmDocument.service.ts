import { IFilmPackageDocument } from "@/interfaces/film";
import { FilmPackageDocumentCreateModel, FilmPackageDocumentUpdateModel } from "@/models/film";
import http from "@/services/http.service";
import { appStore } from "@/store/app";

class FilmDocumentService {
  private url = appStore().getters.baseUrl + "/api/filmDocuments";

  getFileDownloadUrl(docId: number, isInline?: boolean): string {
    return `${this.url}/download/${docId}${isInline ? '?isInline=true' : ''}`;
  }

  getFilmDocumentsUrl(packageId: number): string {
    return `${this.url}/listall/${packageId}`;
  }

  async displayFilmDocument(id: number): Promise<IFilmPackageDocument> {
    const response = await http.get(`${this.url}/${id}`);
    return response.data.data;
  }

  async createFilmDocument(data: FilmPackageDocumentCreateModel) {
    const formData = new FormData();
    formData.append("entitySystemIdentifier", data.entitySystemIdentifier!.toString());
    formData.append("entityType", data.entityType!.toString());
    formData.append("packageId", data.packageId!.toString());
    formData.append("documentTypeId", data.documentTypeId!.toString());
    formData.append("description", data.description || '');
    formData.append("file", data.file!);
    if (data.skipValidation) {
      formData.append("skipValidation", data.skipValidation.toString());
    }

    const response = await http.post(`${this.url}`, formData);
    return response;
  }

  async updateFilmDocument(data: FilmPackageDocumentUpdateModel) {
    const formData = new FormData();
    formData.append("id", data.id!.toString());
    formData.append("entitySystemIdentifier", data.entitySystemIdentifier!.toString());
    formData.append("entityType", data.entityType!.toString());
    formData.append("packageId", data.packageId!.toString());
    formData.append("documentTypeId", data.documentTypeId!.toString());
    formData.append("description", data.description || '');
    formData.append("file", data.file!);
    if (data.skipValidation) {
      formData.append("skipValidation", data.skipValidation.toString());
    }

    const response = await http.put(`${this.url}`, formData);
    return response;
  }

  async deleteFilmDocument(id: number, entityType: string, entitySystemIdentifier: string) {
    const response = await http.delete(`${this.url}/${id}/${entityType}/${entitySystemIdentifier}`);
    return response;
  }

}

const filmDocumentService = new FilmDocumentService();
export default filmDocumentService;
