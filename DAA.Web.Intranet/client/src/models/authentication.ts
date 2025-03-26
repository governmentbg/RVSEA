import { IChangeUserPassword } from "@/interfaces/userInfo";

export class LoginModel {
    constructor(username?: string, password?: string) {
        this.username = username;
        this.password = password;
    }
    username: string | undefined;
    password: string | undefined;
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

export class RegistrationReaderModel {
    constructor(obj?: RegistrationReaderModel) {
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

    // id?: string;
    // authenticationType?: string;
    // userType?: string;
    // userProfileType?: string;
    // userName = '';
    // // certificateThumbprint?: string;
    // // certificateName?: string;
    // // certificateUniqueIdentifier?: string;
    // // adminType?: string;
    // // isAdmin?: boolean;
    // // roles:string[] = [];    
    // firstName: string | undefined;
    // surname: string | undefined;
    // lastName: string | undefined;
    // displayName: string | undefined;
    // // profileType: string | undefined;
    // // profileEntityType: string | undefined;
    // email: string | undefined;
    // emailConfirmation: string | undefined;
    // password: string | undefined;
    // passwordConfirmation: string | undefined;
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
    email: string | undefined | null;
    emailConfirmation: string | undefined | null;
    password: string | undefined;
    passwordConfirmation: string | undefined;
    username: string | undefined;
  }

  export class ChangeUserPassword implements IChangeUserPassword {
    constructor(obj?: ChangeUserPassword) {
      if (obj) {
        Object.assign(this, obj);
      }
    }
    id: string | undefined;
    userName: string | undefined;
    password: string | undefined;
    passwordConfirmation: string | undefined;
  }