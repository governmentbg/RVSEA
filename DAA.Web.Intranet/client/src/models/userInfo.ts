import { IUserInfo } from "@/interfaces/userInfo";

export class UserInfo implements IUserInfo {
    constructor (obj?: IUserInfo) {
        Object.assign(this, obj);
    }
    id?: string;
    authenticationType?: string;
    userType?: string;
    userProfileType?: string;
    displayName = '';
    userName = '';
    email = '';
    certificateThumbprint?: string;
    certificateName?: string;
    certificateUniqueIdentifier?: string;
    adminType?: string;
    isAdmin?: boolean;
    firstName = '';
    surname?: string;
    lastName = '';
    organization?: string;
    department?: string;
    jobTitle?: string;
    address?: string;
    libraryCardNumber?: string;
    roles:string[] = [];
    archives:number[] = [];
}