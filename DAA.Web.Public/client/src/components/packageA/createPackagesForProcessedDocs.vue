<template>
    <div class="p-3">
        <v-card class="col-12 ma-auto mb-3">
            <v-card-title class="v-card-title-uppercase">{{ $t('packages.packageA') }}</v-card-title>
            <v-container>
                <div class="text-center" v-if="loading">
                    <v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
                </div>
                <v-row v-if="!loading">
                    <v-col cols="12" md="6" v-for="t in templates" :key="t.id">
                        <div class="d-flex justify-content-between">
                            <span :class="{ required: t.required }">{{ t.title }}</span>
                            <a href="#" @click="downloadFileTemplate(t.id, t.fileName)">
                                <v-tooltip :text="'Свали шаблон'">
                                    <template v-slot:activator="{ props }">
                                        <v-icon v-bind="props">mdi-file-question-outline</v-icon>
                                    </template>
                                </v-tooltip>
                            </a>
                        </div>
                        <div class="my-2">{{ t.description }}</div>
                        <div v-if="!t.doc.id || t.doc._deleted">
                            <Upload @change="(f) => (t.doc.file = f)"></Upload>
                        </div>
                        <div v-else>
                            {{ t.doc.name }} ({{ parseFloat(t.doc.size / 1024).toFixed(2) }} KB)
                            <v-btn
                                icon
                                @click="displayFile(t.doc)"
                                class="text-decoration-none me-1"
                                v-if="t.doc.id && !t.doc._deleted"
                            >
                                <v-icon>mdi-eye</v-icon>
                                <v-tooltip activator="parent" location="bottom">
                                    {{ $t('common.display') }}
                                </v-tooltip>
                            </v-btn>
                            <v-btn icon @click="removeItemFromPackageA(t)">
                                <v-icon>mdi-delete</v-icon>
                                <v-tooltip activator="parent" location="bottom">
                                    {{ $t('common.delete') }}
                                </v-tooltip>
                            </v-btn>
                        </div>
                        <div class="my-2">
                            <text-field :label="$t('common.description')" v-model="t.doc.description"></text-field>
                        </div>
                    </v-col>
                </v-row>
            </v-container>
        </v-card>
        <v-card class="col-12 ma-auto mb-3" v-if="!modifyPackagesAfterCommission">
            <v-card-title class="v-card-title-uppercase">{{ $t('packages.importFile') }}</v-card-title>
            <v-container>
                <v-row>
                    <v-col>
                        <!-- <div class="h5">{{ $t('packages.importFile') }}:</div> -->
                        <div class="d-flex justify-content-between align-items-center">
                            <Upload
                                ref="importBtn"
                                @change="(f) => (fileToImport = f)"
                                :acceptedFileTypes="'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/vnd.ms-excel, application/vnd.ms-excel.sheet.macroEnabled.12'"
                            ></Upload>
                            <ConfirmDialog
                                :width="800"
                                :disabled="!fileToImport"
                                :activatorButtonText="$t('packages.import')"
                                :confirmationText="$t('applicationPackages.confirmImport')"
                                :confirmButtonText="$t('common.yes')"
                                :cancelButtonText="$t('common.no')"
                                @confirm="uploadImportFile"
                            ></ConfirmDialog>
                        </div>
                        <!-- <div v-if="importedFile && importedFile.file">
							{{ $t('packages.importedFile') }}:
							<b
								><v-icon dark class="text-success pb-1"> mdi-file-excel-outline </v-icon
								>{{ importedFile.file.name }}</b
							>
							<a :href="buildDownloadUrl(importedFile.id)" class="text-decoration-none">
								<v-tooltip>
									<template v-slot:activator="{ props }">
										<v-icon color="primary" dark v-bind="props"> mdi-download </v-icon>
									</template>
									<span>{{ $t('common.download') }}</span>
								</v-tooltip>
							</a>
						</div> -->
                    </v-col>
                </v-row>
            </v-container>
        </v-card>
        <v-card class="col-12 mx-auto mb-3" v-if="modifyPackagesAfterCommission">
            <v-container>
                <v-row>
                    <v-col>
                        <div>
                            <router-link :to="`/inventories/modify/${inventorySystemIdentifier}`">{{
                                $t('packages.inventory')
                            }}</router-link>
                        </div>
                    </v-col>
                </v-row>
            </v-container>
        </v-card>
        <v-card class="col-12 mx-auto mb-3">
            <v-card-title class="v-card-title-uppercase">{{ $t('packages.packageB') }}</v-card-title>
            <v-container>
                <div v-if="!importedStructure" class="my-3">
                    <v-alert border="start" color="red-darken-4" prominent type="error" variant="outlined">
                        {{ $t('packages.noImportFileMsg') }}
                    </v-alert>
                </div>
                <div v-if="importedStructure">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>{{ $t('applicationPackages.numberSymbol') }}</th>
                                <th>{{ $t('applicationPackages.archivalEntity') }}</th>
                                <th>{{ $t('applicationPackages.docsList') }}</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="(structure, index) in importedStructure" :key="'struct' + index">
                                <td class="text-center" style="vertical-align: middle; width: 5%">
                                    {{ structure.number }}
                                </td>
                                <td class="text-start" style="vertical-align: middle">
                                    <div style="width: 10vw !important">
                                        <router-link :to="`/archiveEntities/modify/${structure.systemIdentifier}`">
                                            {{ structure.title }}
                                        </router-link>
                                    </div>
                                </td>
                                <td class="w-60">
                                    <tr
                                        v-for="doc in structure.documents"
                                        :key="doc.systemIdentifier"
                                        class="d-flex justify-content-stretch align-items-center w-100 py-2 tr"
                                    >
                                        <td style="float: left">
                                            <div style="width: 10vw !important">
                                                <router-link :to="`/documents/modify/${doc.systemIdentifier}`">
                                                    {{ doc.documentNumber }} - {{ doc.title }}
                                                </router-link>
                                            </div>
                                        </td>
                                        <td style="margin-left: 100px; width: 100%">
                                            <tr class="d-flex align-items-center justify-content-between w-100 py-2">
                                                <div class="marginR">
                                                    <span
                                                        v-if="
                                                            (doc.doc.file || (doc.doc.id && !doc.doc._deleted)) &&
                                                            doc.doc.name
                                                        "
                                                    >
                                                        <p>
                                                            <b>{{ $t('packages.masterFiles') }}:</b>
                                                        </p>
                                                        {{ doc.doc.name }}
                                                    </span>
                                                    <span
                                                        v-if="
                                                            (doc.doc.file || (doc.doc.id && !doc.doc._deleted)) &&
                                                            doc.doc.size
                                                        "
                                                    >
                                                        ({{ Math.round(doc.doc.size / 1024, 0) }}KB)
                                                    </span>
                                                    <v-icon class="text-success me-2" v-if="doc.doc.file">
                                                        mdi-check-bold
                                                    </v-icon>
                                                </div>
                                                <div class="td" style="float: right; white-space: nowrap">
                                                    <div v-if="doc.doc.file || (doc.doc.id && !doc.doc._deleted)">
                                                        <v-btn
                                                            class="me-1"
                                                            icon
                                                            @click="displayFile(doc.doc)"
                                                            v-if="doc.doc.id && !doc.doc._deleted"
                                                        >
                                                            <v-icon>mdi-eye</v-icon>
                                                            <v-tooltip activator="parent">
                                                                {{ $t('common.display') }}
                                                            </v-tooltip>
                                                        </v-btn>
                                                        <v-btn
                                                            icon
                                                            @click="removeDocumentFile(doc.doc, doc.derivative)"
                                                        >
                                                            <v-icon>mdi-delete</v-icon>
                                                            <v-tooltip activator="parent">
                                                                {{ $t('common.remove') }}
                                                            </v-tooltip>
                                                        </v-btn>
                                                    </div>
                                                    <div class="td" v-else>
                                                        <v-btn class="packageB-files-btn" size="small">
                                                            <input
                                                                type="file"
                                                                @change="(e) => addFileToDoc(e, doc)"
                                                                :title="$t('common.chooseFile')"
                                                            />
                                                            <v-icon>mdi-folder</v-icon>
                                                            <v-tooltip activator="parent" location="bottom">
                                                                {{ $t('packages.masterFiles') }}
                                                            </v-tooltip>
                                                        </v-btn>
                                                    </div>
                                                </div>
                                            </tr>
                                            <tr class="d-flex justify-content-between w-100 py-2">
                                                <div class="marginR">
                                                    <span
                                                        v-if="
                                                            (doc.derivative.file ||
                                                                (doc.derivative.id && !doc.derivative._deleted)) &&
                                                            doc.derivative.name
                                                        "
                                                    >
                                                        <p>
                                                            <b>{{ $t('packages.derivativeFiles') }}:</b>
                                                        </p>
                                                        {{ doc.derivative.name }}
                                                    </span>
                                                    <span
                                                        v-if="
                                                            (doc.derivative.file ||
                                                                (doc.derivative.id && !doc.derivative._deleted)) &&
                                                            doc.derivative.size
                                                        "
                                                    >
                                                        ({{ Math.round(doc.derivative.size / 1024, 0) }}KB)
                                                    </span>
                                                    <v-icon class="text-success me-2" v-if="doc.derivative.file">
                                                        mdi-check-bold
                                                    </v-icon>
                                                </div>
                                                <div>
                                                    <div
                                                        v-if="
                                                            doc.derivative.file ||
                                                            (doc.derivative.id && !doc.derivative._deleted)
                                                        "
                                                        class="align-items-end"
                                                        style="float: right; white-space: nowrap"
                                                    >
                                                        <v-btn
                                                            class="me-1"
                                                            icon
                                                            @click="displayDerivativeFile(doc.derivative)"
                                                            v-if="doc.derivative.id && !doc.derivative._deleted"
                                                        >
                                                            <v-icon>mdi-eye</v-icon>
                                                            <v-tooltip activator="parent">
                                                                {{ $t('common.display') }}
                                                            </v-tooltip>
                                                        </v-btn>
                                                        <!-- <v-btn icon @click="removeDocumentFile(doc.derivative)">
                                                            <v-icon>mdi-delete</v-icon>
                                                            <v-tooltip activator="parent">
                                                                {{ $t('common.remove') }}
                                                            </v-tooltip>
                                                        </v-btn> -->
                                                    </div>
                                                    <!-- <div v-else>
                                                        <v-btn class="packageB-files-btn" size="small">
                                                            <input
                                                                type="file"
                                                                @change="(e) => addDerivativeFileToDoc(e, doc)"
                                                                :title="$t('common.chooseFile')"
                                                                accept="application/pdf, application/vnd.ms-excel"
                                                            />
                                                            <v-icon>mdi-folder</v-icon>
                                                            <v-tooltip activator="parent" location="bottom">
                                                                {{ $t('packages.derivativeFiles') }}
                                                            </v-tooltip>
                                                        </v-btn>
                                                    </div> -->
                                                </div>
                                            </tr>
                                        </td>
                                    </tr>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <!-- <pre>{{ importedStructure }}</pre> -->
            </v-container>
        </v-card>
        <v-row class="mt-3" v-if="!loading">
            <v-col class="d-grid gap-2 d-md-flex justify-content-center">
                <v-btn @click="savePackages">{{ $t('applicationPackages.saveFiles') }}</v-btn>
                <v-btn class="cancel" @click="onCancel">{{ $t('common.close') }}</v-btn>
                <ConfirmDialog
                    :width="800"
                    :disabled="false"
                    :activatorButtonText="$t('applicationPackages.sendToStateArchive')"
                    :confirmationText="$t('applicationPackages.confirmSend')"
                    :confirmButtonText="$t('common.yes')"
                    :cancelButtonText="$t('common.no')"
                    @confirm="onSendToArchive"
                    @cancel="onCancelSubmit"
                ></ConfirmDialog>
            </v-col>
        </v-row>

        <VideoPlayer v-model="displayAudioVideoModal" :src="audioVideoUrl" @close="closeModal" />
        <DisplayImageModal v-model="displayModal" :src="imageUrl" @close="closeModal" />
        <DisplayPdfModal v-model="displayPdf" :src="pdfUrl" @close="closeModal" />
    </div>
    <DisplayErrorList v-if="errorList.length" :items="errorList" class="mt-5" />
    <v-overlay :model-value="saving" class="align-center justify-center">
        <v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
    </v-overlay>
</template>

<script lang="ts">
import { computed, defineComponent, ref, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from '@/store/app';

import { IPackageATemplate } from '@/models/packageATemplates';
import { IPackagesFormData, IPackageBFile, IPackageAFile, ImportErrorList } from '@/models/packages';
import { ImportedStructure, ImportedDocument } from '@/interfaces/application';
import http from '@/services/http.service';
import packagesService from '@/services/packages.service';
import digitalObjectService from '@/services/digitalObject.service';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import DisplayImageModal from '@/components/digitalObjects/displayImageModal.vue';
import VideoPlayer from '@/components/digitalObjects/displayAudioVideoPlayerModal.vue';
import Upload from '@/components/files/upload.vue';
import TextField from '@/components/field/text.field.vue';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import DisplayErrorList from '@/components/packageA/displayErrorList.vue';
import {
    b64toBlob,
    isImage,
    isPdf,
    isSound,
    getTotalUploadPackageBFileSize,
    getTotalUploadPackageAFileSize,
} from '@/helpers/file.helper';
import DisplayPdfModal from '@/components/digitalObjects/displayPdfModal.vue';
import { DigitalObjectType } from '@/enums/digitalObjects';
import { formatBytesToMB, formatImportErrors } from '@/helpers/format.helper';

export default defineComponent({
    name: 'PackageACreate',
    components: {
        ConfirmDialog,
        DisplayImageModal,
        DisplayErrorList,
        VideoPlayer,
        TextField,
        Upload,
        DisplayPdfModal,
    },
    props: {
        applicationId: {
            type: Number,
            required: true,
        },
        modifyPackagesAfterCommission: {
            type: Boolean,
            required: false,
            default: false,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const loading = ref(true);
        const saving = ref(false);
        const templates = ref([] as IPackageATemplate[]);
        const packageB = ref([] as Array<IPackageBFile>);
        const importedFile = ref<IPackageBFile>({} as IPackageBFile);
        const fileToImport = ref<File>();
        const store = useStore();
        const importedStructure = ref<ImportedStructure[]>();
        const displayModal = ref<boolean>(false);
        const displayAudioVideoModal = ref<boolean>(false);
        const audioVideoUrl = ref<string>('');
        const imageUrl = ref<string>('');
        const inventorySystemIdentifier = ref<string>('');
        const pdfUrl = ref<string>('');
        const displayPdf = ref<boolean>(false);
        const errorList = ref([] as Array<ImportErrorList>);
        // load inventory system identifier
        http.get('/api/Applications/getInventoryDraftSysId/' + props.applicationId)
            .then((response) => {
                inventorySystemIdentifier.value = response.data.data as string;
            })
            .catch((err) => console.log(err));

        //Load templates
        //Package A
        http.get('/api/Packages/templatesByApplication/' + props.applicationId)
            .then((response) => {
                templates.value = (response.data.data as IPackageATemplate[]).map((x) => ({
                    ...x,
                    doc: { documentTypeId: x.id },
                })) as IPackageATemplate[];
                loadPackagesData();
            })
            .catch((err) => console.log(err))
            .then(() => (loading.value = false));

        //Load data
        const loadPackagesData = () => {
            packagesService
                .getByApplication(props.applicationId)
                .then((response) => {
                    if (response.packageA) {
                        // eslint-disable-next-line
                        response.packageA.forEach((f: any) => {
                            templates.value.forEach((t) => {
                                if (t.id === f.documentTypeId) {
                                    t.doc = {} as IPackageAFile;
                                    t.doc.description = f.description;
                                    t.doc.id = f.id;
                                    t.doc.name = f.fileName;
                                    t.doc.size = f.fileSize;
                                }
                            });
                        });
                    }
                    if (response.packageB) {
                        // eslint-disable-next-line
                        packageB.value = response.packageB.map((t: any) => ({
                            id: t.id,
                            fileId: t.fileId,
                            name: t.fileName,
                            size: t.fileSize,
                            documentId: t.documentSystemIdentifier,
                            _deleted: false,
                            typeCode: t.typeCode,
                        }));
                    }

                    loadImportedStructure();
                })
                .catch((err) => console.log(err));
        };

        const loadImportedStructure = () => {
            // Get imported file with created structure
            http.get('/api/Packages/structure/' + props.applicationId)
                .then((response) => {
                    importedStructure.value = (response.data.data as ImportedStructure[]).map((x) => {
                        var item = { ...x };
                        item.documents.forEach(
                            (d) => (
                                (d.doc = {
                                    _deleted: false,
                                    documentId: d.systemIdentifier,
                                    typeCode: DigitalObjectType.MasterFile,
                                }),
                                (d.derivative = {
                                    _deleted: false,
                                    documentId: d.systemIdentifier,
                                    typeCode: DigitalObjectType.DerivativeFile,
                                })
                            )
                        );
                        return item;
                    });

                    if (importedStructure.value) {
                        importedStructure.value.forEach((a: ImportedStructure) => {
                            a.documents.forEach((d: ImportedDocument) => {
                                const packageFile = packageB.value.find(
                                    (x) =>
                                        x.documentId === d.systemIdentifier &&
                                        x.typeCode == DigitalObjectType.MasterFile
                                );
                                const packageDemoFile = packageB.value.find(
                                    (x) =>
                                        x.documentId === d.systemIdentifier &&
                                        x.typeCode == DigitalObjectType.DerivativeFile
                                );
                                if (packageFile) {
                                    d.doc = packageFile;
                                    if (packageDemoFile) {
                                        d.derivative = packageDemoFile;
                                    }
                                }
                            });
                        });

                        importedStructure.value.sort((a, b) =>
                            a.numberNumeric != undefined && b.numberNumeric != undefined
                                ? a.numberNumeric - b.numberNumeric
                                : a.numberArray != undefined && b.numberArray != undefined
                                ? a.numberArray?.localeCompare(b.numberArray)
                                : 0
                        );

                        importedStructure.value.forEach((a: ImportedStructure) => {
                            a.documents.sort((a, b) =>
                                a.documentNumber != undefined && b.documentNumber != undefined
                                    ? a.documentNumber - b.documentNumber
                                    : 0
                            );
                        });
                    }
                })
                .catch((err) => console.log(err));
        };

        const canSubmit = computed(() => {
            if (templates.value) {
                const aInvalid = templates.value.some(
                    (x) => x.required === true && !x.doc.file && x.doc.id && x.doc._deleted
                );
                const bInvalid =
                    importedStructure.value &&
                    importedStructure.value.some((x) => {
                        if (x.documents) {
                            return x.documents.some((y) => !y.doc.file);
                        }
                    });
                return aInvalid || bInvalid;
            }

            return true;
        });

        const displayFile = (doc: IPackageBFile | IPackageAFile) => {
            const url = packagesService.getFileDownloadUrl(doc.id!, true);
            if (isImage(doc.name!)) {
                imageUrl.value = url;
                displayModal.value = true;
            } else if (isSound(doc.name!)) {
                audioVideoUrl.value = url;
                displayAudioVideoModal.value = true;
            } else if (isPdf(doc.name as string)) {
                pdfUrl.value = '';
                packagesService.streamPackageDocumentFile(doc.id!)
                .then((response) => {
                    pdfUrl.value = URL.createObjectURL(response);
                });
                displayPdf.value = true;
            } else {
                downloadFromUrl(url, doc.name!);
            }
        };

        const downloadFileTemplate = (templateId: number, filename: string) => {
            http.get(`/api/packages/downloadtemplate/${templateId}`).then((response) => {
                const url = b64toBlob(response.data.message, 'application/octet-stream');
                downloadFromUrl(url, filename);
            });
        };

        const downloadFromUrl = (url: string, filename: string) => {
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', filename);
            document.body.appendChild(link);
            link.click();
        };

        const displayDerivativeFile = (item: IPackageBFile) => {
            //TODO ADD TOKEN!!!!!!!!!!!!!
            if (item) {
                const url = digitalObjectService.streamDigitalObjectDraftFileUrl(
                    item.fileId!,
                    true
                );
                if (isImage(item.name!)) {
                    imageUrl.value = url
                    displayModal.value = true;
                } else if (isSound(item.name!)) {
                    audioVideoUrl.value = url;
                    displayAudioVideoModal.value = true;
                } else if (isPdf(item.name!)) {
                    pdfUrl.value = '';
                    digitalObjectService.streamDigitalObjectDraftFile(item.fileId!)
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
                
            } else {
                message.value = new Message({ type: 'warning', text: t('warning.fileNotFound') });
            }
        };

        const closeModal = () => {
            displayModal.value = false;
            imageUrl.value = '';
            audioVideoUrl.value = '';
            displayAudioVideoModal.value = false;
            pdfUrl.value = '';
            displayPdf.value = false;
        };

        return {
            downloadFileTemplate,
            fileToImport,
            importedFile,
            importedStructure,
            loading,
            loadPackagesData,
            displayFile,
            message,
            canSubmit,
            packageB,
            saving,
            store,
            templates,
            audioVideoUrl,
            displayPdf,
            pdfUrl,
            imageUrl,
            displayAudioVideoModal,
            displayModal,
            errorList,
            closeModal,
            formatImportErrors,
            inventorySystemIdentifier,
            displayDerivativeFile,
        };
    },

    methods: {
        addFileToDoc(e: Event, imp: ImportedDocument) {
            const files = (e.target as HTMLInputElement).files;
            if (files && files.length > 0) {
                imp.doc.file = files[0];
                imp.doc.name = files[0].name;
                imp.doc.size = files[0].size;
            } else {
                imp.doc.file = undefined;
            }
        },

        // addDerivativeFileToDoc(e: Event, imp: ImportedDocument) {
        //     const files = (e.target as HTMLInputElement).files;
        //     if (files && files.length > 0) {
        //         imp.derivative.file = files[0];
        //         imp.derivative.name = files[0].name;
        //         imp.derivative.size = files[0].size;
        //     } else {
        //         imp.derivative.file = undefined;
        //     }
        // },
        // buildDownloadUrl(id: number) {
        //     return this.store.getters.baseUrl + '/api/packages/download/' + id;
        // },
        onCancel() {
            this.$router.back();
        },

        removeDocumentFile(doc: IPackageBFile, derivative: IPackageBFile) {
            if (doc.file) {
                doc.file = undefined;
                doc.name = '';
                doc.size = 0;
            }

            doc._deleted = true;

            if (derivative.file) {
                derivative.file = undefined;
                derivative.name = '';
                derivative.size = 0;
            }

            derivative._deleted = true;
        },

        getDataForSaving() {
            const data: IPackagesFormData = {
                applicationId: this.applicationId,
                packageA: this.templates.map((x) => x.doc),
                packageB: [],
            };

            this.importedStructure?.forEach((ae) => {
                if (ae.documents) {
                    ae.documents.forEach((doc) => {
                        doc.doc.typeCode = DigitalObjectType.MasterFile;
                        data.packageB.push(doc.doc);
                        //Derivative files will be created automatically
                        // if (doc.doc) {
                        //     doc.derivative.typeCode = DigitalObjectType.DerivativeFile;
                        //     data.packageB.push(doc.derivative);
                        // }
                    });
                }
            });

            return data;
        },

        savePackages() {
            this.saving = true;

            const totalFileSizePackageA = getTotalUploadPackageAFileSize(this.templates);
            const totalFileSizePackageB = getTotalUploadPackageBFileSize(this.importedStructure ?? []);
            const totalInMB = formatBytesToMB(totalFileSizePackageA + totalFileSizePackageB);

            if (totalInMB >= this.store.getters.maxPackageBFileSizeInMB) {
                this.message = new Message({
                    text: this.$t('error.fileSizeOverLimit', {
                        fileSize: totalInMB,
                        limit: this.store.getters.maxPackageBFileSizeInMB,
                    }),
                    display: true,
                });
                this.saving = false;
                return;
            }

            const data = this.getDataForSaving();

            packagesService
                .createWithImport(data)
                .then(() => {
                    this.message = new Message({
                        text: this.$t('common.successfullyEdit'),
                        display: true,
                        type: 'success',
                        timeout: 5000,
                    });
                    this.loadPackagesData();
                })
                .catch((err) => {
                    const errorResult = err as ResponseResult;
                    this.message = new Message({
                        text: errorResult.showMessage ? errorResult.message : this.$t('error.basic'),
                        display: true,
                    });
                })
                .then(() => (this.saving = false));
        },

        uploadImportFile() {
            debugger;
            if (this.modifyPackagesAfterCommission == true) {
                return;
            }

            const fd = new FormData();
            fd.append('file', this.fileToImport!);
            this.importedFile = { id: 0, file: this.fileToImport, _deleted: false };
            this.errorList = [];
            http.post(`/api/import/archivalEntities/application/${this.applicationId}`, fd)
                .then(() => {
                    this.message = new Message({
                        text: this.$t('common.successfulImport'),
                        display: true,
                        type: 'success',
                        timeout: 5000,
                    });
                    this.fileToImport = undefined;
                    (this.$refs.importBtn as typeof Upload).clear();
                    this.loadPackagesData();
                })
                .catch((err) => {
                    this.fileToImport = undefined;
                    (this.$refs.importBtn as typeof Upload).clear();
                    //const errorResult = err as ResponseResult;
                    this.errorList = formatImportErrors(err.message);

                    this.message = new Message({
                        text: this.$t('error.importError'), // errorResult.showMessage ? errorResult.message :
                        display: true,
                    });
                });
        },

        onSendToArchive() {
            this.saving = true;
            const data = this.getDataForSaving();

            packagesService
                .createWithImport(data)
                .then(() => {
                    return packagesService.submit(this.applicationId);
                })
                .then(() => {
                    this.onCommited();
                })
                .catch((err) => this.onError(err));
        },

        onCommited() {
            this.message = new Message({
                text: this.$t('applicationPackages.successfullySentToArchive'),
                display: true,
                type: 'success',
                timeout: 5000,
            });
            this.saving = false;
            this.$router.push('/applications');
        },

        onError(errorResult: ResponseResult) {
            this.saving = false;
            this.message = new Message({
                text: errorResult.showMessage ? errorResult.message : this.$t('error.basic'),
                display: true,
                type: 'error',
            });
        },

        onCancelSubmit() {
            this.saving = false;
        },

        removeItemFromPackageA(t: IPackageATemplate) {
            t.doc!.name = '';
            t.doc!.size = 0;
            t.doc!.description = '';
            t.doc._deleted = true;
        },
    },
});
</script>

<style lang="scss" scoped>
.packageB-files-btn {
    margin: 0 !important;
    .v-btn__content {
        position: relative;
        input {
            position: absolute;
            left: 0;
            top: 0;
            right: 0;
            bottom: 0;
            opacity: 0;
            cursor: pointer !important;
            width: 50px;
            height: 40px;
            z-index: 1;
        }
    }
}

.table > tbody {
    font-size: 0.8em;
}
.tr {
    border-bottom: 1px solid rgb(128, 128, 128);
}
.td {
    margin-bottom: 5px;
}
.marginR {
    margin-right: 20px !important;
}
</style>
