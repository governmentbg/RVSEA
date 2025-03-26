import { IUser } from "@/interfaces/user";
import { ActionTypes } from "@/store/user/actions";
import { ActionContext } from "vuex";
import { UserMutations } from "./mutations";
import { UserState } from "./state";

type ActionAugments = Omit<ActionContext<UserState, UserState>, 'commit'> & {
    commit<K extends keyof UserMutations>(
        key: K,
        payload: Parameters<UserMutations[K]>[1]
    ): ReturnType<UserMutations[K]>
}

export type UserActions = {
    [ActionTypes.SetUser](context: ActionAugments, payload: IUser): void
    [ActionTypes.SetUserDisplayName](context: ActionAugments, payload: string): void
    [ActionTypes.RemoveUser](context: ActionAugments): void
}