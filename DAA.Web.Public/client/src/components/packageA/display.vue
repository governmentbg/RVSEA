<template>
    <div>
        <v-card class="mb-3">
            <v-card-title class="v-card-title-uppercase">{{ $t('packages.packageA') }}</v-card-title>
            <v-container>
                <div class="text-center" v-if="loading">
                    <v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
                </div>
                <div v-if="!loading" class="px-3">
                    <v-row v-for="t in packageA" :key="t.id" class="mb-3 border-bottom">
                        <v-col cols="12" md="6">
                            <div>{{ t.documentType }}</div>
                            <div class="d-flex w-100">
                                {{ `${t.fileName} (${t.formattedSize})` }}
                                <a @click="displayFile(t)" class="text-decoration-none cursor-pointer ms-1">
                                    <v-tooltip>
                                        <template v-slot:activator="{ props }">
                                            <v-icon color="var(--ISDA-main-color4)" v-bind="props"> mdi-eye </v-icon>
                                        </template>
                                        <span>{{ $t('common.display') }}</span>
                                    </v-tooltip>
                                </a>
                                <a :href="buildUrl(t.id)" class="text-decoration-none">
                                    <v-tooltip>
                                        <template v-slot:activator="{ props }">
                                            <v-icon color="var(--ISDA-main-color4)" v-bind="props">mdi-download</v-icon>
                                        </template>
                                        <span>{{ $t('common.download') }}</span>
                                    </v-tooltip>
                                </a>
                            </div>
                        </v-col>
                        <v-col cols="12" md="6" v-if="t.description">
                            <div>{{ $t('applicationPackages.description') }}</div>
                            <div>
                                {{ t.description }}
                            </div>
                        </v-col>
                    </v-row>
                </div>
            </v-container>
            <v-card-title v-if="hasSignatureRequests" class="v-card-title-uppercase">{{
                $t('packages.signatureRequest')
            }}</v-card-title>
            <v-container>
                <SignatureRequests v-if="hasSignatureRequests" :applicationId="applicationId" />
            </v-container>
        </v-card>
        <v-card>
            <v-card-title class="v-card-title-uppercase">{{ $t('packages.packageB') }}</v-card-title>
            <v-container>
                <div class="text-center">
                    <v-progress-circular indeterminate size="64" color="primary" v-if="loading"></v-progress-circular>
                </div>
                <div v-if="!loading" class="px-3">
                    <v-row v-for="t in packageB" :key="t.id" class="mb-3 border-bottom">
                        <v-col cols="12" md="6">
                            <div>
                                {{ t.parentId ? `Производен файл ` : $t('applicationPackages.file') }}
                            </div>
                            <div v-if="t.fileSize">
                                {{ `${t.fileName} (${t.formattedSize})` }}
                                <a @click="displayFile(t)" class="text-decoration-none cursor-pointer">
                                    <v-tooltip>
                                        <template v-slot:activator="{ props }">
                                            <v-icon color="var(--ISDA-main-color4)" v-bind="props"> mdi-eye </v-icon>
                                        </template>
                                        <span>{{ $t('common.display') }}</span>
                                    </v-tooltip>
                                </a>
                                <a :href="buildUrl(t.id)" class="text-decoration-none">
                                    <v-tooltip>
                                        <template v-slot:activator="{ props }">
                                            <v-icon color="var(--ISDA-main-color4)" v-bind="props">mdi-download</v-icon>
                                        </template>
                                        <span>{{ $t('common.download') }}</span>
                                    </v-tooltip>
                                </a>
                            </div>
                        </v-col>
                        <v-col cols="12" md="6" v-if="t.description">
                            <div>{{ $t('applicationPackages.description') }}</div>
                            <div>
                                {{ t.description }}
                            </div>
                        </v-col>
                    </v-row>
                </div>
            </v-container>
        </v-card>
    </div>
    <DisplayImageModal v-model="displayModal" :src="imageUrl" @close="closeModal" />
    <VideoPlayer v-model="displayAudioVideoModal" :src="audioVideoUrl" @close="closeModal" />
    <DisplayPdfModal v-model="displayPdf" :src="pdfUrl" @close="closeModal" />
</template>

<script lang="ts">
import { defineComponent, ref } from 'vue';
import { IPackageAFile, IPackageBFile } from '@/models/packages';
import packagesService from '@/services/packages.service';
import { useStore } from '@/store/app';
import { isImage, isSound, isPdf } from '@/helpers/file.helper';
import SignatureRequests from '@/components/packageA/signatureRequests.vue';
import DisplayImageModal from '@/components/digitalObjects/displayImageModal.vue';
import VideoPlayer from '@/components/digitalObjects/displayAudioVideoPlayerModal.vue';
import DisplayPdfModal from '@/components/digitalObjects/displayPdfModal.vue';
//import http from '@/services/http.service';
import { formatBytes } from '@/helpers/format.helper';

export default defineComponent({
    name: 'PackagesDisplay',
    components: {
        SignatureRequests,
        VideoPlayer,
        DisplayImageModal,
        DisplayPdfModal,
    },
    props: {
        applicationId: {
            type: Number,
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
        const store = useStore();
        const displayModal = ref<boolean>(false);
        const displayAudioVideoModal = ref<boolean>(false);
        const audioVideoUrl = ref<string>('');
        const imageUrl = ref<string>('');
        const hasSignatureRequests = ref<boolean>(false);
        const pdfUrl = ref<string>('');
        const displayPdf = ref<boolean>(false);

        //TODO Да се оправи типа резултата който се връща и пропартитата.
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const displayFile = (doc: any) => {
            const url = packagesService.getFileDownloadUrl(doc.id, true);
            if (isImage(doc.fileName)) {
                imageUrl.value = url;
                displayModal.value = true;
            } else if (isSound(doc.fileName as string)) {
                audioVideoUrl.value = url;
                displayAudioVideoModal.value = true;
            } else if (isPdf(doc.fileName as string)) {
                pdfUrl.value = '';
                packagesService.streamPackageDocumentFile(doc.id)
                .then((response) => {
                    pdfUrl.value = URL.createObjectURL(response);
                });
                displayPdf.value = true;
            } else {
                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', doc.fileName!);
                document.body.appendChild(link);
                link.click();
            }
        };
        packagesService
            .getByApplication(props.applicationId)
            .then((data) => {
                loading.value = false;
                packageA.value = data.packageA;
                packageB.value = data.packageB;

                if (packageA.value && packageA.value.length > 0) {
                    packageA.value.forEach((x) => (x.formattedSize = formatBytes(x.fileSize ?? 0)));
                }

                if (packageB.value && packageB.value.length > 0) {
                    packageB.value.forEach((x) => (x.formattedSize = formatBytes(x.fileSize ?? 0)));
                }
            })
            .catch((err) => console.log(err));

        packagesService
            .hasPackageDocumentsBySignatureRequest(props.applicationId)
            .then((data) => {
                hasSignatureRequests.value = data;
            })
            .catch((error) => {
                console.log(error);
            });

        const closeModal = () => {
            displayModal.value = false;
            imageUrl.value = '';
            audioVideoUrl.value = '';
            displayAudioVideoModal.value = false;
            pdfUrl.value = '';
            displayPdf.value = false;
        };

        return {
            loading,
            audioVideoUrl,
            imageUrl,
            displayAudioVideoModal,
            displayModal,
            closeModal,
            packageB,
            packageA,
            displayFile,
            store,
            hasSignatureRequests,
            pdfUrl,
            displayPdf,
        };
    },
    methods: {
        buildUrl(id: number) {
            return packagesService.getFileDownloadUrl(id);
        },
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/dialog.scss';
.cursor-pointer:hover {
    cursor: pointer;
}
</style>
