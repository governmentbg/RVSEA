import { Getters } from '@/types/appStore/getters';
import { State } from '@/types/appStore/state'
import { GetterTree } from 'vuex'

export const getters: GetterTree<State, State> & Getters = {
    isLoading: (state) => state.loading,
    language: (state) => state.language,
    baseUrl: (state) => state.baseUrl,
    uiUrl: (state) => state.uiUrl,
    sideMenu: (state) => state.sideMenu,
    activeRoute: (state) => state.activeRoute,
    dateTimeFormat: (state) => state.dateTimeFormat,
    dateTimeLongFormat: (state) => state.dateTimeLongFormat,
    dateFormat: (state) => state.dateFormat,
    timeFormat: (state) => state.timeFormat,
    maxPackageAFileSizeInMB: (state) => state.maxPackageAFileSizeInMB,
    maxPackageBFileSizeInMB: (state) => state.maxPackageBFileSizeInMB,
}