import { IFilmCard, IPrintedFilmCard } from "@/interfaces/film";
import { defaultGuidString } from "@/helpers/format.helper";
import http from "@/services/http.service";
import { appStore } from "@/store/app";

class FilmCardService {
  private url = appStore().getters.baseUrl + "/api/filmCards";

  getFilmCardsUrl(filmSysId: string, hasExternalSource?: boolean, externalIdentifier?: number): string {
    const url = new URL(`${this.url}/listall/${filmSysId || defaultGuidString()}`);
    
		if (hasExternalSource) {
			url.searchParams.append("hasExternalSource", hasExternalSource.toString());
		}
		if (hasExternalSource && externalIdentifier) {
			url.searchParams.append("externalIdentifier", externalIdentifier.toString());
		}
    return url.toString(); 
  }

  async getParentData(filmSysId: string): Promise<IFilmCard> {
    const response = await http.get(`${this.url}/parentData/${filmSysId}`);
    return response.data.data;
  }

  async displayFilmCard(sysId?: string, hasExternalSource?: boolean, externalIdentifier?: number): Promise<IFilmCard> {
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

  async displayPrintedFilmCard(sysId: string): Promise<IPrintedFilmCard> {
    const response = await http.get(`${this.url}/printed/${sysId}`);
    return response.data.data;
  }

  async createFilmCardDraft(data: IFilmCard) {
    const response = await http.post(`${this.url}`, data);
    return response;
  }

  async updateFilmCard(data: IFilmCard) {
    const response = await http.put(`${this.url}`, data);
    return response;
  }

  async deleteFilmCardDraft(id: number) {
    const response = await http.delete(`${this.url}/draft/${id}`);
    return response;
  }

  async deleteFilmCard(id: string) {
    const response = await http.delete(`${this.url}/${id}`);
    return response;
  }
}

const filmCardService = new FilmCardService();
export default filmCardService;
