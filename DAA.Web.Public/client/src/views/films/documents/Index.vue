<template>
    <DisplayImageModal :src="modalScr" v-model:showModal="showModal" />
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
            :noDataMessage="t('common.noData')"
            @rowClick="onRowClick"
        >
        </grid>
    </div>
</template>
<script lang="ts">
import { computed, defineComponent, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import filmDocumentService from '@/services/filmDocument.service';
import { PageSize } from '@/models/grid';
import Grid from '@/components/grid/grid.vue';
import { formatBytes } from '@/helpers/format.helper';
import RowItem from '@/components/grid/rowItem.vue';
import DisplayImageModal from '@/components/digitalObjects/displayImageModal.vue';

export default defineComponent({
    name: 'FilmDocuments',
    components: {
        Grid,
        DisplayImageModal,
    },
    props: {
        packageId: {
            type: Number,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();

        const gridUrl = computed(() => filmDocumentService.getFilmDocumentsUrl(props.packageId));

        const modalScr = ref('');
        const showModal = ref(false);

        const grid = ref();

        const onRowClick = (row: typeof RowItem) => {
            const fileType = row.items.fileName.split('.').pop();
            if (fileType == 'png' || fileType == 'jpg') {
                modalScr.value = filmDocumentService.getFileDownloadUrl(row.items.id!);
                showModal.value = true;
            } else {
                const url = filmDocumentService.getFileDownloadUrl(row.items.id!);
                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', row.items.fileName!);
                document.body.appendChild(link);
                link.click();
            }
        };

        const columns = [
            {
                title: t('filmDocuments.docType'),
                prop: 'documentTypeName',
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
                title: t('filmDocuments.fileSize'),
                prop: 'fileSizeInBytes',
                type: 'number',
                renderFunction: formatBytes,
                sortable: false,
                filterable: false,
            },
            {
                title: t('filmDocuments.description'),
                prop: 'description',
                type: 'string',
                sortable: false,
                filterable: false,
            },
        ];
        const pageSize = PageSize.ten;

        return {
            t,
            grid,
            gridUrl,
            columns,
            pageSize,
            modalScr,
            showModal,
            onRowClick,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
</style>
