<template>
    <div>
        <v-card class="mb-3">
            <v-card-title class="v-card-title-uppercase">{{ $t('packages.packageA') }}</v-card-title>
            <v-container>
                <!-- <div class="text-center" v-if="loading">
					<v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
				</div> -->
                <div v-if="!loading" class="px-3">
                    <v-row v-for="t in packageA" :key="t.id" class="mb-3 border-bottom">
                        <v-col cols="12" md="6">
                            <div>{{ t.documentType }}</div>
                            <div class="d-flex w-100">
                                <!-- {{ `${t.fileName} (${t.fileSize} KB)` }} -->
                                {{ `${t.fileName} (${t.formattedSize})` }}
                                <a @click="displayFile(t)" role="button" class="text-decoration-none">
                                    <v-tooltip>
                                        <template v-slot:activator="{ props }">
                                            <v-icon color="primary" dark v-bind="props"> mdi-eye </v-icon>
                                        </template>
                                        <span>{{ $t('common.display') }}</span>
                                    </v-tooltip>
                                </a>
                                <a :href="buildUrl(t.id)" role="button" class="text-decoration-none">
                                    <v-tooltip>
                                        <template v-slot:activator="{ props }">
                                            <v-icon color="primary" dark v-bind="props"> mdi-download </v-icon>
                                        </template>
                                        <span>{{ $t('common.download') }}</span>
                                    </v-tooltip>
                                </a>
                            </div>
                        </v-col>
                        <v-col cols="12" md="6" v-if="t.description">
                            <div>Описание</div>
                            <div>
                                {{ t.description }}
                            </div>
                        </v-col>
                    </v-row>
                </div>
            </v-container>
        </v-card>
        <v-card>
            <v-card-title class="v-card-title-uppercase">{{ $t('packages.packageB') }}</v-card-title>
            <v-container>
                <!-- <div class="text-center">
					<v-progress-circular indeterminate size="64" color="primary" v-if="loading"></v-progress-circular>
				</div> -->
                <div v-if="!loading" class="px-3">
                    <div v-if="applicationTypeId !== 'assembled'">
                        <v-row v-for="t in packageB" :key="t.id" class="mb-3 border-bottom">
                            <v-col cols="12" md="6">
                                <div>
                                    {{
                                        t.parentId
                                            ? `${$t('digitalObjects.derivativesFile')}`
                                            : `${$t('digitalObjects.masterFile')}`
                                    }}
                                </div>
                                <div>
                                    <!-- {{ `${t.fileName} (${t.fileSize} KB)` }} -->
                                    {{ `${t.fileName} (${t.formattedSize})` }}
                                    <a @click="displayFile(t)" role="button" class="text-decoration-none">
                                        <v-tooltip>
                                            <template v-slot:activator="{ props }">
                                                <v-icon color="primary" dark v-bind="props"> mdi-eye </v-icon>
                                            </template>
                                            <span>{{ $t('common.display') }}</span>
                                        </v-tooltip>
                                    </a>
                                    <a :href="buildUrl(t.id)" role="button" class="text-decoration-none">
                                        <v-tooltip>
                                            <template v-slot:activator="{ props }">
                                                <v-icon color="primary" dark v-bind="props"> mdi-download </v-icon>
                                            </template>
                                            <span>{{ $t('common.download') }}</span>
                                        </v-tooltip>
                                    </a>
                                </div>
                            </v-col>
                            <v-col cols="12" md="6" v-if="t.description">
                                <div>Описание</div>
                                <div>
                                    {{ t.description }}
                                </div>
                            </v-col>
                        </v-row>
                    </div>

                    <div v-if="applicationTypeId === 'assembled' && importedStructure">
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
                                    <td class="text-center" style="vertical-align: middle">
                                        {{ structure.number }}
                                    </td>
                                    <td class="text-start" style="vertical-align: middle">
                                        <div style="width: 10vw !important">
                                            {{ structure.title }}
                                        </div>
                                    </td>
                                    <td>
                                        <tr
                                            v-for="doc in structure.documents"
                                            :key="doc.systemIdentifier"
                                            class="border-bottom d-flex justify-content-stretch align-items-center w-100 py-2"
                                        >
                                            <td style="float: left">
                                                <div style="flex-basis: 30%; width: 10vw !important">
                                                    {{ doc.title }}
                                                </div>
                                            </td>
                                            <td style="margin-left: 100px; width: 100%">
                                                <tr
                                                    class="border-bottom d-flex justify-content-between align-items-center w-100 py-2 td"
                                                >
                                                    <div style="flex-grow: 1">
                                                        <span v-if="doc.doc.fileName">{{ doc.doc.fileName }}</span>
                                                        <span v-if="doc.doc.fileSize">
                                                            ({{ formatBytes(doc.doc.fileSize) }})
                                                        </span>
                                                    </div>
                                                    <div>
                                                        <div
                                                            v-if="doc.doc.file || (doc.doc.id && !doc.doc._deleted)"
                                                            style="width: 50px"
                                                        >
                                                            <v-icon class="text-success me-2" v-if="doc.doc.file"
                                                                >mdi-check-bold</v-icon
                                                            >
                                                            <a
                                                                role="button"
                                                                @click="displayFile(doc.doc)"
                                                                class="text-decoration-none"
                                                            >
                                                                <v-tooltip>
                                                                    <template v-slot:activator="{ props }">
                                                                        <v-icon color="primary" dark v-bind="props">
                                                                            mdi-eye
                                                                        </v-icon>
                                                                    </template>
                                                                    <span>{{ $t('common.display') }}</span>
                                                                </v-tooltip>
                                                            </a>
                                                            <a
                                                                role="button"
                                                                :href="buildUrl(doc.doc.id)"
                                                                class="text-decoration-none"
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
                                                        </div>
                                                    </div>
                                                </tr>
                                                <tr
                                                    v-if="doc.derivative"
                                                    class="d-flex justify-content-between align-items-center w-100 py-2 td"
                                                >
                                                    <div style="flex-grow: 1">
                                                        <span v-if="doc.derivative.fileName">{{
                                                            doc.derivative.fileName
                                                        }}</span>
                                                        <span v-if="doc.derivative.fileSize">
                                                            ({{ formatBytes(doc.derivative.fileSize) }})
                                                        </span>
                                                    </div>
                                                    <div>
                                                        <div
                                                            v-if="
                                                                doc.derivative.file ||
                                                                (doc.derivative.fileId && !doc.derivative._deleted)
                                                            "
                                                            style="width: 50px"
                                                        >
                                                            <v-icon class="text-success me-2" v-if="doc.derivative.file"
                                                                >mdi-check-bold</v-icon
                                                            >
                                                            <a
                                                                role="button"
                                                                @click="displayDerivativeFile(doc.derivative)"
                                                                class="text-decoration-none"
                                                            >
                                                                <v-tooltip>
                                                                    <template v-slot:activator="{ props }">
                                                                        <v-icon color="primary" dark v-bind="props">
                                                                            mdi-eye
                                                                        </v-icon>
                                                                    </template>
                                                                    <span>{{ $t('common.display') }}</span>
                                                                </v-tooltip>
                                                            </a>
                                                            <a
                                                                role="button"
                                                                :href="buildDownloadDerivativeUrl(doc.derivative.fileId)"
                                                                class="text-decoration-none"
                                                                v-if="doc.derivative.fileId && !doc.derivative._deleted"
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
                </div>
            </v-container>
        </v-card>
        <v-row class="mt-3" v-if="!loading && !readonly">
            <v-col class="d-flex gap-2 justify-content-center">
                <v-btn @click="showApprove = true">{{ $t('common.approve') }}</v-btn>
                <v-btn @click="showReject = true">{{ $t('common.changesRequired') }}</v-btn>
                <v-btn @click="showCancel = true">{{ $t('common.cancel') }}</v-btn>
            </v-col>
        </v-row>
    </div>

    <v-dialog v-model="showApprove" persistent>
        <v-card>
            <v-card-title class="text-h5">
                {{ $t('applications.approvement') }}
            </v-card-title>
            <v-card-text>
                {{ $t('applications.packagesApproveMessage') }}
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <dialog-btn @click="approve">
                    {{ $t('common.save') }}
                    <v-tooltip activator="parent" location="bottom">
                        {{ t('common.saveTooltip') }}
                    </v-tooltip>
                </dialog-btn>
                <cancel-btn @click="showApprove = false">
                    {{ $t('common.cancel') }}
                </cancel-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>

    <v-dialog v-model="showReject" persistent>
        <v-card style="min-width: 500px">
            <v-card-title class="text-h5">
                {{ $t('applications.changesRequired') }}
            </v-card-title>
            <v-card-text>
                <div>
                    {{ $t('applications.reason') }}
                </div>
                <div>
                    <TextAreaField v-model="rejectReason"></TextAreaField>
                </div>
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <dialog-btn :disabled="!rejectReason" @click="reject">
                    {{ $t('common.changesRequired') }}
                </dialog-btn>
                <cancel-btn @click="hideReject">
                    {{ $t('common.cancel') }}
                </cancel-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
    <v-dialog v-model="showCancel" persistent>
        <v-card style="min-width: 500px">
            <v-card-title class="text-h5">
                {{ $t('applications.rejectRequired') }}
            </v-card-title>
            <v-card-text>
                <div>
                    {{ $t('applications.reason') }}
                </div>
                <div>
                    <TextAreaField v-model="rejectReason"></TextAreaField>
                </div>
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <dialog-btn :disabled="!rejectReason" @click="cancel">
                    {{ $t('applications.rejectRequired') }}
                </dialog-btn>
                <cancel-btn @click="hideCancel">
                    {{ $t('common.cancel') }}
                </cancel-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
    <DisplayImageModal v-model="displayModal" :src="imageUrl" @close="closeModal" />
    <DisplayPlayerModal v-model="displayAudioVideoModal" :src="audioVideoUrl" @close="closeModal" />
    <DisplayPdfModal :digitalObjectType="digObjTypeCode" v-model="displayPdf" :src="pdfUrl" :disableScroll="false" @close="closeModal" />
    <v-overlay :model-value="saving" class="align-center justify-center">
        <v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
    </v-overlay>
</template>

<script lang="ts">
import { defineComponent, ref, inject, Ref } from 'vue';
import { IPackageAFile, IPackageBFile } from '@/models/packages';
import { ImportedStructure, ImportedDocument } from '@/interfaces/application';
import applicationService from '@/services/applications.service';
import { useStore } from '@/store/app';
import { useI18n } from 'vue-i18n';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { formatBytes } from '@/helpers/format.helper';
import http from '@/services/http.service';
import TextAreaField from '@/components/field/textarea.field.vue';
import { isImage, isPdf, isSound } from '@/helpers/file.helper';
import DisplayImageModal from '@/components/digitalObject/displayImageModal.vue';
import DisplayPlayerModal from '@/components/digitalObject/displayPlayerModal.vue';
import DisplayPdfModal from '@/components/digitalObject/displayPdfModal.vue';
import { DigitalObjectType } from '@/enums/digitalObject';
import digitalObjectService from '@/services/digitalObject.service';

export default defineComponent({
    name: 'PackageAApproval',
    components: {
        //TextField,
        TextAreaField,
        DisplayPlayerModal,
        DisplayImageModal,
        DisplayPdfModal,
    },
    props: {
        applicationId: {
            type: Number,
            required: true,
        },
        applicationTypeId: {
            type: String,
            required: true,
        },
        readonly: {
            type: Boolean,
            default: false,
        },
    },
    setup(props) {
        const packageA = ref([] as Array<IPackageAFile>);
        const packageB = ref([] as Array<IPackageBFile>);
        const loading = ref(true);
        const rejectReason = ref('');
        const saving = ref(false);
        const showApprove = ref(false);
        const showReject = ref(false);
        const showCancel = ref<boolean>(false);
        const store = useStore();
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const importedStructure = ref<ImportedStructure[]>();
        const displayModal = ref<boolean>(false);
        const displayAudioVideoModal = ref<boolean>(false);
        const imageUrl = ref<string>('');
        const audioVideoUrl = ref<string>('');
        const pdfUrl = ref<string>('');
        const displayPdf = ref(false);
        const digObjTypeCode = ref<number>();

        applicationService
            .getPackages(props.applicationId)
            .then((data) => {
                loading.value = false;
                packageA.value = data.packageA;
                packageB.value = data.packageB;

                if (packageA.value && packageA.value.length > 0) {
                    packageA.value.forEach((x) => (x.formattedSize = formatBytes(x.fileSize)));
                }

                if (packageB.value && packageB.value.length > 0) {
                    packageB.value.forEach((x) => (x.formattedSize = formatBytes(x.fileSize)));
                }

                if (props.applicationTypeId === 'assembled') {
                    loadImportedStructure();
                }
            })
            .catch((err) => console.log(err));

        const loadImportedStructure = () => {
            http.get('/api/Packages/structure/' + props.applicationId)
                .then((response) => {
                    importedStructure.value = (response.data.data as ImportedStructure[]).map((x) => {
                        const item = { ...x };
                        item.documents.forEach(
                            (d) => (d.doc = { documentSystemIdentifier: d.systemIdentifier } as IPackageBFile)
                        );

                        return item;
                    });

                    if (importedStructure.value) {
                        importedStructure.value.forEach((a: ImportedStructure) => {
                            a.documents.forEach((d: ImportedDocument) => {
                                const packageFile = packageB.value.find(
                                    // eslint-disable-next-line
                                    (x: any) =>
                                        x.documentSystemIdentifier === d.systemIdentifier &&
                                        x.typeCode == DigitalObjectType.MasterFile
                                );
                                const derivative = packageB.value.find(
                                    // eslint-disable-next-line
                                    (x: any) =>
                                        x.documentSystemIdentifier === d.systemIdentifier &&
                                        x.typeCode == DigitalObjectType.DerivativeFile
                                );
                                if (packageFile) {
                                    d.doc = packageFile;
                                    if (derivative) d.derivative = derivative;
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

        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const displayFile = (doc: any) => {
            const url = applicationService.packageDocumentStreamUrl(doc.id);
            if (isImage(doc.fileName)) {
                // imageUrl.value =
                //     store.getters.baseUrl + '/api/EDocsCollectingApplications/downloadOrDisplayPackageFile/' + doc.id;
                imageUrl.value = url;
                displayModal.value = true;
            } else if (isSound(doc.fileName)) {
                // audioVideoUrl.value =
                //     store.getters.baseUrl + '/api/EDocsCollectingApplications/downloadOrDisplayPackageFile/' + doc.id;
                audioVideoUrl.value = url;
                displayAudioVideoModal.value = true;
            } else if (isPdf(doc.fileName)) {
                digObjTypeCode.value = doc?.typeCode ?? 2; // това е кода e за производен
                pdfUrl.value = '';
                // http.get(`/api/EDocsCollectingApplications/downloadOrDisplayPackageFile/${doc.id}`).then((response) => {
                //     pdfUrl.value = b64toBlob(response.data.message);
                // });
                applicationService.streamPackageDocumentFile(doc.id)
                            .then((response) => {
                                pdfUrl.value = URL.createObjectURL(response);
                            });
                displayPdf.value = true;
            } else {
                // const url = store.getters.baseUrl + '/api/EDocsCollectingApplications/onlyDownloadPackageFile/' + doc.id;
                // const link = document.createElement('a');
                // link.href = url;
                // link.setAttribute('download', doc.fileName!);
                // document.body.appendChild(link);
                // link.click();
                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', doc.fileName);
                document.body.appendChild(link);
                link.click();
            }
        };

        const displayDerivativeFile = (derivative: IPackageBFile) => {
            const url = digitalObjectService.streamDigitalObjectDraftUrl(derivative.fileId!)
            if (isImage(derivative.fileName!)) {
                //imageUrl.value = store.getters.baseUrl + '/api/digitalobjects/downloadDarivative/' + derivative.fileId;
                imageUrl.value = url;
                displayModal.value = true;
            } else if (isSound(derivative.fileName!)) {
                //audioVideoUrl.value = store.getters.baseUrl + '/api/digitalobjects/downloadDarivative/' + derivative.fileId;
                audioVideoUrl.value = url;
                displayAudioVideoModal.value = true;
            } else if (isPdf(derivative.fileName!)) {
                pdfUrl.value = '';
                // http.get(`/api/digitalobjects/downloadDarivative/${derivative.fileId}`).then((response) => {
                //     pdfUrl.value = b64toBlob(response.data.message);
                // });
                digitalObjectService.streamDigitalObjectFile(derivative.fileId!)
                .then((response) => {
                    pdfUrl.value = URL.createObjectURL(response);
                });
                displayPdf.value = true;
            } else {
                // const url = store.getters.baseUrl + '/api/digitalobjects/downloadDarivative/' + derivative.fileId;
                // const link = document.createElement('a');
                // link.href = url;
                // link.setAttribute('downloadDarivative', derivative.fileName!);
                // document.body.appendChild(link);
                // link.click();

                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', derivative.fileName!);
                document.body.appendChild(link);
                link.click();
            }
        }

        const closeModal = () => {
            displayModal.value = false;
            imageUrl.value = '';
            audioVideoUrl.value = '';
            displayAudioVideoModal.value = false;
            displayPdf.value = false;
            pdfUrl.value = '';
        };

        return {
            t,
            showCancel,
            formatBytes,
            importedStructure,
            loading,
            packageA,
            digObjTypeCode,
            packageB,
            displayFile,
            rejectReason,
            saving,
            showApprove,
            showReject,
            store,
            closeModal,
            message,
            imageUrl,
            audioVideoUrl,
            pdfUrl,
            displayModal,
            displayPdf,
            displayAudioVideoModal,
            displayDerivativeFile,
        };
    },

    methods: {
        approve() {
            this.saving = true;

            applicationService
                .approvePackages({ id: this.applicationId, userId: '' })
                .then(() => {
                    //TODO show message
                    this.showApprove = false;
                    this.$router.push('/edocscollection/applications');
                })
                .catch((err) => {
                    console.log(err);
                    this.showApprove = false;
                    const errorResult = err as ResponseResult;
                    this.message = new Message({
                        text: errorResult.showMessage ? errorResult.message : this.$t('error.basic'),
                        display: true,
                    });
                })
                .then(() => (this.saving = false));
        },
        buildUrl(id: number) {
            //return this.store.getters.baseUrl + '/api/EDocsCollectingApplications/onlyDownloadPackageFile/' + id;
           return applicationService.packageDocumentStreamUrl(id);
        },
        buildDownloadDerivativeUrl (sysId: string) {
            //return digitalObjectService.getDownloadDigitalDerivativeObjectUrl(sysId, true);
            return digitalObjectService.streamDigitalObjectDraftUrl(sysId);
        },
        hideReject() {
            this.showReject = false;
            this.rejectReason = '';
        },
        hideCancel() {
            this.showCancel = false;
            this.rejectReason = '';
        },
        cancel() {
            this.saving = true;

            applicationService
                .cancelPackages({ id: this.applicationId, reason: this.rejectReason })
                .then(() => {
                    this.$router.go(0);
                })
                .catch((err) => console.log(err))
                .then(() => (this.saving = false));
        },

        reject() {
            this.saving = true;

            applicationService
                .rejectPackages({ id: this.applicationId, reason: this.rejectReason })
                .then(() => {
                    //TODO show message
                    //this.$router.push('/edocscollection/applications');
                    this.$router.go(0);
                })
                .catch((err) => console.log(err))
                .then(() => (this.saving = false));
        },
    },
});
</script>

<style lang="scss" scoped>
.td {
    margin-right: 10px;
}
@import '@/assets/styles/dialog.scss';
</style>
