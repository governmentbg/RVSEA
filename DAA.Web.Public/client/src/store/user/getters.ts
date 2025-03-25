import { UserGetters } from '@/types/userStore/getters';
import { UserState } from '@/types/userStore/state'
import { GetterTree } from 'vuex'

export const getters: GetterTree<UserState, UserState> & UserGetters = {
    isAuthenticated(state): boolean {
        if (state.user) {
            return !!(state.user.token && state.user.tokenExpiration > new Date());
        }

        return false
    },
    fullName(state): string {
        if (state.user) {
            const fullName = state.user.displayName;
            return fullName;
        }

        return '';
    },
    name(state): string {
        if (state.user) {
            const name = state.user.name;
            return name;
        }

        return '';
    },
    userId(state): string {
        if (state.user) {
            const userId = state.user.id!;
            return userId;
        }

        return '';
    },
    token(state): string {
        if (state.user) {
            return state.user.token;
        }

        return '';
    },
    profileType(state): string{
        if (state.user) {
            return state.user.profileType;
        }

        return '';
    },
    isAdmin(state): boolean {
        return state.user?.isAdmin ?? false;
    },
    adminType(state): string {
        return state.user?.adminType || '';
    },
		email(state): string {
			return state.user?.email || '';
		}
}