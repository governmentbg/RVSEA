import { appStore } from '@/store/app';
import { userStore } from '@/store/user';
import { ActionTypes as UserStoreActionTypes } from '@/store/user/actions';
import http from '@/services/http.service';
import { LoginModel, PasswordModel, RegistrationModel } from '@/models/authentication';
import { User } from '@/models/user';
import authorization from '@/helpers/authorization.helper';
import { UserProfileAndRolesModel, UserProfileModel } from '@/models/profile';

const aStore = appStore();
const uStore = userStore();
class AuthenticationService {
    private rootUrl: string = `${aStore.getters.baseUrl}/api/account`;

  public async authenticate(): Promise<boolean> {
    const response = await http.post(`${this.rootUrl}/authenticate`, null);
    if (response.data.data) {
      const user = new User(response.data.data);
      uStore.dispatch(UserStoreActionTypes.SetUser, user);
      await authorization.getUserRoles();
      return true;
    }
    return false;
  }

  public async login(model: LoginModel): Promise<void> {
    const response = await http.post(`${this.rootUrl}/login`, model);
    if (response.data.data) {
      const user = new User(response.data.data);
      uStore.dispatch(UserStoreActionTypes.SetUser, user);
      await authorization.getUserRoles();
    }
  }

  public logout(): Promise<void> {
    try {
      uStore.dispatch(UserStoreActionTypes.RemoveRoles);
      uStore.dispatch(UserStoreActionTypes.RemoveUser);
      return Promise.resolve();
    } catch (error) {
      return Promise.reject<void>(error);
    }
  }


  public async setPassword(model: PasswordModel) {
    return await http.post(`${this.rootUrl}/password/set`, model);
  }

  public async changePassword(model: PasswordModel) {
    return await http.post(`${this.rootUrl}/password/change`, model);
  }
  public async setProfile(model: UserProfileModel): Promise<void> {
    try {
      const response = await http.post(`${this.rootUrl}/profile/set`, model);
      console.log(response);
      if (response.data.data) {
        const user = new User(response.data.data);
        uStore.dispatch(UserStoreActionTypes.SetUser, user);
        return Promise.resolve();
      }
    } catch (error) {
      return Promise.reject(error);
    }
    //return await http.post(`${this.rootUrl}/profile/set`, model);
  }


  public async registerReader(model: RegistrationModel) {
    const result = await http.post(`${this.rootUrl}/registerReader`, model);
    return result
  }

    async displayCurrentUser(): Promise<UserProfileAndRolesModel> {
        const response = await http.get(`${this.rootUrl}/userInfo`);
        return response.data.data;
    }
}

const authenticationService = new AuthenticationService();
export default authenticationService;
