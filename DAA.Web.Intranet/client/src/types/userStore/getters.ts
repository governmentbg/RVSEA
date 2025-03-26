import { UserState } from "./state";
import {UINotificationModel} from "@/models/notification"

export type UserGetters = {
    isAuthenticated(state: UserState): boolean,
    fullName(state: UserState): string,
    name(state: UserState): string,
    userId(state: UserState): string,
    token(state: UserState): string,
    isAdmin(state: UserState): boolean,
    adminType(state: UserState): string,
    roles(state: UserState): string[],
    hasRole(state: UserState): (value: string) => boolean,
    unseenNotifications(state: UserState): UINotificationModel[],
    refreshNotificationsPage(state: UserState): boolean,
}