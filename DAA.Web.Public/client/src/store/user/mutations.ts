/* eslint-disable no-unused-vars */
import { MutationTree } from "vuex";
import { UserState } from "@/types/userStore/state";
import { UserMutations } from "@/types/userStore/mutations";
import { User } from "@/models/user";
import { LocalStorageItems } from "@/enums/localStorageItems";

export enum MutationType {
  SetUser = "SET_USER",
  RemoveUser = "REMOVE_USER",
  IsAuthenticated = "IS_AUTHENTICATED",
  SetUserDisplayName = "SET_USER_DISPLAYNAME"
}

export const mutations: MutationTree<UserState> & UserMutations = {
  [MutationType.SetUser](state, value) {
    if (!(value.tokenExpiration instanceof Date)) {
      value.tokenExpiration = new Date(value.tokenExpiration);
    }

    state.user = new User(value);
    localStorage.setItem(
      LocalStorageItems.ExternalUser,
      JSON.stringify(state.user)
    );

    console.log(localStorage.getItem(LocalStorageItems.ExternalUser));
  },
  [MutationType.RemoveUser](state) {
    state.user = null;
    localStorage.removeItem(LocalStorageItems.ExternalUser);
  },
  [MutationType.SetUserDisplayName](state, payload) {
    if (state.user) {
      state.user.displayName = payload;
      localStorage.removeItem(LocalStorageItems.ExternalUser);
      localStorage.setItem(LocalStorageItems.ExternalUser, JSON.stringify(state.user));
    }
  },
};
