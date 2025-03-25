import { UserState } from './state';
import { MutationType } from '@/store/user/mutations';
import { IUser } from '@/interfaces/user';

export type UserMutations = {
  [MutationType.SetUser](state: UserState, payload: IUser): void
  [MutationType.SetUserDisplayName](state: UserState, payload: string): void
  [MutationType.RemoveUser](state: UserState): void
}