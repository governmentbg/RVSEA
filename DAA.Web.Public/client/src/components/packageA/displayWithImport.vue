<template>
    <div class="p-3">
        <v-card class="col-12 ma-auto mb-3">
            <v-card-title class="v-card-title-uppercase">{{ $t('packages.packageA') }}</v-card-title>
            <v-container>
                <div class="text-center" v-if="loading">
                    <v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
                </div>
                <v-row v-for="t in templates" :key="t.id" class="mb-3 border-bottom">
                    <v-col cols="12" md="6">
                        <div>{{ t.title }}</div>
                        <div class="d-flex w-100" v-if="t.doc.size">
                            {{ `${t.doc.name} (${Math.round(t.doc.size / 1024)} KB)` }}
                            <a @click="displayFile(t.doc)" class="text-decoration-none cursor-pointer ms-1">
                                <v-tooltip>
                                    <template v-slot:activator="{ props }">
                                        <v-icon color="var(--ISDA-main-color4)" v-bind="props"> mdi-eye </v-icon>
                                    </template>
                                    <span>{{ $t('common.display') }}</span>
                                </v-tooltip>
                            </a>
                            <a :href="buildDownloadUrl(t.doc.id!)" class="text-decoration-none">
                                <v-tooltip>
                                    <template v-slot:activator="{ props }">
                                        <v-icon color="var(--ISDA-main-color4)" v-bind="props"> mdi-download </v-icon>
                                    </template>
                                    <span>{{ $t('common.download') }}</span>
                                </v-tooltip>
                            </a>
                        </div>
                        <div v-else class="text-danger">{{ $t('applicationPackages.noUploadedFile') }}</div>
                    </v-col>
                    <v-col cols="12" md="6" v-if="t.description">
                        <div>{{ $t('applicationPackages.description') }}</div>
                        <div>
                            {{ t.description }}
                        </div>
                    </v-col>
                </v-row>
            </v-container>
            <v-card-title v-if="hasSignatureRequests" class="v-card-title-uppercase">{{
                $t('packages.signatureRequest')
            }}</v-card-title>
            <v-container v-if="hasSignatureRequests">
                <SignatureRequests :applicationId="applicationId" />
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
                                <th>{{ $t('applicationPackages.number') }}</th>
                                <th>{{ $t('applicationPackages.archivalEntity') }}</th>
                                <th>{{ $t('applicationPackages.docsList') }}</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="(structure, index) in importedStructure" :key="'struct' + index">
                                <td class="text-center" style="vertical-align: middle">
                                    {{ structure.number }}
                                </td>
                                <td class="text-start" style="vertical-align: middle">
                                    <div style="width: 10vw !important;">
                                        {{ structure.title }}
                                    </div>
                                </td>
                                <td>
                                    <tr
                                        v-for="doc in structure.documents"
                                        :key="doc.systemIdentifier"
                                        class="border-bottom d-flex justify-content-stretch align-items-center w-100 py-2"
                                    >
                                        <td style="float: left;">
                                            <div style="flex-basis: 30%; width: 10vw !important;">
                                                {{ doc.title }}
                                            </div>
                                        </td>
                                        <td style="margin-left: 100px; width: 100%">
                                            <tr
                                                class="border-bottom d-flex justify-content-between align-items-center w-100 py-2 td"
                                            >
                                                <div v-if="doc && doc.doc">
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
                                                <div v-if="doc && doc.doc">
                                                    <div
                                                        v-if="doc.doc.file || (doc.doc.id && !doc.doc._deleted)"
                                                        style="width: 50px"
                                                    >
                                                        <v-icon class="text-success me-2" v-if="doc.doc.file"
                                                            >mdi-check-bold</v-icon
                                                        >
                                                        <a
                                                            @click="displayFile(doc.doc)"
                                                            class="text-decoration-none cursor-pointer"
                                                            v-if="doc.doc.id && !doc.doc._deleted"
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
                                                        <a
                                                            :href="buildDownloadUrl(doc.doc.id)"
                                                            class="text-decoration-none"
                                                            v-if="doc.doc.id && !doc.doc._deleted"
                                                        >
                                                            <v-tooltip>
                                                                <template v-slot:activator="{ props }">
                                                                    <v-icon
                                                                        color="var(--ISDA-main-color4)"
                                                                        v-bind="props"
                                                                    >
                                                                        mdi-download
                                                                    </v-icon>
                                                                </template>
                                                                <span>{{ $t('common.download') }}</span>
                                                            </v-tooltip>
                                                        </a>
                                                    </div>
                                                </div>
                                            </tr>
                                            <tr class="d-flex justify-content-between align-items-center w-100 py-2 td">
                                                <div v-if="doc && doc.derivative">
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
                                                <div v-if="doc && doc.derivative">
                                                    <div
                                                        v-if="
                                                            doc.derivative.file ||
                                                            (doc.derivative.id && !doc.derivative._deleted)
                                                        "
                                                        style="width: 50px"
                                                    >
                                                        <v-icon class="text-success me-2" v-if="doc.derivative.file"
                                                            >mdi-check-bold</v-icon
                                                        >
                                                        <a
                                                            @click="displayDerivativeFile(doc.derivative)"
                                                            class="text-decoration-none cursor-pointer"
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
                                                        <a
                                                            :href="buildDownloadDerivativeUrl(doc.derivative.fileId!)"
                                                            class="text-decoration-none"
                                                            v-if="doc.derivative.id && !doc.derivative._deleted"
                                                        >
                                                            <v-tooltip>
                                                                <template v-slot:activator="{ props }">
                                                                    <v-icon
                                                                        color="var(--ISDA-main-color4)"
                                                                        v-bind="props"
                                                                    >
                                                                        mdi-download
                                                                    </v-icon>
                                                                </template>
                                                                <span>{{ $t('common.download') }}</span>
                                                            </v-tooltip>
                                                        </a>
                                                    </div>
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
    </div>
    <v-overlay :model-value="saving" class="align-center justify-center">
        <v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
    </v-overlay>
    <DisplayImageModal v-model="displayModal" :src="imageUrl" @close="closeModal" />
    <VideoPlayer v-model="displayAudioVideoModal" :src="audioVideoUrl" @close="closeModal" />
    <DisplayPdfModal v-model="displayPdf" :src="pdfUrl" @close="closeModal" />
</template>

<script lang="ts">
import { computed, defineComponent, ref, inject, Ref, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from '@/store/app';
import { isImage, isPdf, isSound } from '@/helpers/file.helper';

import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { IPackageATemplate } from '@/models/packageATemplates';
import { IPackageBFile, IPackageAFile } from '@/models/packages';
import { ImportedStructure, ImportedDocument } from '@/interfaces/application';
import { DigitalObjectType } from '@/enums/digitalObjects';

import http from '@/services/http.service';
import packagesService from '@/services/packages.service';
import digitalObjectService from '@/services/digitalObject.service';

import SignatureRequests from '@/components/packageA/signatureRequests.vue';
import DisplayImageModal from '@/components/digitalObjects/displayImageModal.vue';
import VideoPlayer from '@/components/digitalObjects/displayAudioVideoPlayerModal.vue';
import DisplayPdfModal from '@/components/digitalObjects/displayPdfModal.vue';

export default defineComponent({
    name: 'PackageACreate',
    components: {
        VideoPlayer,
        SignatureRequests,
        DisplayImageModal,
        DisplayPdfModal,
    },
    props: {
        applicationId: {
            type: Number,
            required: true,
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
        const hasSignatureRequests = ref<boolean>(false);
        const displayModal = ref<boolean>(false);
        const displayAudioVideoModal = ref<boolean>(false);
        const audioVideoUrl = ref<string>('');
        const imageUrl = ref<string>('');
        const pdfUrl = ref<string>('');
        const displayPdf = ref<boolean>(false);

        const buildDownloadUrl = (id: number) => {
            return packagesService.getFileDownloadUrl(id);
        };

        const buildDownloadDerivativeUrl = (sysId: string) => {
            //TODO ADD TOKEN!!!!!!!!!!!!!
            return digitalObjectService.streamDigitalObjectDraftFileUrl(sysId);
        }

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

            // if (isImage(item.name as string)) {
            //     imageUrl.value = store.getters.baseUrl + '/api/digitalobjects/downloadDarivative/' + item.fileId;
            //     displayModal.value = true;
            // } else if (isSound(item.name as string)) {
            //     audioVideoUrl.value = store.getters.baseUrl + '/api/digitalobjects/downloadDarivative/' + item.fileId;
            //     displayAudioVideoModal.value = true;
            // } else if (isPdf(item.name as string)) {
            //     pdfUrl.value = '';
            //     http.get(`/api/digitalobjects/downloadDarivative/${item.fileId}`).then((response) => {
            //         pdfUrl.value = b64toBlob(response.data.message);
            //     });
            //     displayPdf.value = true;
            // } else {
            //     const url = store.getters.baseUrl + '/api/digitalobjects/downloadDarivative/' + item.fileId;
            //     const link = document.createElement('a');
            //     link.href = url;
            //     link.setAttribute('downloadDarivative', item.name!);
            //     document.body.appendChild(link);
            //     link.click();
            // }
        }

        const hasPackageDocumentsSignatureRequests = () => {
            packagesService
                .hasPackageDocumentsBySignatureRequest(props.applicationId)
                .then((data) => {
                    hasSignatureRequests.value = data;
                })
                .catch((error) => {
                    console.log(error);
                });
        };

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
                    if (response) {
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

                        // eslint-disable-next-line
                        packageB.value = response.packageB.map((t: any) => ({
                            id: t.id,
                            fileId: t.fileId,
                            name: t.fileName,
                            size: t.fileSize,
                            documentId: t.documentSystemIdentifier,
                            _deleted: false,
                            typeCode: t.typeCode,
                            parentId: t.parentId,
                        }));
                    }

                    hasPackageDocumentsSignatureRequests();

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
                        item.documents.forEach((d) => (d.doc = { _deleted: false, documentId: d.systemIdentifier }));
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
                                 const derivativeFile = packageB.value.find(
                                     (x) =>
                                         x.documentId === d.systemIdentifier &&
                                         x.typeCode == DigitalObjectType.DerivativeFile
                                 );
                                if (packageFile) {
                                    d.doc = packageFile;
                                    if (derivativeFile) d.derivative = derivativeFile;
                                }
                            });
                        });

                        importedStructure.value.sort((a, b) =>
                            a.number != undefined && b.number != undefined ? a.number?.localeCompare(b.number) : 0
                        );
                    }
                })
                .catch((err) => console.log(err));
        };

        const displayFile = (doc: IPackageBFile) => {
            const url = packagesService.getFileDownloadUrl(doc.id!, true);
            if (isImage(doc.name!)) {
                imageUrl.value = url;
                displayModal.value = true;
            } else if (isSound(doc.name!)) {
                audioVideoUrl.value = url;
                displayAudioVideoModal.value = true;
            } else if (isPdf(doc.name!)) {
                pdfUrl.value = '';
                packagesService.streamPackageDocumentFile(doc.id!)
                .then((response) => {
                    pdfUrl.value = URL.createObjectURL(response);
                });
                displayPdf.value = true;
            } else {
                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', doc.name!);
                document.body.appendChild(link);
                link.click();
            }
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

        const closeModal = () => {
            displayModal.value = false;
            imageUrl.value = '';
            audioVideoUrl.value = '';
            displayAudioVideoModal.value = false;
            pdfUrl.value = '';
            displayPdf.value = false;
        };

        onMounted( () => {
            loadPackagesData();
        });

        return {
            fileToImport,
            importedFile,
            pdfUrl,
            displayPdf,
            importedStructure,
            loading,
            imageUrl,
            displayModal,
            closeModal,
            loadPackagesData,
            displayFile,
            message,
            canSubmit,
            packageB,
            saving,
            store,
            displayAudioVideoModal,
            templates,
            audioVideoUrl,
            hasSignatureRequests,
            buildDownloadUrl,
            buildDownloadDerivativeUrl,
            displayDerivativeFile
        };
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
.td {
    margin-right: 10px;
}
.cursor-pointer:hover {
    cursor: pointer;
}
</style>
