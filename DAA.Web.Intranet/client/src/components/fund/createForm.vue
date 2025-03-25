<template>
    <v-container>
        <v-expansion-panels v-model="panel" multiple>
            <v-expansion-panel value="general">
                <v-expansion-panel-title>{{ t('funds.panels.general') }}</v-expansion-panel-title>
                <v-expansion-panel-text>
                    <!-- <v-row>
                <v-col class="col-12 mb-10">
                  <label for="fldExisingFund">{{ t('funds.select') }}</label>
                  <AsyncDropdown
                    name="fldExisingFund"
                    :label="t('funds.select')"
                    labelProp="name"
                    valueProp="externalIdentifier"
                    :itemsFunction="getExternalData"
                    @change="changeExternalData" />
                </v-col>
              </v-row> -->
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
                                :disabled="disableArchive"
                                :required="true"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12">
                            <label class="required" for="fldNumberArray">{{ t('funds.columns.numberArray') }}</label>
                            <Dropdown
                                v-model="fundData.numberArray"
                                name="fldNumberArray"
                                :label="t('funds.columns.numberArray')"
                                :items="fundArrays"
                                @change="getFundArrayCounter"
                                :emptable="true"
                            />
                        </v-col>
                    </v-row>
                    <!-- <v-row>
                <v-col class="col-12">
                  <text-field
                    name="fldNumber"
                    :label="t('funds.columns.number')"
                    v-model="fundData.number"
                    validation="required"
                  />
                </v-col>
              </v-row> -->
                    <v-row>
                        <v-col class="col-12">
                            <text-field
                                name="fldTitle"
                                :label="t('funds.columns.title')"
                                v-model="fundData.title"
                                validation="required"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12">
                            <label class="required" for="fldDescriptionLevel">{{
                                t('funds.columns.descriptionLevel')
                            }}</label>
                            <Dropdown
                                v-model="fundData.descriptionLevelCode"
                                name="fldDescriptionLevel"
                                :label="t('funds.columns.descriptionLevel')"
                                labelProp="label"
                                valueProp="code"
                                :items="descriptionLevels"
                                :disabled="disableDescLevel"
                                :required="true"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12">
                            <label :class="[typeCodeIsRequired ? 'required' : '']" for="fldType">{{
                                t('funds.columns.type')
                            }}</label>
                            <Dropdown
                                v-model="fundData.typeCode"
                                name="fldType"
                                :label="t('funds.columns.type')"
                                :items="fundTypes"
                                :required="typeCodeIsRequired"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12">
                            <label for="fldAcquisitionMethod">{{ t('funds.columns.acquisitionMethod') }}</label>
                            <!-- <Dropdown
								v-model="fundData.acquisitionMethodCodes"
								name="fldAcquisitionMethod"
								:label="t('funds.columns.acquisitionMethod')"
								labelProp="label"
								valueProp="code"
								:multiselect="true"
								:items="acquisitionMethods"
							/> -->
                            <Dropdown
                                v-model="fundData.acquisitionMethodId"
                                name="fldAcquisitionMethod"
                                :label="t('funds.columns.acquisitionMethod')"
                                labelProp="label"
                                valueProp="id"
                                :multiselect="false"
                                :items="acquisitionMethods"
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
                                :disabled="fundData.hasNoChronologicalScope"
                                :validation="startDayValidationString"
                            />
                        </v-col>
                        <v-col class="col-12 col-lg-4">
                            <text-field
                                name="fldStartDateMonth"
                                :label="t('funds.columns.month')"
                                v-model="fundData.startDateMonth"
                                :disabled="fundData.hasNoChronologicalScope"
                                validation="numeric|min_value:1|max_value:12"
                            />
                        </v-col>
                        <v-col class="col-12 col-lg-4">
                            <text-field
                                name="fldStartDateYear"
                                :label="t('funds.columns.year')"
                                v-model="fundData.startDateYear"
                                :disabled="fundData.hasNoChronologicalScope"
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
                                :validation="endDayValidationString"
                                :disabled="fundData.hasNoChronologicalScope"
                            />
                        </v-col>
                        <v-col class="col-12 col-lg-4">
                            <text-field
                                name="fldEndDateMonth"
                                :label="t('funds.columns.month')"
                                v-model="fundData.endDateMonth"
                                validation="numeric|min_value:1|max_value:12"
                                :disabled="fundData.hasNoChronologicalScope"
                            />
                        </v-col>
                        <v-col class="col-12 col-lg-4">
                            <text-field
                                name="fldEndDateYear"
                                :label="t('funds.columns.year')"
                                v-model="fundData.endDateYear"
                                :disabled="fundData.hasNoChronologicalScope"
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
                                :disabled="true"
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
                                v-model="fundData.bytes"
                                :disabled="true"
                            />
                        </v-col>
                    </v-row>
                    <!-- <v-row>
                        <v-col class="col-12">
                            <text-field
                                name="fldLinearMeters"
                                :label="t('funds.columns.linearMeters')"
                                v-model="fundData.linearMeters"
                                validation="float"
                            />
                        </v-col>
                    </v-row> -->
                    <v-row>
                        <v-col class="col-12">
                            <text-field
                                name="fldInventoryCount"
                                :label="t('funds.columns.inventoryCount')"
                                v-model="fundData.inventoryCount"
                                :disabled="true"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12">
                            <text-field
                                name="fldArchivalEntityCount"
                                :label="t('funds.columns.archivalEntityCount')"
                                v-model="fundData.archivalEntityCount"
                                :disabled="true"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12">
                            <text-field
                                name="fldDocumentCount"
                                :label="t('funds.columns.documentCount')"
                                v-model="fundData.documentCount"
                                :disabled="true"
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
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12">
                            <text-area-field
                                name="fldFundCreatorActivityHistory"
                                :label="t('funds.columns.fundCreatorActivityHistory')"
                                v-model="fundData.fundCreatorActivityHistory"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12">
                            <text-area-field
                                name="fldFundCreatorBiographicalHistory"
                                :label="t('funds.columns.fundCreatorBiographicalHistory')"
                                v-model="fundData.fundCreatorBiographicalHistory"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12">
                            <text-area-field
                                name="fldHistory"
                                :label="t('funds.columns.history')"
                                v-model="fundData.history"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12">
                            <text-field
                                name="fldDocumentsProvider"
                                :label="t('funds.columns.documentsProvider')"
                                v-model="fundData.documentsProvider"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12">
                            <text-area-field
                                name="fldDocumentsDescription"
                                :label="t('funds.columns.documentsDescription')"
                                v-model="fundData.documentsDescription"
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
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12">
                            <text-area-field
                                name="fldDocumentsAccessDescription"
                                :label="t('funds.columns.documentsAccessDescription')"
                                v-model="fundData.documentsAccessDescription"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12">
                            <text-area-field
                                name="fldRelatedFunds"
                                :label="t('funds.columns.relatedFunds')"
                                v-model="fundData.relatedFunds"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12">
                            <text-area-field
                                name="fldNotes"
                                :label="t('funds.columns.notes')"
                                v-model="fundData.notes"
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
                            />
                        </v-col>
                        <v-col class="col-12 col-lg-6">
                            <text-field
                                name="fldInvaluableDocumentsInventoryCount"
                                :label="t('funds.columns.invaluableDocumentsInventoryCount')"
                                v-model="fundData.invaluableDocumentsInventoryCount"
                                validation="numeric"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12 col-lg-6">
                            <text-field
                                name="fldEnrolledBytes"
                                :label="t('funds.columns.enrolledBytes')"
                                v-model="fundData.enrolledBytes"
                                :disabled="true"
                            />
                        </v-col>
                        <v-col class="col-12 col-lg-6">
                            <text-field
                                name="fldDeductedBytes"
                                :label="t('funds.columns.deductedBytes')"
                                v-model="fundData.deductedBytes"
                                :disabled="true"
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
                            />
                        </v-col>
                        <v-col class="col-12 col-lg-6">
                            <text-field
                                name="fldDeductedInventoryCount"
                                :label="t('funds.columns.deductedInventoryCount')"
                                v-model="fundData.deductedInventoryCount"
                                validation="numeric"
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
                                :disabled="true"
                            />
                        </v-col>
                    </v-row>
                </v-expansion-panel-text>
            </v-expansion-panel>
        </v-expansion-panels>
    </v-container>
</template>

<script lang="ts">
import { defineComponent, ref, onMounted, PropType, watch, computed, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { IFund } from '@/interfaces/fund';
import { IDropdownOption } from '@/interfaces/dropdown';
import { NomenclatureCode } from '@/enums/nomenclature';
import dropdownService from '@/services/dropdown.service';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import Dropdown from '@/components/dropdown/dropdown.vue';
import {
    transformMonth,
    stringifyYear,
    stringifyDay,
    validateDay,
    formatApproximateChronologicalScope,
} from '@/helpers/format.helper';
import { isChronologicalScopeFull, isStartDateBeforeEndDate } from '@/helpers/validate.helper';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { FundDescriptionLevel } from '@/enums/fund';

export default defineComponent({
    name: 'CreateFundForm',
    components: {
        TextField,
        TextAreaField,
        Switch,
        Dropdown,
    },
    props: {
        modelValue: {
            type: Object as PropType<IFund>,
            required: true,
        },
        disableArchive: {
            type: Boolean,
            default: false,
        },
        disableDescLevel: {
            type: Boolean,
            default: false,
        },
        type: {
            type: String,
        },
    },
    emits: ['update:modelValue', 'change', 'chronologicalScopeLabelText'],
    setup(props, { emit }) {
        const fundData = ref(props.modelValue);
        const { t } = useI18n();
        const panel = ref(['general', 'additional', 'availability', 'chronologicalScope', 'storage']);
        const message = inject('notificationMessage') as Ref<IMessage>;
        const archives = ref<IDropdownOption[]>([]);
        const getArchives = () => {
            dropdownService.getArchives().then((data) => (archives.value = data));
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

        const typeCodeIsRequired = computed(
            () =>
                fundData.value.descriptionLevelCode != FundDescriptionLevel.memory &&
                fundData.value.descriptionLevelCode != FundDescriptionLevel.chp
        );

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

        const fundArrays = ref<IDropdownOption[]>([]);
        const getFundArrays = () => {
            dropdownService.getFundArrays().then((data) => (fundArrays.value = data));
        };
        const getFundArrayCounter = (option: IDropdownOption) => {
            console.log(option);
        };

        const fundTypes = ref<IDropdownOption[]>([]);
        const getFundTypes = () => {
            dropdownService.getFundTypes().then((data) => (fundTypes.value = data));
        };

        const getCHPFundTypes = () => {
            dropdownService.getFundTypesReducedForCHP().then((data) => (fundTypes.value = data));
        };

        const descriptionLevels = ref<IDropdownOption[]>([]);
        const getDescriptionLevels = () => {
            dropdownService.getFundDescriptionLevels().then((data) => {
                let descLevels = data;
                if (props.type) {
                    descLevels = descLevels.filter((x) =>
                        props.type === 'Fund'
                            ? x.code === FundDescriptionLevel.fund
                            : x.code !== FundDescriptionLevel.fund
                    );
                }

                descriptionLevels.value = descLevels;
            });
        };

        const acquisitionMethods = ref<IDropdownOption[]>([]);
        const getAcquisitionMethods = () => {
            dropdownService
                .getNomenclaturesByCode(NomenclatureCode.AcquisitionMethod)
                .then((data) => (acquisitionMethods.value = data));
        };

        const industryTypes = ref<IDropdownOption[]>([]);
        const getIndustryTypes = () => {
            dropdownService
                .getNomenclaturesByCode(NomenclatureCode.IndustryType)
                .then((data) => (industryTypes.value = data));
        };

        const fileTypes = ref<IDropdownOption[]>([]);
        const getFileTypes = () => {
            dropdownService.getNomenclaturesByCode(NomenclatureCode.FileType).then((data) => (fileTypes.value = data));
        };

        const languages = ref<IDropdownOption[]>([]);
        const getLanguages = () => {
            dropdownService.getNomenclaturesByCode(NomenclatureCode.Language).then((data) => (languages.value = data));
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

        const endDateIsAfterStartDate = () => {
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
        };
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

        watch(
            () => chronologicalScopeLabelText.value,
            () => {
                emit('chronologicalScopeLabelText', chronologicalScopeLabelText.value);
            }
        );

        watch(
            () => date.value,
            (val) => {
                fundData.value.approxmateChronologicalScope = val;
            }
        );

        watch(
            () => fundData.value.descriptionLevelCode,
            (val) => {
                fundData.value.typeCode = undefined;
                fundTypes.value = [] as IDropdownOption[];
                if (val === FundDescriptionLevel.chp && props.type === 'RawFund') {
                    getCHPFundTypes();
                } else {
                    getFundTypes();
                }
            }
        );

        onMounted(() => {
            window.scrollTo(0, 0);
            getArchives();
            getFundArrays();
            getFundTypes();
            getDescriptionLevels();
            getAcquisitionMethods();
            getIndustryTypes();
            getFileTypes();
            getLanguages();
        });

        watch(
            () => fundData,
            () => {
                emit('update:modelValue', fundData.value);
                emit('change', fundData.value);
            }
        );

        return {
            t,
            panel,
            archives,
            fundArrays,
            fundTypes,
            descriptionLevels,
            typeCodeIsRequired,
            acquisitionMethods,
            industryTypes,
            fileTypes,
            languages,
            getFundArrayCounter,
            fundData,
            date,
            approxmateChronologicalScopeString,
            startDayValidationString,
            endDayValidationString,
            chronologicalScopeLabelText,
        };
    },
});
</script>
