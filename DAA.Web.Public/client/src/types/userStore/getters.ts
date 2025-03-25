import { UserState } from "./state";

export type UserGetters = {
    isAuthenticated(state: UserState): boolean,
    fullName(state: UserState): string,
    name(state: UserState): string,
    userId(state: UserState): string,
    token(state: UserState): string,
    isAdmin(state: UserState): boolean,
    adminType(state: UserState): string,
    email(state: UserState): string,
    profileType(state: UserState): string,
}