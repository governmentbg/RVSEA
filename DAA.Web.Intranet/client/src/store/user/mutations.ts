import { MutationTree } from "vuex";
import { UserState } from "@/types/userStore/state";
import { UserMutations } from "@/types/userStore/mutations";
import { User } from "@/models/user";
import { LocalStorageItems } from "@/enums/localStorageItems";
import { UINotificationModel } from "@/models/notification";

export enum MutationType {
  SetUser = "SET_USER",
  RemoveUser = "REMOVE_USER",
  IsAuthenticated = "IS_AUTHENTICATED",
  SetRoles = 'SET_ROLES',
  RemoveRoles = 'REMOVE_ROLES',
  IncreaseUnSeenNotifications = 'INCREASE_UNSEEN_NOTIFICATIONS',
  DecreaseUnSeenNotifications = 'DECREASE_UNSEEN_NOTIFICATIONS',
  SetUnSeenNotifications = 'SET_UNSEEN_NOTIFICATIONS',
  RefreshNotificationsPage = 'REFRESH_NOTIFICATIONS_PAGE',
}

export const mutations: MutationTree<UserState> & UserMutations = {
  [MutationType.SetUser](state, value) {
    if (!(value.tokenExpiration instanceof Date)) {
      value.tokenExpiration = new Date(value.tokenExpiration);
    }

    state.user = new User(value);
    localStorage.setItem(
      LocalStorageItems.IntranetUser,
      JSON.stringify(state.user)
    );
  },
  [MutationType.RemoveUser](state) {
    state.user = null;
    localStorage.removeItem(LocalStorageItems.IntranetUser);
  },
  [MutationType.SetRoles](state, value: string[]) {
    if (state.user) {
      state.user.roles = value;
    }
  },
  [MutationType.RemoveRoles](state) {
    if (state.user) {
      state.user.roles = [];
    }
  },
  [MutationType.IncreaseUnSeenNotifications](state, value) {
    if (state.user) {
      const list = value as UINotificationModel[];

      list.forEach(x => {
        if (x.userId === state.user?.id) {
          const existing = state.user.unseenNotifications.find(y => y.id === x.id);
          if (existing == null) {
            state.user.unseenNotifications.push(x);
          }
        }
      });

      state.user.refreshNotificationsPage = true;
      localStorage.setItem(LocalStorageItems.IntranetUser, JSON.stringify(state.user));
      console.log("store: new unseen: ");
      console.log(state.user.unseenNotifications);
    }
  },
  [MutationType.DecreaseUnSeenNotifications](state, value) {
    if (state.user) {
      console.log("store: decrease by: ", value);
      state.user.unseenNotifications = state.user.unseenNotifications.filter(x => x.id != value);
      localStorage.setItem(LocalStorageItems.IntranetUser, JSON.stringify(state.user));
      console.log("store: new unseen: ", state.user.unseenNotifications);
    }
  },
  [MutationType.SetUnSeenNotifications](state, value) {
    if (state.user) {
      state.user.unseenNotifications = value as UINotificationModel[];
      localStorage.setItem(LocalStorageItems.IntranetUser, JSON.stringify(state.user));
      console.log("store: set unseen");
    }
  },
  [MutationType.RefreshNotificationsPage](state, value) {
    if (state.user) {
      state.user.refreshNotificationsPage = value;
      localStorage.setItem(LocalStorageItems.IntranetUser, JSON.stringify(state.user));
      console.log("store: refresh notifications: ", value);
    }
  },
};
