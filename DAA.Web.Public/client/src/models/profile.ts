export class UserProfileModel {
    constructor(obj?: UserProfileModel) {
        if (obj) {
            Object.assign(this, obj);
        }
    }
    userId: string | undefined;
    email?: string;
    profileType: string | undefined;
    entityType: string | undefined;
    firstName: string | undefined;
    surname: string | undefined;
    lastName: string | undefined;
    fullName: string | undefined;
    displayName: string | undefined;
    address: string | undefined;
    organization: string | undefined;
    department: string | undefined;
    jobTitle: string | undefined;
    libraryCardNumber: string | undefined;
    phone?: string;
    eik: string | undefined;
    organizationEIK?: string;
    libraryCardValidTo: string | undefined;
}
