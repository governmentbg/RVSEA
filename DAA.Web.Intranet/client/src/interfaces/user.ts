export interface IUser {
    id: string | undefined,
    isAdmin: boolean | undefined,
    adminType: string | undefined,
    profileType : string | undefined,
    name: string;
    displayName: string;
    email: string;
    token: string;
    tokenExpiration: Date;
    roles: Array<string>;
}