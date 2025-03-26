<template>
    <Loader :isLoading="isLoading" />
    <v-row v-if="digitalObjectData.totalCount > 0">
        <v-col>
            <v-list variant="plain" density="compact">
                <v-list-item v-for="item in digitalObjectData.items" :key="item" @click="displayClickHandler(item)">
                    <v-list-item-title>{{ item.sourceName }}</v-list-item-title>
                    <template #append>
                        <v-btn icon color="transparent" variant="flat" @click.stop="downloadFileClickHandler(item)">
                            <v-icon>mdi-download</v-icon>
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('common.downloadTooltip') }}
                            </v-tooltip>
                        </v-btn>
                    </template>
                </v-list-item>
            </v-list>
        </v-col>
    </v-row>
    <v-row v-else>
        <v-col>
            {{ t('search.emptyResult') }}
        </v-col>
    </v-row>
    <v-row>
        <v-col>
            <Pager
                v-if="digitalObjectData.totalCount > pagerOptions.itemsPerPage"
                :initialPage="pagerOptions.pageNumber"
                :initialPageSize="pagerOptions.itemsPerPage"
                @change="changePage"
                ref="pager"
            ></Pager>
        </v-col>
    </v-row>
    <DisplayImageModal v-model="displayModal" :src="imageUrl" @close="closeModal" />
    <DisplayPlayerModal v-model="displayAudioVideoModal" :src="audioVideoUrl" @close="closeModal" />
    <DisplayPdfModal :digitalObjectType="digObjTypeCode" v-model="displayPdf" :src="pdfUrl" @close="closeModal" />
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, PropType, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from '@/store/app';
import { isImage, isPdf, isSound } from '@/helpers/file.helper';
import DisplayPdfModal from '@/components/digitalObject/displayPdfModal.vue';
import { DigitalObjectType } from '@/enums/digitalObject';
import { IMessage } from '@/interfaces/notification';
import { IInventory } from '@/interfaces/inventory';
import { IDigitalObject } from '@/interfaces/digitalObject';
import { ResponseResult } from '@/models/responseResult';
import { Message } from '@/models/notification';
import { GridOptions, GridResponseModel, PageSize } from '@/models/grid';
import digitalObjectService from '@/services/digitalObject.service';

import DisplayImageModal from '@/components/digitalObject/displayImageModal.vue';
import DisplayPlayerModal from '@/components/digitalObject/displayPlayerModal.vue';
import Loader from '@/components/loader/loader.vue';
import Pager from '@/components/grid/pager.vue';
//import http from '@/services/http.service';

export default defineComponent({
    name: 'InventoryDigitalObjects',
    components: {
        DisplayImageModal,
        DisplayPlayerModal,
        Loader,
        Pager,
        DisplayPdfModal,
    },
    props: {
        inventory: {
            type: Object as PropType<IInventory>,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const pdfUrl = ref('');
        const displayPdf = ref(false);
        const isLoading = ref(false);
        const appStore = useStore();
        const displayModal = ref<boolean>(false);
        const displayAudioVideoModal = ref<boolean>(false);
        const imageUrl = ref<string>('');
        const audioVideoUrl = ref<string>('');
        const digObjTypeCode = ref<number>();
        const closeModal = () => {
            displayModal.value = false;
            imageUrl.value = '';
            audioVideoUrl.value = '';
            displayAudioVideoModal.value = false;
            displayPdf.value = false;
            pdfUrl.value = '';
        };

        const pagerOptions = ref<GridOptions>({
            sortBy: '',
            sortDesc: false,
            page: 1,
            itemsPerPage: PageSize.hundred,
            sortByType: '',
        });

        const changePage = async (pageNumber: number, pageSize: number) => {
            pagerOptions.value.page = pageNumber;
            pagerOptions.value.itemsPerPage = pageSize;

            await getDigitalObjectData();
        };

        const digitalObjectData = ref<GridResponseModel<IDigitalObject>>(
            new GridResponseModel<IDigitalObject>({ totalCount: 0, items: [] })
        );

        const getDigitalObjectData = async () => {
            try {
                isLoading.value = true;

                digitalObjectData.value = await digitalObjectService.getInventoryDigitalObjects(
                    pagerOptions.value,
                    props.inventory?.systemIdentifier,
                    props.inventory?.hasExternalSource,
                    props.inventory?.externalIdentifier
                );
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            } finally {
                isLoading.value = false;
            }
        };

        const displayClickHandler = (item: IDigitalObject) => {
            if (item) {
                if (item.hasExternalSource) {
                    if (item.typeCode !== DigitalObjectType.MasterFile) {
                        const url = `${appStore.state.externalSourceGalleryUrl}?Gid=${item.externalIdentifier}`;
                        const link = document.createElement('a');
                        link.href = url;
                        link.target = '_blank';
                        document.body.appendChild(link);
                        link.click();
                    } else {
                        const url = `${appStore.state.externalSourceFileDownloadUrl}?Type=m&Gid=${item.externalIdentifier}`;
                        const link = document.createElement('a');
                        link.href = url;
                        link.setAttribute('download', item.name!);
                        document.body.appendChild(link);
                        link.click();
                    }
                } else {
                    const url = digitalObjectService.streamDigitalObjectUrl(item.systemIdentifier!, true);
                    if (isImage(item.name!)) {
                        imageUrl.value = url;
                        displayModal.value = true;
                    } else if (isSound(item.name!)) {
                        audioVideoUrl.value = url;
                        displayAudioVideoModal.value = true;
                    } else if (isPdf(item.name!)) {
                        digObjTypeCode.value = item.typeCode;
                        pdfUrl.value = '';
                        digitalObjectService.streamDigitalObjectFile(item.systemIdentifier!)
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
                }
            } else {
                message.value = new Message({ type: 'warning', text: t('warning.fileNotFound') });
            }
        };

        const downloadFileClickHandler = (item: IDigitalObject) => {
            if (item) {
                if (item.hasExternalSource) {
                    if (item.typeCode !== DigitalObjectType.MasterFile) {
                        const url = `${appStore.state.externalSourceGalleryUrl}?Gid=${item.externalIdentifier}`;
                        const link = document.createElement('a');
                        link.href = url;
                        link.target = '_blank';
                        //link.setAttribute('download', item.name!);
                        document.body.appendChild(link);
                        link.click();
                    } else {
                        const url = `${appStore.state.externalSourceFileDownloadUrl}?Type=m&Gid=${item.externalIdentifier}`;
                        const link = document.createElement('a');
                        link.href = url;
                        link.setAttribute('download', item.name!);
                        document.body.appendChild(link);
                        link.click();
                    }
                } else {
                    const url = digitalObjectService.streamDigitalObjectUrl(item.systemIdentifier!);
                    const link = document.createElement('a');
                    link.href = url;
                    link.setAttribute('download', item.name!);
                    document.body.appendChild(link);
                    link.click();
                }
            } else {
                message.value = new Message({ type: 'warning', text: t('warning.fileNotFound') });
            }
        };

        onMounted(async () => {
            await getDigitalObjectData();
        });

        return {
            t,
            changePage,
            displayClickHandler,
            downloadFileClickHandler,
            digitalObjectData,
            pagerOptions,
            imageUrl,
            audioVideoUrl,
            displayModal,
            displayAudioVideoModal,
            closeModal,
            isLoading,
            displayPdf,
            digObjTypeCode,
            pdfUrl,
        };
    },
});
</script>
