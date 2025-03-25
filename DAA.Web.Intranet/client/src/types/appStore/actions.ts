
import { ActionTypes } from "@/store/app/actions";
import { ActionContext } from "vuex";
import { Mutations } from "./mutations";
import { State } from "./state";

type ActionAugments = Omit<ActionContext<State, State>, 'commit'> & {
    commit<K extends keyof Mutations>(
        key: K,
        payload?: Parameters<Mutations[K]>[1]
    ): ReturnType<Mutations[K]>
}

export type Actions = {
    [ActionTypes.ToggleLoading](context: ActionAugments, payload: boolean): void
    [ActionTypes.ToggleSideMenu](context: ActionAugments): void
    [ActionTypes.SetSideMenu](context: ActionAugments, payload: boolean): void
}
