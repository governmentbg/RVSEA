import { CommitOptions, DispatchOptions, Store as VuexStore } from "vuex";
import { UserActions } from "./actions";
import { UserGetters } from "./getters";
import { UserMutations } from "./mutations";
import { UserState } from "./state";

export type UserStore = Omit<
    VuexStore<UserState>,
    'getters' | 'commit' | 'dispatch'
> & {
    commit<K extends keyof UserMutations, P extends Parameters<UserMutations[K]>[1]>(
        key: K,
        payload: P,
        options?: CommitOptions
    ): ReturnType<UserMutations[K]>
} & {
    dispatch<K extends keyof UserActions>(
        key: K,
        payload?: Parameters<UserActions[K]>[1],
        options?: DispatchOptions
    ): ReturnType<UserActions[K]>
} & {
    getters: {
        [K in keyof UserGetters]: ReturnType<UserGetters[K]>
    }
}