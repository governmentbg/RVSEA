export interface IUserInfo {
    id?: string;
    authenticationType?: string;
    userType?: string;
    userProfileType?: string;
    displayName?: string;
    userName: string;
    email: string;
    certificateThumbprint?: string;
    certificateName?: string;
    certificateUniqueIdentifier?: string;
    adminType?: string;
    isAdmin?: boolean;
    firstName: string;
    surname?: string;
    lastName: string;
    organization?: string;
    department?: string;
    jobTitle?: string;
    emailConfirmed?: boolean;
    address?: string;
    libraryCardNumber?: string;
    roles?: string[];
    archives?: number[];
    createdBy?: string;
    createdByName?: string;
    createdOn?: Date;
    updatedBy?: string;
    updatedByName?: string;
    updatedOn?: Date;
    deleted?: boolean;
    deletedBy?: string;
    deletedByName?: string;
    deletedOn?: Date;
}

export interface IRegistrationReaderModel {
    id?: string;
    authenticationType?: string;
    userType?: string;
    userProfileType?: string;
    userName: string;
    certificateThumbprint?: string;
    certificateName?: string;
    certificateUniqueIdentifier?: string;
    adminType?: string;
    isAdmin?: boolean;
    roles: string[];
    firstName: string | undefined;
    surname: string | undefined;
    lastName: string | undefined;
    displayName: string | undefined;
    profileType: string | undefined;
    profileEntityType: string | undefined;
    email: string | undefined;
    emailConfirmation: string | undefined;
    password: string | undefined;
    passwordConfirmation: string | undefined;
}

export interface IChangeUserPassword {
    id?: string;
    userName: string | undefined;
    currPassword?: string | undefined;
    password: string | undefined;
    passwordConfirmation: string | undefined;
}
