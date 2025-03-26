import { IUser } from "@/interfaces/user";
import { UINotificationModel } from "@/models/notification"

export class User implements IUser {
    constructor(obj: IUser | undefined) {
        if (obj) {
            Object.assign(this, obj);

            if (!(this.tokenExpiration instanceof Date)) {
                this.tokenExpiration = new Date(this.tokenExpiration)
            }
        }
    }
    id: string | undefined;
    isAdmin: boolean | undefined;
    adminType: string | undefined;
    profileType : string | undefined;
    name = '';
    displayName = '';
    email = '';
    token = '';
    tokenExpiration = new Date();
    roles: string[] = [];
    unseenNotifications: UINotificationModel[] = [];
    refreshNotificationsPage: boolean = false;
}