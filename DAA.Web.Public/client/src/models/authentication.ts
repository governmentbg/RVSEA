export class LoginModel {
    constructor(email?: string, password?: string) {
        this.email = email;
        this.password = password;
    }
    email: string | undefined;
    password: string | undefined;
}

export class RegistrationModel {
    constructor(obj?: RegistrationModel) {
        if (obj) {
            Object.assign(this, obj);
        }
    }
    firstName: string | undefined;
    surname: string | undefined;
    lastName: string | undefined;
    displayName: string | undefined;
    address: string | undefined;
    organization: string | undefined;
    department: string | undefined;
    jobTitle: string | undefined;
    libraryCardNumber: string | undefined;
    profileType: string | undefined;
    profileEntityType: string | undefined;
    email: string | undefined;
    emailConfirmation: string | undefined;
    password: string | undefined;
    passwordConfirmation: string | undefined;
    eik: string | undefined;
    phone: string | undefined;
    libraryCardValidTo: string | undefined;
}

export class ConfirmationModel {
    constructor(obj?: ConfirmationModel) {
        if (obj) {
            Object.assign(this, obj);
        }
    }
    userId: string | undefined;
    confirmationToken: string | undefined;
}

export class PasswordModel {
    userId: string | undefined;
    passwordToken: string | undefined;
    password: string | undefined;
    passwordConfirmation: string | undefined;
    currentPassword?: string;
}

export class EAuthRequestModel {
    requestId: string | null = null;
    eAuthUrl: string | null = null;
    samlRequest: string | null = null; // Base64 кодиран.
    relayState: string | null = null;
    samlRequestBeautified: string | null = null;
    samlRequestDecoded: string | null = null;
    relayStateDecoded: string | null = null;
    signatureStatusName: string | null = null;
}

export class LoginReaderModel {
    constructor(username?: string, password?: string) {
        this.username = username;
        this.password = password;
    }
    username: string | undefined;
    password: string | undefined;
}
