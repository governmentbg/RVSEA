<template>
    <div class="component">
        <button id="notificationsBtn" type="button" class="btn" aria-expanded="false" @click="goToNotifications">
            <i class="fas fa-bell"></i>
            <div v-if="unseenNotificationsCount !== 0" class="unseenNotificationsCounter">{{ unseenNotificationsCount }}</div>
        </button>
    </div>
</template>

<script lang="ts">
import { computed, defineComponent, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useStore } from '@/store/user'
import notificationService from '@/services/notification.service';
import { ActionTypes as UserStoreActionTypes } from "@/store/user/actions";
import { useI18n } from 'vue-i18n'
import { UINotificationModel } from "@/models/notification";

export default defineComponent({
    name: 'Notifications',
    setup() {
        const userStore = useStore()
        const router = useRouter()
        const { t } = useI18n()

        const goToNotifications = () => {
            router.push({
                name: 'UserNotifications',
            })
        }
        let unseenNotificationsCount = ref(0);
        const unseenNotifications = computed(() => userStore.getters.unseenNotifications.length);

        const getUnseenNotificationsCount = async () => {
            notificationService
            .getUnseenNotifications()
            .then((response) => {
                const list = response as UINotificationModel[];
                unseenNotificationsCount.value = list.length;
                console.log("load unseen count: ", unseenNotificationsCount.value);
                userStore.dispatch(UserStoreActionTypes.SetUnSeenNotifications, list);
            })
            .catch((err) => {
                console.log(err);
            });

        };

        getUnseenNotificationsCount();

        watch(unseenNotifications, () => {
            console.log("watch unseenNotifications");
            unseenNotificationsCount.value = unseenNotifications.value;
            console.log("changed unseenNotifications: ", unseenNotificationsCount.value);
        });

        return {
            unseenNotificationsCount,
            goToNotifications,
            t,
        }
    },
})
</script>

<style lang="scss" scoped>
.component {
    position: relative;
}

.btn {
    color: white;
}

.unseenNotificationsCounter {
  float: right;
  margin-top: 8px;
  color: white;
  font-weight: bold;
  border-radius: 10px;
  border-style: solid;
  font-size: small;
  background-color: rgb(212, 0, 0);
  /* color: white; */
  border-color: rgb(212, 0, 0);
  font-weight: 500;
  padding-left: 2px;
  padding-right: 2px;
  line-height: 12px;
}
</style>
