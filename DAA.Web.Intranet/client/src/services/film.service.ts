
import { ProcessModel } from "@/models/process"
import { IFilm, IFilmChangeStepModel, IFilmReview } from "@/interfaces/film";
//import { FilmReview } from "@/models/film";
//import { GridResponseModel } from "@/models/grid";
import http from "@/services/http.service";
import { appStore } from "@/store/app";

class FilmService {
  private url = appStore().getters.baseUrl + "/api/films";

  getFilmsUrl(hasExternalSource?: boolean, externalIdentifier?: number): string {
    const url = new URL(`${this.url}/listall`);

    if (hasExternalSource) {
			url.searchParams.append("hasExternalSource", hasExternalSource.toString());
		}
		if (hasExternalSource && externalIdentifier) {
			url.searchParams.append("externalIdentifier", externalIdentifier.toString());
		}

    return url.toString(); 
  }

  async displayFilm(sysId?: string, hasExternalSource?: boolean, externalIdentifier?: number): Promise<IFilm> {
    const url = new URL(`${this.url}/${sysId ?? ''}`);

    if (hasExternalSource) {
      url.searchParams.append("hasExternalSource", hasExternalSource.toString());
    }
    if (hasExternalSource && externalIdentifier) {
      url.searchParams.append("externalIdentifier", externalIdentifier.toString());
    }
    const response = await http.get(url.toString());
    return response.data.data;
  }

  async createFilm(data: IFilm) {
    const response = await http.post(`${this.url}`, data);
    return response;
  }

  async getNextInventoryNumber(): Promise<number> {
    const response = await http.get(`${this.url}/nextNumber`);
    return response.data.data;
  }

  async updateFilm(data: IFilm) {
    const response = await http.put(`${this.url}`, data);
    return response;
  }

  async deleteFilm(id: string) {
    const response = await http.delete(`${this.url}/${id}`);
    return response;
  }

  async deleteFilmDraft(id: number) {
    const response = await http.delete(`${this.url}/draft/${id}`);
    return response;
  }

  async changeStep(model: IFilmChangeStepModel) {
    const response = await http.post(`${this.url}/changeStep`, model);
    return response;
  }

  async startProcess(model: ProcessModel): Promise<number> {
    const response = await http.post(`${this.url}/startProcess`, model);
    return response.data.data;
  }

  getFilmReviewsUrl(): string {
    return `${this.url}/listAllFilmReviews`;
  }

  async createFilmReview(data: IFilmReview) {
    const response = await http.post(`${this.url}/filmReview`, data);
    return response;
  }
  async updateAccess(model: IFilmReview){
    const response = await http.put(`${this.url}/updateAccess`,model);
    return response;
}
}

const filmService = new FilmService();
export default filmService;
