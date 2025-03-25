<template>
    <v-app>
        <side-navigation v-model="sideNav" :sideNav="sideNav" />
        <top-navigation class="d-print-none" v-if="isAuthenticated" @navIconClick="sideNav = !sideNav" />
        <v-main>
            <v-container fluid>
                <router-view></router-view>
            </v-container>
        </v-main>

        <v-footer
            v-if="isAuthenticated"
            color="primary"
            class="d-print-none d-flex align-items-start justify-content-center"
            app
        >
            <picture style="margin-top: 15px">
                <source srcset="@/assets/ES.jpg" />
                <img class="footer" alt="ESLogo" width="104.6" height="100" />
            </picture>
            <div id="footertext">
                <p>
                    {{ t('footer.footerText') }}
                </p>
                <strong>
                    {{ t('footer.version', { version: version }) }}
                </strong>
            </div>
            <picture style="margin-top: 15px">
                <source srcset="@/assets/DU.jpg" />
                <img class="footer" alt="DULogo" width="130.54" height="100" />
            </picture>
        </v-footer>
        <NotificationMessage :options="message" />
    </v-app>
</template>

<script lang="ts">
import { computed, defineComponent, provide, ref, watch, onUnmounted, onMounted /*, inject */ } from 'vue';
import { useI18n } from 'vue-i18n';
import { IMessage } from './interfaces/notification';

import authorization from '@/helpers/authorization.helper';
import settingsService from '@/services/settings.service';

import TopNavigation from '@/components/navigation/topNav.vue';
import SideNavigation from '@/components/navigation/sideNav.vue';
import NotificationMessage from '@/components/notification/message.vue';
// import { useStore } from '@/store/user';
// import { NotificationsHubModel } from '@/models/notification';

export default defineComponent({
    name: 'App',
    components: {
        TopNavigation,
        SideNavigation,
        NotificationMessage,
    },
    setup() {
        const { t } = useI18n();

        const isAuthenticated = computed(() => authorization.isAuthenticated());
        const sideNav = ref(false);
        const message = ref<IMessage>();
        provide('notificationMessage', message);

        // const userStore = useStore();
        // const notificationsHub = inject('notificationsHub') as NotificationsHubModel;

        if (isAuthenticated.value) {
            authorization.getUserRoles();

            // try {
            //     notificationsHub.establishConnection(userStore.getters.token);
            // } catch (e) {
            //     console.log(e);
            // }
        }

        const version = ref('');
        const getVersion = async () => {
            try {
                const result = await settingsService.getVersion();
                version.value = result as string;
            } catch (error) {
                console.log(error);
            }
        };

        watch([() => sideNav.value, () => isAuthenticated.value], ([val, valAuth]) => {
            sideNav.value = val;
            if (valAuth) {
                authorization.getUserRoles();
            }
        });

        onUnmounted(authorization.clearUserRoles);

        onMounted(async () => {
            await getVersion();
        });

        return {
            t,
            sideNav,
            isAuthenticated,
            message,
            version,
        };
    },
});
</script>

<style lang="scss">
@import '~bootstrap/scss/bootstrap';
//@import '~vuetify/dist/vuetify.css';
@import '~@vueform/multiselect/themes/default';

html,
body {
    min-height: 100vh;
}
#app {
    min-height: 100vh;
}
.v-application {
    min-height: 100vh;
}
.v-footer {
    flex: 0;
}
.v-card-title-uppercase {
    text-transform: uppercase !important;
}
.required::after {
    content: '*';
    //color: var(--bs-danger);
}

img.footer {
    margin: 0px 25px !important;
}

#footertext {
    margin: 20px 0px;
    text-align: center;
}

footer {
    position: absolute !important;
    bottom: 0 !important;
    padding: 0px !important;
}

:root {
   
    --v-disabled-opacity: 0.85;

    --popper-theme-background-color: #ffffff;
    --popper-theme-background-color-hover: #ffffff;
    --popper-theme-text-color: #333333;
    --popper-theme-border-width: 1px;
    --popper-theme-border-style: solid;
    --popper-theme-border-color: #dadada;
    --popper-theme-border-radius: 6px;
    --popper-theme-padding: 0.5rem;
    --popper-theme-box-shadow: 0 6px 30px -6px rgba(0, 0, 0, 0.25);

    --ms-ring-color: var(--bs-gray-200);
    // --ms-placeholder-color: #9CA3AF;

    //--ms-spinner-color: var(--bs-primary);
    --ms-spinner-color: rgb(var(--v-theme-primary));
    // --ms-caret-color: #999999;
    // --ms-clear-color: #999999;
    // --ms-clear-color-hover: #000000;

    //--ms-tag-bg: var(--bs-primary);
    --ms-tag-bg: rgb(var(--v-theme-primary));
    // --ms-tag-bg-disabled: #9CA3AF;
    // --ms-tag-color: #FFFFFF;
    // --ms-tag-color-disabled: #FFFFFF;

    // --ms-dropdown-bg: #FFFFFF;
    // --ms-dropdown-border-color: #D1D5DB;

    // --ms-group-label-bg: #E5E7EB;
    // --ms-group-label-color: #374151;
    // --ms-group-label-bg-pointed: #D1D5DB;
    // --ms-group-label-color-pointed: #374151;
    // --ms-group-label-bg-disabled: #F3F4F6;
    // --ms-group-label-color-disabled: #D1D5DB;
    //--ms-group-label-bg-selected: var(--bs-primary);
    --ms-group-label-bg-selected: rgb(var(--v-theme-primary));
    //--ms-group-label-color-selected: #FFFFFF;
    //--ms-group-label-bg-selected-pointed: var(--bs-primary);
    --ms-group-label-bg-selected-pointed: rgb(var(--v-theme-primary));
    // --ms-group-label-color-selected-pointed: #FFFFFF;
    // --ms-group-label-bg-selected-disabled: #75cfb1;
    // --ms-group-label-color-selected-disabled: #D1FAE5;

    // --ms-option-bg-pointed: #FFFFFF;
    // --ms-option-color-pointed: #1F2937;
    //--ms-option-bg-selected: var(--bs-primary);
    --ms-option-bg-selected: rgb(var(--v-theme-primary));
    // --ms-option-color-selected: #FFFFFF;
    // --ms-option-bg-disabled: #FFFFFF;
    // --ms-option-color-disabled: #D1D5DB;
    //--ms-option-bg-selected-pointed: var(--bs-primary);
    --ms-option-bg-selected-pointed: rgb(var(--v-theme-primary));
    // --ms-option-color-selected-pointed: #FFFFFF;
    // --ms-option-bg-selected-disabled: #FFFFFF;
    // --ms-option-color-selected-disabled: #D1FAE5;

    // --ms-empty-color: #4B5563;

    //--ISDA-main-color1: #c66310;
    --ISDA-main-color1: #423129;
    --ISDA-main-color2: #f6e8e0; //Преработен ISDA-main-color3
    --ISDA-main-color2-1: #fff9f6; //Преработен ISDA-main-color3
    --ISDA-main-color3: #bdada5;
    //--ISDA-main-color4: #423129;
    --ISDA-main-color4: #c66310;
    --ISDA-main-color4-loader: #ffb300;
    //--ISDA-main-color4-loader: #ffee00;
    //--ISDA-main-color4-loader: #0040ff;
    --ISDA-main-color4-rgb-op: rgb(198, 99, 16, 0.5);
    //--ISDA-main-fund-color: #0c740c;
    --ISDA-main-fund-color: #005600;
    --ISDA-main-fund-color-light: #e8fce8;
    --ISDA-main-fund-color-light2: #f6fff6;
    //--ISDA-main-inv-color: #691569;
    --ISDA-main-inv-color: #620062;
    --ISDA-main-inv-color-light: #fcebfc;
    --ISDA-main-inv-color-light2: #fff7ff;
    --ISDA-main-ae-color: #176396;
    --ISDA-main-ae-color-light: #e5f2fd;
    --ISDA-main-ae-color-light2: #f4faff;
    --ISDA-main-doc-color: #069385;
    --ISDA-main-doc-color-light: #e9ffff;
    --ISDA-main-doc-color-light2: #f6ffff;
    --input-background-color: #a4a4a411;
    --input-border-color: #b4a8a3;
}

//Reports-Grid

// footer.v-footer {
//     background-color: var(--ISDA-main-color1) !important;
// }

// .v-text-field input:disabled,
// .v-text-field label,
// .v-textarea input:disabled {
// 	color: red !important;
// 	//color: black !important;
//     opacity: 1 !important;
// }

div.v-field:has(:disabled),
div.v-field:has(:disabled) label,
div.form-check:has(:disabled) label {
    opacity: 0.7 !important;
}
//TODO Да се обсъди с екипа колко да е !?
// div.v-field:has(:read-only),
// div.v-field:has(:read-only) label,
// div.form-check:has(:read-only) label {
//     opacity: 0.7 !important;
// }


.four-lines {
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 4;
  white-space: normal;
  max-height: 130px !important;
}
</style>