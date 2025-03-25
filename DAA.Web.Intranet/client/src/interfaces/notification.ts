export interface IMessage {
    text: string | undefined,
    title?: string,
    type?: string,
    timeout?: number,
    display?: boolean,
}


export interface INotification {
    id: number;
    toUserId: string;
    to: string;
    subject: string;
    body: string;
    createdOn: Date;
    sentOn?: Date;
    isSeen: boolean;
    isSent: boolean;
}

export interface IUINotification {
    id: number;
    userId: string;
}

export interface INotificationsHub {
    establishConnection: (jwtToken: string) => void;
    stopConnection: () => void;
  }