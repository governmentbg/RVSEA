export class UserProfileModel {
    constructor(obj?: UserProfileModel) {
        if (obj) {
            Object.assign(this, obj);
        }
    }
    userId: string | undefined;
    profileType: string | undefined;
    entityType: string | undefined;
    firstName: string | undefined;
    surname: string | undefined;
    lastName: string | undefined;
    displayName: string | undefined;
    address: string | undefined;
    organization: string | undefined;
    department: string | undefined;
    jobTitle: string | undefined;
    libraryCardNumber: string | undefined;
}

export class UserProfileAndRolesModel {
    constructor(obj?: UserProfileAndRolesModel) {
        if (obj) {
            Object.assign(this, obj);
        }
    }
    userId: string | undefined;
    firstName: string | undefined;
    surname: string | undefined;
    lastName: string | undefined;
    displayName: string | undefined;
    address: string | undefined;
    organization: string | undefined;
    department: string | undefined;
    jobTitle: string | undefined;
    roles?: string[] = [];
    archives?: number[] = [];
}
