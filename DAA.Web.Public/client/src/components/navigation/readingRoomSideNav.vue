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
        <v-list nav density="compact" v-if="isAuthenticated">
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
        <!-- <v-list nav density="compact">
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
        </v-list> -->
    </v-navigation-drawer>
</template>
<script lang="ts">
import { computed, defineComponent, onMounted, ref, onUpdated } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from '@/store/user';
import { useRouter } from 'vue-router';

import authenticationService from '@/services/authentication.service';
import { useRedirect } from '@/helpers/router.helper';
import authorization from '@/helpers/authorization.helper';

export default defineComponent({
    name: 'ReadingRoomSideNavigation',
    props: {
        modelValue: {
            type: Boolean,
            default: false,
        },
    },
    setup(props, context) {
        const { t } = useI18n();
        const filmsForReaderNavItems = ref();
        const profileNavItems = ref();
        const userStore = useStore();
        const isAuthenticated = computed(() => authorization.isAuthenticated());
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

        const filmsForReaderNavItemsFunction = () => {
            filmsForReaderNavItems.value = [
            {
                icon: 'mdi-video-vintage',
                title: t('navigation.left.films'),
                to: { name: 'FilmsForReader' },
            },
        ]};
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
        ]};

        
        onMounted(() => {
            filmsForReaderNavItemsFunction();
            profileNavItemsFunction();
        });

        onUpdated(() => {
            filmsForReaderNavItemsFunction();
            profileNavItemsFunction();
        });

        return {
            showNav,
            userProfile,
            profileNavItems,
            filmsForReaderNavItems,
            isAuthenticated,
            displayName,
            name,
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
