import { userStore as useUserStore } from "@/store/user";
import authorizationService from "@/services/authorization.service";
import { ActionTypes as UserStoreActionTypes } from "@/store/user/actions";

import { AdminType } from "@/enums/adminType";

const store = useUserStore();
class Authorization {
  async getUserRoles() {
    if (this.isAuthenticated() /*&& !this.isAdmin(AdminType.GlobalAdmin) && !this.isAdmin(AdminType.Admin)*/) {
      try {
        const userRoles = await authorizationService.getUserRoles();
        if (userRoles) {
          store.dispatch(UserStoreActionTypes.SetRoles, userRoles);         
        }
      } catch (error) {
        return Promise.reject(error);
      }
    }
  }

  clearUserRoles() {
    store.dispatch(UserStoreActionTypes.RemoveRoles);
  }

  isAuthenticated() {
    return store.getters.isAuthenticated;
  }

  isAdmin(adminType: AdminType) {
    return store.getters.isAuthenticated 
            && store.getters.isAdmin 
            && store.getters.adminType === adminType;
  }

  isCurrentUser(userId: string) {
    return store.getters.userId === userId;
  }
  
  hasRole(roleName: string, archiveId?: number) {
    console.log(archiveId, roleName);
    return store.getters.hasRole(roleName);
  }
}
const authorization = new Authorization();
export default authorization;
