<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <div class="py-3">
        <grid
            ref="grid"
            :mode="'remote'"
            :baseUrl="gridUrl"
            :columns="columns"
            :paging="true"
            :pageSize="pageSize"
            :searchLabel="t('grid.search.tooltip')"
        >
        </grid>
    </div>
</template>

<script lang="ts">
import { computed, defineComponent, inject, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirectWithId } from '@/helpers/router.helper';
import { formatYesNo } from '@/helpers/format.helper';

import { ApplicationUserType } from '@/enums/userType';
import { PageSize } from '@/models/grid';
import { Message } from '@/models/notification';
import { IUserInfo } from '@/interfaces/userInfo';
import userService from '@/services/user.service';
import authorization from '@/helpers/authorization.helper';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import Grid from '@/components/grid/grid.vue';
import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
import { IMessage } from '../../../interfaces/notification';
import { ResponseResult } from '../../../models/responseResult';
import { AdminType } from '@/enums/adminType';

export default defineComponent({
    name: 'Users',
    components: {
        //ButtonGroup,
        Breadcrumbs,
        Grid,
    },
    setup() {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const gridUrl = computed(() => userService.getUsersByTypeUrl(ApplicationUserType.External));

        const router = useRouter();

        const grid = ref();
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.externalUsers'),
                disabled: true,
            },
        ];
        const pageSize = PageSize.twenty;

        const rowButtons = [
            {
                name: 'btnDisplayUser',
                text: t('users.buttons.display'),
                tooltip: t('users.buttons.displayTooltip'),
                icon: 'mdi mdi-eye',
                show: authorization.isAuthenticated(),
                clickHandler: (item: IUserInfo) => {
                    if (item.id) {
                        useRedirectWithId(router, 'DisplayExternalUser', item.id);
                    }
                },
            },
            {
                name: 'btnEditUser',
                text: t('users.buttons.edit'),
                tooltip: t('users.buttons.editTooltip'),
                icon: 'mdi mdi-pencil',
                show: authorization.isAuthenticated(),
                clickHandler: (item: IUserInfo) => {
                    if (item.id) {
                        useRedirectWithId(router, 'EditExternalUser', item.id);
                    }
                },
            },
            {
                name: 'btnResetPassword',
                text: t('users.buttons.resetPassword'),
                tooltip: t('users.buttons.resetPasswordTooltip'),
                icon: 'mdi mdi-lock-reset',
                show: authorization.isAuthenticated(),
                clickHandler: async (item: IUserInfo) => {
                    if (item) {
                        if (confirm(t('users.buttons.resetPasswordConfirmation', { title: item.userName }))) {
                            try {
                                await userService.resetUserPassword(item);
                                
                                message.value = new Message({
                                        type: 'success',
                                        text: t('users.buttons.resetPasswordSuccessResult', { title: item.userName}),
                                        display: true,
                                        timeout: 5000,
                                });
                                
                            } catch (error: unknown) {
                                const errorResult = error as ResponseResult;
                                message.value = new Message({
                                    text: errorResult.showMessage ? errorResult.message : t('users.buttons.resetPasswordErrorResult', { title: item.userName}),
                                    display: true,
                                });
                            }
                        }
                    }
                },
            },
            {
                name: 'btnSendConfirmationEmail',
                text: t('users.buttons.sendConfirmation'),
                tooltip: t('users.buttons.sendConfirmationTooltip'),
                icon: 'mdi mdi-mail',
                show: (item: IUserInfo) => {
                    return (
                        authorization.isAuthenticated() &&
                        !item.emailConfirmed &&
                        (authorization.isAdmin(AdminType.GlobalAdmin) || authorization.isAdmin(AdminType.Admin))
                    );
                },
                clickHandler: async (item: IUserInfo) => {
                    if (item) {
                        if (confirm(t('users.buttons.sendConfirmationConfirmation', { title: item.userName }))) {
                            try {
                                await userService.sendAgainConfirmedMail(item.id!);
                                
                               message.value = new Message({
                                    text: t('users.confirmationMailSent'),
                                    display: true,
                                    type: 'success',
                                    timeout: 5000,
                                });
                                
                            } catch (error: unknown) {
                                const errorResult = error as ResponseResult;
                                message.value = new Message({
                                    text: errorResult.showMessage ? errorResult.message : t('users.confirmationMailNotSent'),
                                    display: true,
                                });
                            }
                        }
                    }
                },
            },
            {
                name: 'btnDeleteUser',
                text: t('users.buttons.delete'),
                tooltip: t('users.buttons.deleteTooltip'),
                class: 'text-danger',
                icon: 'mdi mdi-delete',
                show: authorization.isAuthenticated(),
                clickHandler: async (item: IUserInfo) => {
                    if (item.id) {
                        if (confirm(t('users.buttons.deleteConfirmation', { title: item.userName }))) {
                            try {
                                await userService.deleteUser(item.id);
                                
                                if (grid.value) {
                                    grid.value.refreshData();
                                }
                            } catch (error: unknown) {
                                const errorResult = error as ResponseResult;
                                message.value = new Message({
                                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                                    display: true,
                                });
                            }
                        }
                    }
                },
            },
        ];

        const columns = [
            {
                prop: '',
                //title: t('users.columns.actions'),
                type: 'vue',
                template: (e: ObjectConstructor) => {
                    return {
                        template: BtnsTemplate,
                        templateArgs: {
                            ...e,
                            btns: rowButtons,
                            showAsDropdown: true,
                        },
                    };
                },
                sortable: false,
                filterable: false,
            },
            {
                title: t('users.columns.profileType'),
                prop: 'userProfileType',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('users.columns.userName'),
                prop: 'userName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('users.columns.displayName'),
                prop: 'displayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('users.columns.email'),
                prop: 'email',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('users.columns.certificate'),
                prop: 'certificateThumbprint',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('users.columns.confirmed'),
                prop: 'emailConfirmed',
                type: 'boolean',
                sortable: true,
                filterable: true,
                renderFunction: formatYesNo,
                textAlign: 'center',
            },
            // {
            //   title: t('users.columns.createdBy'),
            //   prop: "createdByDisplayName",
            //   type: "string",
            //   sortable: true,
            //   filterable: true,
            // },
            // {
            //   title: t('users.columns.createdOn'),
            //   prop: "createdOn",
            //   type: "date",
            //   renderFunction: formatDateTime,
            //   sortable: true,
            //   filterable: true,
            // },

            // {
            //   title: t('users.columns.updatedBy'),
            //   prop: "updatedByDisplayName",
            //   type: "string",
            //   sortable: true,
            //   filterable: true,
            // },
            // {
            //   title: t('users.columns.updatedOn'),
            //   prop: "updatedOn",
            //   type: "date",
            //   renderFunction: formatDateTime,
            //   sortable: true,
            //   filterable: true,
            // },
        ];

        return {
            t,
            columns,
            gridUrl,
            grid,
            pageSize,
            breadcrumbItems,
        };
    },
});
</script>
>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
