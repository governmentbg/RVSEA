import { appStore } from '@/store/app';
import { userStore } from '@/store/user';
import { ActionTypes as UserStoreActionTypes } from '@/store/user/actions';
import http from '@/services/http.service';
import {
    ConfirmationModel,
    LoginModel,
    PasswordModel,
    RegistrationModel,
    EAuthRequestModel,
    LoginReaderModel,
} from '@/models/authentication';
import { User } from '@/models/user';
import { UserProfileModel } from '@/models/profile';
import { displayMessage } from '@/helpers/notification.helper';
import { Ref } from 'vue';
import { IMessage } from '@/interfaces/notification';
const aStore = appStore();
const uStore = userStore();
class AuthenticationService {
    private rootUrl: string = `${aStore.getters.baseUrl}/api/account`;

    public async register(model: RegistrationModel) {
        return await http.post(`${this.rootUrl}/register`, model);
    }

    public async login(model: LoginModel, err?: Ref<IMessage>): Promise<void> {
        try {
            const response = await http.post(`${this.rootUrl}/login`, model);
            if (response.data.data) {
                const user = new User(response.data.data);
                uStore.dispatch(UserStoreActionTypes.SetUser, user);
                if(response.data.message != null && response.data.message != '' && err) {
                    displayMessage(err, response.data.message, 'warning');
                }
                return Promise.resolve();
            }
        } catch (error) {
            return Promise.reject<void>(error);
        }
    }

    public loginCertUrl(email?: string) {
        const url = new URL(`${aStore.getters.baseUrl}/certificate/login`);
        if (email) {
            url.searchParams.append('email', email);
        }
        return url.toString();
    }

    public async eAuthLogin(email: string = ''): Promise<EAuthRequestModel> {
        return (await http.get(`${aStore.getters.baseUrl}/eAuthentication/eauthRequest/${email}`)).data;
    }

    public eAuthLoginWithAddedEmail(email: string, certPersonIdentifier: string, certNames: string) {
        const url = new URL(`${aStore.getters.baseUrl}/eAuthentication/login`);
        if (email) {
            url.searchParams.append('email', email);
            url.searchParams.append('certPersonIdentifier', certPersonIdentifier);
            url.searchParams.append('certNames', certNames);
        }
        return url.toString();
    }

    public logout(): Promise<void> {
        try {
            //localStorage.removeItem('user');
            uStore.dispatch(UserStoreActionTypes.RemoveUser);
            return Promise.resolve();
        } catch (error) {
            return Promise.reject<void>(error);
        }
    }

    public async confirm(model: ConfirmationModel) {
        return await http.post(`${this.rootUrl}/confirm`, model);
    }

    public async resetPassword(email: string) {
        return await http.post(`${this.rootUrl}/password/reset`, email);
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

    public async loginUsernameUrl(model: LoginReaderModel): Promise<void> {
        try {
            const response = await http.post(`${this.rootUrl}/loginReader`, model);
            if (response.data.data) {
                const user = new User(response.data.data);
                uStore.dispatch(UserStoreActionTypes.SetUser, user);
                return Promise.resolve();
            }
        } catch (error) {
            console.log(error);

            return Promise.reject<void>(error);
        }
    }
    public async getUserData() {
        const response = await http.get(`${this.rootUrl}/userProfile`);
        return response.data.data;
    }
}

const authenticationService = new AuthenticationService();
export default authenticationService;
