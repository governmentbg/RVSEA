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
            <template v-slot:menubar>
                <!-- <button-group :buttons="headerButtons" /> -->
                <v-btn @click="addUserHandler">{{ t('users.create') }}</v-btn>
                <!-- <Dropdown 
          :items="userTypes" 
          valueProp="code"
          labelProp="label"
          :label="t('grid.search.tooltip')"
          @change="loadUsersByTypeHandler"
        /> -->
            </template>
        </grid>
    </div>
</template>

<script lang="ts">
import { computed, defineComponent, inject, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { formatDateTime, formatYesNo } from '@/helpers/format.helper';

import { ApplicationUserType } from '@/enums/userType';
import { PageSize } from '@/models/grid';
import { Message } from '@/models/notification';
import { IUserInfo } from '@/interfaces/userInfo';
import userService from '@/services/user.service';
import authorization from '@/helpers/authorization.helper';
//import ButtonGroup from "@/components/buttons/btn-group.vue";
import Grid from '@/components/grid/grid.vue';
import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
import { IMessage } from '../../../interfaces/notification';
import { ResponseResult } from '../../../models/responseResult';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';

export default defineComponent({
    name: 'Users',
    components: {
        //ButtonGroup,
        Grid,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const gridUrl = computed(() => userService.getUsersByTypeUrl(ApplicationUserType.Internal));
        const router = useRouter();

        const grid = ref();

        const pageSize = PageSize.twenty;

        const addUserHandler = () => {
            useRedirect(router, 'CreateUser');
        };
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.internalUsers'),
                disabled: true,
            },
        ];
        // const loadUsersByTypeHandler = (option: IDropdownOption) => {
        //   console.log(option);
        //   if (option && option.code) {
        //     console.log(userService.getUsersByTypeUrl(option.code))
        //     gridUrl.value = userService.getUsersByTypeUrl(option.code);

        //   } else {
        //     gridUrl.value = userService.getAllUsersUrl();
        //   }

        // };

        const rowButtons = [
            {
                name: 'btnDisplayUser',
                text: t('users.buttons.display'),
                tooltip: t('users.buttons.displayTooltip'),
                icon: 'mdi mdi-eye',
                show: authorization.isAuthenticated(),
                clickHandler: (item: IUserInfo) => {
                    if (item.id) {
                        useRedirectWithId(router, 'DisplayUser', item.id);
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
                        useRedirectWithId(router, 'EditUser', item.id);
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
                                const result = await userService.deleteUser(item.id);
                                if (result.status == 200) {
                                    if (grid.value) {
                                        grid.value.refreshData();
                                    }
                                } else {
                                    message.value = new Message({
                                        text: result.response.data.message,
                                        display: true,
                                    });
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
        // function isAxiosError(somethink): somethink is AxiosError {
        //   return somethink.isAxiosError === true;
        // }
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
            {
                title: t('users.columns.createdBy'),
                prop: 'createdByDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('users.columns.createdOn'),
                prop: 'createdOn',
                type: 'date',
                renderFunction: formatDateTime,
                sortable: true,
                filterable: true,
            },

            {
                title: t('users.columns.updatedBy'),
                prop: 'updatedByDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('users.columns.updatedOn'),
                prop: 'updatedOn',
                type: 'date',
                renderFunction: formatDateTime,
                sortable: true,
                filterable: true,
            },
        ];

        const userTypes = [
            {
                code: ApplicationUserType.System,
                label: t(`userTypes.${ApplicationUserType.System}`),
            },
            {
                code: ApplicationUserType.Internal,
                label: t(`userTypes.${ApplicationUserType.Internal}`),
            },
            {
                code: ApplicationUserType.External,
                label: t(`userTypes.${ApplicationUserType.External}`),
            },
        ];

        return {
            t,
            addUserHandler,
            //loadUsersByTypeHandler,
            columns,
            gridUrl,
            grid,
            breadcrumbItems,
            pageSize,
            userTypes,
        };
    },
});
</script>
>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
