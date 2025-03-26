import { IFilmCard } from '@/interfaces/film';
import http from '@/services/http.service';
import { appStore } from '@/store/app';

class FilmCardService {
    private url = appStore().getters.baseUrl + '/api/filmCards';

    getFilmCardsUrl(filmSysId?: string): string {
        return `${this.url}/listall/${filmSysId}`;
    }

    async displayFilmCard(sysId: string): Promise<IFilmCard> {
        const response = await http.get(`${this.url}/${sysId}`);
        return response.data.data;
    }
}

const filmCardService = new FilmCardService();
export default filmCardService;
