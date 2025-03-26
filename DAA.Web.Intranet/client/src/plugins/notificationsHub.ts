import { HubConnectionBuilder, LogLevel } from '@microsoft/signalr';
import { App } from 'vue';
import { appStore as useAppStore } from "@/store/app";
import { userStore as useUserStore } from '@/store/user';
import { UINotificationModel, NotificationsHubModel } from "@/models/notification";
import { ActionTypes } from "@/store/user/actions";

export default {
  install: function (app: App<Element>): void {
    let startedPromise: (Promise<unknown> | null) = null;
    
    const notificationsHub = new NotificationsHubModel({
      establishConnection: (/*jwtToken: string*/) => {
        const url = `${useAppStore().getters.baseUrl}/notificationsHub`;
        const connection = new HubConnectionBuilder()
        // Bearer token
          //.withUrl(url, { accessTokenFactory: () => jwtToken })
        // Windows authentication
          .withUrl(url, 
            {
                withCredentials: true
            })
          .configureLogging(LogLevel.Information)
          .build();

        connection.on('SendNotifications', (notifications) => {
          console.log('HUB: receiving notifications ...');
          console.log(notifications);
          const data = notifications as UINotificationModel[];
          useUserStore().dispatch(ActionTypes.IncreaseUnSeenNotifications, data);
          useUserStore().dispatch(ActionTypes.RefreshNotificationsPage, true);
        });
        
        function start() {
          startedPromise = connection.start().catch(err => {
            console.error('HUB: Failed to connect with hub', err);
            //return new Promise((resolve, reject) => setTimeout(() => start().then(resolve).catch(reject), 20000));
            return null;
          });
          return startedPromise;
        }
        // temporarily disable real-time notifications
        //connection.onclose(() => start());
  
        start();
      },
      stopConnection: async () => {
        if (!startedPromise) {
          return;
        }

        return startedPromise
          //.then(() => connection!.stop())
          .then(() => startedPromise = null)
      }
    });

    app.config.globalProperties.$notificationsHub = notificationsHub;
    app.provide('notificationsHub', notificationsHub);
  }
}