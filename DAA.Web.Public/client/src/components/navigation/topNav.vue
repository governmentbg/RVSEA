<template>
    <v-app-bar color="var(--ISDA-main-color1)" app>
        <v-app-bar-nav-icon title="Menu" icon="mdi-menu" @click.stop="navIconClickHandler" />
        <a @click="getBaseUrl()">
            <picture id="picture_logo">
                <source srcset="../../assets/logoDAA1.png" />
                <!-- <source srcset="@/assets/logoDAA2.png"> -->
                <img alt="DAALogo" width="75" height="46.35" />
            </picture>
        </a>
        <v-toolbar-title :text="t('navigation.title')" />
        <v-spacer />
        <v-app-bar-nav-icon title="Search" icon="mdi-magnify " @click="goSearch" />

        <!-- <v-app-bar-nav-icon v-if="isAuthenticated" @click="goToUserProfile" icon="mdi-account"> </v-app-bar-nav-icon> -->
        <v-btn v-if="!isAuthenticated" @click="registerClickHandler">{{ t('navigation.top.register') }}</v-btn>
        <v-btn v-if="!isAuthenticated" @click="loginClickHandler">{{ t('navigation.top.login') }}</v-btn>
        <language-picker />
    </v-app-bar>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect } from '@/helpers/router.helper';
import authorization from '@/helpers/authorization.helper';
import LanguagePicker from '@/components/language/languagePicker.vue';
import { appStore as useAppStore } from '@/store/app';

export default defineComponent({
    name: 'TopNavigation',
    components: {
        LanguagePicker,
    },
    setup(props, context) {
        const { t } = useI18n();

        const navIconClickHandler = () => {
            context.emit('navIconClick');
        };
        const isAuthenticated = computed(() => authorization.isAuthenticated());

        const router = useRouter();

        const loginClickHandler = () => {
            useRedirect(router, 'Login');
        };

        const registerClickHandler = () => {
            useRedirect(router, 'Register');
        };
        const goToUserProfile = () => {
            useRedirect(router, 'UserProfile');
        };
        const goSearch = () => {
            useRedirect(router, 'Search');
        };

        const getBaseUrl = () => {
            window.location.href = useAppStore().getters.uiUrl;
        };

        return {
            t,
            navIconClickHandler,
            loginClickHandler,
            registerClickHandler,
            goToUserProfile,
            goSearch,
            isAuthenticated,
            getBaseUrl,
        };
    },
});
</script>

<style scoped lang="scss">
.v-app-bar-nav-icon,
.v-btn,
.v-toolbar {
    color: white !important;
    padding: 0px 5px !important;
}

picture {
    margin: 0px 10px;
}

#picture_logo {
  cursor: pointer;
}
</style>
