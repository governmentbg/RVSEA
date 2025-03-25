<template>
    <v-dialog v-model="dialog" persistent>
        <v-card class="vw-50 p-3">
            <v-card-text>
                <grid
                    ref="grid"
                    :items="items"
                    :columns="columns"
                    :mode="'local'"
                    :paging="true"
                    :pageSize="pageSize"
                    :showSearch="false"
                    :noDataMessage="t('common.noDataMessage')"
                    :exportMode="'all'"
                    :businessObjectType="objectType"
                    :exportParams="exportParams"
                >
                </grid>
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <cancel-btn @click="onClose">
                    {{ $t('common.close') }}
                </cancel-btn>
                <v-spacer></v-spacer>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>

<script lang="ts">
import { computed, defineComponent, ref } from 'vue';
import { BusinessObjectType, PageSize } from '@/models/grid';
import packagesService from '@/services/packages.service';
import { useI18n } from 'vue-i18n';
import Grid from '@/components/grid/grid.vue';
import { IPackageAFile } from '@/models/packages';
import BtnsTemplate from '@/components/grid/btnsTemplate.vue';

export default defineComponent({
    name: 'DisplayPackageFile',
    components: {
        Grid,
    },
    props: {
        show: {
            type: Boolean,
            required: true,
        },
        packageId: {
            type: Number,
            required: true,
        },
        packageType: {
            type: String,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const gridUrl = computed(() => packagesService.getPackageUrl(props.packageId));
        const grid = ref();
        const dialog = ref(false);
        const items = ref([] as Array<IPackageAFile>);
        const pageSize = PageSize.ten;
        const objectType = BusinessObjectType.packageB;
        const exportParams = ref(props.packageId);
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
                            showAsDropdown: true,
                        },
                    };
                },
                sortable: false,
                filterable: false,
                visible: false,
            },
            {
                title: t('filmDocuments.rowNumber'),
                prop: 'rowNumber',
                type: 'int',
                sortable: false,
                filterable: false,
            },
            {
                title: t('filmDocuments.workDocumentNumber'),
                prop: 'id',
                type: 'int',
                sortable: false,
                filterable: false,
            },
            {
                title: t('filmDocuments.documentTitle'),
                prop: 'description',
                type: 'string',
                sortable: false,
                filterable: false,
            },
            {
                title: t('filmDocuments.docType'),
                prop: 'documentType',
                type: 'string',
                sortable: false,
                filterable: false,
                visible: props.packageType === 'A',
            },
            {
                title: t('filmDocuments.fileName'),
                prop: 'fileName',
                type: 'string',
                sortable: false,
                filterable: false,
            },
            {
                title: t('archiveEntities.columns.bytes'),
                prop: 'fileSizeInMB',
                type: 'number',
                sortable: false,
                filterable: false,
            },
            {
                title: t('funds.columns.fileType'),
                prop: 'fileTypeName',
                type: 'string',
                sortable: false,
                filterable: false,
            },
        ];

        const loadData = async () => {
            await packagesService
                .get(props.packageId)
                .then((data) => {
                    items.value = data;
                    let index = 1;
                    items.value.forEach((element) => {
                        element.rowNumber = index;
                        index++;
                    });
                })
                .catch((err) => console.log(err));
        };

        return {
            items,
            t,
            columns,
            pageSize,
            dialog,
            gridUrl,
            grid,
            loadData,
            exportParams,
            objectType,
        };
    },
    methods: {
        onClose() {
            this.dialog = false;
            this.$emit('update:show', false);
        },
    },
    watch: {
        show: function (val: boolean) {
            if (val !== false) {
                this.loadData();
            }
            this.dialog = val;
        },
    },
});
</script>

<style scoped lang="scss">
.vw-50 {
    min-width: 80%;
    min-height: 50vh;
}
</style>
