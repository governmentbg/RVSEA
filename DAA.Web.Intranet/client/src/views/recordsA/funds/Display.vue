<template>
    <Breadcrumbs :items="breadcrumbItems" />
    <v-card ref="fundCard" class="mt-3 col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('funds.display') }}</v-card-title>
        <v-container>
            <v-expansion-panels v-model="panel" multiple>
                <v-expansion-panel value="generalInfo">
                    <v-expansion-panel-title>{{ t('funds.panels.generalInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldArchive"
                                    :label="t('funds.columns.archive')"
                                    v-model="fundData.archiveName"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldNumber"
                                    :label="t('funds.columns.number')"
                                    v-model="fundData.number"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldSystemIdentifier"
                                    :label="t('funds.columns.systemIdentifier')"
                                    v-model="fundData.systemIdentifier"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="fundInfo">
                    <v-expansion-panel-title>{{ t('funds.panels.fundInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldNumber"
                                    :label="t('funds.columns.number')"
                                    v-model="fundData.number"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldStatus"
                                    :label="t('funds.columns.status')"
                                    v-model="fundData.statusText"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDescriptionLevel"
                                    :label="t('funds.columns.descriptionLevel')"
                                    v-model="fundData.descriptionLevelText"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldTitle"
                                    :label="t('funds.columns.title')"
                                    v-model="fundData.title"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldType"
                                    :label="t('funds.columns.type')"
                                    v-model="fundData.typeText"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldAcquisitionMethod"
                                    :label="t('funds.columns.acquisitionMethod')"
                                    v-model="fundData.acquisitionMethodText"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldIndustryType"
                                    :label="t('funds.columns.industryType')"
                                    v-model="fundData.industryTypeText"
                                    :disabled="true"
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
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateMonth"
                                    :label="t('funds.columns.month')"
                                    v-model="fundData.startDateMonth"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateYear"
                                    :label="t('funds.columns.year')"
                                    v-model="fundData.startDateYear"
                                    :disabled="true"
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
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateMonth"
                                    :label="t('funds.columns.month')"
                                    v-model="fundData.endDateMonth"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateYear"
                                    :label="t('funds.columns.year')"
                                    v-model="fundData.endDateYear"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldApproxmateChronologicalScope"
                                    :label="t('funds.columns.approxmateChronologicalScope')"
                                    v-model="fundData.approxmateChronologicalScope"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="externalSource">
                    <v-expansion-panel-title>{{ t('funds.panels.externalSource') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <Switch
                                    :label="t('funds.columns.hasExternalSource')"
                                    v-model="fundData.hasExternalSource"
                                    :large="false"
                                    :showLabel="true"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12">
                                <text-field
                                    name="fldExternalIdentifier"
                                    :label="t('funds.columns.externalIdentifier')"
                                    v-model="fundData.externalIdentifier"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="inventoryInfo">
                    <v-expansion-panel-title>{{ t('funds.panels.inventoryInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text @DOMContentLoaded="getFundData()">
                        <FundInventories
                            :fund="fundData"
                            displayRouteName="DisplayRecordAInventory"
                            :readOnly="true"
                        />
                    </v-expansion-panel-text>
                </v-expansion-panel>
            </v-expansion-panels>
            <v-row class="mt-3">
                <v-col class="d-flex justify-content-center">
                    <v-btn class="cancel" @click="goBack">{{ t('common.back') }}</v-btn>
                </v-col>
            </v-row>
        </v-container>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, inject, Ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { Message } from '@/models/notification';

import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { IFund } from '@/interfaces/fund';
import { Fund } from '@/models/fund';
import fundService from '@/services/fund.service';

import TextField from '@/components/field/text.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import FundInventories from '@/components/inventory/fundInventories.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';


export default defineComponent({
    name: 'DisplayFund',
    components: {
        TextField,
        Switch,
        Breadcrumbs,
        FundInventories,
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
        const breadcrumbItems = ref([
            {
                title: computed(() => fundData.value.archiveName),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('funds.fund'),
                disabled: true,
            },
        ]);

        const panel = ref(['generalInfo', 'fundInfo', 'inventoryInfo']);

        const possibleEmptyFields = {
            fundCreatorTitleHistory: '',
            fundCreatorActivityHistory: '',
            fundCreatorBiographicalHistory: '',
            history: '',
            documentsProvider: '',
            documentsDescription: '',
            languageText: '',
            documentsAccessDescription: '',
            relatedFunds: '',
            notes: '',
        };

        const lowClass = 'low';

        const router = useRouter();
        const goBack = () => {
            router.go(-1);
        };
        
        const fundData = ref<IFund>(new Fund());
        
        const getFundData = async () => {
            try {
                if (props.id || props.externalIdentifier) {
                    fundData.value = await fundService.displayFund(
                        props.id,
                        props.hasExternalSource,
                        props.externalIdentifier
                    );

                    if (!fundData.value.fundCreatorTitleHistory) {
                        possibleEmptyFields.fundCreatorTitleHistory = lowClass;
                    }
                    if (!fundData.value.fundCreatorActivityHistory) {
                        possibleEmptyFields.fundCreatorActivityHistory = lowClass;
                    }
                    if (!fundData.value.fundCreatorBiographicalHistory) {
                        possibleEmptyFields.fundCreatorBiographicalHistory = lowClass;
                    }
                    if (!fundData.value.history) {
                        possibleEmptyFields.history = lowClass;
                    }
                    if (!fundData.value.documentsProvider) {
                        possibleEmptyFields.documentsProvider = lowClass;
                    }
                    if (!fundData.value.documentsDescription) {
                        possibleEmptyFields.documentsDescription = lowClass;
                    }
                    if (!fundData.value.languageText) {
                        possibleEmptyFields.languageText = lowClass;
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
            }
        };

        
        onMounted(async () => {
            await getFundData();
        });

        return {
            t,
            fundData,
            goBack,
            message,
            panel,
            breadcrumbItems,
            possibleEmptyFields,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/index.scss';
@import '@/assets/styles/breadcrumbs-fund.scss';

.low,
:deep(.low div),
:deep(.low textarea) {
    height: 50px;
    margin-bottom: 25px;
}
</style>
