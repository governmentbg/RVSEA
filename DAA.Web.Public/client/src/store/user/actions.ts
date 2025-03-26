/* eslint-disable no-unused-vars */
import { UserActions } from "@/types/userStore/actions";
import { UserState } from "@/types/userStore/state";
import { ActionTree } from "vuex";
import { MutationType } from "./mutations";

export enum ActionTypes {
  SetUser = "SET_USER",
  RemoveUser = "REMOVE_USER",
  IsAuthenticated = "IS_AUTHENTICATED",
  SetUserDisplayName = "SET_USER_DISPLAYNAME"
}

export const actions: ActionTree<UserState, UserState> & UserActions = {
  [ActionTypes.SetUser]({ commit }, payload) {
    commit(MutationType.SetUser, payload);
  },
  [ActionTypes.RemoveUser]({ commit }) {
    commit(MutationType.RemoveUser, undefined);
  },
  [ActionTypes.SetUserDisplayName]({ commit }, payload) {
    commit(MutationType.SetUserDisplayName, payload);
  },
};
