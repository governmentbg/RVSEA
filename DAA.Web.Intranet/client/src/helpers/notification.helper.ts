import { IMessage } from "@/interfaces/notification"
import { Message } from "@/models/notification";
import { Ref } from "vue";

export const displayMessage = (component: Ref<IMessage>, text?: string, type?: string, title?: string, timeout?: number, forceDisplay: boolean = false) => {
    // if (!component.value 
    //     || !component.value.display 
    //     || (component.value.type !== undefined && component.value.type !== 'error') 
    //     || forceDisplay) {
        console.log(forceDisplay);
        
        component.value = new Message({
            text: text,
            display: true,
            type: type,
            timeout: timeout,
            title: title,
        });
    //}
};
