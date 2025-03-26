import { State } from './state';
import { MutationType } from '@/store/app/mutations';

export type Mutations = {
    [MutationType.ToggleLoading](state: State, show: boolean): void
    [MutationType.ToggleSideMenu](state: State): void
    [MutationType.SetSideMenu](state: State, show: boolean): void
  }