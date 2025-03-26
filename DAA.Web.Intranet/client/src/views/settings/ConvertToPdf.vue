<template>
    <div>
        <label>Конвертиране към pdf</label>
        <v-row>
            <v-col cols="12">
                <UploadFile
                    class="mt-2"
                    ref="fileUploader"
                    :multipleFiles="false"
                    packageType="B"
                    @change="fileChanged"
                />
            </v-col>
        </v-row>

        <v-row class="mb-3">
            <v-col class="d-inline-flex gap-2 justify-content-start">
                <submit-btn v-if="canSaveChanges" @click="convertToPdf"
                    >{{ t('common.save') }}
                    <v-tooltip activator="parent" location="bottom">
                        {{ t('common.saveTooltip') }}
                    </v-tooltip>
                </submit-btn>
            </v-col>
        </v-row>
    </div>

    <Loader :isLoading="isLoading" />
</template>

<script lang="ts">
import { defineComponent, ref, computed, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';

import settingsService from '@/services/settings.service';

import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { FileDownloadModel } from '@/models/file';

import { base64ToBlob } from '@/helpers/blob.helper';

import UploadFile from '@/components/files/uploadFile.vue';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'ConvertToPdf',
    components: {
        UploadFile,
        Loader,
    },
    setup() {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const isLoading = ref(false);
        const uploadedFile = ref(new File([], ''));
        const canSaveChanges = computed(() => uploadedFile.value.size > 0);

        const fileChanged = (model: File[]) => {
            uploadedFile.value = model && model.length > 0 ? model[0] : new File([], '');
        };

        const convertToPdf = async () => {
            try {
                isLoading.value = true;
                const response = await settingsService.convertToPdf(uploadedFile.value);
                download(response);
                isLoading.value = false;
            } catch (error: unknown) {
                isLoading.value = false;
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const download = (response: FileDownloadModel) => {
            const blob = base64ToBlob(response.data, response.mimetype);
            if (blob == null) {
                return;
            }

            const url = window.URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', response.filename);
            document.body.appendChild(link);
            link.click();
        };

        return {
            t,
            isLoading,
            fileChanged,
            convertToPdf,
            canSaveChanges,
        };
    },
});
</script>
