import { MutationTree } from 'vuex'
import { State } from '@/types/appStore/state'
import { Mutations } from '@/types/appStore/mutations';

export enum MutationType {
    ToggleLoading = 'TOGGLE_LOADING',
    ToggleSideMenu = 'TOGGLE_SIDEMENU',
    SetSideMenu = 'SET_SIDEMENU',
}

export const mutations: MutationTree<State> & Mutations = {
    [MutationType.ToggleLoading](state, value) {
        state.loading = value
    },
    [MutationType.ToggleSideMenu](state) {
        state.sideMenu = !state.sideMenu;
    },
    [MutationType.SetSideMenu](state) {
        state.sideMenu = !state.sideMenu;
    },
}