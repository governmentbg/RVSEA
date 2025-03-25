<template>
    <div class="component">
    <v-menu
      transition="slide-y-transition"
    >
      <template v-slot:activator="{ props }">
        <v-btn color="white" icon v-bind="props" >
            <!-- <v-icon>mdi-download</v-icon> -->
            <i class="fas fa-download"></i>
            <v-tooltip activator="parent" location="bottom">
                {{ t('files.downloadFileUploaderApp') }}
            </v-tooltip>
        </v-btn>
        <!-- <button
            id="fileUploaderBtn"
            type="button"
            class="btn"
            aria-expanded="false"
            :title="t('files.downloadFileUploaderApp')"
            v-bind="props"
        >
            <i class="fas fa-download"></i>
        </button> -->
      </template>
      <v-list>
        <v-list-item :key="64" @click="downloadFileUploader(64)">
          <v-list-item-title>{{ t('files.version64') }}</v-list-item-title>
        </v-list-item>
        <v-list-item :key="32" @click="downloadFileUploader(32)">
          <v-list-item-title>{{ t('files.version32') }}</v-list-item-title>
        </v-list-item>
      </v-list>
    </v-menu>
  </div>
</template>

<script lang="ts">
import { defineComponent, inject, Ref } from 'vue';
import settingsService from '@/services/settings.service';
import { ResponseResult } from '@/models/responseResult';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { useI18n } from 'vue-i18n';
import { FileDownloadModel } from '@/models/file';
import { base64ToBlob } from '@/helpers/blob.helper';

export default defineComponent({
    name: 'FileUploader',
    setup() {
        const message = inject('notificationMessage') as Ref<IMessage>;
        const { t } = useI18n();

        const downloadFileUploader = async (version: number) => {
            await settingsService
                .downloadFileUploaderApp(version)
                .then((result) => {
                    const response = result;
                    download(response);
                })
                .catch((error: unknown) => {
                    const errorResult = error as ResponseResult;
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                        display: true,
                    });
                });
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
            downloadFileUploader,
        };
    },
});
</script>

<style lang="scss" scoped>
.component {
    position: relative;
}

// .btn {
//     color: white;
// }
</style>
