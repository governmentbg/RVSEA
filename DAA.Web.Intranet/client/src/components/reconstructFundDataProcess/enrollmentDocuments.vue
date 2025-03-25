<template>
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
        <v-col class="col-12 col-lg-6 d-flex justify-content-start">
            <v-btn @click="searchDocuments" variant="flat">{{ t('common.search') }}
                <v-tooltip
                    activator="parent"
                    location="bottom"
                >
                {{t('common.searchTooltip')}}
                </v-tooltip>
            </v-btn>
            <v-btn class="cancel" @click="clearAllSearchCriteria" variant="flat">{{ t('common.clear') }}
                <v-tooltip
                    activator="parent"
                    location="bottom"
                >
                {{t('common.clearTooltip')}}
                </v-tooltip>
            </v-btn>
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
                    <template #prepend v-if="selectionEnabled">
                        <v-checkbox
                            v-model="selectedItems"
                            :value="item.systemIdentifier"
                            hide-details="auto"
                            :disabled="
                                readOnly ||
                                selectionConditions === false ||
                                (typeof selectionConditions === 'function' && !selectionConditions(item))
                            "
                        />
                    </template>
                    <v-list-item-title>{{
                        t('documents.searchTemplate', {
                            descriptionLevel: item.descriptionLevelText,
                            title: trimText(item.title, 100),
                            chronologicalScope: item.approxmateChronologicalScope,
                        })
                    }}</v-list-item-title>
                    <v-list-item-subtitle>{{ item.statusText }}</v-list-item-subtitle>
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
                v-if="documentData.totalCount > pagerOptions.itemsPerPage"
                :initialPage="pagerOptions.pageNumber"
                :initialPageSize="pagerOptions.itemsPerPage"
                @change="changePage"
                ref="pager"
            ></Pager>
        </v-col>
    </v-row>
    <slot name="actions"> </slot>
</template>
<script lang="ts">
import { computed, defineComponent, inject, onMounted, PropType, Ref, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { trimText } from '@/helpers/format.helper';
import { Message } from '@/models/notification';

import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { AvailabilityStatus } from '@/enums/status';
import { PageSize, GridResponseModel, GridOptions } from '@/models/grid';
import { IProcess } from '@/interfaces/process';
import { IDocument } from '@/interfaces/document';
import documentService from '@/services/document.service';

import TextField from '@/components/field/text.field.vue';
import Pager from '@/components/grid/pager.vue';

export default defineComponent({
    name: 'RelocationEnrollmentDocuments',
    components: {
        TextField,
        Pager,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>,
            required: true,
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
    },
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const selectedItems = computed({
            get: () => props.modelValue,
            set: (value) => context.emit('update:modelValue', value),
        });

        const pagerOptions = ref<GridOptions>({
            sortBy: '',
            sortDesc: false,
            page: 1,
            itemsPerPage: PageSize.twenty,
            sortByType: '',
        });

        const initPagerOptions = () => {
            pagerOptions.value = new GridOptions({
                sortBy: '',
                sortDesc: false,
                page: 1,
                itemsPerPage: PageSize.twenty,
                sortByType: '',
                searchString: '',
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
                documentData.value = await documentService.getDocumentsByAvailabilityStatus(
                    pagerOptions.value,
                    AvailabilityStatus.RelocationDeduction,
                    props.process.fundSystemIdentifier!,
                    number,
                    startSheetNumber,
                    endSheetNumber
                );
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

        watch(
            () => selectedItems.value,
            (newVal, oldVal) => {
                console.log('si new val', newVal);
                console.log('si old val', oldVal);
            }
        );

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
        };
    },
});
</script>
