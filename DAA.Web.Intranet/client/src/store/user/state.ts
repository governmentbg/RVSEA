import { LocalStorageItems } from "@/enums/localStorageItems";
import { IUser } from "@/interfaces/user";
import { User } from "@/models/user";
import { UserState } from "@/types/userStore/state";

const userJSON = localStorage.getItem(LocalStorageItems.IntranetUser);
let user = null;
if (userJSON) {
    user = new User(JSON.parse(userJSON) as IUser);

    if (user.tokenExpiration && user.tokenExpiration.getTime() < Date.now()) {
        user = null;
    }
}

export const state: UserState = {
    user
};