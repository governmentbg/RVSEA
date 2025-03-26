import { userStore as useUserStore } from "@/store/user";
import { AdminType } from "@/enums/adminType";
import { ProfileType } from "@/enums/profile";

const store = useUserStore();
class Authorization {
  // async authorizeAdmin(to: RouteLocationNormalized, from: RouteLocationNormalized, next: NavigationGuardNext) {
  //     try {
  //         const hasPermission = await authorizationService.authorizeAdmin();
  //         if (hasPermission) {
  //             next();
  //         } else {
  //             next({ name: 'AccessDenied'});
  //         }
  //     } catch (error: any) {
  //         next(error);
  //     }
  // }

  // async authorizeAdmin(to: RouteLocationRaw | null, next: NavigationGuardNext) {
  //     try {
  //         const hasPermission = await authorizationService.authorizeAdmin();
  //         if (hasPermission) {
  //             if (to) {
  //                 next(to);
  //             } else {
  //                 next();
  //             }
  //         } else {
  //             next({
  //                 name: 'AccessDenied',
  //             });
  //         }
  //     } catch (error: any) {
  //         next(error);
  //     }
  // }

  // async authorize(to: RouteLocationNormalized, from: RouteLocationNormalized, next: NavigationGuardNext, model: PermissionModel) {
  //     try {
  //         const hasPermission = await authorizationService.authorize(model);
  //         if (hasPermission) {
  //             next();
  //         } else {
  //             next({ name: 'AccessDenied'});
  //         }
  //     } catch (error: any) {
  //         next(error);
  //     }
  // }

  // async authorize(to: RouteLocationRaw | null, next: NavigationGuardNext, model: PermissionModel) {
  //     try {
  //         const hasPermission = await authorizationService.authorize(model);
  //         if (hasPermission) {
  //             if (to) {
  //                 next(to);
  //             } else {
  //                 next();
  //             }
  //         } else {
  //             next({ name: 'AccessDenied'});
  //         }
  //     } catch (error: any) {
  //         next(error);
  //     }
  // }

  isAuthenticated() {
    return store.getters.isAuthenticated;
  }
  isAdmin(adminType: AdminType) {
    return (
      store.getters.isAuthenticated &&
      store.getters.isAdmin &&
      store.getters.adminType == adminType
    );
  }
  isCurrentUser(userId: string) {
    return store.getters.userId === userId;
  }
  isProfileType(profileType: ProfileType) {
    console.log(store.getters.isAuthenticated && store.getters.profileType === profileType);
    return store.getters.isAuthenticated && store.getters.profileType === profileType;
  }
}
const authorization = new Authorization();
export default authorization;
