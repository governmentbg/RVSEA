<template>
    <div class="p-3">
        <v-card class="col-12 ma-auto mb-3" v-if="!readonly">
            <v-card-title class="v-card-title-uppercase">{{ $t('packages.importFile') }}</v-card-title>
            <v-container>
                <v-row>
                    <v-col>
                        <!-- <div class="h5">{{ $t('packages.importFile') }}:</div> -->
                        <div class="d-flex gap-2 justify-content-between align-items-center">
                            <Upload
                                ref="importBtn"
                                @change="(f) => (fileToImport = f[0])"
                                :acceptedFileTypes="'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/vnd.ms-excel, application/vnd.ms-excel.sheet.macroEnabled.12'"
                            ></Upload>
                            <ConfirmDialog
                                :width="800"
                                :disabled="!fileToImport"
                                :activatorButtonText="$t('packages.import')"
                                :confirmationText="'Всяка предишна структура ще бъде изтрита и заменена с новата от импортния файл. Сигурни ли сте, че искате да импортирате този файл?'"
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
                                <th>Номер</th>
                                <th>Архивна единица</th>
                                <th>Списък с документи</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="(structure, index) in importedStructure" :key="'struct' + index">
                                <td class="text-start" style="vertical-align: middle">
                                    {{ structure.number }}
                                </td>
                                <td class="text-start" style="vertical-align: middle">
                                    <div style="width: 10vw !important">
                                        {{ structure.title }}
                                    </div>
                                </td>
                                <td class="w-60">
                                    <tr
                                        v-for="doc in structure.documents"
                                        :key="doc.systemIdentifier"
                                        class="border-bottom d-flex justify-content-stretch align-items-center w-100 py-2 tr"
                                    >
                                        <td style="float: right">
                                            <div style="width: 10vw !important">
                                                {{ doc.title }}
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
                                                        >{{ doc.doc.name }}</span
                                                    >
                                                    <span
                                                        v-if="
                                                            (doc.doc.file || (doc.doc.id && !doc.doc._deleted)) &&
                                                            doc.doc.size
                                                        "
                                                    >
                                                        ({{ Math.round(doc.doc.size / 1024) }}KB)</span
                                                    >
                                                    <v-icon class="text-success me-2" v-if="doc.doc.file"
                                                        >mdi-check-bold</v-icon
                                                    >
                                                </div>
                                                <div>
                                                    <div
                                                        v-if="doc.doc.file || (doc.doc.id && !doc.doc._deleted)"
                                                        style="width: 50px"
                                                    >
                                                        <a
                                                            :href="buildDownloadUrl(doc.doc.id)"
                                                            class="text-decoration-none pointer fix-dumb-margins"
                                                            v-if="doc.doc.id && !doc.doc._deleted"
                                                        >
                                                            <v-tooltip>
                                                                <template v-slot:activator="{ props }">
                                                                    <v-icon color="primary" dark v-bind="props">
                                                                        mdi-download
                                                                    </v-icon>
                                                                </template>
                                                                <span>{{ $t('common.download') }}</span>
                                                            </v-tooltip>
                                                        </a>
                                                        <v-tooltip :text="$t('common.remove')" v-if="!readonly">
                                                            <template v-slot:activator="{ props }">
                                                                <v-icon
                                                                    v-bind="props"
                                                                    class="text-danger pointer fix-dumb-margins"
                                                                    @click="removeDocumentFile(doc.doc, doc.derivative)"
                                                                    >mdi-delete</v-icon
                                                                >
                                                            </template>
                                                        </v-tooltip>
                                                    </div>
                                                    <div v-else>
                                                        <v-btn
                                                            class="packageB-files-btn"
                                                            v-if="!readonly"
                                                            icon
                                                            color="transparent"
                                                            variant="flat"
                                                        >
                                                            <input
                                                                type="file"
                                                                @change="(e) => addFileToDoc(e, doc)"
                                                                title="Изберете файл"
                                                            />
                                                            <v-icon>mdi-folder</v-icon>
                                                            <v-tooltip activator="parent" location="bottom">
                                                                {{ 'Изберете файл' }}
                                                            </v-tooltip>
                                                        </v-btn>
                                                    </div>
                                                </div>
                                            </tr>
                                            <tr class="d-flex align-items-center justify-content-between w-100 py-2">
                                                <div>
                                                    <span
                                                        v-if="
                                                            (doc.derivative.file ||
                                                                (doc.derivative.id && !doc.derivative._deleted)) &&
                                                            doc.derivative.name
                                                        "
                                                        >{{ doc.derivative.name }}</span
                                                    >
                                                    <span
                                                        v-if="
                                                            (doc.derivative.file ||
                                                                (doc.derivative.id && !doc.derivative._deleted)) &&
                                                            doc.derivative.size
                                                        "
                                                    >
                                                        ({{ Math.round(doc.derivative.size / 1024, 0) }}KB)</span
                                                    >
                                                    <v-icon class="text-success me-2" v-if="doc.derivative.file"
                                                        >mdi-check-bold</v-icon
                                                    >
                                                </div>
                                                <div>
                                                    <div
                                                        v-if="
                                                            doc.derivative.file ||
                                                            (doc.derivative.id && !doc.derivative._deleted)
                                                        "
                                                        style="width: 50px"
                                                    >
                                                        <a
                                                            :href="buildDownloadDerivativeUrl(doc.derivative.fileId)"
                                                            class="text-decoration-none pointer fix-dumb-margins"
                                                            v-if="doc.derivative.id && !doc.derivative._deleted"
                                                        >
                                                            <v-tooltip>
                                                                <template v-slot:activator="{ props }">
                                                                    <v-icon color="primary" dark v-bind="props">
                                                                        mdi-download
                                                                    </v-icon>
                                                                </template>
                                                                <span>{{ $t('common.download') }}</span>
                                                            </v-tooltip>
                                                        </a>
                                                    <a
                                                            @click="displayDerivativeFile(doc.derivative)"
                                                            class="text-decoration-none cursor-pointer fix-dumb-margins"
                                                            v-if="doc.derivative.fileId && !doc.derivative._deleted"
                                                        >
                                                            <v-tooltip>
                                                                <template v-slot:activator="{ props }">
                                                                    <v-icon
                                                                        color="var(--ISDA-main-color4)"
                                                                        v-bind="props"
                                                                    >
                                                                        mdi-eye
                                                                    </v-icon>
                                                                </template>
                                                                <span>{{ $t('common.display') }}</span>
                                                            </v-tooltip>
                                                        </a>
                                                        <!-- <v-tooltip :text="$t('common.remove')" v-if="!readonly">
                                                            <template v-slot:activator="{ props }">
                                                                <v-icon
                                                                    v-bind="props"
                                                                    class="text-danger pointer fix-dumb-margins"
                                                                    @click="removeDocumentFile(doc.derivative)"
                                                                    >mdi-delete</v-icon
                                                                >
                                                            </template>
                                                        </v-tooltip> -->
                                                    </div>
                                                    <!-- <div v-else>
                                                        <v-btn
                                                            class="packageB-files-btn"
                                                            v-if="!readonly"
                                                            icon
                                                            color="transparent"
                                                            variant="flat"
                                                        >
                                                            <input
                                                                type="file"
                                                                @change="(e) => addDerivativeFileToDoc(e, doc)"
                                                                title="Изберете файл"
                                                            />
                                                            <v-icon>mdi-folder</v-icon>
                                                            <v-tooltip activator="parent" location="bottom">
                                                                {{ 'Изберете производен файл' }}
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
            </v-container>
        </v-card>
        <v-row class="mt-3" v-if="!loading && !readonly">
            <v-col class="d-grid gap-2 d-md-flex justify-content-center">
                <submit-btn @click="savePackages">{{ $t('common.save') }}</submit-btn>
            </v-col>
        </v-row>
    </div>
    <DisplayErrorList v-if="errorList.length" :items="errorList" class="mt-5" />
    <v-overlay :model-value="saving" class="align-center justify-center">
        <v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
    </v-overlay>
    <DisplayPdfModal v-model="displayPdf" :src="pdfUrl" @close="closeModal" :disableScroll="false" />
</template>

<script lang="ts">
import http from '@/services/http.service';
import { defineComponent, ref, inject, Ref } from 'vue';
import { useStore } from '@/store/app';
import Upload from '@/components/files/uploadFile.vue';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import { IPackageBFile, IInternalPackagesFormData, ImportErrorList } from '@/models/packages';
import { ImportedStructure, ImportedDocument } from '@/interfaces/application';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { IMessage } from '@/interfaces/notification';
import DisplayErrorList from '@/components/packageB/displayErrorList.vue';
import packagesService from '@/services/packages.service';
import { DigitalObjectType } from '@/enums/digitalObject';
import { formatBytesToMB, formatImportErrors } from '@/helpers/format.helper';
import { getTotalUploadFileSize } from '@/helpers/file.helper';
import router from '@/router';
import digitalObjectService from '@/services/digitalObject.service';
import { isPdf } from '@/helpers/file.helper';
import DisplayPdfModal from '@/components/digitalObject/displayPdfModal.vue';

export default defineComponent({
    name: 'PackageACreate',
    components: {
        ConfirmDialog,
        DisplayErrorList,
        Upload,
        DisplayPdfModal
    },
    emits: ['refresh'],
    props: {
        packageId: {
            type: Number,
            required: true,
        },
        inventoryIdentifier: {
            type: String,
            required: true,
        },
        readonly: {
            type: Boolean,
            default: false,
        },
    },
    setup(props, context) {
        const message = inject('notificationMessage') as Ref<IMessage>;
        const loading = ref(true);
        const saving = ref(false);
        const packageB = ref([] as Array<IPackageBFile>);
        const importedFile = ref<IPackageBFile>({} as IPackageBFile);
        const fileToImport = ref<File>();
        const store = useStore();
        const importedStructure = ref<ImportedStructure[]>();
        const errorList = ref([] as Array<ImportErrorList>);
        const pdfUrl = ref<string>('');
        const audioVideoUrl = ref<string>('');
        const imageUrl = ref<string>('');
        const displayModal = ref<boolean>(false);
        const displayAudioVideoModal = ref<boolean>(false);
        const displayPdf = ref<boolean>(false);

        //Load data
        const loadPackagesData = () => {
            loading.value = true;
            packagesService
                .getPackageBById(props.packageId)
                .then((response) => {
                    if (response.length && response.length > 0) {
                        // eslint-disable-next-line
                        packageB.value = response.map((t: any) => ({
                            id: t.id,
                            fileId: t.fileId,
                            name: t.fileName,
                            size: t.fileSize,
                            documentId: t.documentSystemIdentifier,
                            _deleted: false,
                            description: '',
                            documentSystemIdentifier: '',
                            fileSize: t.fileSize,
                            isInvaluable: false,
                            typeCode: t.typeCode,
                        }));
                    }

                    loadImportedStructure();
                })
                .catch((err) => console.log(err))
                .finally(() => (loading.value = false));
        };

        const loadImportedStructure = () => {
            // Get imported file with created structure
            loading.value = true;
            http.get('/api/Packages/structureByInventory/' + props.inventoryIdentifier)
                .then((response) => {
                    if (response.data.data) {
                        importedStructure.value = (response.data.data as ImportedStructure[]).map((x) => {
                            const item = { ...x };
                            item.documents.forEach(
                                (d) => (
                                    (d.doc = {
                                        _deleted: false,
                                        documentId: d.systemIdentifier,
                                        description: '',
                                        documentSystemIdentifier: '',
                                        fileSize: 0,
                                        isInvaluable: false,
                                        typeCode: DigitalObjectType.MasterFile,
                                    })
                                    ,
                                    (d.derivative = {
                                        _deleted: false,
                                        documentId: d.systemIdentifier,
                                        description: '',
                                        documentSystemIdentifier: '',
                                        fileSize: 0,
                                        isInvaluable: false,
                                        typeCode: DigitalObjectType.DerivativeFile,
                                    })
                                )
                            );
                            return item;
                        });
                    }

                    if (importedStructure.value) {
                        importedStructure.value.forEach((a: ImportedStructure) => {
                            a.documents.forEach((d: ImportedDocument) => {
                                const packageFile = packageB.value.find(
                                    (x) =>
                                        x.documentId === d.systemIdentifier &&
                                        x.typeCode == DigitalObjectType.MasterFile
                                );
                                const derivative = packageB.value.find(
                                    (x) =>
                                        x.documentId === d.systemIdentifier &&
                                        x.typeCode == DigitalObjectType.DerivativeFile
                                );
                                if (packageFile) {
                                    d.doc = packageFile;
                                    if (derivative) {
                                        d.derivative = derivative;
                                    }
                                }
                            });
                        });

                        importedStructure.value.sort((a, b) =>
                            a.number != undefined && b.number != undefined ? a.number?.localeCompare(b.number) : 0
                        );
                    }
                })
                .catch((err) => console.log(err))
                .finally(() => (loading.value = false));
        };

        const emitRefresh = () => {
            context.emit('refresh');
        };

        loadPackagesData();

        return {
            fileToImport,
            importedFile,
            errorList,
            importedStructure,
            loading,
            loadPackagesData,
            message,
            packageB,
            saving,
            store,
            emitRefresh,
            router,
            pdfUrl,
            audioVideoUrl,
            imageUrl,
            displayModal,
            displayAudioVideoModal,
            displayPdf
        };
    },

    methods: {
        addFileToDoc(e: Event, imp: ImportedDocument) {
            const files = (e.target as HTMLInputElement).files;
            if (files && files.length > 0) {
                imp.doc.file = files[0];
                imp.doc.name = files[0].name;
                imp.doc.size = files[0].size;
                imp.doc.typeCode = DigitalObjectType.MasterFile;
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
        //         imp.derivative.typeCode = DigitalObjectType.DerivativeFile;
        //     } else {
        //         imp.derivative.file = undefined;
        //     }
        // },

        buildDownloadUrl(id: number) {
            return packagesService.getPackageFileUrl(id, this.packageId);
        },

        buildDownloadDerivativeUrl (sysId: string) {
            //return digitalObjectService.getDownloadDigitalDerivativeObjectUrl(sysId, true);
            return digitalObjectService.streamDigitalObjectDraftUrl(sysId);
        },

        displayDerivativeFile(packageDocument: IPackageBFile) {
            if (isPdf(packageDocument.name!)) {
                this.pdfUrl = '';
                digitalObjectService.streamDigitalObjectDraftFile(packageDocument.fileId!)
                .then((response) => {
                    this.pdfUrl = URL.createObjectURL(response);
                });
                this.displayPdf = true;
            } else {
                //const url = this.store.getters.baseUrl + '/api/digitalobjects/downloadDarivative/' + packageDocument.fileId;
                const url = digitalObjectService.streamDigitalObjectDraftUrl(packageDocument.fileId!);
                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', packageDocument.name!);
                document.body.appendChild(link);
                link.click();
            }
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

        savePackages() {
            this.saving = true;
            const data: IInternalPackagesFormData = {
                inventoryId: this.inventoryIdentifier,
                packageB: [],
            };

            console.log(this.importedStructure);
            const totalFileSize = getTotalUploadFileSize(this.importedStructure ?? []);
            const totalInMB = formatBytesToMB(totalFileSize);

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

            this.importedStructure?.forEach((ae) => {
                if (ae.documents) {
                    ae.documents.forEach((doc) => {
                        data.packageB.push(doc.doc);
                        //data.packageB.push(doc.derivative);
                    });
                }
            });

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
                    this.router.go(0)
                })
                .catch((err: ResponseResult) => {
                    const errorResult = err as ResponseResult;
                    this.message = new Message({
                        text: errorResult.showMessage ? errorResult.message : this.$t('error.basic'),
                        display: true,
                    });
                })
                .then(() => (this.saving = false));
        },

        uploadImportFile() {
            const fd = new FormData();
            fd.append('file', this.fileToImport!);
            this.importedFile = {
                id: '',
                file: this.fileToImport,
                _deleted: false,
                fileSize: this.importedFile.fileSize,
                documentSystemIdentifier: '',
                description: '',
                isInvaluable: true,
                typeCode: null,
            };
            this.errorList = [];
            http.post(
                `/api/import/archivalEntities/${this.inventoryIdentifier}?readPackagesSheet=false&readInventorySheet=true`,
                fd
            )
                .then(() => {
                    this.fileToImport = undefined;
                    (this.$refs.importBtn as typeof Upload).clear();
                    this.loadPackagesData();
                    this.emitRefresh();
                })
                .catch((err) => {
                    console.log(err);
                    this.errorList = formatImportErrors(err.message);
                    this.message = new Message({
                        text: this.$t('error.importErrorSeeList'), //(err as ResponseResult)?.message,
                        display: true,
                    });
                });
        },

        onCommited() {
            this.message = new Message({
                text: this.$t('common.successfullyEdit'),
                display: true,
                type: 'success',
                timeout: 5000,
            });
            this.saving = false;
            this.$router.push('/applications');
        },

        onError() {
            this.saving = false;
            this.message = new Message({
                text: this.$t('error.basic'),
                display: true,
                type: 'error',
            });
        },

        onCancelSubmit() {
            this.saving = false;
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

.fix-dumb-margins {
    margin: 0 !important;
    display: table-cell !important;
}
</style>
