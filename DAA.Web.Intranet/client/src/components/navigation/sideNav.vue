<template>
    <v-navigation-drawer v-model="showNav" temporary app>
        <v-list v-if="isAuthenticated">
            <v-list-item :title="displayName" :subtitle="name" @click="viewProfilePage">
                <template v-slot:append>
                    <v-avatar>
                        <v-icon icon="mdi-account-circle" size="x-large" />
                    </v-avatar>
                </template>
                <!-- <v-list-item-avatar>
                    <v-icon icon="mdi-account-circle" size="x-large" />
                </v-list-item-avatar> -->
            </v-list-item>
            <v-list-item
                :title="profileNavGroup.title"
                :to="profileNavGroup.to"
                @click="profileNavGroup.clickHandler"
            ></v-list-item>
        </v-list>
        <v-divider v-if="isAuthenticated" />
        <v-list nav density="compact">
            <side-navigation-item
                v-for="(item, index) in mainNavItems"
                :key="index"
                :icon="item.icon"
                :title="item.title"
                :value="item.title"
                :to="item.to"
                :clickHandler="item.clickHandler"
                :visible="item.visible"
            ></side-navigation-item>
            <side-navigation-item-group
                :icon="eDocsNavGroup.icon"
                :title="eDocsNavGroup.title"
                :visible="eDocsNavGroup.visible"
            >
                <template #items>
                    <side-navigation-item
                        v-for="(item, index) in eDocsNavGroup.items"
                        :key="index"
                        :icon="item.icon"
                        :title="item.title"
                        :to="item.to"
                        :clickHandler="item.clickHandler"
                        :visible="item.visible"
                    ></side-navigation-item>
                </template>
            </side-navigation-item-group>
            <side-navigation-item-group
                :icon="commissionNavGroup.icon"
                :title="commissionNavGroup.title"
                :visible="commissionNavGroup.visible"
            >
                <template #items>
                    <side-navigation-item
                        v-for="(item, index) in commissionNavGroup.items"
                        :key="index"
                        :icon="item.icon"
                        :title="item.title"
                        :to="item.to"
                        :clickHandler="item.clickHandler"
                        :visible="item.visible"
                    ></side-navigation-item>
                </template>
            </side-navigation-item-group>
            <side-navigation-item-group
                :icon="tasksNavGroup.icon"
                :title="tasksNavGroup.title"
                :visible="tasksNavGroup.visible"
            >
                <template #items>
                    <!-- <v-row
                        class="col-12"
                        style="max-height: 80px; margin-bottom: -22px; margin-top: -22px"
                        :key="index"
                    > -->
                    <!-- <v-col class="col"> -->
                    <side-navigation-item
                        v-for="(item, index) in tasksNavGroup.items"
                        :key="index"
                        class="col-12"
                        :icon="item.icon"
                        :title="item.title"
                        :to="item.to"
                        :clickHandler="item.clickHandler"
                        :visible="item.visible"
                    >
                    </side-navigation-item>
                    <!-- </v-col> -->
                    <!-- <span v-if="item.title == t('navigation.left.myTasks')" class="component">
                            <div v-if="newTaskCount !== 0" class="newTaskCount">
                                {{ newTaskCount }}
                            </div>
                        </span> -->
                    <!-- </v-row> -->
                </template>
            </side-navigation-item-group>
            <v-divider />
            <side-navigation-item-group
                :icon="settingsNavGroup.icon"
                :title="settingsNavGroup.title"
                :visible="settingsNavGroup.visible"
            >
                <template #items>
                    <side-navigation-item
                        v-for="(item, index) in settingsNavGroup.items"
                        :key="index"
                        :icon="item.icon"
                        :title="item.title"
                        :to="item.to"
                        :clickHandler="item.clickHandler"
                        :visible="item.visible"
                    ></side-navigation-item>
                </template>
            </side-navigation-item-group>
            <side-navigation-item-group
                v-show="canSeeReaderInReadingRoomNavGroup"
                :icon="readerInReadingRoomNavGroup.icon"
                :title="readerInReadingRoomNavGroup.title"
                :visible="readerInReadingRoomNavGroup.visible"
            >
                <template #items>
                    <side-navigation-item
                        v-for="(item, index) in readerInReadingRoomNavGroup.items"
                        :key="index"
                        :icon="item.icon"
                        :title="item.title"
                        :to="item.to"
                        :clickHandler="item.clickHandler"
                        :visible="item.visible"
                    ></side-navigation-item>
                </template>
            </side-navigation-item-group>
        </v-list>
    </v-navigation-drawer>
</template>
<script lang="ts">
import { computed, defineComponent, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from '@/store/user';

import SideNavigationItem from '@/components/navigation/sideNavItem.vue';
import SideNavigationItemGroup from '@/components/navigation/sideNavItemGroup.vue';
import authenticationService from '@/services/authentication.service';
import { useRedirect } from '@/helpers/router.helper';
import { useRouter } from 'vue-router';
import { RoleNames } from '@/enums/roles';
import taskService from '@/services/task.service';
export default defineComponent({
    name: 'SideNavigation',
    components: {
        SideNavigationItem,
        SideNavigationItemGroup,
    },
    props: {
        modelValue: {
            type: Boolean,
            default: false,
        },
        sideNav: {
            type: Boolean,
            default: false,
        },
    },
    setup(props, context) {
        const { t } = useI18n();

        const userStore = useStore();
        const router = useRouter();
        const newTaskCount = ref(0);
        const canSeeReaderInReadingRoomNavGroup = computed(() => userStore.getters.hasRole(RoleNames.GroupI1));
        const userId = computed(() => userStore.getters.userId);
        const showNav = computed({
            get: () => props.modelValue,
            set: (value) => context.emit('update:modelValue', value),
        });

        const isAuthenticated = computed(() => userStore.getters.isAuthenticated);
        const displayName = computed(() => userStore.getters.fullName ?? userStore.getters.name);
        const name = computed(() => userStore.getters.name);

        const viewProfilePage = () => {
            useRedirect(router, 'DisplayAvatar');
        };

        const getUnseenTaskCount = async () => {
            if (userId.value != null && userId.value != '' && userId.value != undefined) {
                taskService
                    .getMyNewTasksCount()
                    .then((response) => {
                        const count = response as number;
                        newTaskCount.value = count;
                    })
                    .catch((err) => {
                        console.log(err);
                    });
            } else return;
        };

        const mainNavItems = [
            {
                icon: 'mdi-home',
                title: t('navigation.left.home'),
                to: { name: 'Home' },
            },
            {
                icon: 'mdi-archive',
                title: t('navigation.left.funds'),
                to: { name: 'Funds' },
            },
            {
                icon: 'mdi-clipboard-list',
                title: t('navigation.left.inventories'),
                to: { name: 'Inventories' },
            },
            {
                icon: 'mdi-file-document-multiple-outline',
                title: t('navigation.left.entities'),
                to: { name: 'ArchiveEntities' },
            },
            {
                icon: 'mdi-file-document-outline',
                title: t('navigation.left.documents'),
                to: { name: 'Documents' },
            },
            {
                icon: 'mdi-video-vintage',
                title: t('navigation.left.films'),
                to: { name: 'Films' },
            },
            {
                icon: 'mdi-chart-box',
                title: t('navigation.left.reports'),
                to: { name: 'Reports' },
            },
            {
                icon: 'mdi-folder-multiple',
                title: t('navigation.left.recordA'),
                to: { name: 'RecordsA' },
            },
        ];

        const settingsNavGroup = {
            icon: 'mdi-cog',
            title: t('navigation.left.settings'),
            items: [
                {
                    //icon: 'mdi-users',
                    title: t('navigation.left.internalUsers'),
                    to: { name: 'Users' },
                },
                {
                    //icon: 'mdi-users',
                    title: t('navigation.left.externalUsers'),
                    to: { name: 'ExternalUsers' },
                },
                {
                    //icon: 'mdi-office-building-cog',
                    title: t('navigation.left.archives'),
                    to: { name: 'Archives' },
                },
                {
                    //icon: 'mdi-office-building-cog',
                    title: t('navigation.left.nomenclatures'),
                    to: { name: 'Nomenclatures' },
                },
                {
                    //icon: 'mdi-office-building-cog',
                    title: t('navigation.left.packageATemplates'),
                    to: { name: 'PackageATemplates' },
                },
                {
                    //icon: 'mdi-office-building-cog',
                    title: t('navigation.left.tasksTemplates'),
                    to: { name: 'TasksTemplates' },
                },
                {
                    //icon: 'mdi-office-building-cog',
                    title: t('navigation.left.passportization'),
                    to: { name: 'VerifyChecksums' },
                },
                {
                    title: t('navigation.left.converter'),
                    to: { name: 'ConvertToPdf' },
                },
                {
                    title: t('navigation.left.informationBoard'),
                    to: { name: 'Information' },
                },
            ],
        };

        const tasksNavGroup = {
            icon: 'mdi-cog',
            title: t('navigation.left.tasks'),
            items: [
                {
                    title: t('navigation.left.myTasks'),
                    to: { name: 'MyTasks' },
                },
                {
                    title: t('navigation.left.tasksAssignedByMe'),
                    to: { name: 'TasksAssignedByMe' },
                },
            ],
        };

        const eDocsNavGroup = {
            icon: 'mdi-package',
            title: t('navigation.left.eDocsCollection'),
            items: [
                {
                    //icon: 'mdi-users',
                    title: t('navigation.left.eDocsCollectingApplications'),
                    to: { name: 'ЕDocsCollectingApplications' },
                },
                {
                    //icon: 'mdi-users',
                    title: t('navigation.left.eDocsCollectingProcesses'),
                    to: { name: 'ЕDocsCollectingProcesses' },
                },
            ],
        };

        const commissionNavGroup = {
            icon: 'mdi-cog',
            title: t('navigation.left.sessions'),
            items: [
                {
                    title: t('navigation.left.sessionDates'),
                    to: { name: 'Sessions' },
                },
                {
                    title: t('navigation.left.upcomingSessions'),
                    to: { name: 'UpcomingSessions' },
                },
                {
                    title: t('navigation.left.pastSessions'),
                    to: { name: 'PastSessions' },
                },
            ],
        };

        const readerInReadingRoomNavGroup = {
            icon: 'mdi-users',
            title: t('navigation.left.readerAccess'),
            items: [
                {
                    //icon: 'mdi-users',
                    title: t('navigation.left.readerAccessRecords'),
                    to: { name: 'DisplayFilmReviews' },
                },
                {
                    //icon: 'mdi-users',
                    title: t('navigation.left.readerProfiles'),
                    to: { name: 'ReaderUsers' },
                },
            ],
        };

        const profileNavGroup = {
            icon: 'mdi-logout',
            title: t('navigation.left.logout'),
            to: undefined,
            clickHandler: async () => {
                await authenticationService.logout();

                // try {
                //     notificationsHub.stopConnection();
                // } catch (e) {
                //     console.log(e);
                // }

                useRedirect(router, 'Logout');
            },
        };

        watch(
            () => props.sideNav,
            (val) => {
                if (val === true) {
                    getUnseenTaskCount();
                }
            }
        );

        return {
            t,
            isAuthenticated,
            displayName,
            eDocsNavGroup,
            name,
            showNav,
            mainNavItems,
            profileNavGroup,
            newTaskCount,
            settingsNavGroup,
            tasksNavGroup,
            commissionNavGroup,
            readerInReadingRoomNavGroup,
            canSeeReaderInReadingRoomNavGroup,
            viewProfilePage,
        };
    },
});
</script>

<style lang="scss" scoped>
// :global(.v-list--nav:has(.v-list-group > .v-list-item--active) > .v-list-item--active) {
//     color: black !important;
// }

// :global(.v-list--nav:has(.v-list-group > .v-list-item--active) > .v-list-item--active > .v-list-item__overlay) {
//     color: white !important;
// }

// .v-list--nav .v-list-item--active,
// .v-list-item:hover {
//     color: var(--ISDA-main-color4) !important;
// }
// .unseenNotificationsCounter {
//     float: right;
//     margin-top: 8px;
//     color: white;
//     font-weight: bold;
//     border-radius: 10px;
//     border-style: solid;
//     font-size: small;
//     background-color: rgb(212, 0, 0);
//     /* color: white; */
//     border-color: rgb(212, 0, 0);
//     font-weight: 500;
//     padding-left: 2px;
//     padding-right: 2px;
//     line-height: inherit;
// }
.component {
    position: relative;
    max-height: 36px;
}
</style>
