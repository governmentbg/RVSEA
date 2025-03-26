<template>
    <div>
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto mb-3">
            <v-card-title class="v-card-title-uppercase">{{ $t('packages.packageA') }}</v-card-title>
            <v-container>
                <div class="text-center" v-if="loading">
                    <v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
                </div>
                <v-row v-if="!loading">
                    <v-col cols="12" md="6" v-for="t in templates" :key="t.id">
                        <div :class="{ required: t.required }">{{ t.title }}</div>
                        <div class="my-2">{{ t.description }}</div>
                        <div v-if="!t.doc.id || t.doc._deleted">
                            <Upload @change="(f) => (t.doc.file = f)"></Upload>
                        </div>
                        <div v-else>
                            {{ t.doc.name }} ({{ parseFloat(t.doc.size / 1024).toFixed(2) }} KB)
                            <v-btn icon @click="displayFile(t.doc)" class="me-2" v-if="t.doc.id && !t.doc._deleted">
                                <v-icon>mdi-eye</v-icon>
                                <v-tooltip activator="parent" location="bottom">
                                    {{ $t('common.display') }}
                                </v-tooltip>
                            </v-btn>
                            <v-btn icon @click="removeItemFromPackageA(t)">
                                <v-icon>mdi-delete</v-icon>
                                <v-tooltip activator="parent" location="bottom">
                                    {{ $t('common.display') }}
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
        <v-card class="col-12 col-md-9 col-lg-9 mx-auto mb-3">
            <v-card-title class="v-card-title-uppercase">{{ $t('packages.packageB') }}</v-card-title>
            <v-container>
                <div v-if="packageB.length === 0" class="my-3">
                    <v-alert border="start" color="red-darken-4" prominent type="error" variant="outlined">
                        {{ $t('packages.noFilesMsg') }}
                    </v-alert>
                </div>
                <v-row v-for="(t, index) in packageBFilesToSHow" :key="t" class="mb-3">
                    <v-col cols="12" v-if="!t.parentId">
                        <div class="d-flex justify-content-between align-items-center border-bottom w-100">
                            <div class="fw-bold">{{ index + 1 }}</div>
                            <div class="w-100 ps-3" v-if="t.file">
                                {{ `${t.file.name} (${parseFloat(t.file.size / 1024).toFixed(2)} KB)` }}
                            </div>
                            <div class="w-100 ps-3" v-else>
                                {{ `${t.name} (${parseFloat(t.size / 1024).toFixed(2)} KB)` }}
                            </div>
                            <v-btn
                                v-if="t.id && !t.parentFileId && !haveDerivativeFile(t.id)"
                                icon
                                class="packageB-files-btn me-2"
                            >
                                <input
                                    type="file"
                                    @change="(e) => onPackageDerBFilesChange(e, t.id)"
                                    :title="$t('common.chooseFile')"
                                    accept="application/pdf, application/vnd.ms-excel"
                                />
                                <v-icon>mdi-folder</v-icon>
                                <v-tooltip activator="parent" location="bottom">
                                    {{ 'Производен файл' }}
                                </v-tooltip>
                            </v-btn>
                            <v-btn v-if="t.id" icon @click="displayFile(t)" class="me-2">
                                <v-icon>mdi-eye</v-icon>
                                <v-tooltip activator="parent" location="bottom">
                                    {{ $t('common.display') }}
                                </v-tooltip>
                            </v-btn>
                            <v-btn icon @click="removeItemFromPackageB(index)">
                                <v-icon>mdi-delete</v-icon>
                                <v-tooltip activator="parent" location="bottom">
                                    {{ $t('common.delete') }}
                                </v-tooltip>
                            </v-btn>
                        </div>
                    </v-col>
                    <v-col cols="12" v-if="t.parentId">
                        <div class="d-flex justify-content-between align-items-center border-bottom w-100">
                            <div class="w-100 ps-3" v-if="t.file">
                                {{ `${t.file.name} (${parseFloat(t.file.size / 1024).toFixed(2)} KB)` }}
                            </div>
                            <div class="w-100 ps-3" v-if="t.file">
                                {{ `Мастър файл : ${getMasterFileName(t.parentId)} ` }}
                            </div>

                            <div class="w-100 ps-3" v-else>
                                {{ `${t.name} (${parseFloat(t.size / 1024).toFixed(2)} KB)` }}
                            </div>
                            <div class="w-100 ps-3" v-if="!t.file">
                                {{ `Мастър файл : ${getMasterFileName(t.parentId)} ` }}
                            </div>

                            <v-btn v-if="t.id" icon @click="displayFile(t)" class="me-2">
                                <v-icon>mdi-eye</v-icon>
                                <v-tooltip activator="parent" location="bottom">
                                    {{ $t('common.display') }}
                                </v-tooltip>
                            </v-btn>
                            <v-btn icon @click="removeItemFromPackageB(index)">
                                <v-icon>mdi-delete</v-icon>
                                <v-tooltip activator="parent" location="bottom">
                                    {{ $t('common.delete') }}
                                </v-tooltip>
                            </v-btn>
                        </div>
                    </v-col>
                </v-row>
                <div>
                    <v-btn class="packageB-files-btn" variant="outlined" color="secondary">
                        <input multiple type="file" @change="onPackageBFilesChange" />
                        {{ $t('packages.addFile') }}
                    </v-btn>
                </div>
            </v-container>
        </v-card>

        <v-row class="mt-3 mb-3" v-if="!loading">
            <v-col class="d-flex gap-2 justify-content-center">
                <v-btn @click="sendPackages">{{ $t('common.save') }}</v-btn>
                <v-btn class="cancel" @click="onCancel">{{ $t('common.cancel') }}</v-btn>
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
    </div>
    <VideoPlayer v-model="displayAudioVideoModal" :src="audioVideoUrl" @close="closeModal" />
    <DisplayImageModal v-model="displayModal" :src="imageUrl" @close="closeModal" />
    <DisplayPdfModal v-model="displayPdf" :src="pdfUrl" @close="closeModal" />
    <v-overlay :model-value="saving" class="align-center justify-center">
        <v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
    </v-overlay>
</template>

<script lang="ts">
import { computed, defineComponent, ref, inject, Ref } from 'vue';
import { isImage, isPdf, isSound } from '@/helpers/file.helper';
import { IPackageATemplate } from '@/models/packageATemplates';
import http from '@/services/http.service';
import { IPackagesFormData, IPackageBFile, IPackageAFile } from '@/models/packages';
import packagesService from '@/services/packages.service';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import DisplayPdfModal from '@/components/digitalObjects/displayPdfModal.vue';
import Upload from '@/components/files/upload.vue';
import TextField from '@/components/field/text.field.vue';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import DisplayImageModal from '@/components/digitalObjects/displayImageModal.vue';
import VideoPlayer from '@/components/digitalObjects/displayAudioVideoPlayerModal.vue';
import { DigitalObjectType } from '@/enums/digitalObjects';

export default defineComponent({
    name: 'PackageACreate',
    components: {
        ConfirmDialog,
        TextField,
        Upload,
        DisplayImageModal,
        VideoPlayer,
        DisplayPdfModal,
    },
    props: {
        applicationId: {
            type: Number,
            required: true,
        },
    },
    setup(props) {
        const message = inject('notificationMessage') as Ref<IMessage>;
        const loading = ref(true);
        const saving = ref(false);
        const templates = ref([] as IPackageATemplate[]);
        const packageB = ref([] as Array<IPackageBFile>);
        const displayModal = ref<boolean>(false);
        const displayAudioVideoModal = ref<boolean>(false);
        const audioVideoUrl = ref<string>('');
        const imageUrl = ref<string>('');
        const pdfUrl = ref<string>('');
        const displayPdf = ref<boolean>(false);
        const packageBFilesToSHow = computed(() => {
            return packageB.value.filter((x) => !x._deleted);
        });

        //TODO Да се оправи типа резултата който се връща и пропартитата.
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const displayFile = (doc: any) => {
            const url = packagesService.getFileDownloadUrl(doc.id!, true)
            if (isImage(doc.name!)) {
                imageUrl.value = url;
                displayModal.value = true;
            } else if (isSound(doc.name!)) {
                audioVideoUrl.value = url;
                displayAudioVideoModal.value = true;
            } else if (isPdf(doc.name!)) {
                pdfUrl.value = '';
                packagesService.streamPackageDocumentFile(doc.id)
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

        const closeModal = () => {
            displayModal.value = false;
            imageUrl.value = '';
            audioVideoUrl.value = '';
            displayAudioVideoModal.value = false;
            pdfUrl.value = '';
            displayPdf.value = false;
        };

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

        const loadPackagesData = () => {
            packagesService.getByApplication(props.applicationId).then((response) => {
                console.log(response);

                if (response) {
                    if (response.packageB) {
                        packageB.value = [];
                        // eslint-disable-next-line
                        response.packageB.forEach((f: any) => {
                            packageB.value.push({
                                _deleted: false,
                                documentId: f.documentId,
                                fileId: f.fileId,
                                id: f.id,
                                name: f.fileName,
                                size: f.fileSize,
                                parentId: f.parentId,
                            });
                        });
                    }
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
                }
            });
        };

        const packageAInvalid = computed(() => {
            const aInvalid = templates.value.some((x) => x.required === true && !x.doc.file && x.doc._deleted);
            const bInvalid = packageBFilesToSHow.value.length == 0; // TODO && packageB.value.
            return aInvalid || bInvalid;
        });

        return {
            loading,
            pdfUrl,
            displayPdf,
            packageAInvalid,
            packageB,
            packageBFilesToSHow,
            saving,
            templates,
            message,
            displayModal,
            displayAudioVideoModal,
            audioVideoUrl,
            imageUrl,
            loadPackagesData,
            displayFile,
            closeModal,
        };
    },
    methods: {
        onCancel() {
            this.$router.back();
        },

        onPackageBFilesChange(e: Event) {
            const files = (e.target as HTMLInputElement).files;
            if (files && files.length) {
                for (let i = 0; i < files.length; i++) {
                    const file = files[i];
                    this.packageB.push({
                        id: 0,
                        file,
                        _deleted: false,
                    });
                }

                (e.target! as HTMLInputElement).value = '';
            }
        },

        onPackageDerBFilesChange(e: Event, parentId: number) {
            const files = (e.target as HTMLInputElement).files;
            if (files && files.length) {
                for (let i = 0; i < files.length; i++) {
                    const file = files[i];
                    this.packageB.push({
                        id: 0,
                        file,
                        _deleted: false,
                        parentId: parentId,
                        typeCode: DigitalObjectType.DerivativeFile,
                    });
                }

                (e.target! as HTMLInputElement).value = '';
            }
        },

        removeItemFromPackageA(t: IPackageATemplate) {
            t.doc!.name = '';
            t.doc!.size = 0;
            t.doc!.description = '';
            t.doc._deleted = true;
        },

        removeItemFromPackageB(index: number) {
            const item = this.packageBFilesToSHow[index];
            if (item.id) {
                this.packageBFilesToSHow[index]._deleted = true;
            } else {
                this.packageB = this.packageB.filter(
                    (x) => !x.file || (x.file.name !== item.file!.name && x.file.size !== item.file!.size)
                );
            }
        },

        getDataForSaving() {
            const data: IPackagesFormData = {
                applicationId: this.applicationId,
                packageA: this.templates.map((x) => x.doc),
                packageB: this.packageB,
            };

            return data;
        },

        sendPackages() {
            this.saving = true;
            const data = this.getDataForSaving();

            packagesService
                .create(data)
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
                    console.log(err);
                    const errorResult = err as ResponseResult;
                    this.message = new Message({
                        text: errorResult.showMessage ? errorResult.message : this.$t('error.basic'),
                        display: true,
                    });
                })
                .then(() => (this.saving = false));
        },

        onSendToArchive() {
            this.saving = true;
            const data = this.getDataForSaving();

            packagesService
                .create(data)
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

        getMasterFileName(val: number) {
            const { name } = this.packageB.filter((x) => x.id == val)[0]
                ? this.packageB.filter((x) => x.id == val)[0]
                : { name: '' };
            return name;
        },

        haveDerivativeFile(val: number) {
            const demo = this.packageB.filter((x) => x.parentId == val)[0];
            return demo != null ? true : false;
        },
    },
});
</script>

<style lang="scss" scoped>
.packageB-files-btn {
    .v-btn__content {
        position: relative;
        input {
            position: absolute;
            left: 0;
            opacity: 0;
            cursor: pointer !important;
        }
    }
}
</style>
