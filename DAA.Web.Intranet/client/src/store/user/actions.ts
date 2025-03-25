import { UserActions } from "@/types/userStore/actions"
import { UserState } from "@/types/userStore/state"
import { ActionTree } from "vuex"
import { MutationType } from "./mutations"

export enum ActionTypes {
    SetUser = 'SET_USER',
    RemoveUser = 'REMOVE_USER',
    IsAuthenticated = 'IS_AUTHENTICATED',
    SetRoles = 'SET_ROLES',
    RemoveRoles = 'REMOVE_ROLES',
    IncreaseUnSeenNotifications = 'INCREASE_UNSEEN_NOTIFICATIONS',
    DecreaseUnSeenNotifications = 'DECREASE_UNSEEN_NOTIFICATIONS',
    SetUnSeenNotifications = 'SET_UNSEEN_NOTIFICATIONS',
    RefreshNotificationsPage = 'REFRESH_NOTIFICATIONS_PAGE',
}

export const actions: ActionTree<UserState, UserState> & UserActions = {
  [ActionTypes.SetUser]({ commit }, payload) {
    commit(MutationType.SetUser, payload);
  },
  [ActionTypes.RemoveUser]({ commit }) {
    commit(MutationType.RemoveUser, undefined);
  },
  [ActionTypes.SetRoles]({ commit }, payload) {
    commit(MutationType.SetRoles, payload);
  },
  [ActionTypes.RemoveRoles]({commit}) {
    commit(MutationType.RemoveRoles, undefined);
  },
  [ActionTypes.IncreaseUnSeenNotifications]({ commit }, payload) {
    commit(MutationType.IncreaseUnSeenNotifications, payload);
  },
  [ActionTypes.DecreaseUnSeenNotifications]({ commit }, payload) {
    commit(MutationType.DecreaseUnSeenNotifications, payload);
  },
  [ActionTypes.SetUnSeenNotifications]({ commit }, payload) {
    commit(MutationType.SetUnSeenNotifications, payload);
  },
  [ActionTypes.RefreshNotificationsPage]({ commit }, payload) {
    commit(MutationType.RefreshNotificationsPage, payload);
  }
}