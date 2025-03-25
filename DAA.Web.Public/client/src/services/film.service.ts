import { IFilm } from "@/interfaces/film";
import http from "@/services/http.service";
import { appStore } from "@/store/app";

class FilmService {
	private url = appStore().getters.baseUrl + "/api/films";

	async displayFilm(sysId?: string, hasExternalSource?: boolean, externalIdentifier?: number): Promise<IFilm> {
		const url = new URL(`${this.url}/${sysId ?? ''}`);

		if (hasExternalSource) {
			url.searchParams.append("hasExternalSource", hasExternalSource.toString());
		}
		if (hasExternalSource && externalIdentifier) {
			url.searchParams.append("externalIdentifier", externalIdentifier.toString());
		}
		const response = await http.get(url.toString());
		return response.data.data.data;
	}

	async getIsdaEServicesLink():Promise<string> {
		const response = await http.get(`${this.url.toString()}/getLink`);
		return response.data.data;
	}

	getFilmsForReaderUrl(): string {
		return `${this.url}/listallforreader`;
	}
}
const filmService = new FilmService();
export default filmService;
