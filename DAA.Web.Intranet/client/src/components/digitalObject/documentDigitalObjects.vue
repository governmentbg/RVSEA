<template>
    <v-row align="start" v-if="fileUploadEnabled">
        <v-col class="col-12">
            <label>{{ t('digitalObjects.file') }}</label>
            <UploadFile ref="digitalObjectUploader" :multipleFiles="false" @change="masterFilesChanged" />
        </v-col>
    </v-row>
    <v-row v-if="fileUploadEnabled">
        <v-col cols="12">
            <Switch
                v-model="skipValidation"
                :label="t('docsCreateProc.skipValidation')"
                :large="false"
                :showLabel="true"
            />
        </v-col>
    </v-row>
    <v-row v-if="fileUploadEnabled">
        <v-col class="col-12 col-lg-2">
            <v-btn @click="addDigitalObjects">{{ t('digitalObjects.buttons.create') }}</v-btn>
        </v-col>
        <v-col class="col-12 col-lg-2" v-if="updateExistingFiles">
            <v-checkbox
                class="mt-3"
                v-model="overwriteExistingDigitalObjects"
                :label="t('digitalObjects.updateExistingFiles')"
                hide-details="auto"
                density="compact"
            />
        </v-col>
    </v-row>
    <!-- <v-row v-if="digitalObjectData.totalCount > 0">
        <v-col>
            <v-list variant="plain" density="compact">
                <v-list-item v-for="item in digitalObjectData.items" :key="item" @click="displayClickHandler(item)">
                    <v-list-item-title>{{ item.sourceName }}</v-list-item-title>
                    <template #append>
                        <v-btn icon color="transparent" variant="flat" @click.stop="downloadFileClickHandler(item)">
                            <v-icon>mdi-download</v-icon>
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('common.downloadTooltip') }}
                            </v-tooltip>
                        </v-btn>
                        <ConfirmDialog
                            v-if="!readOnly && deleteEnabled && !item.hasExternalSource"
                            :confirmationText="
                                $t('digitalObjects.buttons.deleteConfirmation', { title: item.sourceName })
                            "
                            :confirmButtonText="$t('common.yes')"
                            :cancelButtonText="$t('common.cancel')"
                            activatorButtonIcon="mdi-delete-outline"
                            activatorButtonColor="transparent"
                            activatorButtonVariant="flat"
                            @confirm="deleteFileClickHandler(item)"
                        />
                    </template>
                </v-list-item>
            </v-list>
        </v-col>
    </v-row> -->
    <v-row v-if="digitalObjectData.totalCount > 0">
        <v-col class="col-12 col-lg-6">
            <v-list variant="plain" density="compact">
                <v-list-subheader>{{ t('digitalObjects.masterFiles') }}</v-list-subheader>
                <v-list-item
                    v-for="item in digitalObjectData.items.filter((obj) => obj.typeCode === 1)"
                    :key="item"
                    @click="displayClickHandler(item)"
                >
                    <v-list-item-title>{{ item.sourceName }}</v-list-item-title>
                    <template #append>
                        <v-btn icon color="transparent" variant="flat" @click.stop="downloadFileClickHandler(item)">
                            <v-icon>mdi-download</v-icon>
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('common.downloadTooltip') }}
                            </v-tooltip>
                        </v-btn>
                        <ConfirmDialog
                            v-if="!readOnly && deleteEnabled && !item.hasExternalSource && !item.isImported"
                            :confirmationText="
                                $t('digitalObjects.buttons.deleteConfirmation', { title: item.sourceName })
                            "
                            :confirmButtonText="$t('common.yes')"
                            :cancelButtonText="$t('common.cancel')"
                            activatorButtonIcon="mdi-delete-outline"
                            activatorButtonColor="transparent"
                            activatorButtonVariant="flat"
                            @confirm="deleteFileClickHandler(item)"
                        />
                    </template>
                </v-list-item>
            </v-list>
        </v-col>
        <v-col class="col-12 col-lg-6">
            <v-list variant="plain">
                <v-list-subheader>{{ t('digitalObjects.derivativesFile') }}</v-list-subheader>
                <v-list-item
                    v-for="item in digitalObjectData.items.filter((obj) => obj.typeCode === 2)"
                    :key="item"
                    @click="displayClickHandler(item)"
                >
                    <v-list-item-title>{{ item.sourceName }}</v-list-item-title>
                </v-list-item>
            </v-list>
        </v-col>
    </v-row>
    <v-row v-else>
        <v-col>
            {{ t('search.emptyResult') }}
        </v-col>
    </v-row>
    <v-row>
        <v-col>
            <Pager
                v-if="digitalObjectData.totalCount > pagerOptions.itemsPerPage"
                :initialPage="pagerOptions.page"
                :initialPageSize="pagerOptions.itemsPerPage"
                @change="changePage"
                ref="pager"
            ></Pager>
        </v-col>
    </v-row>
    <Loader :isLoading="isLoading" />
    <DisplayImageModal v-model="displayModal" :src="imageUrl" @close="closeModal" />
    <DisplayPlayerModal v-model="displayAudioVideoModal" :src="audioVideoUrl" @close="closeModal" />
    <DisplayPdfModal :digitalObjectType="digObjTypeCode" v-model="displayPdf" :src="pdfUrl" @close="closeModal" />
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, PropType, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from '@/store/app';
import { getFileExtension, isImage, isPdf, isSound } from '@/helpers/file.helper';
import { useRouter } from 'vue-router';
import { displayMessage } from '@/helpers/notification.helper';

import { Status } from '@/enums/status';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { GridOptions, GridResponseModel, PageSize } from '@/models/grid';
import { IDocument } from '@/interfaces/document';
import { IDigitalObject, IDigitalObjectDraft } from '@/interfaces/digitalObject';
import { DigitalObjectDraft } from '@/models/digitalObject';
import { DigitalObjectType } from '@/enums/digitalObject';
//import http from '@/services/http.service';
import digitalObjectService from '@/services/digitalObject.service';

import DisplayPlayerModal from '@/components/digitalObject/displayPlayerModal.vue';
//import Grid from '@/components/grid/grid.vue';
//import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
//import HyperlinkTemplate from '@/components/grid/hyperlinkTemplate.vue';
import UploadFile from '@/components/files/uploadFile.vue';
import DisplayImageModal from '@/components/digitalObject/displayImageModal.vue';
import Loader from '@/components/loader/loader.vue';
import Switch from '@/components/checkbox/switch.vue';
import Pager from '@/components/grid/pager.vue';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import DisplayPdfModal from '@/components/digitalObject/displayPdfModal.vue';


export default defineComponent({
    name: 'DocumentDigitalObjects',
    components: {
        //Grid,
        UploadFile,
        DisplayImageModal,
        DisplayPlayerModal,
        Loader,
        Switch,
        Pager,
        ConfirmDialog,
        DisplayPdfModal,
    },
    props: {
        document: {
            type: Object as PropType<IDocument>,
        },
        fileUploadEnabled: {
            type: Boolean,
            default: false,
        },
        deleteEnabled: {
            type: Boolean,
            default: false,
        },
        updateExistingFiles: {
            type: Boolean,
            default: false,
        },
        readOnly: {
            type: Boolean,
            default: false,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const pdfUrl = ref('');
        const displayPdf = ref(false);
        const appStore = useStore();
        const digObjTypeCode = ref<number>();
        const isLoading = ref(false);
        //const pageSize = PageSize.ten;

        const masterFileSystemIdentifier = ref('');

        const displayModal = ref<boolean>(false);
        const displayAudioVideoModal = ref<boolean>(false);
        const imageUrl = ref<string>('');
        const audioVideoUrl = ref<string>('');
        const closeModal = () => {
            displayModal.value = false;
            imageUrl.value = '';
            audioVideoUrl.value = '';
            displayAudioVideoModal.value = false;
            displayPdf.value = false;
            pdfUrl.value = '';
        };

        const pagerOptions = ref<GridOptions>({
            sortBy: '',
            sortDesc: false,
            page: 1,
            itemsPerPage: PageSize.hundred,
            sortByType: '',
        });

        const changePage = async (pageNumber: number, pageSize: number) => {
            pagerOptions.value.page = pageNumber;
            pagerOptions.value.itemsPerPage = pageSize;

            await getDigitalObjectData();
        };

        const digitalObjectData = ref<GridResponseModel<IDigitalObject>>(
            new GridResponseModel<IDigitalObject>({ totalCount: 0, items: [] })
        );

        const getDigitalObjectData = async () => {
            try {
                isLoading.value = true;

                digitalObjectData.value = await digitalObjectService.getDocumentDigitalObjects(
                    pagerOptions.value,
                    props.document?.systemIdentifier,
                    props.document?.hasExternalSource,
                    props.document?.externalIdentifier,
                    false
                );
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            } finally {
                isLoading.value = false;
            }
        };

        const displayClickHandler = (item: IDigitalObject) => {
            if (item) {
                if (item.hasExternalSource) {
                    if (item.typeCode !== DigitalObjectType.MasterFile) {
                        const url = `${appStore.state.externalSourceGalleryUrl}?Gid=${item.externalIdentifier}`;
                        const link = document.createElement('a');
                        link.href = url;
                        link.target = '_blank';
                        //link.setAttribute('download', item.name!);
                        document.body.appendChild(link);
                        link.click();
                    } else {
                        const url = `${appStore.state.externalSourceFileDownloadUrl}?Type=m&Gid=${item.externalIdentifier}`;
                        const link = document.createElement('a');
                        link.href = url;
                        link.setAttribute('download', item.name!);
                        document.body.appendChild(link);
                        link.click();
                    }
                } else {
                    const url = digitalObjectService.streamDigitalObjectUrl(
                            item.systemIdentifier!, true
                        );
                    if (isImage(item.name!)) {
                        imageUrl.value = url;
                        displayModal.value = true;
                    } else if (isSound(item.name!)) {
                        audioVideoUrl.value = url;
                        displayAudioVideoModal.value = true;
                    } else if (isPdf(item.name!)) {
                        digObjTypeCode.value = item.typeCode;
                        pdfUrl.value = '';
                        digitalObjectService.streamDigitalObjectFile(item.systemIdentifier!)
                        .then((response) => {
                            pdfUrl.value = URL.createObjectURL(response);
                        });
                        displayPdf.value = true;
                    } else {
                        const link = document.createElement('a');
                        link.href = url;
                        link.setAttribute('download', item.name!);
                        document.body.appendChild(link);
                        link.click();
                    }
                }
            } else {
                message.value = new Message({ type: 'warning', text: t('warning.fileNotFound') });
            }
        };

        const downloadFileClickHandler = (item: IDigitalObject) => {
            if (item) {
                if (item.hasExternalSource) {
                    if (item.typeCode !== DigitalObjectType.MasterFile) {
                        const url = `${appStore.state.externalSourceGalleryUrl}?Gid=${item.externalIdentifier}`;
                        const link = document.createElement('a');
                        link.href = url;
                        link.target = '_blank';
                        //link.setAttribute('download', item.name!);
                        document.body.appendChild(link);
                        link.click();
                    } else {
                        const url = `${appStore.state.externalSourceFileDownloadUrl}?Type=m&Gid=${item.externalIdentifier}`;
                        const link = document.createElement('a');
                        link.href = url;
                        link.setAttribute('download', item.name!);
                        document.body.appendChild(link);
                        link.click();
                    }
                } else {
                    const url = digitalObjectService.streamDigitalObjectUrl(
                        item.systemIdentifier!
                    );
                    const link = document.createElement('a');
                    link.href = url;
                    link.setAttribute('download', item.name!);
                    document.body.appendChild(link);
                    link.click();
                }
            } else {
                displayMessage(message, t('warning.fileNotFound'), 'warning');
                //message.value = new Message({ type: 'warning', text: t('warning.fileNotFound') });
            }
        };

        const deleteFileClickHandler = async (item: IDigitalObject) => {
            if (item) {
                try {
                    isLoading.value = true;

                    if (item.isDraft) {
                        await digitalObjectService.deleteDigitalObjectDraft(item.id!, true);
                    } else {
                        await digitalObjectService.deleteDigitalObject(item.systemIdentifier!, true);
                    }

                    await getDigitalObjectData();
                } catch (error: unknown) {
                    const errorResult = error as ResponseResult;
                    displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
                    // message.value = new Message({
                    //     text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    //     display: true,
                    // });
                } finally {
                    isLoading.value = false;
                }
            } else {
                displayMessage(message, t('warning.fileNotFound'), 'warning');
                //message.value = new Message({ type: 'warning', text: t('warning.fileNotFound') });
            }
        };

        const skipValidation = ref(false);

        const masterFiles = ref<IDigitalObjectDraft[]>([]);
        const overwriteExistingDigitalObjects = ref<boolean>(false);

        const masterFilesChanged = (files: File[]) => {
            masterFiles.value = [];
            files.forEach((f) =>
                masterFiles.value.push(
                    new DigitalObjectDraft({
                        isCurrent: true,
                        isDigitized: false,
                        archiveId: props.document?.archiveId,
                        fundDraftId: props.document?.fundDraftId,
                        fundSystemIdentifier: props.document?.fundSystemIdentifier,
                        fundHasExternalSource: props.document?.fundHasExternalSource,
                        fundExternalIdentifier: props.document?.fundExternalIdentifier,
                        inventoryDraftId: props.document?.inventoryDraftId,
                        inventorySystemIdentifier: props.document?.inventorySystemIdentifier,
                        inventoryHasExternalSource: props.document?.inventoryHasExternalSource,
                        inventoryExternalIdentifier: props.document?.inventoryExternalIdentifier,
                        archivalEntityDraftId: props.document?.archivalEntityDraftId,
                        archivalEntitySystemIdentifier: props.document?.archivalEntitySystemIdentifier,
                        archivalEntityHasExternalSource: props.document?.archivalEntityHasExternalSource,
                        archivalEntityExternalIdentifier: props.document?.archivalEntityExternalIdentifier,
                        documentDraftId: props.document?.isDraft ? props.document.id : undefined,
                        documentSystemIdentifier: props.document?.systemIdentifier,
                        documentHasExternalSource: props.document?.hasExternalSource,
                        documentExternalIdentifier: props.document?.externalIdentifier,
                        typeCode: DigitalObjectType.MasterFile,
                        name: f.name,
                        sourceName: f.name,
                        fileType: getFileExtension(f.name),
                        contentType: f.type,
                        statusCode: '1',
                        content: f,
                    })
                )
            );
        };

        const router = useRouter();

        const addDigitalObjects = async () => {
            try {
                if (overwriteExistingDigitalObjects.value == true) {
                    masterFiles.value[0].statusCode = Status.Modified; // редактиран
                    masterFiles.value[0].skipValidation = skipValidation.value;
                    await digitalObjectService.updateDigitalObject(masterFiles.value[0])
                    .then((result) => {
                        masterFileSystemIdentifier.value = result;
                    });
                } else {
                    masterFiles.value[0].skipValidation = skipValidation.value;
                    await digitalObjectService.createDigitalObject(masterFiles.value[0], true)
                    .then((result) => {
                        masterFileSystemIdentifier.value = result;
                    });
                }
                router.go(0);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        onMounted(async () => {
            await getDigitalObjectData();
        });

        return {
            t,
            masterFiles,
            overwriteExistingDigitalObjects,
            changePage,
            displayClickHandler,
            downloadFileClickHandler,
            deleteFileClickHandler,
            digitalObjectData,
            pagerOptions,
            imageUrl,
            digObjTypeCode,
            audioVideoUrl,
            displayPdf,
            pdfUrl,
            displayModal,
            displayAudioVideoModal,
            closeModal,
            masterFilesChanged,
            addDigitalObjects,
            isLoading,
            skipValidation,
        };
    },
});
</script>

<style lang="scss" scoped>
// @import '@/assets/styles/index.scss';

// :deep(.table-responsive),
// :deep(div > div:has(.table)) {
//     position: relative !important;
//     max-height: 600px;
//     min-width: 500px !important;
//     overflow-y: auto !important;
//     overflow-x: auto !important;
// }

// :deep(thead) {
//     position: sticky !important;
//     position: -webkit-sticky !important;
//     top: 0px !important;
//     z-index: 2;
// }
// :deep(.floatingBtnIcon) {
//     background-color: transparent !important;
//     color: var(--ISDA-main-color1) !important;
//     box-shadow: none !important;
//     margin: 0px 0px;
// }
</style>
