import { IMessage } from "@/interfaces/notification";

export class Message implements IMessage {
    constructor (obj?: IMessage) {
        Object.assign(this,obj);
    }
    text: string | undefined;
    title?: string | undefined;
    type?: string | undefined;
    timeout?: number = -1;
    display?: boolean = false;
}