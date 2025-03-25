export type State = {
    loading: boolean;
    sideMenu: boolean;
    language: string,
    baseUrl: string,
    uiUrl: string,
    externalSourceGalleryUrl: string,
    externalSourceGalleryServiceUrl: string,
    activeRoute: string,
    dateTimeFormat: string,
    dateTimeLongFormat: string,
    dateFormat: string,
    timeFormat: string,
    maxPackageAFileSizeInMB: number;
    maxPackageBFileSizeInMB: number;
};
