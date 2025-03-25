import { IMessage, INotification, INotificationsHub } from "@/interfaces/notification";
import { IDataTableResponse } from "@/interfaces/dataTable";

export class Message implements IMessage {
    constructor(obj?: IMessage) {
        Object.assign(this, obj);
    }
    text: string | undefined;
    title?: string | undefined;
    type?: string | undefined;
    timeout?: number = -1;
    display?: boolean = false;
}

export class NotificationViewModel {
    constructor(obj: INotification) {
        this.id = obj.id || 0;
        this.toUserId = obj.toUserId;
        this.to = obj.to;
        this.subject = obj.subject;
        this.body = obj.body;
        this.createdOn = new Date(obj.createdOn);
        this.sentOn = obj.sentOn ? new Date(obj.sentOn) : undefined;
        this.isSeen = obj.isSeen || false;
        this.isSent = obj.isSent || false;

    }

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

export class NotificationDataSourceResponseModel<T>{
    constructor(obj: IDataTableResponse<T>) {
        this.totalCount = obj.totalCount || 0;
        this.items = obj.items || [];
    }

    totalCount: number;
    items: T[];
    totalUnseen?: number = 0;
}

export class UINotificationModel {
    id: number = 0;
    userId: string = ""
}

export class NotificationsHubModel {
    constructor(obj: INotificationsHub) {
      this.establishConnection = obj.establishConnection,
      this.stopConnection = obj.stopConnection
    }
  
    establishConnection: (jwtToken: string) => void;
    stopConnection: () => void;
  }