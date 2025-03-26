import { IUser } from "@/interfaces/user";
import { ActionTypes } from "@/store/user/actions";
import { ActionContext } from "vuex";
import { UserMutations } from "./mutations";
import { UserState } from "./state";
import { UINotificationModel } from "@/models/notification";

type ActionAugments = Omit<ActionContext<UserState, UserState>, 'commit'> & {
    commit<K extends keyof UserMutations>(
        key: K,
        payload: Parameters<UserMutations[K]>[1]
    ): ReturnType<UserMutations[K]>
}

export type UserActions = {
    [ActionTypes.SetUser](context: ActionAugments, payload: IUser): void
    [ActionTypes.RemoveUser](context: ActionAugments): void
    [ActionTypes.SetRoles](context: ActionAugments, payload: Array<string>): void
    [ActionTypes.RemoveRoles](context: ActionAugments) : void
    [ActionTypes.IncreaseUnSeenNotifications](context: ActionAugments, payload: UINotificationModel[] | null): void
    [ActionTypes.DecreaseUnSeenNotifications](context: ActionAugments, payload: number | null): void
    [ActionTypes.SetUnSeenNotifications](context: ActionAugments, payload: UINotificationModel[] | null): void
    [ActionTypes.RefreshNotificationsPage](context: ActionAugments, payload: boolean): void
}