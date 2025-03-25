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
import { UserState } from '@/types/userStore/state'
import { UserStore } from '@/types/userStore/store'

// define injection key
export const key: InjectionKey<VuexStore<UserState>> = Symbol()

export const store = createStore<UserState>({
  plugins: process.env.NODE_ENV === 'development' ? [createLogger()] : [],
  state,
  mutations,
  actions,
  getters
})

export function userStore(): UserStore {
  return store as UserStore
} 

export function useStore(): UserStore {
  return baseUseStore(key)
}