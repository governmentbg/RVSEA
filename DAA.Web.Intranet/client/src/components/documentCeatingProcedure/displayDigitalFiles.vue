<template>
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
            <template v-slot:menubar> </template>
        </grid>
    </div>
</template>
<script lang="ts">
import { computed, defineComponent, inject, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { Message } from '@/models/notification';
import authorization from '@/helpers/authorization.helper';
import documentService from '@/services/documentCreatingProcedure.service';
import { IDocumentFilesShort } from '@/interfaces/documentFiles';
import { PageSize } from '@/models/grid';
import { formatYesNo } from '@/helpers/format.helper';
import Grid from '@/components/grid/grid.vue';
import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
import { IMessage } from '../../interfaces/notification';
import { ResponseResult } from '../../models/responseResult';

export default defineComponent({
    name: 'FilmDocuments',
    components: {
        Grid,
    },
    props: {
        documentSys: {
            type: String,
            required: true,
        },
        packageType: {
            type: String,
            required: true,
        },
        readonly: {
            type: Boolean,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const pageSize = PageSize.ten;

        const gridUrl = computed(() => documentService.getDocumentFilesUrl(props.documentSys));

        const grid = ref();
        const rowButtons = [
            {
                name: 'btnDisplayFilmDocument',
                text: t('docsCreateProc.download'),
                tooltip: t('docsCreateProc.download'),
                icon: 'mdi mdi-download',
                show: authorization.isAuthenticated(),
                clickHandler: (item: IDocumentFilesShort) => {
                    if (item.id) {
                        const url = documentService.getFileDownloadUrl(item.fileId);
                        const link = document.createElement('a');
                        link.href = url;
                        link.setAttribute('download', item.fileName);
                        document.body.appendChild(link);
                        link.click();
                    }
                },
            },
            {
                name: 'btnDeleteFilmDocument',
                text: t('common.delete'),
                tooltip: t('filmDocuments.deleteTooltip'),
                class: 'text-danger',
                icon: 'mdi mdi-delete',
                show: () => {
                    return authorization.isAuthenticated() && !props.readonly;
                },
                clickHandler: async (item: IDocumentFilesShort) => {
                    if (item.id) {
                        if (confirm(t('filmDocuments.deleteConfirmation'))) {
                            try {
                                const result = await documentService.deleteDocumentFile(item.fileId, item.id);
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
                                message.value = new Message({
                                    text: (error as ResponseResult)?.message,
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
                title: t('filmDocuments.docType'),
                prop: 'fileType',
                type: 'string',
                sortable: false,
                filterable: false,
            },
            {
                title: t('filmDocuments.fileName'),
                prop: 'fileName',
                type: 'string',
                sortable: false,
                filterable: false,
            },
            {
                title: t('docsCreateProc.isMasterFile'),
                prop: 'isMaster',
                type: 'bool',
                renderFunction: formatYesNo,
                sortable: false,
                filterable: false,
            },
        ];

        return {
            t,
            grid,
            gridUrl,
            columns,
            pageSize,
        };
    },
});
</script>
