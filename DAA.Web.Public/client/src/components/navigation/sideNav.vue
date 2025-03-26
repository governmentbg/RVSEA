<template>
    <v-navigation-drawer v-model="showNav" temporary app>
        <v-list v-if="isAuthenticated">
            <v-list-item @click="userProfile" :title="displayName" :subtitle="name">
                <template #append>
                    <v-avatar>
                        <v-icon icon="mdi-account-circle" size="x-large" />
                    </v-avatar>
                </template>
            </v-list-item>
            <v-list-item
                v-for="(item, index) in profileNavItems"
                :key="index"
                :title="item.title"
                :value="item"
                :to="item.to"
                @click="item.clickHandler"
            >
                <template v-slot:append v-if="item.icon">
                    <v-avatar>
                        <v-icon :icon="item.icon" />
                    </v-avatar>
                </template>
            </v-list-item>
            <v-divider />
        </v-list>
        <v-list nav density="compact" v-if="!canSeeFilm">
            <v-list-item
                v-for="(item, index) in mainNavItems"
                :key="index"
                :value="item"
                :title="item.title"
                :to="item.to"
            >
                <template v-slot:append v-if="item.icon">
                    <v-avatar>
                        <v-icon :icon="item.icon" />
                    </v-avatar>
                </template>
            </v-list-item>
        </v-list>
        <v-list nav density="compact" v-if="canSeeFilm">
            <v-list-item
                v-for="(item, index) in filmsForReaderNavItems"
                :key="index"
                :value="item"
                :title="item.title"
                :to="item.to"
                @click="item.clickHandler"
            >
                <template v-slot:append v-if="item.icon">
                    <v-avatar>
                        <v-icon :icon="item.icon" />
                    </v-avatar>
                </template>
            </v-list-item>
        </v-list>
        <v-divider />
        <v-list nav density="compact">
            <v-list-item
                v-for="(item, index) in surveysLinkNavGroup"
                :key="index"
                :value="item"
                :title="item.title"
                :to="item.to"
                @click="item.clickHandler"
            >
                <template v-slot:append v-if="item.icon">
                    <v-avatar>
                        <v-icon :icon="item.icon" />
                    </v-avatar>
                </template>
            </v-list-item>
        </v-list>
    </v-navigation-drawer>
</template>
<script lang="ts">
import { computed, defineComponent, onMounted, ref, onUpdated } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from '@/store/user';
import { useRouter } from 'vue-router';

import authenticationService from '@/services/authentication.service';
import { useRedirect } from '@/helpers/router.helper';
import { ProfileType } from '@/enums/profile';
import authorization from '@/helpers/authorization.helper';
import linksService from '@/services/links.service';
import filmService from '@/services/film.service';

export default defineComponent({
    name: 'SideNavigation',
    props: {
        modelValue: {
            type: Boolean,
            default: false,
        },
    },
    setup(props, context) {
        const { t } = useI18n();
        const mainNavItems = ref();
        const surveysLinkNavGroup = ref();
        const filmsForReaderNavItems = ref();
        const profileNavItems = ref();
        const userStore = useStore();
        const isAuthenticated = computed(() => authorization.isAuthenticated());
        const canSeeFilm = computed(() => userStore.getters.profileType === ProfileType.ReaderInReadingRoom);
        const canSeeApplications = computed(
            () => authorization.isAuthenticated() && userStore.getters.profileType === ProfileType.FundCreator
        );
        const displayName = computed(() => userStore.getters.fullName ?? userStore.getters.name);
        const name = computed(() => userStore.getters.name);

        const userProfile = () => {
            useRedirect(router, 'UserProfile');
        };
        const showNav = computed({
            get: () => props.modelValue,
            set: (value) => context.emit('update:modelValue', value),
        });

        const router = useRouter();

        const setmainNavItemsIfUserIsAReader = () => {
            if (!canSeeApplications.value) {
                mainNavItems.value = [
                    {
                        icon: 'mdi-home',
                        title: t('navigation.left.home'),
                        to: { name: 'Home' },
                    },
                    {
                        icon: 'mdi-chart-box',
                        title: t('navigation.left.reports'),
                        to: { name: 'Reports' },
                    },
                    // {
                    //     icon: 'mdi-magnify',
                    //     title: t('navigation.left.search'),
                    //     to: { name: 'Search' },
                    // },
                ];
            } else {
                mainNavItems.value = [
                    {
                        icon: 'mdi-home',
                        title: t('navigation.left.home'),
                        to: { name: 'Home' },
                    },
                    {
                        icon: 'mdi-application-edit',
                        title: t('navigation.left.applications'),
                        to: { name: 'Applications' },
                    },
                    {
                        icon: 'mdi-chart-box',
                        title: t('navigation.left.reports'),
                        to: { name: 'Reports' },
                    },
                    // {
                    //     icon: 'mdi-magnify',
                    //     title: t('navigation.left.search'),
                    //     to: { name: 'Search' },
                    // },
                ];
            }
        };

        const filmsForReaderNavItemsFunction = () => {
            filmsForReaderNavItems.value = [
                {
                    icon: 'mdi-video-vintage',
                    title: t('navigation.left.films'),
                    to: { name: 'FilmsForReader' },
                },
            ];
        };
        const profileNavItemsFunction = () => {
            profileNavItems.value = [
                {
                    icon: 'mdi-logout',
                    title: t('navigation.left.logout'),
                    to: undefined,
                    clickHandler: async () => {
                        await authenticationService.logout();
                        useRedirect(router, 'Login');
                    },
                },
            ];
        };

        const surveysLinkNavGroupFunction = () => {
            surveysLinkNavGroup.value = [
                {
                    icon: 'mdi-beaker-question-outline',
                    title: t('navigation.left.surveysLink'),
                    to: undefined,
                    clickHandler: async () => {
                        const link = await linksService.getDaaSurveysLink();
                        window.open(link);
                    },
                },
                {
                    icon: 'mdi-book-play-outline',
                    title: t('navigation.left.eServices'),
                    to: undefined,
                    clickHandler: async () => {
                        const link = await filmService.getIsdaEServicesLink();
                        window.open(link);
                    },
                },
                {
                    icon: 'mdi-hand-coin-outline',
                    title: t('navigation.left.prices'),
                    to: undefined,
                    clickHandler: async () => {
                        const link = `https://www.archives.government.bg/34-%D0%A2%D0%B0%D1%80%D0%B8%D1%84%D0%B0_%D0%B8_%D0%A6%D0%B5%D0%BD%D0%B8_%D0%BD%D0%B0_%D1%83%D1%81%D0%BB%D1%83%D0%B3%D0%B8-LM`;
                        window.open(link);
                    },
                },
                {
                    icon: 'mdi-information-outline',
                    title: t('navigation.left.about'),
                    to: undefined,
                    clickHandler: async () => {
                        const link = `https://www.archives.government.bg/`;
                        window.open(link);
                    },
                },
            ];
        };

        onMounted(() => {
            setmainNavItemsIfUserIsAReader();
            surveysLinkNavGroupFunction();
            filmsForReaderNavItemsFunction();
            profileNavItemsFunction();
        });

        onUpdated(() => {
            setmainNavItemsIfUserIsAReader();
            surveysLinkNavGroupFunction();
            filmsForReaderNavItemsFunction();
            profileNavItemsFunction();
        });

        return {
            showNav,
            mainNavItems,
            userProfile,
            profileNavItems,
            filmsForReaderNavItems,
            canSeeFilm,
            isAuthenticated,
            displayName,
            name,
            surveysLinkNavGroup,
        };
    },
});
</script>

<style lang="scss" scoped>
:global(.v-list--nav:has(.v-list-group > .v-list-item--active) > .v-list-item--active) {
    color: black !important;
}

:global(.v-list--nav:has(.v-list-group > .v-list-item--active) > .v-list-item--active > .v-list-item__overlay) {
    color: white !important;
}

.v-list--nav .v-list-item--active,
.v-list-item:hover {
    color: var(--ISDA-main-color4) !important;
}
</style>
