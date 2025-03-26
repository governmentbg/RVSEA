<template>
    <Loader :isLoading="isLoading" />
    <span v-if="digitalObjectData.totalCount > 0">
        <v-list variant="plain">
            <v-col>
                <v-row>
                    <v-col
                        v-if="digitalObjectData.items.filter((obj) => obj.typeCode == 2).length > 0"
                        class="col-12 col-lg-6"
                    >
                        <v-list-subheader>{{ t('digitalObjects.derivativesFiles') }}</v-list-subheader>
                        <v-list-item
                            v-for="item in digitalObjectData.items.filter((obj) => obj.typeCode == 2)"
                            :key="item"
                            @click="displayClickHandler(item)"
                        >
                            <v-list-item-title>{{ item.sourceName }}</v-list-item-title>
                        </v-list-item>
                    </v-col>
                    <v-col
                        v-if="digitalObjectData.items.filter((obj) => obj.typeCode == 3).length > 0"
                        :class="{
                            'col-12 col-lg-6': digitalObjectData.items.filter((obj) => obj.typeCode == 2).length > 0,
                            'col-12': (digitalObjectData.items.filter((obj) => obj.typeCode == 2).length = 0),
                        }"
                    >
                        <v-list-subheader>{{ t('digitalObjects.demoFiles') }}</v-list-subheader>
                        <v-list-item
                            v-for="item in digitalObjectData.items.filter((obj) => obj.typeCode == 3)"
                            :key="item"
                            @click="displayClickHandler(item)"
                        >
                            <v-list-item-title>{{ item.sourceName }}</v-list-item-title>
                        </v-list-item>
                    </v-col>
                </v-row>
            </v-col>
        </v-list>
    </span>

    <v-row v-else>
        <v-col>
            {{ t('search.emptyResult') }}
        </v-col>
    </v-row>
    <v-row>
        <v-col>
            <Pager
                v-if="digitalObjectData.totalCount > pagerOptions.itemsPerPage"
                :initialPage="pagerOptions.page"
                :initialPageSize="pagerOptions.itemsPerPage"
                @change="changePage"
                ref="pager"
            ></Pager>
        </v-col>
    </v-row>
    <DisplayImageModal v-model="displayModal" :src="imageUrl" @close="closeModal" />
    <VideoPlayer v-model="displayAudioVideoModal" :src="audioVideoUrl" @close="closeModal" />
    <DisplayPdfModal :digitalObjectType="digObjTypeCode" v-model="displayPdf" :src="pdfUrl" @close="closeModal" />
    <!-- <ReviewModal :src="modalScr" v-model:showModal="showModal" />
	<v-row class="mt-3">
		<grid
			ref="grid"
			:baseUrl="gridUrl"
			:columns="columns"
			:mode="'remote'"
			:paging="true"
			:pageSize="pageSize"
			:showSearch="false"
			:showExport="false"
			:noDataMessage="t('common.noDataMessage')"
		>
			<template v-slot:menubar> </template>
		</grid>
	</v-row> -->
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, PropType, Ref, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from '@/store/app';
import { isImage, isPdf, isSound } from '@/helpers/file.helper';
import VideoPlayer from '@/components/digitalObjects/displayAudioVideoPlayerModal.vue';
import { ResponseResult } from '@/models/responseResult';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { GridOptions, GridResponseModel, PageSize } from '@/models/grid';
import { IDocument } from '@/interfaces/document';
import { IDigitalObject } from '@/interfaces/digitalObject';
import DisplayPdfModal from '@/components/digitalObjects/displayPdfModal.vue';
//import { userStore as useUserStore } from '@/store/user';

import digitalObjectService from '@/services/digitalObject.service';

import DisplayImageModal from '@/components/digitalObjects/displayImageModal.vue';
import Pager from '@/components/grid/pager.vue';
import Loader from '@/components/loader/loader.vue';
//import http from '@/services/http.service';

export default defineComponent({
    name: 'DocumentDigitalObjects',
    components: {
        DisplayImageModal,
        DisplayPdfModal,
        Pager,
        Loader,
        VideoPlayer,
    },
    props: {
        document: {
            type: Object as PropType<IDocument>,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const appStore = useStore();
        const displayAudioVideoModal = ref<boolean>(false);
        const audioVideoUrl = ref<string>('');
        const isLoading = ref<boolean>(false);
        const displayModal = ref<boolean>(false);
        const imageUrl = ref<string>('');
        const pdfUrl = ref<string>('');
        const displayPdf = ref<boolean>(false);
        const digObjTypeCode = ref<number>();
        const token = ref<string>('');
        //const userStore = useUserStore();

        const closeModal = () => {
            displayModal.value = false;
            imageUrl.value = '';
            audioVideoUrl.value = '';
            displayAudioVideoModal.value = false;
        };

        const pagerOptions = ref<GridOptions>({
            sortBy: '',
            sortDesc: false,
            page: 1,
            itemsPerPage: PageSize.twenty,
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

                var result = await digitalObjectService.getDocumentDigitalObjects(
                    pagerOptions.value,
                    props.document?.systemIdentifier,
                    props.document?.hasExternalSource,
                    props.document?.externalIdentifier
                );
                digitalObjectData.value = result.data;
                token.value = result.message;
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
                    const url = `${appStore.state.externalSourceGalleryUrl}?Gid=${item.externalIdentifier}`;
                    const link = document.createElement('a');
                    link.href = url;
                    link.target = '_blank';
                    document.body.appendChild(link);
                    link.click();
                } else {
                    const url = digitalObjectService.streamDigitalObjectFileUrl(
                            item?.systemIdentifier,
                            item?.hasExternalSource,
                            item?.externalIdentifier,
                            true,
                            token.value
                        );
                    if (isImage(item.name!)) {
                        imageUrl.value = url
                        displayModal.value = true;
                    } else if (isSound(item.name!)) {
                        audioVideoUrl.value = url;
                        displayAudioVideoModal.value = true;
                    } else if (isPdf(item.name!)) {
                        digObjTypeCode.value = item.typeCode;
                        pdfUrl.value = '';
                        // const url = new URL(`${appStore.getters.baseUrl }/api/digitalobjects/download/${item.systemIdentifier}`);
                        // if(userStore.getters.userId && token) {
                        //     url.searchParams.append('userId', userStore.getters.userId)
                        //     url.searchParams.append('token', token.value)
                        // }
                        // http.get(url.toString()).then((response) => {
                        //     pdfUrl.value = b64toBlob(response.data.message);
                        // });
                        digitalObjectService.streamDigitalObjectFile(item.systemIdentifier!, item.hasExternalSource, item.externalIdentifier, token.value)
                        .then((response) => {
                            pdfUrl.value = URL.createObjectURL(response);
                        });
                        displayPdf.value = true;
                    } else {
                        const url = digitalObjectService.streamDigitalObjectFileUrl(
                            item?.systemIdentifier,
                            item?.hasExternalSource,
                            item?.externalIdentifier,
                            true,
                            token.value
                        );
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

        onMounted(async () => {
            await getDigitalObjectData();
        });

        return {
            t,
            isLoading,
            displayModal,
            displayPdf,
            pdfUrl,
            closeModal,
            imageUrl,
            audioVideoUrl,
            displayAudioVideoModal,
            pagerOptions,
            digitalObjectData,
            changePage,
            displayClickHandler,
            digObjTypeCode
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
</style>
