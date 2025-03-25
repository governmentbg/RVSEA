<template>
    <div v-if="loading" class="d-flex justify-content-center">
        <v-progress-circular :size="50" color="green-lighten-2" indeterminate></v-progress-circular>
    </div>

    <div v-if="!loading">
        <v-row align="center" v-if="!readOnly && showFileUpload">
            <v-col class="col-12 col-lg-10">
                <UploadFile :multipleFiles="true" @change="fileChanged" />
            </v-col>
            <v-col class="col-12 col-lg-2">
                <v-btn @click="uploadFiles">{{ t('common.upload') }}</v-btn>
            </v-col>
        </v-row>
        <v-list density="compact">
            <v-list-subheader v-if="showListHeader">{{ listHeader }}</v-list-subheader>
            <v-list-item
                density="compact"
                v-for="file in packageFileList"
                :key="file.id"
                :value="file.id"
                :title="file.fileName"
            >
                <template #append>
                    <v-btn 
                        class="floatingBtnIcon"
                        icon 
                        @click="downloadFile(file.id, file.fileName)" 
                    >
                        <v-icon>mdi-download</v-icon>
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('common.downloadTooltip') }}
                        </v-tooltip>
                    </v-btn>
                    <ConfirmDialog
                        v-if="!readOnly"
                        :confirmationText="
                            $t('packages.buttons.deleteConfirmation', { title: file.fileName })
                        "
                        :confirmButtonText="$t('common.yes')"
                        :cancelButtonText="$t('common.cancel')"
                        activatorButtonIcon="mdi-delete-outline"
                        activatorButtonCssClass="floatingBtnIcon"
                        @confirm="deleteFile(file.id)"
                    />
                </template>
            </v-list-item>
        </v-list>
    </div>
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, PropType, Ref, ref } from 'vue';
import { useI18n } from 'vue-i18n';

import { PackageType } from '@/enums/packages';
import { ResponseResult } from '@/models/responseResult';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { IPackageFile } from '@/interfaces/package';
import packagesService from '@/services/packages.service';

import UploadFile from '@/components/files/uploadFile.vue';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';

export default defineComponent({
    name: "PackageFileList",
    components: {
        UploadFile,
        ConfirmDialog,
    },
    props: {
        showFileUpload: {
            type: Boolean,
            default: false,
        },
        showListHeader: {
            type: Boolean,
            default: false,
        },
        listHeader: {
            type: String,
        },
        readOnly: {
            type: Boolean,
            default: false,
        },
        inventoryId: {
            type: String,
            required: true,
        },
        packageId: {
            type: Number,
            requred: false,
        },
        packageType: {
            type: String as PropType<PackageType>,
            required: false,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const loading = ref<boolean>(true);

        const packageFileList = ref<Array<IPackageFile>>([]);

        const loadFilesData = async () => {
            try {
                loading.value = true;
                
                let packageId = props.packageId;
                if (!props.packageId) {
                    packageId = await packagesService.getPackageIdByInventory(props.inventoryId, props.packageType!);
                }

                if (packageId) {
                    packageFileList.value = await packagesService.getPackageFiles(packageId);
                }
                                
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

        const fileUploadList = ref<Array<File>>([]);
        const fileChanged = (files: File[]) => {
            fileUploadList.value = [];
            if (files) {
                fileUploadList.value = files;
            }
        };

        const uploadFiles = async () => {
            try {
                loading.value = true;
                if (fileUploadList.value && fileUploadList.value.length > 0) {
                    await packagesService.addPackageFiles(fileUploadList.value, props.packageId, props.packageType, props.inventoryId);

                    await loadFilesData();
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            } finally {
                loading.value = false;
            }
        }

        const downloadFile =async (id: number, name: string) => {
            let packageId = props.packageId;
            if (!props.packageId) {
                packageId = await packagesService.getPackageIdByInventory(props.inventoryId, props.packageType!);
            }

            const url = packagesService.getPackageFileUrl(id, packageId!);
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', name);
            document.body.appendChild(link);
            link.click();
        };

        const deleteFile = async (id: number) => {
            try {

                let packageId = props.packageId;
                if (!props.packageId) {
                    packageId = await packagesService.getPackageIdByInventory(props.inventoryId, props.packageType!);
                }

                await packagesService.deletePackageFile(id, packageId!);

                await loadFilesData();

            } catch (error: unknown) { 
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        onMounted(async () => {
            await loadFilesData();
        });

        return {
            t,
            loading,
            packageFileList,
            fileUploadList,
            fileChanged,
            uploadFiles,
            downloadFile,
            deleteFile,
        }
    },
})
</script>

<style scoped>
:deep(.floatingBtnIcon) {
    background-color: transparent !important;
    color: var(--ISDA-main-color1) !important;
    box-shadow: none !important;
    margin: 15px 0px;
}
</style>