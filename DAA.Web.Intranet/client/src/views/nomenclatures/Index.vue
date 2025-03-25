<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <div class="py-3">
        <grid
            ref="grid"
            :mode="'remote'"
            :baseUrl="gridUrl"
            :columns="columns"
            :searchLabel="t('grid.search.tooltip')"
            :paging="true"
            :pageSize="pageSize"
            :exportMode="exportMode"
            :businessObjectType="objectType"
        >
            <template v-slot:menubar>
                <v-btn @click="addNomenclatureHandler">{{ t('nomenclature.buttons.create') }}
                    <v-tooltip
                        activator="parent"
                        location="bottom"
                    >
                    {{t('nomenclature.buttons.createTooltip')}}
                    </v-tooltip>
                </v-btn>
            </template>
        </grid>
    </div>
</template>
<script lang="ts">
import { computed, defineComponent, inject, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { formatDateTime } from '@/helpers/format.helper';
import { Message } from '@/models/notification';

import authorization from '@/helpers/authorization.helper';
import nomenclatureService from '@/services/nomenclature.service';
import { INomenclature } from '@/interfaces/nomenclature';
import { BusinessObjectType, ExportMode, PageSize } from '@/models/grid';

import Grid from '@/components/grid/grid.vue';
import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
import { IMessage } from '../../interfaces/notification';
import { ResponseResult } from '../../models/responseResult';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
export default defineComponent({
    name: 'Nomenclatures',
    components: {
        Grid,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const gridUrl = computed(() => nomenclatureService.getNomenclaturesUrl());
        const grid = ref();
        const pageSize = PageSize.twenty;
        const objectType = BusinessObjectType.nomenclature;
        const exportMode = ExportMode.all;

        const router = useRouter();

        const addNomenclatureHandler = () => {
            useRedirect(router, 'CreateNomenclature');
        };
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.nomenclatures'),
                disabled: true,
            },
        ];
        const rowButtons = [
            {
                name: 'btnDisplayNomenclature',
                text: t('nomenclature.buttons.display'),
                tooltip: t('nomenclature.buttons.displayTooltip'),
                icon: 'mdi mdi-eye',
                show: authorization.isAuthenticated(),
                clickHandler: (item: INomenclature) => {
                    if (item.id) {
                        useRedirectWithId(router, 'DisplayNomenclature', item.id);
                    }
                },
            },
            {
                name: 'btnEditNomenclature',
                text: t('nomenclature.buttons.edit'),
                tooltip: t('nomenclature.buttons.editTooltip'),
                icon: 'mdi mdi-pencil',
                show: authorization.isAuthenticated(),
                clickHandler: (item: INomenclature) => {
                    if (item.id) {
                        useRedirectWithId(router, 'EditNomenclature', item.id);
                    }
                },
            },
            {
                name: 'btnDeleteNomenclature',
                text: t('nomenclature.buttons.delete'),
                tooltip: t('nomenclature.buttons.deleteTooltip'),
                class: 'text-danger',
                icon: 'mdi mdi-delete',
                show: authorization.isAuthenticated(),
                clickHandler: async (item: INomenclature) => {
                    if (item.id) {
                        if (
                            confirm(
                                t('nomenclature.buttons.deleteConfirmation', {
                                    title: item.text,
                                })
                            )
                        ) {
                            try {
                                const result = await nomenclatureService.deleteNomenclature(item.id);
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
                title: t('nomenclature.columns.title'),
                prop: 'text',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('nomenclature.columns.code'),
                prop: 'code',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('nomenclature.columns.description'),
                prop: 'description',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('nomenclature.columns.createdBy'),
                prop: 'createdByDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('nomenclature.columns.createdOn'),
                prop: 'createdOn',
                type: 'date',
                renderFunction: formatDateTime,
                sortable: true,
                filterable: true,
            },

            {
                title: t('nomenclature.columns.updatedBy'),
                prop: 'updatedByDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('nomenclature.columns.updatedOn'),
                prop: 'updatedOn',
                type: 'date',
                renderFunction: formatDateTime,
                sortable: true,
                filterable: true,
            },
        ];

        return {
            t,
            grid,
            gridUrl,
            columns,
            objectType,
            pageSize,
            exportMode,
            addNomenclatureHandler,
            breadcrumbItems,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
