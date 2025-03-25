<template>
    <Breadcrumbs :items="breadcrumbItems" />
    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('funds.edit') }}</v-card-title>
        <Form @submit="submitFundData" @invalid-submit="showHintMessageForRequiredFields">
            <v-container>
                <v-expansion-panels v-model="panel" multiple>
                    <v-expansion-panel value="general">
                        <v-expansion-panel-title>{{ t('funds.panels.general') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <label class="required" for="fldArchive">{{ t('funds.columns.archive') }}</label>
                                    <Dropdown
                                        v-model="fundData.archiveId"
                                        name="fldArchive"
                                        :label="t('funds.columns.archive')"
                                        labelProp="label"
                                        valueProp="id"
                                        :items="archives"
                                        :disabled="fldArchiveReadOnly || isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label class="required" for="fldNumberArray">{{
                                        t('funds.columns.numberArray')
                                    }}</label>
                                    <Dropdown
                                        v-model="fundData.numberArray"
                                        name="fldNumberArray"
                                        :label="t('funds.columns.numberArray')"
                                        :items="fundArrays"
                                        :disabled="fldNumberReadOnly || isRegistrarStep"
                                        :emptable="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12" v-if="fldNumberReadOnly">
                                    <text-field
                                        name="fldNumber"
                                        :label="t('funds.columns.number')"
                                        v-model="fundData.number"
                                        :readonly="true"
                                    />
                                </v-col>
                                <v-col class="col-12" v-else>
                                    <text-field
                                        name="fldNumberNumeric"
                                        :readonly="!isRegistrarStep"
                                        :label="t('funds.columns.number')"
                                        v-model="fundData.numberNumeric"
                                        validation="integer"
                                        appendButtonIcon="mdi-numeric"
                                        :appendButtonTooltip="t('funds.buttons.getNumberTooltip')"
                                        appendButtonCssClass="floatingBtnIcon"
                                        @click:append="getFundNumber"
                                    >
                                    </text-field>
                                </v-col>
                                <!-- <v-col
                                    class="col-2"
                                    v-if="
                                        !fldNumberReadOnly
                                        && activeProcessData
                                        && activeProcessData.activeProcessStepTypeId === processStep.Registration
                                    "
                                >
                                    <v-btn
                                        icon
                                        @click="getFundNumber"
                                        :loading="showNumberLoading"
                                    >
                                        <v-icon>mdi-counter</v-icon>
                                        <v-tooltip activator="parent" location="bottom">
                                            {{ t('funds.button.getNumberTooltip') }}
                                        </v-tooltip>
                                    </v-btn>
                                </v-col> -->
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldTitle"
                                        :label="t('funds.columns.title')"
                                        v-model="fundData.title"
                                        validation="required"
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldDescriptionLevel">{{ t('funds.columns.descriptionLevel') }}</label>
                                    <Dropdown
                                        v-model="fundData.descriptionLevelCode"
                                        name="fldDescriptionLevel"
                                        :label="t('funds.columns.descriptionLevel')"
                                        labelProp="label"
                                        valueProp="code"
                                        :items="descriptionLevels"
                                        :disabled="fldDescriptionLevelReadOnly || isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldType">{{ t('funds.columns.type') }}</label>
                                    <Dropdown
                                        v-model="fundData.typeCode"
                                        name="fldType"
                                        :label="t('funds.columns.type')"
                                        :items="fundTypes"
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
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
                                    <label for="fldAcquisitionMethod">{{ t('funds.columns.acquisitionMethod') }}</label>
                                    <Dropdown
                                        v-model="fundData.acquisitionMethodId"
                                        name="fldAcquisitionMethod"
                                        :label="t('funds.columns.acquisitionMethod')"
                                        labelProp="label"
                                        valueProp="id"
                                        :multiselect="false"
                                        :items="acquisitionMethods"
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldIndustryType">{{ t('funds.columns.industryType') }}</label>
                                    <Dropdown
                                        v-model="fundData.industryTypeCodes"
                                        name="fldIndustryType"
                                        :label="t('funds.columns.industryType')"
                                        labelProp="label"
                                        valueProp="code"
                                        :multiselect="true"
                                        :items="industryTypes"
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="chronologicalScope">
                        <v-expansion-panel-title>{{ t('funds.panels.chronologicalScope') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <Switch
                                        v-model="fundData.hasNoChronologicalScope"
                                        :label="t('funds.columns.chronologicalScope')"
                                        :large="false"
                                        :showLabel="true"
                                        :disabled="isRegistrarStep"
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
                                        :disabled="fundData.hasNoChronologicalScope || isRegistrarStep"
                                        :validation="startDayValidationString"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldStartDateMonth"
                                        :label="t('funds.columns.month')"
                                        v-model="fundData.startDateMonth"
                                        :disabled="fundData.hasNoChronologicalScope || isRegistrarStep"
                                        validation="numeric|min_value:1|max_value:12"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldStartDateYear"
                                        :label="t('funds.columns.year')"
                                        v-model="fundData.startDateYear"
                                        :disabled="fundData.hasNoChronologicalScope || isRegistrarStep"
                                        :validation="
                                            !fundData.hasNoChronologicalScope
                                                ? 'required|numeric|min_value:1000|max_value:2200'
                                                : 'numeric|min_value:1000|max_value:2200'
                                        "
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
                                        :disabled="fundData.hasNoChronologicalScope || isRegistrarStep"
                                        :validation="endDayValidationString"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldEndDateMonth"
                                        :label="t('funds.columns.month')"
                                        v-model="fundData.endDateMonth"
                                        :disabled="fundData.hasNoChronologicalScope || isRegistrarStep"
                                        validation="numeric|min_value:1|max_value:12"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldEndDateYear"
                                        :label="t('funds.columns.year')"
                                        v-model="fundData.endDateYear"
                                        :disabled="fundData.hasNoChronologicalScope || isRegistrarStep"
                                        :validation="
                                            !fundData.hasNoChronologicalScope
                                                ? 'required|numeric|min_value:1000|max_value:2200'
                                                : 'numeric|min_value:1000|max_value:2200'
                                        "
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldApproxmateChronologicalScope"
                                        :label="t('funds.columns.approxmateChronologicalScope')"
                                        v-model="date"
                                        :readonly="true"
                                    />
                                    <label style="color: red">{{ chronologicalScopeLabelText }}</label>
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="storage">
                        <v-expansion-panel-title>{{ t('funds.panels.storage') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldBytes"
                                        :label="t('funds.columns.bytes')"
                                        v-model="formattedBytes"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldLinearMeters"
                                        :label="t('funds.columns.linearMeters')"
                                        v-model="fundData.linearMeters"
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row> -->
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldInventoryCount"
                                        :label="t('funds.columns.inventoryCount')"
                                        v-model="fundData.inventoryCount"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldArchivalEntityCount"
                                        :label="t('funds.columns.archivalEntityCount')"
                                        v-model="fundData.archivalEntityCount"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
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
                                    <label for="fldFileType">{{ t('funds.columns.fileType') }}</label>
                                    <Dropdown
                                        v-model="fundData.fileTypeCodes"
                                        name="fldFileType"
                                        :label="t('funds.columns.fileType')"
                                        labelProp="label"
                                        valueProp="code"
                                        :multiselect="true"
                                        :items="fileTypes"
                                        :disabled="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldOtherMetrics"
                                        :label="t('funds.columns.otherMetrics')"
                                        v-model="fundData.otherMetrics"
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="additional">
                        <v-expansion-panel-title>{{ t('funds.panels.additional') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldFundCreatorTitleHistory"
                                        :label="t('funds.columns.fundCreatorTitleHistory')"
                                        v-model="fundData.fundCreatorTitleHistory"
                                        auto-grow
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldFundCreatorActivityHistory"
                                        :label="t('funds.columns.fundCreatorActivityHistory')"
                                        v-model="fundData.fundCreatorActivityHistory"
                                        auto-grow
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldFundCreatorBiographicalHistory"
                                        :label="t('funds.columns.fundCreatorBiographicalHistory')"
                                        v-model="fundData.fundCreatorBiographicalHistory"
                                        auto-grow
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldHistory"
                                        :label="t('funds.columns.history')"
                                        v-model="fundData.history"
                                        auto-grow
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldDocumentsProvider"
                                        :label="t('funds.columns.documentsProvider')"
                                        v-model="fundData.documentsProvider"
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldDocumentsDescription"
                                        :label="t('funds.columns.documentsDescription')"
                                        v-model="fundData.documentsDescription"
                                        auto-grow
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldLanguage">{{ t('funds.columns.language') }}</label>
                                    <Dropdown
                                        v-model="fundData.languageCodes"
                                        name="fldLanguage"
                                        :label="t('funds.columns.language')"
                                        labelProp="label"
                                        valueProp="code"
                                        :multiselect="true"
                                        :items="languages"
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldDocumentsAccessDescription"
                                        :label="t('funds.columns.documentsAccessDescription')"
                                        v-model="fundData.documentsAccessDescription"
                                        auto-grow
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldRelatedFunds"
                                        :label="t('funds.columns.relatedFunds')"
                                        v-model="fundData.relatedFunds"
                                        auto-grow
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldNotes"
                                        :label="t('funds.columns.notes')"
                                        v-model="fundData.notes"
                                        auto-grow
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="availability">
                        <v-expansion-panel-title>{{ t('funds.panels.availability') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldValuableDocumentsInventoryCount"
                                        :label="t('funds.columns.valuableDocumentsInventoryCount')"
                                        v-model="fundData.valuableDocumentsInventoryCount"
                                        validation="numeric"
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldInvaluableDocumentsInventoryCount"
                                        :label="t('funds.columns.invaluableDocumentsInventoryCount')"
                                        v-model="fundData.invaluableDocumentsInventoryCount"
                                        validation="numeric"
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldEnrolledBytes"
                                        :label="t('funds.columns.enrolledBytes')"
                                        v-model="formattedEnrolledBytes"
                                        :readonly="true"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldDeductedBytes"
                                        :label="t('funds.columns.deductedBytes')"
                                        v-model="formattedDeductedBytes"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldEnrolledInventoryCount"
                                        :label="t('funds.columns.enrolledInventoryCount')"
                                        v-model="fundData.enrolledInventoryCount"
                                        validation="numeric"
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldDeductedInventoryCount"
                                        :label="t('funds.columns.deductedInventoryCount')"
                                        v-model="fundData.deductedInventoryCount"
                                        validation="numeric"
                                        :readonly="isRegistrarStep"
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
                                        :disabled="true"
                                        :showLabel="true"
                                    />
                                </v-col>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldExternalIdentifier"
                                        :label="t('funds.columns.externalIdentifier')"
                                        v-model="fundData.externalIdentifier"
                                        :validation="fundData.hasExternalSource ? 'required|numeric' : 'numeric'"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                </v-expansion-panels>
                <v-row class="mt-3">
                    <v-col class="d-flex gap-2 justify-content-center">
                        <submit-btn type="submit"
                            >{{ t('common.save') }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('common.saveTooltip') }}
                            </v-tooltip>
                        </submit-btn>
                        <cancel-btn @click="goBack"
                            >{{ t('common.cancel') }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('funds.buttons.cancelTooltip') }}
                            </v-tooltip>
                        </cancel-btn>
                    </v-col>
                </v-row>
            </v-container>
        </Form>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, onMounted, inject, Ref, computed, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
//import { useRedirect } from '@/helpers/router.helper';
import { Message } from '@/models/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { IProcess } from '@/interfaces/process';
import { BusinessObjectType } from '@/models/grid';
import { ProcessType, ProcessStep } from '@/enums/process';
import { Status } from '@/enums/status';
import { IFund } from '@/interfaces/fund';
import { Fund, FundDraft } from '@/models/fund';
import { IDropdownOption } from '@/interfaces/dropdown';
import { NomenclatureCode } from '@/enums/nomenclature';
import fundService from '@/services/fund.service';
import dropdownService from '@/services/dropdown.service';
import processService from '@/services/process.service';

import { Form } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import Dropdown from '@/components/dropdown/dropdown.vue';
import {
    transformMonth,
    stringifyYear,
    stringifyDay,
    validateDay,
    formatBytesToMB,
    formatApproximateChronologicalScope,
} from '@/helpers/format.helper';
import { isChronologicalScopeFull, isProcessStepType, isStartDateBeforeEndDate } from '@/helpers/validate.helper';
import numberService from '@/services/number.service';
import { useRedirectWithId } from '@/helpers/router.helper';

export default defineComponent({
    name: 'EditArchive',
    components: {
        Form,
        TextField,
        TextAreaField,
        Switch,
        Dropdown,
        Breadcrumbs,
    },
    props: {
        id: {
            type: String,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const fldArchiveReadOnly = computed(
            () =>
                activeProcessData.value &&
                (activeProcessData.value?.processTypeId === ProcessType.EditData ||
                    activeProcessData.value?.processTypeId === ProcessType.EditFundData ||
                    activeProcessData.value?.processTypeId === ProcessType.RefineData)
        );
        const fldNumberReadOnly = computed(
            () =>
                activeProcessData.value &&
                (activeProcessData.value?.processTypeId === ProcessType.EditData ||
                    activeProcessData.value?.processTypeId === ProcessType.EditFundData ||
                    activeProcessData.value?.processTypeId === ProcessType.RefineData)
        );
        const fldDescriptionLevelReadOnly = computed(
            () =>
                activeProcessData.value &&
                (activeProcessData.value?.processTypeId === ProcessType.EditData ||
                    activeProcessData.value?.processTypeId === ProcessType.EditFundData ||
                    activeProcessData.value?.processTypeId === ProcessType.RefineData)
        );
        const fldStatusReadOnly = computed(
            () =>
                activeProcessData.value &&
                (activeProcessData.value?.processTypeId === ProcessType.EditData ||
                    activeProcessData.value?.processTypeId === ProcessType.EditFundData ||
                    activeProcessData.value?.processTypeId === ProcessType.RefineData)
        );
        const showNumberLoading = ref(false);

        const router = useRouter();
        const goBack = () => {
            //router.go(-1);
            useRedirectWithId(router, 'DisplayFund', props.id);
        };

        const panel = ref(['general', 'additional', 'availability', 'chronologicalScope', 'storage']);
        const startDayValidationString = computed(
            () =>
                `numeric|min_value:1|max_value:${validateDay(
                    fundData.value.startDateMonth,
                    fundData.value.startDateYear
                )}`
        );
        const endDayValidationString = computed(
            () =>
                `numeric|min_value:1|max_value:${validateDay(fundData.value.endDateMonth, fundData.value.endDateYear)}`
        );

        const archives = ref<IDropdownOption[]>([]);
        const getArchives = async () => {
            archives.value = await dropdownService.getArchives();
        };

        const fundArrays = ref<IDropdownOption[]>([]);
        const getFundArrays = async () => {
            fundArrays.value = await dropdownService.getFundArrays();
        };

        const fundTypes = ref<IDropdownOption[]>([]);
        const getFundTypes = async () => {
            fundTypes.value = await dropdownService.getFundTypes();
        };

        const descriptionLevels = ref<IDropdownOption[]>([]);
        const getDescriptionLevels = async () => {
            descriptionLevels.value = await dropdownService.getFundDescriptionLevels();
        };

        const acquisitionMethods = ref<IDropdownOption[]>([]);
        const getAcquisitionMethods = async () => {
            acquisitionMethods.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.AcquisitionMethod);
        };

        const industryTypes = ref<IDropdownOption[]>([]);
        const getIndustryTypes = async () => {
            industryTypes.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.IndustryType);
        };

        const fileTypes = ref<IDropdownOption[]>([]);
        const getFileTypes = async () => {
            fileTypes.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.FileType);
        };

        const languages = ref<IDropdownOption[]>([]);
        const getLanguages = async () => {
            languages.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.Language);
        };

        const fundData = ref<IFund>(new Fund());
        const activeProcessData = ref<IProcess>();

        // const registrarSteps = [
        //     ProcessStep.AddInventory_Registration,                              // 70
        //     ProcessStep.AddInventoryRaw_Registration,                           // 83
        //     ProcessStep.AddFundAndInventory_Registration,                       // 96
        //     ProcessStep.ProcessFundWithRawInventory_RegisterInventories,        // 210
        //     ProcessStep.ProcessRawFundWithRawInventory_RegisterInventories,     // 212
        //     ProcessStep.ReconstructFundData_Registration,                       // 233
        //     ProcessStep.Registration,                                           // 1014

        // ];

        const isRegistrarStep = computed(
            () =>
                activeProcessData.value &&
                isProcessStepType(
                    activeProcessData.value,
                    ProcessStep.AddInventory_Registration, // 70
                    ProcessStep.AddInventoryRaw_Registration, // 83
                    ProcessStep.AddFundAndInventory_Registration, // 96
                    ProcessStep.ProcessFundWithRawInventory_RegisterInventories, // 210
                    ProcessStep.ProcessRawFundWithRawInventory_RegisterInventories, // 212
                    ProcessStep.ReconstructFundData_Registration, // 233
                    ProcessStep.Registration // 1014
                )
        );

        const formattedBytes = computed(() => {
            return formatBytesToMB(fundData.value.bytes || 0);
        });
        const formattedEnrolledBytes = computed(() => {
            return formatBytesToMB(fundData.value.enrolledBytes || 0);
        });
        const formattedDeductedBytes = computed(() => {
            return formatBytesToMB(fundData.value.deductedBytes || 0);
        });

        const getFundData = async () => {
            try {
                fundData.value = await fundService.displayFund(props.id);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const getActiveProcessData = async () => {
            try {
                if (props.id) {
                    activeProcessData.value = await processService.getCurrentActiveProcess(
                        BusinessObjectType.fund,
                        props.id
                    );
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
        const breadcrumbItems = computed(() => getBreadcrumbs());

        const getBreadcrumbs = () => {
            if (activeProcessData.value?.processTypeId) {
                return [
                    {
                        title: fundData.value.archiveName,
                        disabled: false,
                        to: { name: 'Home' },
                    },
                    {
                        title: t('funds.fund'),
                        disabled: false,
                        to: {
                            name: 'DisplayFund',
                            params: {
                                id: fundData.value.systemIdentifier,
                            },
                            query: {
                                hasExternalSource: fundData.value.hasExternalSource,
                                externalIdentifier: fundData.value.externalIdentifier,
                            },
                        },
                    },
                    {
                        title: activeProcessData.value.processTypeTitle,
                        disabled: true,
                    },
                ];
            } else
                return [
                    {
                        title: fundData.value.archiveName,
                        disabled: false,
                        to: { name: 'Home' },
                    },
                    {
                        title: t('funds.title'),
                        disabled: false,
                        to: { name: 'Funds' },
                    },
                    {
                        title: t('funds.edit'),
                        disabled: true,
                    },
                ];
        };

        const showHintMessageForRequiredFields = () => {
            message.value = new Message({
                text: t('common.requiredFields'),
                display: true,
            });
        };

        const submitFundData = async () => {
            if (fundData.value) {
                try {
                    const fundDraft = new FundDraft(fundData.value);
                    fundDraft.isCurrent = true;
                    fundDraft.readOnly = false;
                    if (fundData.value.numberNumeric) {
                        //fundDraft.number = fundData.value.numberNumeric.toString() + (fundData.value.numberArray ?? '');
                        fundDraft.number = numberService.formatEntityNumber(
                            fundData.value.numberNumeric,
                            fundData.value.numberArray
                        );
                    } else {
                        fundDraft.number = '';
                    }
                    fundDraft.approxmateChronologicalScope = date.value;
                    //TODO да се прави от съответния процес?
                    switch (activeProcessData.value?.processTypeId) {
                        case ProcessType.EditData:
                            fundDraft.statusCode = Status.Modified;
                            break;
                        case ProcessType.EditFundData:
                            fundDraft.statusCode = Status.NameChanged;
                            break;
                        case ProcessType.RefineData:
                            fundDraft.statusCode = Status.Refined;
                            break;
                    }

                    const result = await fundService.updateFund(fundDraft);
                    if (result.data.message) {
                        message.value = new Message({
                            text: result.data.message,
                            display: true,
                            type: 'warning',
                        });
                    } else {
                        message.value = new Message({
                            text: t('common.successfullyEdit'),
                            display: true,
                            type: 'success',
                            timeout: 5000,
                        });
                    }
                    goBack();
                } catch (error: unknown) {
                    const errorResult = error as ResponseResult;
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                        display: true,
                    });
                }
            }
        };

        const approxmateChronologicalScopeString = (): string => {
            let date = '';
            if (fundData.value != null) {
                if (fundData.value.startDateMonth) {
                    fundData.value.startDateMonth = parseInt(fundData.value.startDateMonth.toString());
                }

                if (fundData.value.endDateMonth) {
                    fundData.value.endDateMonth = parseInt(fundData.value.endDateMonth.toString());
                }

                const startDay = fundData.value.startDateDay;
                const startMonth = fundData.value.startDateMonth;
                const startYear = fundData.value.startDateYear;
                const endDay = fundData.value.endDateDay;
                const endMonth = fundData.value.endDateMonth;
                const endYear = fundData.value.endDateYear;

                if (!isChronologicalScopeFull(startDay, startMonth, startYear, endDay, endMonth, endYear)) {
                    date = '';
                } else if (!isStartDateBeforeEndDate(startDay, startMonth, startYear, endDay, endMonth, endYear)) {
                    date = '';
                } else {
                    const startDate = `${
                        startDay == undefined || startDay.toString() == '' ? '' : stringifyDay(startDay.toString())
                    } ${startMonth == undefined ? '' : transformMonth(startMonth.toString() as string)} ${
                        startYear == undefined || startYear.toString() == '' ? '' : stringifyYear(startYear.toString())
                    }`;
                    const endDate = `${
                        endDay == undefined || endDay.toString() == '' ? '' : stringifyDay(endDay.toString())
                    } ${endMonth == undefined ? '' : transformMonth(endMonth.toString() as string)} ${
                        endYear == undefined || endYear.toString() == '' ? '' : stringifyYear(endYear.toString())
                    }`;

                    if (startDate.trim() != '' && endDate.trim() != '') {
                        date = `${startDate} - ${endDate}`;
                    } else if (startDate.trim() != '') {
                        date = startDate;
                    } else if (endDate.trim() != '') {
                        date = endDate;
                    } else {
                        date = '';
                    }
                }
            }
            if (fundData.value.hasNoChronologicalScope) {
                date = 'Б.Д.';
                fundData.value.startDateDay = undefined;
                fundData.value.startDateMonth = undefined;
                fundData.value.startDateYear = undefined;
                fundData.value.endDateDay = undefined;
                fundData.value.endDateMonth = undefined;
                fundData.value.endDateYear = undefined;
            }
            fundData.value.approxmateChronologicalScope = date;
            return date.toString();
        };

        const getFundNumber = async () => {
            try {
                showNumberLoading.value = true;
                fundData.value.numberNumeric = await numberService.getFundNumberNumeric(
                    fundData.value.archiveId!,
                    fundData.value.descriptionLevelCode!,
                    fundData.value.numberArray!
                );
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('funds.errors.gettingLastNumber'),
                    display: true,
                });
            } finally {
                showNumberLoading.value = false;
            }
        };

        const date = computed(() => formatApproximateChronologicalScope(approxmateChronologicalScopeString()));
        const chronologicalScopeLabelText = computed(() => {
            if (
                !isChronologicalScopeFull(
                    fundData.value.startDateDay,
                    fundData.value.startDateMonth,
                    fundData.value.startDateYear,
                    fundData.value.endDateDay,
                    fundData.value.endDateMonth,
                    fundData.value.endDateYear
                )
            ) {
                return t('common.isChronologicalScopeFullLabel');
            } else if (
                !isStartDateBeforeEndDate(
                    fundData.value.startDateDay,
                    fundData.value.startDateMonth,
                    fundData.value.startDateYear,
                    fundData.value.endDateDay,
                    fundData.value.endDateMonth,
                    fundData.value.endDateYear
                )
            ) {
                return t('common.isStartDateBeforeEndDateLabel');
            }
            return '';
        });
        function endDateIsAfterStartDate() {
            let ok = true;
            if (
                fundData.value.startDateDay != undefined &&
                fundData.value.startDateMonth != undefined &&
                fundData.value.endDateDay != undefined &&
                fundData.value.endDateMonth != undefined
            ) {
                if (fundData.value.endDateYear == fundData.value.startDateYear) {
                    if (
                        fundData.value.startDateMonth > fundData.value.endDateMonth ||
                        (fundData.value.startDateMonth == fundData.value.endDateMonth &&
                            fundData.value.startDateDay > fundData.value.endDateDay)
                    ) {
                        ok = false;
                    }
                }
                if (ok === false) {
                    message.value = new Message({
                        text: t('common.checkDate'),
                        display: true,
                    });
                }
            }
        }
        watch(
            () => date.value,
            () => {
                if (
                    fundData.value.startDateYear &&
                    fundData.value.endDateYear &&
                    fundData.value.endDateYear.toString().length == 4
                )
                    if (fundData.value.endDateYear < fundData.value.startDateYear) {
                        message.value = new Message({
                            text: t('common.checkDate'),
                            display: true,
                        });
                    } else endDateIsAfterStartDate();
            }
        );

        onMounted(async () => {
            window.scrollTo(0, 0);
            await getArchives();
            await getFundArrays();
            await getFundTypes();
            await getDescriptionLevels();
            await getAcquisitionMethods();
            await getIndustryTypes();
            await getFileTypes();
            await getLanguages();
            await getFundData();
            await getActiveProcessData();
        });

        return {
            activeProcessData,
            t,
            panel,
            archives,
            fundArrays,
            breadcrumbItems,
            fundTypes,
            descriptionLevels,
            acquisitionMethods,
            industryTypes,
            fileTypes,
            languages,
            fundData,
            fldArchiveReadOnly,
            fldNumberReadOnly,
            fldDescriptionLevelReadOnly,
            fldStatusReadOnly,
            processStep: ProcessStep,
            goBack,
            showHintMessageForRequiredFields,
            submitFundData,
            approxmateChronologicalScopeString,
            date,
            getFundNumber,
            showNumberLoading,
            startDayValidationString,
            endDayValidationString,
            isRegistrarStep,
            chronologicalScopeLabelText,
            formattedBytes,
            formattedEnrolledBytes,
            formattedDeductedBytes,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs-fund.scss';

:deep(.floatingBtnIcon) {
    margin: 0px 0px !important;
}
</style>
