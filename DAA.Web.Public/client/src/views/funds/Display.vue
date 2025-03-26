<template>
<Loader :isLoading="isLoading" />
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('funds.display') }}</v-card-title>

        <v-container>
            <v-expansion-panels v-model="panel" multiple>
                <v-expansion-panel value="generalInfo">
                    <v-expansion-panel-title>{{ t('funds.panels.generalInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-9">
                                <text-field
                                    name="fldArchive"
                                    :label="t('funds.columns.archive')"
                                    v-model="fundData.archiveName"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-3">
                                <text-field
                                    name="fldNumber"
                                    :label="t('funds.columns.number')"
                                    v-model="fundData.number"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="fundInfo" v-if="loadClass">
                    <v-expansion-panel-title>{{ t('funds.panels.fundInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-6">
                                <text-field
                                    name="fldNumber"
                                    :label="t('funds.columns.number')"
                                    v-model="fundData.number"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-6">
                                <text-field
                                    name="fldStatus"
                                    :label="t('funds.columns.status')"
                                    v-model="fundData.statusText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDescriptionLevel"
                                    :label="t('funds.columns.descriptionLevel')"
                                    v-model="fundData.descriptionLevelText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldTitle"
                                    :label="t('funds.columns.title')"
                                    v-model="fundData.title"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <v-divider></v-divider>
                                <h6>{{ t('funds.panels.chronologicalScope') }}</h6>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <Switch
                                    v-model="fundData.hasNoChronologicalScope"
                                    :label="t('funds.columns.chronologicalScope')"
                                    :large="false"
                                    :showLabel="true"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <label>{{ t('funds.columns.startDate') }}</label>
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateDay"
                                    :label="t('funds.columns.day')"
                                    v-model="fundData.startDateDay"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateMonth"
                                    :label="t('funds.columns.month')"
                                    v-model="fundData.startDateMonth"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateYear"
                                    :label="t('funds.columns.year')"
                                    v-model="fundData.startDateYear"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <label>{{ t('funds.columns.endDate') }}</label>
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateDay"
                                    :label="t('funds.columns.day')"
                                    v-model="fundData.endDateDay"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateMonth"
                                    :label="t('funds.columns.month')"
                                    v-model="fundData.endDateMonth"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateYear"
                                    :label="t('funds.columns.year')"
                                    v-model="fundData.endDateYear"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldApproxmateChronologicalScope"
                                    :label="t('funds.columns.approxmateChronologicalScope')"
                                    v-model="fundData.approxmateChronologicalScope"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <v-divider></v-divider>
                                <h6>{{ t('funds.panels.storage') }}</h6>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldBytes"
                                    :label="t('funds.columns.bytes')"
                                    v-model="formattedBytes"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldLinearMeters"
                                    :label="t('funds.columns.linearMeters')"
                                    v-model="fundData.linearMeters"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldInventoryCount"
                                    :label="t('funds.columns.inventoryCount')"
                                    v-model="fundData.inventoryCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldArchivalEntityCount"
                                    :label="t('funds.columns.archivalEntityCount')"
                                    v-model="fundData.archivalEntityCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldDocumentCount"
                                    :label="t('funds.columns.documentCount')"
                                    v-model="fundData.documentCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldFileType"
                                    :label="t('funds.columns.fileType')"
                                    v-model="fundData.fileTypeText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldOtherMetrics"
                                    :label="t('funds.columns.otherMetrics')"
                                    v-model="fundData.otherMetrics"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <v-divider></v-divider>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.fundCreatorTitleHistory">
                                <text-area-field
                                    name="fldFundCreatorTitleHistory"
                                    :label="t('funds.columns.fundCreatorTitleHistory')"
                                    v-model="fundData.fundCreatorTitleHistory"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.fundCreatorBiographicalHistory">
                                <text-area-field
                                    name="fldFundCreatorBiographicalHistory"
                                    :label="t('funds.columns.fundCreatorBiographicalHistory')"
                                    v-model="fundData.fundCreatorBiographicalHistory"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.history">
                                <text-area-field
                                    name="fldHistory"
                                    :label="t('funds.columns.history')"
                                    v-model="fundData.history"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.documentsDescription">
                                <text-area-field
                                    name="fldDocumentsDescription"
                                    :label="t('funds.columns.documentsDescription')"
                                    v-model="fundData.documentsDescription"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldLanguage"
                                    :label="t('funds.columns.language')"
                                    v-model="fundData.languageText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.documentsAccessDescription">
                                <text-area-field
                                    name="fldDocumentsAccessDescription"
                                    :label="t('funds.columns.documentsAccessDescription')"
                                    v-model="fundData.documentsAccessDescription"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.relatedFunds">
                                <text-area-field
                                    name="fldRelatedFunds"
                                    :label="t('funds.columns.relatedFunds')"
                                    v-model="fundData.relatedFunds"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.notes">
                                <text-area-field
                                    name="fldNotes"
                                    :label="t('funds.columns.notes')"
                                    v-model="fundData.notes"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="inventoryInfo">
                    <v-expansion-panel-title>{{ t('funds.panels.inventoryInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row v-if="inventoryData.totalCount > 0">
                            <v-col>
                                <v-list variant="text">
                                    <v-list-item
                                        v-for="item in inventoryData.items"
                                        :key="item"
                                        :title="
                                            t('inventories.searchTemplate', {
                                                descriptionLevel: item.descriptionLevelText,
                                                number: item.number,
                                                chronologicalScope: item.approxmateChronologicalScope,
                                            })
                                        "
                                        :subtitle="item.statusText"
                                        :to="{
                                            name: 'DisplayInventory',
                                            params: {
                                                id: item.systemIdentifier,
                                            },
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
                        <v-row v-if="inventoryData.totalCount > pagerOptions.itemsPerPage">
                            <v-col>
                                <Pager
                                    :initialPage="pagerOptions.pageNumber"
                                    :initialPageSize="pagerOptions.itemsPerPage"
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
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { Message } from '@/models/notification';
import { formatBytesToMB } from '@/helpers/format.helper';

import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { GridOptions, GridResponseModel, PageSize } from '@/models/grid';
import { IFund } from '@/interfaces/fund';
import { IInventory } from '@/interfaces/inventory';
import { Fund } from '@/models/fund';

import fundService from '@/services/fund.service';
import inventoryService from '@/services/inventory.service';

import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import Pager from '@/components/grid/pager.vue';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'DisplayFund',
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

        const panel = ref(['generalInfo', 'fundInfo', 'inventoryInfo', 'startProcess', 'processInfo']);

        const possibleEmptyFields = {
            fundCreatorTitleHistory: '',
            fundCreatorBiographicalHistory: '',
            history: '',
            documentsDescription: '',
            documentsAccessDescription: '',
            relatedFunds: '',
            notes: '',
        };

        const lowClass = 'low';
        const loadClass = ref(false);
        const isLoading = ref(false);

        const breadcrumbItems = computed(() => [
            {
                title: fundData.value.archiveName,
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('funds.fund'),
                disabled: true,
            },
        ]);

        const router = useRouter();

        const goBack = () => {
            router.go(-1);
        };

        const formattedBytes = computed(() => {
            return formatBytesToMB(fundData.value.bytes || 0);
        });

        const fundData = ref<IFund>(new Fund());
        const getFundData = async () => {
            try {
                isLoading.value = true;
                if (props.id || props.externalIdentifier) {
                    fundData.value = await fundService.displayFund(
                        props.id,
                        props.hasExternalSource,
                        props.externalIdentifier
                    );

                    if (!fundData.value.fundCreatorTitleHistory) {
                        possibleEmptyFields.fundCreatorTitleHistory = lowClass;
                    }
                    if (!fundData.value.fundCreatorBiographicalHistory) {
                        possibleEmptyFields.fundCreatorBiographicalHistory = lowClass;
                    }
                    if (!fundData.value.history) {
                        possibleEmptyFields.history = lowClass;
                    }
                    if (!fundData.value.documentsDescription) {
                        possibleEmptyFields.documentsDescription = lowClass;
                    }
                    if (!fundData.value.documentsAccessDescription) {
                        possibleEmptyFields.documentsAccessDescription = lowClass;
                    }
                    if (!fundData.value.relatedFunds) {
                        possibleEmptyFields.relatedFunds = lowClass;
                    }
                    if (!fundData.value.notes) {
                        possibleEmptyFields.notes = lowClass;
                    }

                    if (fundData.value.resultMessage && fundData.value.resultMessage === 'ISDADataCannotBeDisplayed') {
                        message.value = new Message({
                            text: t('warnings.ISDADataCannotBeDisplayed'),
                            display: true,
                            type: 'warning',
                        });
                    }
                } else {
                    message.value = new Message({
                        text: t('error.operationError'),
                        display: true,
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
        });
        const changePage = async (pageNumber: number, pageSize: number) => {
            pagerOptions.value.page = pageNumber;
            pagerOptions.value.itemsPerPage = pageSize;

            await getFundInventoryData();
        };

        const inventoryData = ref<GridResponseModel<IInventory>>(
            new GridResponseModel<IInventory>({ totalCount: 0, items: [] })
        );
        const getFundInventoryData = async () => {
            try {
                isLoading.value = true;
                inventoryData.value = await inventoryService.getFundInventories(
                    pagerOptions.value,
                    fundData.value.systemIdentifier,
                    props.hasExternalSource,
                    props.externalIdentifier
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

        onMounted(async () => {
            window.scrollTo(0, 0);
            await getFundData();
            await getFundInventoryData();
            loadClass.value = true;
        });

        return {
            changePage,

            fundData,
            goBack,
            inventoryData,
            message,
            pagerOptions,
            panel,
            t,
            breadcrumbItems,
            possibleEmptyFields,
            loadClass,
            formattedBytes,
            isLoading,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs-fund.scss';

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
