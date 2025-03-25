import { Actions } from "@/types/appStore/actions"
import { State } from "@/types/appStore/state"
import { ActionTree } from "vuex"
import { MutationType } from "./mutations"

export enum ActionTypes {
  ToggleLoading = 'TOGGLE_LOADING',
  ToggleSideMenu = 'TOGGLE_SIDEMENU',
  SetSideMenu = 'SET_SIDEMENU',
}

export const actions: ActionTree<State, State> & Actions = {
  [ActionTypes.ToggleLoading]({ commit }, payload) {
    commit(MutationType.ToggleLoading, payload);
  },
  [ActionTypes.ToggleSideMenu]({ commit }) {
    commit(MutationType.ToggleSideMenu);
  },
  [ActionTypes.SetSideMenu]({ commit }, payload) {
    commit(MutationType.SetSideMenu, payload);
  },
}