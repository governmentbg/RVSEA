<template>
<Loader :isLoading="isLoading" />
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('inventories.display') }}</v-card-title>
        <v-container>
            <v-expansion-panels v-model="panel" multiple>
                <v-expansion-panel value="general">
                    <v-expansion-panel-title>{{ t('inventories.panels.general') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldArchive"
                                    :label="t('funds.columns.archive')"
                                    v-model="inventoryData.archiveName"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldFund"
                                    :label="t('inventories.columns.fund')"
                                    v-model="inventoryData.fundNumber"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldNumber"
                                    :label="t('inventories.columns.number')"
                                    v-model="inventoryData.number"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDescriptionLevel"
                                    :label="t('inventories.columns.descriptionLevel')"
                                    v-model="inventoryData.descriptionLevelText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldAcquisitionMethod"
                                    :label="t('inventories.columns.acquisitionMethod')"
                                    v-model="inventoryData.acquisitionMethodText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="chronologicalScope">
                    <v-expansion-panel-title>{{ t('inventories.panels.chronologicalScope') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <Switch
                                    v-model="inventoryData.hasNoChronologicalScope"
                                    :label="t('inventories.columns.chronologicalScope')"
                                    :large="false"
                                    :showLabel="true"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <label>{{ t('inventories.columns.startDate') }}</label>
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateDay"
                                    :label="t('inventories.columns.day')"
                                    v-model="inventoryData.startDateDay"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateMonth"
                                    :label="t('inventories.columns.month')"
                                    v-model="inventoryData.startDateMonth"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateYear"
                                    :label="t('inventories.columns.year')"
                                    v-model="inventoryData.startDateYear"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <label>{{ t('inventories.columns.endDate') }}</label>
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateDay"
                                    :label="t('inventories.columns.day')"
                                    v-model="inventoryData.endDateDay"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateMonth"
                                    :label="t('inventories.columns.month')"
                                    v-model="inventoryData.endDateMonth"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateYear"
                                    :label="t('inventories.columns.year')"
                                    v-model="inventoryData.endDateYear"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldApproxmateChronologicalScope"
                                    :label="t('inventories.columns.approxmateChronologicalScope')"
                                    v-model="inventoryData.approxmateChronologicalScope"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="storage">
                    <v-expansion-panel-title>{{ t('inventories.panels.storage') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldBytes"
                                    :label="t('inventories.columns.bytes')"
                                    v-model="formattedBytes"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldLinearMeters"
                                    :label="t('inventories.columns.linearMeters')"
                                    v-model="inventoryData.linearMeters"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldArchivalEntityCount"
                                    :label="t('inventories.columns.archivalEntityCount')"
                                    v-model="inventoryData.archivalEntityCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldDocumentCount"
                                    :label="t('inventories.columns.documentCount')"
                                    v-model="inventoryData.documentCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldBoxCount"
                                    :label="t('inventories.columns.boxCount')"
                                    v-model="inventoryData.boxCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldRollCount"
                                    :label="t('inventories.columns.rollCount')"
                                    v-model="inventoryData.rollCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldAudioDocumentArchivalEntityCount"
                                    :label="t('inventories.columns.audioDocumentArchivalEntityCount')"
                                    v-model="inventoryData.audioDocumentArchivalEntityCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldPhotoDocumentArchivalEntityCount"
                                    :label="t('inventories.columns.photoDocumentArchivalEntityCount')"
                                    v-model="inventoryData.photoDocumentArchivalEntityCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldVideoDocumentArchivalEntityCount"
                                    :label="t('inventories.columns.videoDocumentArchivalEntityCount')"
                                    v-model="inventoryData.videoDocumentArchivalEntityCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldDigitalDocumentArchivalEntityCount"
                                    :label="t('inventories.columns.digitalDocumentArchivalEntityCount')"
                                    v-model="inventoryData.digitalDocumentArchivalEntityCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldFileType"
                                    :label="t('inventories.columns.fileType')"
                                    v-model="inventoryData.fileTypeText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldOtherMetrics"
                                    :label="t('inventories.columns.otherMetrics')"
                                    v-model="inventoryData.otherMetrics"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="additional" v-if="loadClass">
                    <v-expansion-panel-title>{{ t('inventories.panels.additional') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col :class="possibleEmptyFields.fundCreatorTitleHistory">
                                <text-area-field
                                    name="fldFundCreatorTitleHistory"
                                    :label="t('inventories.columns.fundCreatorTitleHistory')"
                                    v-model="inventoryData.fundCreatorTitleHistory"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.fundCreatorBiographicalHistory">
                                <text-area-field
                                    name="fldFundCreatorBiographicalHistory"
                                    :label="t('inventories.columns.fundCreatorBiographicalHistory')"
                                    v-model="inventoryData.fundCreatorBiographicalHistory"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.history">
                                <text-area-field
                                    name="fldHistory"
                                    :label="t('inventories.columns.history')"
                                    v-model="inventoryData.history"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDocumentsProvider"
                                    :label="t('inventories.columns.documentsProvider')"
                                    v-model="inventoryData.documentsProvider"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.documentsDescription">
                                <text-area-field
                                    name="fldDocumentsDescription"
                                    :label="t('inventories.columns.documentsDescription')"
                                    v-model="inventoryData.documentsDescription"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldOriginality"
                                    :label="t('inventories.columns.originality')"
                                    v-model="inventoryData.originalityText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldCreationMethod"
                                    :label="t('inventories.columns.creationMethod')"
                                    v-model="inventoryData.creationMethodText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldLanguage"
                                    :label="t('inventories.columns.language')"
                                    v-model="inventoryData.languageText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.documentsAccessDescription">
                                <text-area-field
                                    name="fldDocumentsAccessDescription"
                                    :label="t('inventories.columns.documentsAccessDescription')"
                                    v-model="inventoryData.documentsAccessDescription"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.notes">
                                <text-area-field
                                    name="fldNotes"
                                    :label="t('inventories.columns.notes')"
                                    v-model="inventoryData.notes"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="copies">
                    <v-expansion-panel-title>{{ t('inventories.panels.copies') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldMicrofilmedArchivalEntityCount"
                                    :label="t('inventories.columns.microfilmedArchivalEntityCount')"
                                    v-model="inventoryData.microfilmedArchivalEntityCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldDigitizedArchivalEntityCount"
                                    :label="t('inventories.columns.digitizedArchivalEntityCount')"
                                    v-model="inventoryData.digitizedArchivalEntityCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldPositiveFrameCount"
                                    :label="t('inventories.columns.positiveFrameCount')"
                                    v-model="inventoryData.positiveFrameCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldNegativeFrameCount"
                                    :label="t('inventories.columns.negativeFrameCount')"
                                    v-model="inventoryData.negativeFrameCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel 
                    value="archivalEntitiesInInventory"
                    v-if="
                        renderComponent && inventoryData.descriptionLevelText === InventoryDescriptionLevelText.inventory
                    ">
                    <v-expansion-panel-title>{{
                        t('inventories.panels.archivalEntitiesInInventory')
                    }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row align="center">
                            <v-col class="col-12 col-md-6 col-lg-4">
                                <text-field
                                    onkeypress="return event.charCode >= 48"
                                    :label="t('archiveEntities.columns.number')"
                                    v-model="searchNumber"
                                    validation="numeric"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-6 col-lg-4">
                                <text-field :label="t('inventories.keyWords')" v-model="searchKeyword" />
                            </v-col>
                            <v-col class="col-12 col-lg-4 d-flex gap-2 justify-content-start">
                                <v-btn @click="searchArchivalEntities" variant="flat"
                                    >{{ t('common.search') }}
                                    <v-tooltip activator="parent" location="bottom">
                                        {{ t('common.searchTooltip') }}
                                    </v-tooltip>
                                </v-btn>
                                <v-btn class="cancel" @click="clearAllSearchCriteria" variant="flat"
                                    >{{ t('common.clear') }}
                                    <v-tooltip activator="parent" location="bottom">
                                        {{ t('common.clearTooltip') }}
                                    </v-tooltip>
                                </v-btn>
                            </v-col>
                        </v-row>
                        <v-row v-if="archivalEntityData.totalCount > 0">
                            <v-col>
                                <v-list variant="text">
                                    <v-list-item
                                        v-for="item in archivalEntityData.items"
                                        :key="item"
                                        :title="
                                            t('archiveEntities.searchTemplate', {
                                                descriptionLevel: item.descriptionLevelText,
                                                number: item.number,
                                                title: trimText(item.title, 100),
                                                chronologicalScope: item.approxmateChronologicalScope,
                                            })
                                        "
                                        :subtitle="item.statusText + (item.hasDigitizedDigitalObjects === true ? ' / ' + t('archiveEntities.activeDigitalObjectYes') : ' / ' + t('archiveEntities.activeDigitalObjectNo'))"
                                        :to="{
                                            name: 'DisplayArchivalEntity',
                                            params: { id: item.systemIdentifier },
                                            query: {
                                                hasExternalSource: item.hasExternalSource,
                                                externalIdentifier: item.externalIdentifier,
                                            },
                                        }"
                                    >
                                    </v-list-item>
                                </v-list>
                            </v-col>
                        </v-row>
                        <v-row v-else>
                            <v-col>
                                {{ t('search.emptyResult') }}
                            </v-col>
                        </v-row>
                        <v-row v-if="archivalEntityData.totalCount > pagerOptions.itemsPerPage">
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
                    </v-expansion-panel-text>
                </v-expansion-panel>
            </v-expansion-panels>
        </v-container>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, inject, Ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { formatBytesToMB } from '@/helpers/format.helper';
import { trimText } from '@/helpers/format.helper';

import { InventoryDescriptionLevelText } from '@/enums/inventory';
import { IArchivalEntity } from '@/interfaces/archivalEntity';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { PageSize, GridResponseModel, GridOptions } from '@/models/grid';
import { IInventory } from '@/interfaces/inventory';
import { Inventory } from '@/models/inventory';
import inventoryService from '@/services/inventory.service';
import archiveEntityService from '@/services/archivalEntity.service';

import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import Pager from '@/components/grid/pager.vue';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'DisplayInventory',
    components: {
        Loader,
        TextField,
        TextAreaField,
        Switch,
        Pager,
        Breadcrumbs,
    },
    props: {
        id: {
            type: String,
        },
        hasExternalSource: {
            type: Boolean,
        },
        externalIdentifier: {
            type: Number,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const panel = ref([
            'general',
            'additional',
            'chronologicalScope',
            'externalSource',
            'storage',
            'copies',
            'archivalEntitiesInInventory',
        ]);
        const router = useRouter();

        const renderComponent = ref(false);

        const possibleEmptyFields = {
            fundCreatorTitleHistory: '',
            fundCreatorBiographicalHistory: '',
            history: '',
            documentsDescription: '',
            documentsAccessDescription: '',
            notes: '',
        };

        const lowClass = 'low';
        const loadClass = ref(false);
        const isLoading = ref(false);

        const formattedBytes = computed(() => {
            return formatBytesToMB(inventoryData.value.bytes || 0);
        });

        const goBack = () => {
            router.go(-1);
        };

        const inventoryData = ref<IInventory>(new Inventory());
        const getInventoryData = async () => {
            try {
                isLoading.value = true;
                inventoryData.value = await inventoryService.displayInventory(
                    props.id,
                    props.hasExternalSource,
                    props.externalIdentifier
                );

                if (!inventoryData.value.fundCreatorTitleHistory) {
                    possibleEmptyFields.fundCreatorTitleHistory = lowClass;
                }
                if (!inventoryData.value.fundCreatorBiographicalHistory) {
                    possibleEmptyFields.fundCreatorBiographicalHistory = lowClass;
                }
                if (!inventoryData.value.history) {
                    possibleEmptyFields.history = lowClass;
                }
                if (!inventoryData.value.documentsDescription) {
                    possibleEmptyFields.documentsDescription = lowClass;
                }
                if (!inventoryData.value.documentsAccessDescription) {
                    possibleEmptyFields.documentsAccessDescription = lowClass;
                }
                if (!inventoryData.value.notes) {
                    possibleEmptyFields.notes = lowClass;
                }

                if (inventoryData.value.resultMessage && inventoryData.value.resultMessage === 'ISDADataCannotBeDisplayed') {
                    message.value = new Message({
                        text: t('warnings.ISDADataCannotBeDisplayed'),
                        display: true,
                        type: 'warning',
                    });
                }
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

            await getInventoryArchivalEntityData();
        };

        const archivalEntityData = ref<GridResponseModel<IArchivalEntity>>(
            new GridResponseModel<IArchivalEntity>({ totalCount: 0, items: [] })
        );
        const getInventoryArchivalEntityData = async (keywords?: string, number?: string) => {
            try {
                isLoading.value = true;
                if (keywords || number) {
                    initPagerOptions();
                }
                if (keywords) {
                    pagerOptions.value.searchString = keywords;
                }
                const result = await archiveEntityService.getInventoryArchivalEntities(
                    pagerOptions.value,
                    inventoryData.value.systemIdentifier,
                    props.hasExternalSource,
                    props.externalIdentifier,
                    number
                );

                if(result){
                    archivalEntityData.value  = result;
                    pagerOptions.value.totalPages = archivalEntityData.value.totalCount < pagerOptions.value.itemsPerPage
                            ? 1
                            : Math.ceil(archivalEntityData.value.totalCount / pagerOptions.value.itemsPerPage);
                }
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

        const breadcrumbItems = computed(() => [
            {
                title: inventoryData.value.archiveName,
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('funds.fund'),
                disabled: false,
                to: {
                    name: 'DisplayFund',
                    params: { id: inventoryData.value.fundSystemIdentifier },
                    query: {
                        hasExternalSource: inventoryData.value.fundHasExternalSource,
                        externalIdentifier: inventoryData.value.fundExternalIdentifier,
                    },
                },
            },
            {
                title: t('inventories.inventory'),
                disabled: true,
            },
        ]);
        const searchKeyword = ref('');
        const searchNumber = ref('');

        function searchArchivalEntities() {
            getInventoryArchivalEntityData(searchKeyword.value, searchNumber.value);
        }

        function clearAllSearchCriteria() {
            searchKeyword.value = '';
            searchNumber.value = '';
            initPagerOptions();
            getInventoryArchivalEntityData();
        }

        onMounted(async () => {
            window.scrollTo(0, 0);
            await getInventoryData();
            await getInventoryArchivalEntityData();
            loadClass.value = true;
            renderComponent.value = true;
        });

        return {
            t,
            panel,
            inventoryData,
            archivalEntityData,
            goBack,
            message,
            pagerOptions,
            changePage,
            trimText,
            searchKeyword,
            breadcrumbItems,
            searchNumber,
            searchArchivalEntities,
            clearAllSearchCriteria,
            possibleEmptyFields,
            loadClass,
            formattedBytes,
            InventoryDescriptionLevelText,
            renderComponent,
            isLoading,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs-inv.scss';

:deep(.v-container),
.v-container,
:deep(.v-expansion-panels),
:deep(.v-expansion-panel-text),
:deep(.v-expansion-panel-title) {
    margin: 0px !important;
}
:deep(.float-right button) {
    margin: 0px;
}

.low,
:deep(.low div),
:deep(.low textarea) {
    height: 50px;
    margin-bottom: 25px;
}
</style>
