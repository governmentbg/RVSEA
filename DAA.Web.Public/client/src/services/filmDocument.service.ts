import { appStore } from '@/store/app';

class FilmDocumentService {
    private url = appStore().getters.baseUrl + '/api/filmDocuments';

    getFileDownloadUrl(docId: number): string {
        return `${this.url}/download/${docId}`;
    }

    getFilmDocumentsUrl(packageId: number): string {
        return `${this.url}/listall/${packageId}`;
    }
}

const filmDocumentService = new FilmDocumentService();
export default filmDocumentService;
