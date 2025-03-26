<template>
    <v-dialog
        v-model="showDialog"
        persistent
    >
        <template v-slot:activator="{ props }">
            <v-btn v-bind="props" >{{ t('processes.buttons.sendForFundHolderSignatureStep') }}</v-btn>
        </template>
        <v-card>
            <v-card-title class="text-h5 text-center">
                {{ t('processes.buttons.sendForFundHolderSignatureStep') }}
            </v-card-title>
            <div class="d-flex justify-content-center" v-if="loading">
                <v-progress-circular :size="50" :width="5" color="primary" indeterminate></v-progress-circular>
            </div>
            <v-card-text>
                <v-list density="compact">
                    <v-list-item
                        density="compact"
                        v-for="item in packageDocuments"
                        :key="item"
                    >
                        <template #prepend>
                            <v-checkbox
                                v-model="selectedItems"
                                :value="item.id"
                                hide-details="auto"
                            />
                        </template>
                        <v-list-item-title>{{ item.fileName }}</v-list-item-title>
                        <v-list-item-subtitle>{{ item.documentType }}</v-list-item-subtitle>
                        <v-list-item-subtitle>{{ item.description }}</v-list-item-subtitle>
                        <template #append>
                                <v-btn
                                    class="floatingBtnIcon"
                                    icon
                                    @click="downloadFile(item.id, item.sourceName)"
                                >
                                    <v-icon>mdi-download</v-icon>
                                    <v-tooltip activator="parent" location="bottom">
                                        {{ t('common.downloadTooltip') }}
                                    </v-tooltip>
                                </v-btn>
                            </template>
                    </v-list-item>
                </v-list>
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <ConfirmDialog
                    :activatorButtonText="t('common.send')"
                    activatorButtonVariant="elevated"
                    :confirmButtonText="t('common.yes')"
                    :cancelButtonText="t('common.cancel')"
                    :confirmationText="t('processes.buttons.sendForFundHolderSignatureStepConfirmation')"
                    :disabled="selectedItems.length <= 0"
                    @confirm="confirmDialogBtnClickHandler(true)"
                    @cancel="confirmDialogBtnClickHandler(false)"
                ></ConfirmDialog>
                <cancel-btn                    
                    @click="dialogBtnClickHandler(false)"
                >
                    {{ t('common.cancel') }}
                </cancel-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>

    
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, Ref, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';

import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { IPackageAFile } from '@/models/packages';
import packagesService from '@/services/packages.service';
import eDocsCollectingService from '@/services/eDocsCollecting.service';

import ConfirmDialog from '@/components/confirm/confirmDialog.vue';

export default defineComponent({
    name: 'SignatureRequestDialog',
    components: {
        ConfirmDialog,
    },
    props: {
        processId: {
            type: Number,
            required: true,
        },
        packageId: {
            type: Number,
            required: true
        }
    },
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const loading = ref(true);

        const showDialog = ref<boolean>(false);
        const selectedItems = ref([]);

        const packageDocuments = ref<IPackageAFile[]>([]);

        const getPackageDocuments = async () => {
            try {
                packageDocuments.value = await packagesService.get(props.packageId, true);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
            finally {
                loading.value = false;
            }
        };

        const confirmDialogBtnClickHandler = async (confirmed: boolean) => {
            if (confirmed) {
                try {
                    await eDocsCollectingService.sendSignatureRequest(props.processId, props.packageId, selectedItems.value);
                    
                    context.emit('send');
                    showDialog.value = false;
                } catch (error: unknown) {
                    const errorResult = error as ResponseResult;
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                        display: true,
                    });
                }
            }
        }

        const downloadFile = (id: number, fileName: string) => {
            const url = packagesService.getPackageFileUrl(id, props.packageId);
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', fileName);
            document.body.appendChild(link);
            link.click();
        };
                
        const dialogBtnClickHandler = (confirmed: boolean) => {
            if (confirmed) {
                context.emit('send');
            } else {
                context.emit('cancel');
                selectedItems.value = [];
            }
            showDialog.value = false;
        }
        
        onMounted(async () => {
            await getPackageDocuments();
        });

        watch(
            () => showDialog.value, 
            async (value) => {
                console.log('wartcher', value);
                if(value) {
                  await getPackageDocuments()
                }
        });

        return {
            t,
            loading,
            showDialog,
            selectedItems,
            packageDocuments,
            dialogBtnClickHandler,
            confirmDialogBtnClickHandler,
            downloadFile,
        }
    },
})
</script>

<style lang="scss" scoped>
@import "@/assets/styles/dialog.scss";

:deep(.floatingBtnIcon) {
    background-color: transparent !important;
    color: var(--ISDA-main-color1) !important;
    box-shadow: none !important;
    margin: 15px 0px;
}
</style>