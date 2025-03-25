export interface IMessage {
    text: string | undefined,
    title?: string,
    type?: string,
    timeout?: number,
    display?: boolean,
}