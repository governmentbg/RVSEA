<template>
    <v-row align="start" v-if="fileUploadEnabled">
        <v-col class="col-12 col-lg-7">
            <label>{{ t('docsCreateProc.masterFiles') }}</label>
            <UploadFile ref="masterFileUploader" :multipleFiles="false" @change="masterFilesChanged" />
        </v-col>
    </v-row>
    <v-row align="start" class="col-12 col-lg-7" v-for="item in masterFiles" :key="item.id">
        <v-col v-if="fileUploadEnabled" class="col-12">
            <label>{{ t('docsCreateProc.derivativesFiles') }} {{ item.name }}</label>
            <UploadFile :multipleFiles="true" @change="derivativesFilesChanged" />
        </v-col>
        <v-col v-if="fileUploadEnabled">
            <label>{{ t('docsCreateProc.demoFiles') }} {{ item.name }}</label>
            <UploadFile ref="fileUploader" :multipleFiles="true" @change="demoFilesChanged" />
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
        <v-col class="col-12 col-lg-2" v-if="overwriteExistingFiles">
            <v-checkbox
                class="mt-3"
                v-model="overwriteExistingDigitalObjects"
                :label="t('digitalObjects.updateExistingFiles')"
                hide-details="auto"
                density="compact"
            />
        </v-col>
    </v-row>
    <v-row v-if="digitalObjectData.totalCount > 0">
        <v-col class="col-12 col-lg-4">
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
                            v-if="!readOnly && deleteEnabled && !item.hasExternalSource"
                            :confirmationText="
                                $t('digitalObjects.buttons.deleteMasterConfirmation', { title: item.sourceName })
                            "
                            :confirmButtonText="t('common.yes')"
                            :cancelButtonText="t('common.cancel')"
                            activatorButtonIcon="mdi-delete-outline"
                            activatorButtonColor="transparent"
                            activatorButtonVariant="flat"
                            @confirm="deleteFileClickHandler(item, true)"
                        />
                        <v-menu v-if="appendEnabled">
                            <template v-slot:activator="{ props }">
                                <v-btn icon color="transparent" variant="flat" v-bind="props">
                                    <v-icon>mdi-paperclip</v-icon>
                                </v-btn>
                            </template>

                            <v-list>
                                <v-list-item @click="openUploadDialog(DigitalObjectType.DerivativeFile, item.systemIdentifier)">
                                    <v-list-item-title>{{ t('digitalObjects.derivativesFile') }}</v-list-item-title>
                                </v-list-item>
                                <v-list-item @click="openUploadDialog(DigitalObjectType.DemoFile, item.systemIdentifier)">
                                    <v-list-item-title>{{  t('digitalObjects.demoFile') }}</v-list-item-title>
                                </v-list-item>
                            </v-list>
                        </v-menu>
                        
                    </template>
                </v-list-item>
            </v-list>
        </v-col>
        <v-col class="col-12 col-lg-4">
            <v-list variant="plain" density="compact">
                <v-list-subheader>{{ t('digitalObjects.derivativesFile') }}</v-list-subheader>
                <v-list-item
                    v-for="item in digitalObjectData.items.filter((obj) => obj.typeCode === 2)"
                    :key="item"
                    @click="displayClickHandler(item)"
                >
                    <v-list-item-title>{{ item.sourceName }}</v-list-item-title>
                    <template #append>
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
                            @confirm="deleteFileClickHandler(item, false)"
                        />
                    </template>
                </v-list-item>
            </v-list>
        </v-col>
        <v-col class="col-12 col-lg-4">
            <v-list variant="plain" density="compact" class="col-12">
                <v-list-subheader>{{ t('digitalObjects.demoFiles') }}</v-list-subheader>
                <v-list-item
                    v-for="item in digitalObjectData.items.filter((obj) => obj.typeCode === 3)"
                    :key="item"
                    @click="displayClickHandler(item)"
                >
                    <v-list-item-title>{{ item.sourceName }}</v-list-item-title>
                    <template #append>
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
                            @confirm="deleteFileClickHandler(item, false)"
                        />
                    </template>
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
    <UploadFileDialog
        v-model="showUploadDialog"
        packageType="B"
        :multiple="true"
        :skipValidationEnabled="true"
        @save="saveFilesHandler"
        @cancel="showUploadDialog = false"
    />
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, PropType, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from '@/store/app';
import { getFileExtension, isImage, isPdf, isSound } from '@/helpers/file.helper';
import { useRouter } from 'vue-router';
import { displayMessage } from '@/helpers/notification.helper';

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

import DisplayPdfModal from '@/components/digitalObject/displayPdfModal.vue';
import DisplayPlayerModal from '@/components/digitalObject/displayPlayerModal.vue';
import UploadFile from '@/components/files/uploadFile.vue';
import DisplayImageModal from '@/components/digitalObject/displayImageModal.vue';
import Loader from '@/components/loader/loader.vue';
import Switch from '@/components/checkbox/switch.vue';
import Pager from '@/components/grid/pager.vue';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import UploadFileDialog from '@/components/files/uploadFileDialog.vue';

export default defineComponent({
    name: 'DocumentDigitizedDigitalObjects',
    components: {
        //Grid,
        UploadFile,
        UploadFileDialog,
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
        appendEnabled: {
            type: Boolean,
            default: false,
        },
        deleteEnabled: {
            type: Boolean,
            default: false,
        },
        overwriteExistingFiles: {
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
        const digObjTypeCode = ref<number>();
        const appStore = useStore();

        const isLoading = ref(false);
        //const pageSize = PageSize.ten;
        const showUploadDialog = ref<boolean>(false);
        const uploadTypeCode = ref<number>();

        const masterFileSystemIdentifier = ref<string>();

        const displayModal = ref<boolean>(false);
        const displayAudioVideoModal = ref<boolean>(false);
        const imageUrl = ref<string>('');
        const pdfUrl = ref('');
        const displayPdf = ref(false);
        const audioVideoUrl = ref<string>('');

        const openUploadDialog = (typeCode?: number, parentSysId?: string) => {
            showUploadDialog.value = true;
            uploadTypeCode.value = typeCode;
            masterFileSystemIdentifier.value = parentSysId;
        };

        const closeModal = () => {
            displayModal.value = false;
            imageUrl.value = '';
            displayPdf.value = false;
            pdfUrl.value = '';
            audioVideoUrl.value = '';
            displayAudioVideoModal.value = false;
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
                    true
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
                    try {
                        const url = digitalObjectService.streamDigitalObjectUrl(
                            item.systemIdentifier!, true
                        );
                        if (isImage(item.name!)) {
                            imageUrl.value = url;
                            displayModal.value = true;
                        } else if (isPdf(item.name!)) {
                            digObjTypeCode.value = item.typeCode;
                            pdfUrl.value = '';
                            digitalObjectService.streamDigitalObjectFile(item.systemIdentifier!)
                            .then((response) => {
                                pdfUrl.value = URL.createObjectURL(response);
                            });
                            displayPdf.value = true;
                        } else if (isSound(item.name!)) {
                            audioVideoUrl.value = url;
                            displayAudioVideoModal.value = true;
                        } else {
                            const link = document.createElement('a');
                            link.href = url;
                            link.setAttribute('download', item.name!);
                            document.body.appendChild(link);
                            link.click();
                        }
                    } catch (error) {
                        if (error.status === 404) {
                            message.value = new Message({ type: 'warning', text: t('warning.fileNotFound') });
                        }
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
                message.value = new Message({ type: 'warning', text: t('warning.fileNotFound') });
            }
        };

        const deleteFileClickHandler = async (item: IDigitalObject, deleteRelated?: boolean) => {
            if (item) {
                try {
                    isLoading.value = true;

                    if (item.isDraft) {
                        await digitalObjectService.deleteDigitalObjectDraft(item.id!, deleteRelated);
                    } else {
                        await digitalObjectService.deleteDigitalObject(item.systemIdentifier!, deleteRelated);
                    }
                    await getDigitalObjectData();
                } catch (error: unknown) {
                    const errorResult = error as ResponseResult;
                    displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
                } finally {
                    isLoading.value = false;
                }
            } else {
                displayMessage(message, t('warning.fileNotFound'), 'warning');
            }
        };

        const saveFilesHandler = async (uploads: File[], skipValidation?: boolean) => {
            try {
                isLoading.value = true;

                await Promise.all(uploads.map(async (file) => {
                    const draft = new DigitalObjectDraft({
                        isCurrent: true,
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
                        typeCode: uploadTypeCode.value,
                        name: file.name,
                        sourceName: file.name,
                        fileType: file.type,
                        statusCode: '1',
                        isDigitized: true,
                        content: file,
                    });
                    draft.parentSystemIdentifier = masterFileSystemIdentifier.value;
                    draft.skipValidation = skipValidation ?? false;

                    await digitalObjectService.createDigitalObject(draft);
                }));
                
                await getDigitalObjectData();

                showUploadDialog.value = false;
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

        const skipValidation = ref(false);

        const masterFiles = ref<IDigitalObjectDraft[]>([]);
        const overwriteExistingDigitalObjects = ref<boolean>(false);

        const masterFilesChanged = (files: File[]) => {
            masterFiles.value = [];
            derivativesFiles.value = [];
            demoFiles.value = [];
            files.forEach((f) =>
                masterFiles.value.push(
                    new DigitalObjectDraft({
                        isCurrent: true,
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
        const derivativesFiles = ref<IDigitalObjectDraft[]>([]);
        const derivativesFilesChanged = (derivatives: File[]) => {
            derivativesFiles.value = [];
            derivatives.forEach((f) =>
                derivativesFiles.value.push(
                    new DigitalObjectDraft({
                        isCurrent: true,
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
                        typeCode: DigitalObjectType.DerivativeFile,
                        name: f.name,
                        sourceName: f.name,
                        fileType: f.type,
                        statusCode: '1',
                        content: f,
                    })
                )
            );
        };
        const demoFiles = ref<IDigitalObjectDraft[]>([]);
        const demoFilesChanged = (demo: File[]) => {
            demoFiles.value = [];
            demo.forEach((f) =>
                demoFiles.value.push(
                    new DigitalObjectDraft({
                        isCurrent: true,
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
                        typeCode: DigitalObjectType.DemoFile,
                        name: f.name,
                        sourceName: f.name,
                        fileType: f.type,
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
                    masterFiles.value[0].skipValidation = skipValidation.value;
                    await digitalObjectService.updateDigitalObject(masterFiles.value[0]).then((result) => {
                        masterFileSystemIdentifier.value = result;
                    });

                    derivativesFiles.value.forEach(async (dod) => {
                        dod.parentSystemIdentifier = masterFileSystemIdentifier.value;
                        dod.skipValidation = skipValidation.value;
                        await digitalObjectService.updateDigitalObject(dod);
                    });
                    demoFiles.value.forEach(async (dod) => {
                        dod.parentSystemIdentifier = masterFileSystemIdentifier.value;
                        dod.skipValidation = skipValidation.value;
                        await digitalObjectService.updateDigitalObject(dod);
                    });
                } else {
                    masterFiles.value[0].skipValidation = skipValidation.value;
                    await digitalObjectService.createDigitalObject(masterFiles.value[0]).then((result) => {
                        masterFileSystemIdentifier.value = result;
                    });
                    derivativesFiles.value.forEach(async (dod) => {
                        dod.parentSystemIdentifier = masterFileSystemIdentifier.value;
                        dod.skipValidation = skipValidation.value;
                        await digitalObjectService.createDigitalObject(dod);
                    });
                    demoFiles.value.forEach(async (dod) => {
                        dod.parentSystemIdentifier = masterFileSystemIdentifier.value;
                        dod.skipValidation = skipValidation.value;
                        await digitalObjectService.createDigitalObject(dod);
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
            digObjTypeCode,
            overwriteExistingDigitalObjects,
            changePage,
            displayClickHandler,
            downloadFileClickHandler,
            deleteFileClickHandler,
            saveFilesHandler,
            digitalObjectData,
            pagerOptions,
            imageUrl,
            audioVideoUrl,
            displayModal,
            displayPdf,
            pdfUrl,
            displayAudioVideoModal,
            openUploadDialog,
            closeModal,
            masterFilesChanged,
            addDigitalObjects,
            derivativesFilesChanged,
            demoFilesChanged,
            isLoading,
            skipValidation,
            showUploadDialog,
            DigitalObjectType,
        };
    },
});
</script>
