<template>
    <grid
        ref="grid"
        :items="items"
        :columns="columns"
        :mode="'local'"
        :paging="true"
        :pageSize="pageSize"
        :showSearch="false"
        :showExport="false"
        :noDataMessage="t('common.noDataMessage')"
        :hasRowButtons="true"
        @tdClick="onRowClick"
    >
        <template v-slot:menubar>
            <AddModal
                v-if="!readonly && showAdd"
                :packageId="packageId"
                :processId="processId"
                :packageType="packageType"
                :requireType="packageType === 'A'"
                :showSkipValidation="packageType === 'B'"
                @created="loadData"
            ></AddModal>
        </template>
    </grid>
    <v-btn
        class="col-3"
        v-if="packageType === 'B' && showGenerate"
        @click="isReadyForPrint = true"
        style="float: RIGHT"
    >
        {{ t('filmDocuments.generate') }}
    </v-btn>
    <GenerationModal v-model:show="isReadyForPrint" :packageId="packageId" :packageType="packageType" />
    <AddModal 
        v-if="showAddModal"
        :packageId="packageId"
        :processId="processId" 
        :packageType="packageType"
        :showSkipValidation="packageType === 'B'"
    ></AddModal>
    <DisplayModal v-model="fileToDisplay" v-model:show="showDisplayModal"></DisplayModal>
    <DisplayImageModal v-model="displayModal" :src="imageUrl" @close="closeModal" />
    <DisplayPlayerModal v-model="displayAudioVideoModal" :src="audioVideoUrl" @close="closeModal" />
    <DisplayPdfModal
        :digitalObjectType="digObjTypeCode"
        v-model="displayPdf"
        :src="pdfUrl"
        @close="closeModal"
        :packageType="packageType"
    />
</template>
<script lang="ts">
import { computed, defineComponent, ref, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
//import { useStore } from '@/store/app';
import { formatDate, formatYesNo } from '@/helpers/format.helper';
import { isImage, isPdf, isSound } from '@/helpers/file.helper';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { PageSize } from '@/models/grid';
import { IPackageAFile } from '@/models/packages';
import authorization from '@/helpers/authorization.helper';
import packagesService from '@/services/packages.service';
import DisplayPdfModal from '@/components/digitalObject/displayPdfModal.vue';
import Grid from '@/components/grid/grid.vue';
import RowItem from '@/components/grid/rowItem.vue';
import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
import AddModal from '@/components/packageA/add.modal.vue';
import DisplayModal from '@/components/packageA/display.modal.vue';
import GenerationModal from './inventoryGeneration.modal.vue';
import DisplayPlayerModal from '@/components/digitalObject/displayPlayerModal.vue';
import DisplayImageModal from '@/components/digitalObject/displayImageModal.vue';
//import http from '@/services/http.service';
import applicationService from '@/services/applications.service';

export default defineComponent({
    name: 'PackageAList',
    components: {
        AddModal,
        DisplayModal,
        GenerationModal,
        Grid,
        DisplayImageModal,
        DisplayPdfModal,
        DisplayPlayerModal,
    },
    props: {
        inventoryId: {
            type: String,
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
        processId: {
            type: Number,
            required: true,
        },
        readonly: {
            type: Boolean,
            default: false,
        },
        showAdd: {
            type: Boolean,
            default: false,
        },
        showGenerate: {
            type: Boolean,
            default: false,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const gridUrl = computed(() => packagesService.getPackageUrl(props.packageId));
        const grid = ref();
        const showAddModal = ref();
        const showDisplayModal = ref(false);
        const items = ref([] as Array<IPackageAFile>);
        const fileToDisplay = ref({} as IPackageAFile);
        const isReadyForPrint = ref(false);
        const displayModal = ref<boolean>(false);
        const displayAudioVideoModal = ref<boolean>(false);
        const imageUrl = ref<string>('');
        const audioVideoUrl = ref<string>('');
        //const store = useStore();
        const pdfUrl = ref<string>('');
        const displayPdf = ref<boolean>(false);
        const digObjTypeCode = ref<number>();

        const closeModal = () => {
            displayModal.value = false;
            imageUrl.value = '';
            audioVideoUrl.value = '';
            displayAudioVideoModal.value = false;
            displayPdf.value = false;
            pdfUrl.value = '';
        };

        const rowButtons = [
            {
                name: 'btnDisplayFilmDocument',
                class: 'd-print-none',
                text: t('common.display'),
                tooltip: t('filmDocuments.displayTooltip'),
                icon: 'mdi mdi-eye',
                show: authorization.isAuthenticated(),
                clickHandler: (item: IPackageAFile) => {
                    if (item.id) {
                        fileToDisplay.value = item;
                        showDisplayModal.value = true;
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
                clickHandler: async (item: IPackageAFile) => {
                    if (item.id) {
                        if (item.id) {
                            removeFileFromPackage(parseInt(item.id));
                        }
                    }
                },
            },
        ];

        const buildUrl = (id: number, inline?: boolean) => {
            return applicationService.packageDocumentStreamUrl(id, inline)
        };

        const onRowClick = (row: typeof RowItem) => {
            if (row) {
                if (isImage(row.items.fileName!)) {
                    imageUrl.value = buildUrl(row.items.id, true);
                    displayModal.value = true;
                } else if (isSound(row.items.fileName!)) {
                    audioVideoUrl.value = buildUrl(row.items.id, true);
                    displayAudioVideoModal.value = true;
                } else if (isPdf(row.items.fileName!)) {
                    digObjTypeCode.value =
                        (row?.items?.typeCode == null && row?.items?.parentId == null) || row?.items?.typeCode == 1
                            ? 1
                            : 2; // това е кода e за производен
                    pdfUrl.value = '';
                    applicationService.streamPackageDocumentFile(row.items.id)
                    .then((response) => {
                        pdfUrl.value = URL.createObjectURL(response);
                    })
                    displayPdf.value = true;
                } else {
                    const url = buildUrl(row.items.id);
                    const link = document.createElement('a');
                    document.createElement('a');
                    link.href = url;
                    link.setAttribute('download', row.items.fileName);
                    document.body.appendChild(link);
                    link.click();
                }
            }
        };

        const columns = ref([
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
                title: t('filmDocuments.description'),
                prop: 'description',
                type: 'string',
                sortable: false,
                filterable: false,
            },
            {
                title: t('filmDocuments.id'),
                prop: 'id',
                type: 'number',
                sortable: false,
                filterable: false,
                visible: props.packageType === 'B',
            },
            //
            {
                title: t('users.user'),
                prop: 'createdByDisplayName',
                type: 'string',
                sortable: false,
                filterable: false,
                visible: props.packageType !== 'B',
            },
            {
                title: t('notifications.list.createdOn'),
                prop: 'updateOrCreateDate',
                renderFunction: formatDate,
                type: 'string',
                sortable: false,
                filterable: false,
                visible: props.packageType !== 'B',
            },
            {
                title: t('documents.isSigned'),
                prop: 'isSigned',
                type: 'bool',
                sortable: false,
                renderFunction: formatYesNo,
                filterable: false,
                visible: props.packageType !== 'B',
            },
        ]);

        const pageSize = PageSize.ten;
        const loadData = () => {
            packagesService
                .get(props.packageId)
                .then((data) => (items.value = data))
                .catch((err) => console.log(err));
        };

        const removeFileFromPackage = (id: number) => {
            packagesService
                .removeFileFromPackage(id)
                .then(() => {
                    loadData();
                })
                .catch((error: unknown) => {
                    console.log(error);
                    const errorResult = error as ResponseResult;
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                        display: true,
                    });
                });
        };

        loadData();

        return {
            columns,
            digObjTypeCode,
            fileToDisplay,
            grid,
            pdfUrl,
            isReadyForPrint,
            displayModal,
            displayAudioVideoModal,
            gridUrl,
            displayPdf,
            items,
            loadData,
            closeModal,
            pageSize,
            removeFileFromPackage,
            onRowClick,
            showAddModal,
            showDisplayModal,
            audioVideoUrl,
            imageUrl,
            t,
        };
    },
});
</script>
