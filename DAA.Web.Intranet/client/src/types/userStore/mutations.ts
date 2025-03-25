import { UserState } from './state';
import { MutationType } from '@/store/user/mutations';
import { IUser } from '@/interfaces/user';
import { UINotificationModel } from "@/models/notification";

export type UserMutations = {
    [MutationType.SetUser](state: UserState, payload: IUser): void
    [MutationType.RemoveUser](state: UserState): void
    [MutationType.SetRoles](state: UserState, payload: Array<string>): void
    [MutationType.RemoveRoles](state: UserState): void
    [MutationType.IncreaseUnSeenNotifications](state: UserState, value: UINotificationModel[] | null): void
    [MutationType.DecreaseUnSeenNotifications](state: UserState, value: number | null): void
    [MutationType.SetUnSeenNotifications](state: UserState, value: UINotificationModel[] | null): void
    [MutationType.RefreshNotificationsPage](state: UserState, value: boolean): void
  }