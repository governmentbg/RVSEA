<template>
    <v-card class="col-md-9 col-lg-9 ma-auto mb-3">
        <v-card-title class="v-card-title-uppercase">{{ t('packages.signedDocuments') }}</v-card-title>
        <v-container>
            <div class="text-center" v-if="loading">
                <v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
            </div>
            <v-row v-if="!loading">
                <v-col cols="12" md="6" v-for="template in templates" :key="template.id">
                    <div class="required">{{ template.documentType }}</div>
                    <div>
                        <Upload 
                            :packageType="'A'"
                            :required="true"
                            :multipleFiles="false"
                            @change="(f) => (template.content = f)" 
                        ></Upload>
                    </div>
                </v-col>
            </v-row>
            <v-row class="mt-3" v-if="!loading">
                <v-col class="d-grid gap-2 d-md-flex justify-content-center">
                    <ConfirmDialog
                        width="50vw"
                        :activatorButtonText="t('packages.sendSignedDocuments')"
                        :confirmationText="t('packages.sendSignedDocumentsConfirmation')"
                        :confirmButtonText="t('common.send')"
                        :cancelButtonText="t('common.cancel')"
                        @confirm="submitSignedDocuments"
                    ></ConfirmDialog>
                    <v-btn class="cancel me-3" @click="goBack">{{ t('common.cancel') }}</v-btn>
                </v-col>
            </v-row>
        </v-container>
    </v-card>
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRedirect } from '@/helpers/router.helper';
import { useRouter } from 'vue-router';
import { useStore } from '@/store/app';

import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';

import { IPackageAFile } from '@/models/packages';
import packagesService from '@/services/packages.service';

import Upload from '@/components/files/upload.vue';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import { IPackageDocument } from '@/models/applications';
import { formatBytesToMB } from '@/helpers/format.helper';
import { getTotalUploadPackageADocFileSize } from '@/helpers/file.helper';

export default defineComponent({
    name: 'SignedPackageDocuments',
    components: {
        Upload,
        ConfirmDialog,
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
        const store = useStore();
        const loading = ref(true);

        const templates = ref<IPackageDocument[]>([]);

        const loadSignatureRequestTemplates = async () => {
            try {
                const signatureRequestTemplates = await packagesService.getPackageDocumentsBySignatureRequest(
                    props.applicationId
                );
                if (signatureRequestTemplates) {
                    templates.value = signatureRequestTemplates.map((tpl) => ({
                        ...tpl,
                        doc: { documentTypeId: tpl.id },
                    })) as IPackageDocument[];
                }

                loading.value = false;
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const submitSignedDocuments = async () => {
            try {
                loading.value = true;

                const totalFileSize = getTotalUploadPackageADocFileSize(templates.value);
                const totalInMB = formatBytesToMB(totalFileSize);

                if (totalInMB >= store.getters.maxPackageBFileSizeInMB) {
                    message.value = new Message({
                        text: t('error.fileSizeOverLimit', {
                            fileSize: totalInMB,
                            limit: store.getters.maxPackageBFileSizeInMB,
                        }),
                        display: true,
                    });
                    loading.value = false;
                    return;
                }

                const signedDocuments = templates.value.map((tpl) => ({
                    documentTypeId: tpl.documentTypeId,
                    name: tpl?.fileName,
                    size: tpl?.fileSizeInBytes,
                    file: tpl?.content,
                    id: tpl.id,
                })) as IPackageAFile[];
                await packagesService.sendSignedPackageDocuments(props.applicationId, signedDocuments);

                useRedirect(router, 'Applications');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            } finally {
                loading.value = false;
            }
        };

        const router = useRouter();
        const goBack = () => {
            useRedirect(router, 'Applications');
        };

        onMounted(async () => {
            await loadSignatureRequestTemplates();
        });

        return {
            t,
            goBack,
            loading,
            templates,
            submitSignedDocuments,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
</style>
