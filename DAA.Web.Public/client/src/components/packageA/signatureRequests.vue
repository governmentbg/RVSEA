<template>
    <v-container>
        <div class="text-center" v-if="loading">
            <v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
        </div>
        <v-row v-if="packageDocuments.length <= 0">
            <v-alert type="info" density="compact" variant="outlined">{{ t('packages.noSignatureRequests') }}</v-alert>
        </v-row>
        <v-row v-for="documentTemplate in packageDocumentTemplates" :key="documentTemplate">
            <div>{{ documentTemplate[0].documentType }}</div>
            <div class="d-flex w-100" v-for="document in documentTemplate" :key="document.id">
                {{ `${document.fileName} (${Math.round(document.fileSize / 1024, 2)}) KB` }}
                <a :href="downloadPackageDocument(document.id)" class="text-decoration-none">
                    <v-tooltip>
                        <template v-slot:activator="{ props }">
                            <v-icon color="var(--ISDA-main-color4)" v-bind="props"> mdi-download </v-icon>
                        </template>
                        <span>{{ t('common.download') }}</span>
                    </v-tooltip>
                </a>
            </div>
            <v-divider />
        </v-row>
    </v-container>
</template>
<script lang="ts">
import { computed, defineComponent, inject, onMounted, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';

import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { IPackageDocument } from '@/models/applications';
import packagesService from '@/services/packages.service';
import { groupBy } from '@/helpers/format.helper';

export default defineComponent({
    name: 'SignatureRequests',
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

        const packageDocumentTemplates = computed(() => groupBy(packageDocuments.value, 'documentTypeId'));

        const packageDocuments = ref<IPackageDocument[]>([]);
        const getPackageDocumentsForSigning = async () => {
            try {
                packageDocuments.value = await packagesService.getPackageDocumentsBySignatureRequest(
                    props.applicationId
                );
                loading.value = false;
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            } finally {
                console.log(packageDocumentTemplates.value);
            }
        };

        const downloadPackageDocument = (id: number) => {
            const fileUrl = packagesService.getFileDownloadUrl(id);
            return fileUrl;
        };

        onMounted(async () => {
            await getPackageDocumentsForSigning();
        });

        return {
            t,
            loading,
            packageDocuments,
            packageDocumentTemplates,
            downloadPackageDocument,
        };
    },
});
</script>
