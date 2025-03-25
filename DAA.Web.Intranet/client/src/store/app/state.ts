import { State } from '@/types/appStore/state';

const isDevelopment = process.env.NODE_ENV == 'development';
console.log('environment: ', process.env.NODE_ENV);

let baseUrl = '';
let uiUrl = '';
if (!isDevelopment) {
    const pubPath = process.env.BASE_URL as string;
    let href = window.location.origin + pubPath;
    if (href[href.length - 1] === '/') {
        href = href.slice(0, href.length - 1);
    }
    baseUrl = href;
    uiUrl = href;
} else {
    baseUrl = 'https://localhost:44308';
    uiUrl = 'http://localhost:8081';
}

export const state: State = {
    loading: false,
    sideMenu: false,
    language: 'bg',
    baseUrl,
    uiUrl,
    externalSourceDisplayEntityBaseUrl: 'http://isda.archives.government.bg:84/Process.aspx?type=',
    externalSourceGalleryUrl: 'http://172.17.100.10/Gallery.aspx',
    externalSourceGalleryServiceUrl: 'http://172.17.100.10/JpgHandler.ashx',
    externalSourceFileDownloadUrl: 'http://172.17.100.10/Download.ashx',
    // externalSourceGalleryUrl: 'http://isda.archives.government.bg:84/Gallery.aspx',
    // externalSourceGalleryServiceUrl: 'http://isda.archives.government.bg:84/JpgPublicHandler.ashx',
    // externalSourceFileDownloadUrl: 'http://isda.archives.government.bg:84/Download.ashx',
    activeRoute: '',
    dateTimeFormat: 'DD.MM.YYYY HH:mm',
    dateTimeLongFormat: 'DD.MM.YYYY HH:mm:ss',
    dateFormat: 'DD.MM.YYYY',
    timeFormat: 'HH:mm',
    // maxPackageAFileSizeInMB: 50, 
    // maxPackageBFileSizeInMB: 100, 
    maxPackageAFileSizeInMB: 200, 
    maxPackageBFileSizeInMB: 500, 
};
