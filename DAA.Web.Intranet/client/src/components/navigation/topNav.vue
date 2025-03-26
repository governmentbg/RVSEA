<template>
  <v-app-bar color="primary" app>
    <v-app-bar-nav-icon title="Menu" icon="mdi-menu" color="white" @click.stop="navIconClickHandler" />
    <a @click="getBaseUrl()">
    <picture id="picture_logo">
      <source srcset="@/assets/logoDAA1.png">
      <!-- <source srcset="@/assets/logoDAA2.png"> -->
      <img alt="DAALogo" width="75" height="46.35">
      </picture>
    </a>
    <v-toolbar-title :text="t('navigation.title')" />
    <v-spacer />
    <file-uploader v-if="isAuthenticated && hasFileUploaderAllowedRole"/>
  </v-app-bar>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue';
import { useI18n } from 'vue-i18n';
// import Notifications from '@/components/buttons/notifications.vue';
import FileUploader from '@/components/buttons/fileUploader.vue';
import authorization from '@/helpers/authorization.helper'
import { appStore as useAppStore } from "@/store/app";
import { RoleNames } from '@/enums/roles';
import { useStore } from '@/store/user';

export default defineComponent({
    name: 'TopNavigation',
    components: { /*Notifications,*/ FileUploader },
    setup(props, context) {
        const { t } = useI18n();
        const userStore = useStore();

        const navIconClickHandler = () => {
            context.emit('navIconClick');
        };

        const getBaseUrl = () => {
          window.location.href = useAppStore().getters.uiUrl;
        }

        const isAuthenticated = computed(() => authorization.isAuthenticated())
        const hasFileUploaderAllowedRole = computed(() => {
          const result = 
            userStore.getters.hasRole(RoleNames.GroupI) ||
            userStore.getters.hasRole(RoleNames.GroupZ) ||
            userStore.getters.hasRole(RoleNames.GroupJ)

          return result;
        })

    return {
      t,
      navIconClickHandler,
      isAuthenticated,
      hasFileUploaderAllowedRole,
      getBaseUrl,
    };
  },
});
</script>

<style scoped lang="scss">
// .v-app-bar-nav-icon {
//     color: white !important;
// }

picture {
    margin: 0px 10px;
}

#picture_logo {
  cursor: pointer;
}
</style>
