import {
  createStore,
  createLogger,
  Store as VuexStore,
  useStore as baseUseStore,
} from 'vuex'
import { InjectionKey } from 'vue'
import { state } from './state'
import { mutations } from './mutations'
import { actions } from './actions'
import { getters } from './getters'
import { State } from '@/types/appStore/state'
import { Store } from '@/types/appStore/store'

// define injection key
export const key: InjectionKey<VuexStore<State>> = Symbol()

export const store = createStore<State>({
  plugins: process.env.NODE_ENV === 'development' ? [createLogger()] : [],
  state,
  mutations,
  actions,
  getters
})

export function appStore(): Store {
  return store as Store
} 

export function useStore(): VuexStore<State> {
  return baseUseStore(key)
}