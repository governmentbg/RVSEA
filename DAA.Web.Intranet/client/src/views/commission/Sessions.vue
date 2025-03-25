<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <div class="py-3">
        <grid
            ref="grid"
            :baseUrl="gridUrl"
            :columns="columns"
            :mode="'remote'"
            :paging="true"
            :pageSize="pageSize"
            :showSearch="false"
            :showExport="false"
            :noDataMessage="t('common.noDataMessage')"
        >
            <template v-slot:menubar>
                <v-dialog v-model="showDialog">
                    <template v-slot:activator="{ props }">
                        <v-btn v-bind="props"
                            >{{ t('sessions.buttons.create') }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('sessions.buttons.createTooltip') }}
                            </v-tooltip>
                        </v-btn>
                    </template>
                    <!--Create Session-->
                    <v-card width="1000" height="800">
                        <v-card-title class="text-h5 text-center">
                            {{ t('sessions.create') }}
                        </v-card-title>
                        <v-card-text>
                            <v-col>
                                <DatepPicker v-model:date="model.sessionDate" :startDate="new Date()" />
                            </v-col>
                            <v-col cols="12">
                                <label class="required" for="fldArchive">{{ t('sessions.columns.archive') }}</label>
                                <Dropdown
                                    v-if="archives"
                                    valueProp="id"
                                    :items="archives"
                                    name="fldArchive"
                                    :multiselect="false"
                                    :label="t('sessions.columns.archive')"
                                    :required="true"
                                    :disabled="editMode"
                                    v-model="model.archiveId"
                                />
                            </v-col>
                            <v-col v-if="model.archiveId" cols="12">
                                <label class="required" for="types">{{ t('sessions.columns.type') }}</label>
                                <Dropdown
                                    v-if="sessionTypes"
                                    :items="sessionTypes || model.sessionTypeCode"
                                    name="types"
                                    :multiselect="false"
                                    :label="t('sessions.columns.type')"
                                    :required="true"
                                    v-model="model.sessionTypeCode"
                                    :disabled="editMode"
                                />
                            </v-col>
                            <v-col v-if="model.archiveId != null && model.sessionTypeCode != null" cols="12">
                                <label class="required" for="prec">{{ t('sessions.columns.chairman') }}</label>
                                <Dropdown
                                    v-if="users && model.archiveId != null && model.sessionTypeCode != null"
                                    :items="users"
                                    name="prec"
                                    :multiselect="false"
                                    :label="t('sessions.columns.chairman')"
                                    :required="true"
                                    v-model="model.chairmanId"
                                />
                            </v-col>
                            <v-col v-if="model.archiveId != null && model.sessionTypeCode != null" cols="12">
                                <label class="required" for="secretar">{{ t('sessions.columns.secretary') }}</label>
                                <Dropdown
                                    v-if="users"
                                    :items="users"
                                    name="secretar"
                                    :multiselect="false"
                                    :label="t('sessions.columns.secretary')"
                                    :required="true"
                                    v-model="model.secretaryId"
                                />
                            </v-col>
                        </v-card-text>
                        <v-card-actions>
                            <v-spacer></v-spacer>
                            <dialog-btn
                                :disabled="!isActiveForCreateUpdateSession"
                                v-if="!editMode"
                                @click="createSession"
                            >
                                {{ t('common.save') }}
                                <v-tooltip activator="parent" location="bottom">
                                    {{ t('common.save') }}
                                </v-tooltip>
                            </dialog-btn>
                            <dialog-btn
                                :disabled="!isActiveForCreateUpdateSession"
                                v-if="editMode"
                                @click="createSession"
                            >
                                {{ t('common.save') }}
                                <v-tooltip activator="parent" location="bottom">
                                    {{ t('common.save') }}
                                </v-tooltip>
                            </dialog-btn>
                            <cancel-btn  @click="closeDialog">
                                {{ t('common.cancel') }}
                                <v-tooltip activator="parent" location="bottom">
                                    {{ t('common.cancel') }}
                                </v-tooltip>
                            </cancel-btn>
                        </v-card-actions>
                    </v-card>
                </v-dialog>
            </template>
        </grid>
    </div>
</template>
<script lang="ts">
import { computed, defineComponent, inject, ref, Ref, onMounted, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { formatDate, formatDateTime, returnSessionTypeName, switchProtocolStatusText } from '@/helpers/format.helper';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import authorization from '@/helpers/authorization.helper';
import { CommissionSessionModel } from '@/models/commission';
import { PageSize } from '@/models/grid';
import commissionSessionService from '@/services/commissionSession.service';
import Grid from '@/components/grid/grid.vue';
import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
import DatepPicker from '@/components/datetime/datepPicker.vue';
import dropdownService from '@/services/dropdown.service';
import { IDropdownOption } from '@/interfaces/dropdown';
import Dropdown from '@/components/dropdown/dropdown.vue';
import { RoleNames } from '@/enums/roles';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { SessionType } from '@/enums/sessionTypes';
import { useRedirectWithId } from '@/helpers/router.helper';
export default defineComponent({
    name: 'Sessions',
    components: {
        Grid,
        DatepPicker,
        Dropdown,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const gridUrl = computed(() => commissionSessionService.getListAllSessionsUrl());
        const router = useRouter();
        const grid = ref();
        const showDialog = ref<boolean>(false);
        const model = ref<CommissionSessionModel>(new CommissionSessionModel());
        const archives = ref<IDropdownOption[]>();
        const sessionTypes = ref<IDropdownOption[]>();
        const editMode = ref(false);
        const isActiveForCreateUpdateSession = ref(true);

        const getArchives = async () => {
            archives.value = await dropdownService.getArchives();
        };
        const getSessionTypes = async () => {
            sessionTypes.value = await dropdownService.GetSessionTypes();
        };
        const users = ref<IDropdownOption[]>([]);

        const getUsers = async (val: string) => {
            if (val == SessionType.EPC) {
                users.value = await dropdownService.getUsersInRoles(model.value.archiveId!, [RoleNames.GroupV1]);
            } else if (val == SessionType.EOC) {
                users.value = await dropdownService.getUsersInRoles(model.value.archiveId!, [RoleNames.GroupV2]);
            } else if (val == SessionType.REOC) {
                users.value = await dropdownService.getUsersInRoles(model.value.archiveId!, [RoleNames.GroupV3]);
            }
        };

        const getSessionById = async (id: number) => {
            editMode.value = true;
            model.value = await commissionSessionService.getSession(id);
            showDialog.value = true;
        };

        const createSession = async () => {
            isActiveForCreateUpdateSession.value = false;
            if (
                !model.value.archiveId ||
                !model.value.sessionTypeCode ||
                !model.value.sessionDate ||
                !model.value.secretaryId ||
                !model.value.chairmanId
            ) {
                message.value = new Message({
                    text: t('sessions.missiData'),
                    display: true,
                });
               
                return isActiveForCreateUpdateSession.value = true;
            }
            try {
                if (editMode.value) {
                    await commissionSessionService.updateSession(model.value);
                    editMode.value = false;
                } else {
                    await commissionSessionService.createSession(model.value);
                }

                showDialog.value = false;
                model.value = new CommissionSessionModel();
                isActiveForCreateUpdateSession.value = true;

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
        };

        function closeDialog() {
            if (editMode.value) {
                editMode.value = false;
            }
            showDialog.value = false;
            model.value = new CommissionSessionModel();
        }

        const rowButtons = [
            {
                name: 'btnManageSessionAgenda',
                text: t('sessions.buttons.manageSessionAgenda'),
                tooltip: t('sessions.buttons.manageSessionAgendaTooltip'),
                icon: 'mdi mdi-view-list-outline',
                show: (item: CommissionSessionModel) => {
                    console.log(item);
                    return authorization.isAuthenticated() && !item.minutesOfMeetingId;
                },
                clickHandler: (item: CommissionSessionModel) => {
                    if (item.id) {
                        useRedirectWithId(router, 'ManageSessionAgenda', item.id);
                    }
                },
            },
            {
                name: 'btnEditSession',
                text: t('sessions.buttons.edit'),
                tooltip: t('sessions.buttons.edit'),
                icon: 'mdi mdi-pencil',
                show: (item: CommissionSessionModel) => {
                    return authorization.isAuthenticated() && !item.minutesOfMeetingId;
                },
                clickHandler: async (item: CommissionSessionModel) => {
                    await getSessionById(item.id as number);
                },
            },
            {
                name: 'btnDeleteSession',
                text: t('common.delete'),
                tooltip: t('sessions.buttons.deleteTooltip'),
                class: 'text-danger',
                icon: 'mdi mdi-delete',
                show: (item: CommissionSessionModel) => {
                    return authorization.isAuthenticated() && !item.minutesOfMeetingId;
                },
                clickHandler: async (item: CommissionSessionModel) => {
                    if (item.id) {
                        if (confirm(t('sessions.buttons.deleteConfirmation', formatDate(item.sessionDate!)))) {
                            try {
                                await commissionSessionService.deleteSession(item.id);

                                if (grid.value) {
                                    grid.value.refreshData();
                                } else {
                                    router.go(0);
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
                title: '',
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
                title: t('sessions.columns.date'),
                prop: 'sessionDate',
                type: 'date',
                renderFunction: formatDate,
                sortable: true,
                filterable: true,
            },
            {
                title: t('sessions.columns.type'),
                prop: 'sessionTypeCode',
                renderFunction: returnSessionTypeName,
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('sessions.columns.archive'),
                prop: 'archiveName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('sessions.columns.chairman'),
                prop: 'chairmanDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('sessions.columns.secretary'),
                prop: 'secretaryDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('sessions.columns.minutesOfMeetingStatus'),
                prop: 'minutesOfMeetingStatus',
                type: 'string',
                sortable: true,
                filterable: true,
                renderFunction: switchProtocolStatusText,
            },
            {
                title: t('sessions.columns.createdBy'),
                prop: 'createdByDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('sessions.columns.createdOn'),
                prop: 'createdOn',
                type: 'date',
                renderFunction: formatDateTime,
                sortable: true,
                filterable: true,
            },
            {
                title: t('sessions.columns.updatedBy'),
                prop: 'updatedByDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('sessions.columns.updatedOn'),
                prop: 'updatedOn',
                type: 'date',
                renderFunction: formatDateTime,
                sortable: true,
                filterable: true,
            },
        ];

        watch(
            () => model.value.sessionTypeCode,
            (val) => getUsers(val as string)
        );

        watch(
            () => model.value.archiveId,
            () => (
                editMode.value == true ? '' : (model.value.sessionTypeCode = undefined),
                editMode.value == true ? '' : (model.value.secretaryId = undefined),
                editMode.value == true ? '' : (model.value.chairmanId = undefined)
            )
        );

        const pageSize = PageSize.ten;

        onMounted(async () => {
            await getArchives();
            await getSessionTypes();
        });

        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.sessionDates'),
                disabled: true,
            },
        ];

        return {
            t,
            createSession,
            closeDialog,
            isActiveForCreateUpdateSession,
            grid,
            sessionTypes,
            showDialog,
            gridUrl,
            columns,
            model,
            router,
            pageSize,
            archives,
            users,
            breadcrumbItems,
            editMode,
        };
    },
});
</script>

<style lang="scss" scoped>
@use '@/assets/styles/common.scss' as *;
@import '@/assets/styles/index.scss';
@import '@/assets/styles/breadcrumbs.scss';

.v-card {
    margin: auto;
}

// .v-expansion-panel-title {
//     @include button-expansion-panel($color: var(--ISDA-main-color1), $background: var(--ISDA-main-color2-1));
//     top: 0px !important;
//     margin-top: 0px !important;
// }

// :deep(.input-group) {
//     background-color: var(--input-background-color) !important;
//     border-radius: 10px 0px 0px 10px !important;
//     border: none !important;
//     border-bottom: 1px solid var(--input-border-color) !important;
//     box-shadow: none;
// }

.v-card-actions .v-btn {
    margin-left: 15px;
}
</style>
