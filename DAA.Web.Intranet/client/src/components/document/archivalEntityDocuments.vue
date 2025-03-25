<template>
    <v-row>
        <v-col>
            <slot name="toolbar">
                <v-toolbar density="compact" color="transparent" v-if="addEnabled">
                    <v-btn  color="primary" variant="elevated" @click="goAddDocument">
                        {{ t('documents.create') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('documents.buttons.createTooltip') }}
                        </v-tooltip>
                    </v-btn>
                </v-toolbar>
            </slot>
        </v-col>
    </v-row>
    <v-row align="center" v-if="searchEnabled">
        <v-col class="col-12 col-md-6 col-lg-6">
            <text-field
                onkeypress="return event.charCode >= 48"
                :label="t('documents.columns.pageFrom')"
                v-model="searchStartSheetNumber"
                validation="numeric"
            />
        </v-col>
        <v-col class="col-12 col-md-6 col-lg-6">
            <text-field
                onkeypress="return event.charCode >= 48"
                :label="t('documents.columns.pageTo')"
                v-model="searchEndSheetNumber"
                validation="numeric"
            />
        </v-col>
        <v-col class="col-12 col-lg-6">
            <text-field :label="t('archiveEntities.keyWords')" v-model="searchKeyword" />
        </v-col>
        <v-col class="col-12 col-lg-6 d-flex gap-2 justify-content-start">
            <submit-btn @click="searchDocuments"
                >{{ t('common.search') }}
                <v-tooltip activator="parent" location="bottom">
                    {{ t('common.searchTooltip') }}
                </v-tooltip>
            </submit-btn>
            <cancel-btn @click="clearAllSearchCriteria"
                >{{ t('common.clear') }}
                <v-tooltip activator="parent" location="bottom">
                    {{ t('common.clearTooltip') }}
                </v-tooltip>
            </cancel-btn>
        </v-col>
    </v-row>
    <v-row v-if="documentData.totalCount > 0">
        <v-col>
            <v-list lines="two">
                <v-list-item
                    lines="two"
                    v-for="item in documentData.items"
                    :key="item"
                    :to="{
                        name: 'DisplayDocument',
                        params: { id: item.systemIdentifier },
                        query: {
                            hasExternalSource: item.hasExternalSource,
                            externalIdentifier: item.externalIdentifier,
                        },
                    }"
                >
                    <template #prepend>
                        <v-checkbox
                            @click.stop
                            v-if="selectionEnabled"
                            v-model="selectedItems"
                            :value="item.systemIdentifier"
                            hide-details="auto"
                            :disabled="
                                readOnly ||
                                selectionConditions === false ||
                                (typeof selectionConditions === 'function' && !selectionConditions(item))
                            "
                        />

                        <button
                            v-if="deleteEnabled"
                            type="button"
                            class="icon-btn"
                            @click.prevent="onDeleteDocument(item.id, item.title)"
                        >
                            <i class="fas fa-trash-alt"></i>
                        </button>
                    </template>

                    <!-- <v-list-item-action v-if="selectionEnabled">
                    <v-checkbox
                        v-model="selectedItems"
                        :value="item.systemIdentifier"
                        hide-details="auto"
                        :disabled="readOnly || (selectionConditions === false || typeof selectionConditions === 'function' && !selectionConditions(item))"
                    />
                </v-list-item-action> -->
                    <!-- <v-list-item-header> -->
                    <v-list-item-title
                        >{{
                            t('documents.listTemplate', {
                                descriptionLevel: item.descriptionLevelText,
                                number: item.number,
                                title: trimText(item.title, 100),
                                chronologicalScope: item.approximateChronologicalScope,
                            })
                        }}
                        <span v-if="item.isInProcess">
                            <v-icon>mdi-progress-check</v-icon
                            ><v-tooltip activator="parent" location="bottom">{{
                                t('films.columns.process')
                            }}</v-tooltip>
                        </span></v-list-item-title
                    >
                    <v-list-item-subtitle>{{ item.statusText }}{{item.hasDigitizedDigitalObjects === true ? ' / ' + t('documents.activeDigitalObject') : ''}}</v-list-item-subtitle>
                </v-list-item>
            </v-list>
        </v-col>
        <Loader :isLoading="isLoading" />
    </v-row>
    <v-row v-else>
        <v-col>
            {{ t('search.emptyResult') }}
        </v-col>
    </v-row>
    <v-row v-if="documentData.totalCount > pagerOptions.itemsPerPage">
        <v-col>
            <Pager
                :initialPage="pagerOptions.pageNumber"
                :initialPageSize="pagerOptions.itemsPerPage"
                :totalPages="pagerOptions.totalPages"
                @change="changePage"
                ref="pager"
            ></Pager>
        </v-col>
    </v-row>
    <slot name="actions"> </slot>
</template>
<script lang="ts">
import { computed, defineComponent, inject, onMounted, PropType, Ref, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { LocationQueryRaw, useRouter } from 'vue-router';
import { useRedirect } from '@/helpers/router.helper';
import { trimText } from '@/helpers/format.helper';
import { Message } from '@/models/notification';

import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { PageSize, GridResponseModel, GridOptions } from '@/models/grid';
import { IArchivalEntity } from '@/interfaces/archivalEntity';
import { IDocument } from '@/interfaces/document';
import documentService from '@/services/document.service';
import processRawService from '@/services/processRawInventoriesProcess.service';

import TextField from '@/components/field/text.field.vue';
import Pager from '@/components/grid/pager.vue';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'ArchivalEntityDocuments',
    components: {
        TextField,
        Pager,
        Loader,
    },
    props: {
        archivalEntity: {
            type: Object as PropType<IArchivalEntity>,
            required: true,
        },
        addEnabled: {
            type: Boolean,
            default: false,
        },
        searchEnabled: {
            type: Boolean,
            default: false,
        },
        selectionEnabled: {
            type: Boolean,
            default: false,
        },
        modelValue: {
            type: Array as PropType<string[]>,
            default: () => [],
        },
        selectionConditions: {
            //type: [Boolean, Function] as PropType<boolean | ((value?: IArchivalEntity) => boolean)>,
            type: [Boolean, Function],
            default: false,
        },
        readOnly: {
            type: Boolean,
            default: false,
        },
        deleteEnabled: {
            type: Boolean,
            default: false,
        },
    },
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const selectedItems = computed({
            get: () => props.modelValue,
            set: (value) => context.emit('update:modelValue', value),
        });

        const router = useRouter();
        const isLoading = ref(false);

        const goAddDocument = () => {
            const routeQuery: LocationQueryRaw = {
                archivalEntitySystemIdentifier: props.archivalEntity.systemIdentifier,
                archivalEntityHasExternalSource: String(props.archivalEntity.hasExternalSource),
                archivalEntityExternalIdentifier: props.archivalEntity.externalIdentifier,
            };

            useRedirect(router, 'CreateDocument', undefined, routeQuery);
        };

        const onDeleteDocument = async (id: number, title: string) => {
            try {
                if (confirm(t('documents.buttons.deleteConfirmation', { title }))) {
                    isLoading.value = true;
                    const result = await processRawService.deleteDocumentDraft(id);

                    isLoading.value = false;
                    if (result.status == 200) {
                        await getDocumentData();
                    } else {
                        message.value = new Message({
                            text: result.response.data.message,
                            display: true,
                        });
                    }
                }
            } catch (error: unknown) {
                isLoading.value = false;
                message.value = new Message({
                    text: (error as ResponseResult)?.message,
                    display: true,
                });
            }
        };

        const pagerOptions = ref<GridOptions>({
            sortBy: '',
            sortDesc: false,
            page: 1,
            itemsPerPage: PageSize.twenty,
            sortByType: '',
            totalPages: 1
        });

        const initPagerOptions = () => {
            pagerOptions.value = new GridOptions({
                sortBy: '',
                sortDesc: false,
                page: 1,
                itemsPerPage: PageSize.twenty,
                sortByType: '',
                searchString: '',
                totalPages: 1
            });
        };

        const changePage = async (pageNumber: number, pageSize: number) => {
            pagerOptions.value.page = pageNumber;
            pagerOptions.value.itemsPerPage = pageSize;

            await getDocumentData();
        };

        const documentData = ref<GridResponseModel<IDocument>>(
            new GridResponseModel<IDocument>({ totalCount: 0, items: [] })
        );

        const getDocumentData = async (
            keywords?: string,
            number?: string,
            startSheetNumber?: number,
            endSheetNumber?: number
        ) => {
            try {
                if (keywords || number) {
                    initPagerOptions();
                    console.log(pagerOptions.value);
                }
                if (keywords) {
                    pagerOptions.value.searchString = keywords;
                }
                const result = await documentService.getArchivalEntityDocuments(
                    pagerOptions.value,
                    props.archivalEntity.systemIdentifier,
                    props.archivalEntity.hasExternalSource,
                    props.archivalEntity.externalIdentifier,
                    number,
                    startSheetNumber,
                    endSheetNumber
                );

                if(result){
                    documentData.value = result;
                    
                    documentData.value.items.sort((a, b) =>
                        a.number != undefined && b.number != undefined 
                        ? Number(a.number) - Number(b.number)
                        : 0
                    );

                    pagerOptions.value.totalPages = documentData.value.totalCount < pagerOptions.value.itemsPerPage
                            ? 1
                            : Math.ceil(documentData.value.totalCount / pagerOptions.value.itemsPerPage)
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const searchKeyword = ref('');
        const searchNumber = ref('');
        const searchStartSheetNumber = ref();
        const searchEndSheetNumber = ref();

        const searchDocuments = async () => {
            await getDocumentData(
                searchKeyword.value,
                searchNumber.value,
                searchStartSheetNumber.value,
                searchEndSheetNumber.value
            );
        };

        const clearAllSearchCriteria = async () => {
            searchKeyword.value = '';
            searchNumber.value = '';
            initPagerOptions();
            await getDocumentData();
        };

        onMounted(async () => {
            await getDocumentData();
        });

        return {
            t,
            selectedItems,
            documentData,
            pagerOptions,
            searchNumber,
            searchKeyword,
            searchStartSheetNumber,
            searchEndSheetNumber,
            trimText,
            changePage,
            searchDocuments,
            clearAllSearchCriteria,
            goAddDocument,
            onDeleteDocument,
            isLoading,
        };
    },
});
</script>
