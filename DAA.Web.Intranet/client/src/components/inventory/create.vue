<template>
    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ $t('inventories.create') }}</v-card-title>
        <Form @submit="submitInventoryData">
            <v-container>
                <v-expansion-panels v-model="panel" multiple>
                    <v-expansion-panel value="general">
                        <v-expansion-panel-title>{{ $t('inventories.panels.general') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <ArchiveDropdown
                                        v-model="inventoryData.archiveId"
                                        :required="true"
                                        @change="onArchiveChange"
                                    ></ArchiveDropdown>
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <FundDropdown
                                        @change="onFundChanged"
                                        :required="true"
                                        :archive="archiveCode"
                                        :descLevels="[fundDescLevel]"
                                    ></FundDropdown>
                                    <div>
                                        <a href="#" @click="showFundCreateModal" v-if="archiveCode">{{
                                            $t('inventories.buttons.createFund')
                                        }}</a>
                                    </div>
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldDescriptionLevel">{{
                                        $t('inventories.columns.descriptionLevel')
                                    }}</label>
                                    <AsyncDropdown
                                        v-model="inventoryData.descriptionLevelCode"
                                        name="fldDescriptionLevel"
                                        :label="$t('inventories.columns.descriptionLevel')"
                                        labelProp="label"
                                        valueProp="code"
                                        :itemsFunction="
                                            async () => await dropdownService.getInventoryDescriptionLevels()
                                        "
                                        :disabled="false"
                                    ></AsyncDropdown>
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldStatus">{{ $t('inventories.columns.status') }}</label>
                                    <AsyncDropdown
                                        v-model="inventoryData.statusCode"
                                        name="fldStatus"
                                        :label="$t('inventories.columns.status')"
                                        labelProp="label"
                                        valueProp="code"
                                        :itemsFunction="
                                            async () => await dropdownService.getFundStatusesInternalAndExternal()
                                        "
                                    ></AsyncDropdown>
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldAcquisitionMethod">{{
                                        $t('inventories.columns.acquisitionMethod')
                                    }}</label>
                                    <AsyncDropdown
                                        v-model="inventoryData.acquisitionMethodCodes"
                                        name="fldAcquisitionMethod"
                                        :label="$t('inventories.columns.acquisitionMethod')"
                                        labelProp="label"
                                        valueProp="code"
                                        :itemsFunction="
                                            async () =>
                                                await dropdownService.getNomenclaturesByCode(
                                                    NomenclatureCode.AcquisitionMethod
                                                )
                                        "
                                        :multiselect="false"
                                    ></AsyncDropdown>
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="chronologicalScope">
                        <v-expansion-panel-title>{{
                            $t('inventories.panels.chronologicalScope')
                        }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <Switch
                                        v-model="inventoryData.hasNoChronologicalScope"
                                        :label="$t('inventories.columns.chronologicalScope')"
                                        :large="false"
                                        :showLabel="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label>{{ $t('inventories.columns.startDate') }}</label>
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldStartDateDay"
                                        :label="$t('inventories.columns.day')"
                                        v-model="inventoryData.startDateDay"
                                        :disabled="inventoryData.hasNoChronologicalScope"
                                        :validation="startDayValidationString"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldStartDateMonth"
                                        :label="$t('inventories.columns.month')"
                                        v-model="inventoryData.startDateMonth"
                                        :disabled="inventoryData.hasNoChronologicalScope"
                                        validation="numeric|min_value:1|max_value:12"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldStartDateYear"
                                        :label="$t('inventories.columns.year')"
                                        v-model="inventoryData.startDateYear"
                                        :disabled="inventoryData.hasNoChronologicalScope"
                                        validation="numeric|min_value:1000|max_value:2200"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label>{{ $t('inventories.columns.endDate') }}</label>
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldEndDateDay"
                                        :label="$t('inventories.columns.day')"
                                        v-model="inventoryData.endDateDay"
                                        :disabled="inventoryData.hasNoChronologicalScope"
                                        :validation="endDayValidationString"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldEndDateMonth"
                                        :label="$t('inventories.columns.month')"
                                        v-model="inventoryData.endDateMonth"
                                        :disabled="inventoryData.hasNoChronologicalScope"
                                        validation="numeric|min_value:1|max_value:12"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldEndDateYear"
                                        :label="$t('inventories.columns.year')"
                                        v-model="inventoryData.endDateYear"
                                        :disabled="inventoryData.hasNoChronologicalScope"
                                        validation="numeric|min_value:1000|max_value:2200"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldApproxmateChronologicalScope"
                                        :label="$t('inventories.columns.approxmateChronologicalScope')"
                                        v-model="date"
                                        :disabled="inventoryData.hasNoChronologicalScope"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="storage">
                        <v-expansion-panel-title>{{ $t('inventories.panels.storage') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldBytes"
                                        :label="$t('inventories.columns.bytes')"
                                        v-model="inventoryData.bytes"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldLinearMeters"
                                        :label="$t('inventories.columns.linearMeters')"
                                        v-model="inventoryData.linearMeters"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldArchivalEntityCount"
                                        :label="$t('inventories.columns.archivalEntityCount')"
                                        v-model="inventoryData.archivalEntityCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldDocumentCount"
                                        :label="$t('inventories.columns.documentCount')"
                                        v-model="inventoryData.documentCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldBoxCount"
                                        :label="$t('inventories.columns.boxCount')"
                                        v-model="inventoryData.boxCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldRollCount"
                                        :label="$t('inventories.columns.rollCount')"
                                        v-model="inventoryData.rollCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldAudioDocumentArchivalEntityCount"
                                        :label="$t('inventories.columns.audioDocumentArchivalEntityCount')"
                                        v-model="inventoryData.audioDocumentArchivalEntityCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldPhotoDocumentArchivalEntityCount"
                                        :label="$t('inventories.columns.photoDocumentArchivalEntityCount')"
                                        v-model="inventoryData.photoDocumentArchivalEntityCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldVideoDocumentArchivalEntityCount"
                                        :label="$t('inventories.columns.videoDocumentArchivalEntityCount')"
                                        v-model="inventoryData.videoDocumentArchivalEntityCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldDigitalDocumentArchivalEntityCount"
                                        :label="$t('inventories.columns.digitalDocumentArchivalEntityCount')"
                                        v-model="inventoryData.digitalDocumentArchivalEntityCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldFileType">{{ $t('inventories.columns.fileType') }}</label>
                                    <AsyncDropdown
                                        v-model="inventoryData.fileTypeCodes"
                                        name="fldFileType"
                                        :label="$t('inventories.columns.fileType')"
                                        labelProp="label"
                                        valueProp="code"
                                        :itemsFunction="
                                            async () =>
                                                await dropdownService.getNomenclaturesByCode(NomenclatureCode.FileType)
                                        "
                                        :multiselect="true"
                                    ></AsyncDropdown>
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldOtherMetrics"
                                        :label="$t('inventories.columns.otherMetrics')"
                                        v-model="inventoryData.otherMetrics"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="additional">
                        <v-expansion-panel-title>{{ $t('inventories.panels.additional') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldFundCreatorTitleHistory"
                                        :label="$t('inventories.columns.fundCreatorTitleHistory')"
                                        v-model="inventoryData.fundCreatorTitleHistory"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldFundCreatorBiographicalHistory"
                                        :label="$t('inventories.columns.fundCreatorBiographicalHistory')"
                                        v-model="inventoryData.fundCreatorBiographicalHistory"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldHistory"
                                        :label="$t('inventories.columns.history')"
                                        v-model="inventoryData.history"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldDocumentsProvider"
                                        :label="$t('inventories.columns.documentsProvider')"
                                        v-model="inventoryData.documentsProvider"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldDocumentsDescription"
                                        :label="$t('inventories.columns.documentsDescription')"
                                        v-model="inventoryData.documentsDescription"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldOriginality">{{ $t('inventories.columns.originality') }}</label>
                                    <AsyncDropdown
                                        v-model="inventoryData.originalityCodes"
                                        name="fldOriginality"
                                        :label="$t('inventories.columns.originality')"
                                        labelProp="label"
                                        valueProp="code"
                                        :itemsFunction="
                                            async () =>
                                                await dropdownService.getNomenclaturesByCode(
                                                    NomenclatureCode.Originality
                                                )
                                        "
                                        :multiselect="true"
                                    ></AsyncDropdown>
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldCreationMethod">{{
                                        $t('inventories.columns.creationMethod')
                                    }}</label>
                                    <AsyncDropdown
                                        v-model="inventoryData.creationMethodCodes"
                                        name="fldCreationMethod"
                                        :label="$t('inventories.columns.creationMethod')"
                                        labelProp="label"
                                        valueProp="code"
                                        :itemsFunction="
                                            async () =>
                                                await dropdownService.getNomenclaturesByCode(
                                                    NomenclatureCode.CreationMethod
                                                )
                                        "
                                        :multiselect="true"
                                    ></AsyncDropdown>
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldLanguage">{{ $t('inventories.columns.language') }}</label>
                                    <AsyncDropdown
                                        v-model="inventoryData.languageCodes"
                                        name="fldLanguage"
                                        :label="$t('inventories.columns.language')"
                                        labelProp="label"
                                        valueProp="code"
                                        :itemsFunction="
                                            async () =>
                                                await dropdownService.getNomenclaturesByCode(NomenclatureCode.Language)
                                        "
                                        :multiselect="true"
                                    ></AsyncDropdown>
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldDocumentsAccessDescription"
                                        :label="$t('inventories.columns.documentsAccessDescription')"
                                        v-model="inventoryData.documentsAccessDescription"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldClassificationScheme"
                                        :label="$t('inventories.columns.classificationScheme')"
                                        v-model="inventoryData.classificationScheme"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldAbbreviationList"
                                        :label="$t('inventories.columns.abbreviationList')"
                                        v-model="inventoryData.abbreviationList"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldNotes"
                                        :label="$t('inventories.columns.notes')"
                                        v-model="inventoryData.notes"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="copies">
                        <v-expansion-panel-title>{{ $t('inventories.panels.copies') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldMicrofilmedArchivalEntityCount"
                                        :label="$t('inventories.columns.microfilmedArchivalEntityCount')"
                                        v-model="inventoryData.microfilmedArchivalEntityCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldPositiveFrameCount"
                                        :label="$t('inventories.columns.positiveFrameCount')"
                                        v-model="inventoryData.positiveFrameCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldNegativeFrameCount"
                                        :label="$t('inventories.columns.negativeFrameCount')"
                                        v-model="inventoryData.negativeFrameCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldDigitizedArchivalEntityCount"
                                        :label="$t('inventories.columns.digitizedArchivalEntityCount')"
                                        v-model="inventoryData.digitizedArchivalEntityCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="externalSource">
                        <v-expansion-panel-title>{{ $t('inventories.panels.externalSource') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <Switch
                                        :label="$t('inventories.columns.hasExternalSource')"
                                        v-model="inventoryData.hasExternalSource"
                                        :large="false"
                                        :showLabel="true"
                                    />
                                </v-col>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldExternalIdentifier"
                                        :label="$t('inventories.columns.externalIdentifier')"
                                        v-model="inventoryData.externalIdentifier"
                                        :validation="inventoryData.hasExternalSource ? 'required|numeric' : 'numeric'"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                </v-expansion-panels>
                <v-row class="mt-3">
                    <v-col class="d-flex justify-content-center">
                        <v-btn type="submit" variant="outlined" color="primary" class="me-3"
                            >{{ $t('common.save') }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('common.saveTooltip') }}
                            </v-tooltip>
                        </v-btn>
                        <v-btn class="cancel" @click="onCancel" variant="outlined" color="danger"
                            >{{ $t('common.cancel') }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('inventories.buttons.cancelTooltip') }}
                            </v-tooltip>
                        </v-btn>
                    </v-col>
                </v-row>
            </v-container>
        </Form>
    </v-card>
    <FundCreateModal
        v-model:show="showFundModal"
        :fundDescLevel="fundDescLevel"
        :archiveId="inventoryData.archiveId"
    ></FundCreateModal>
</template>

<script lang="ts">
import { defineComponent, ref, computed } from 'vue';
import { transformMonth, stringifyDay, stringifyYear, validateDay } from '@/helpers/format.helper';

import { NomenclatureCode } from '@/enums/nomenclature';
import { FundDescriptionLevel } from '@/enums/fund';
import { InventoryDescriptionLevel } from '@/enums/inventory';
import { IInventory } from '@/interfaces/inventory';
import { Inventory } from '@/models/inventory';
import { IDropdownOption } from '@/interfaces/dropdown';
import inventoryService from '@/services/inventory.service';
import dropdownService from '@/services/dropdown.service';

import { Form } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import ArchiveDropdown from '@/components/dropdown/archive.dropdown.vue';
import FundDropdown from '@/components/dropdown/fund.dropdown.vue';
import AsyncDropdown from '@/components/dropdown/service.dropdown.vue';
import FundCreateModal from '@/components/fund/create.modal.vue';

export default defineComponent({
    name: 'CreateInventory',
    components: {
        ArchiveDropdown,
        AsyncDropdown,
        Form,
        FundDropdown,
        TextField,
        TextAreaField,
        Switch,
        FundCreateModal,
    },
    props: {
        processed: {
            type: Boolean,
            required: true,
        },
        internal: {
            type: Boolean,
            required: true,
        },
    },
    emits: ['created', 'cancel'],
    setup(props, { emit }) {
        const panel = ref(['general', 'additional', 'chronologicalScope', 'externalSource', 'storage', 'copies']);
        const onCancel = () => emit('cancel');
        const showFundModal = ref(false);
        const fundDescLevel = ref(
            props.processed ? FundDescriptionLevel.fund : (FundDescriptionLevel.rawFund as string)
        );

        const date = computed(() => approxmateChronologicalScopeString());
        const startDayValidationString = computed(
            () =>
                `numeric|min_value:1|max_value:${validateDay(
                    inventoryData.value.startDateMonth,
                    inventoryData.value.startDateYear
                )}`
        );
        const endDayValidationString = computed(
            () =>
                `numeric|min_value:1|max_value:${validateDay(
                    inventoryData.value.endDateMonth,
                    inventoryData.value.endDateYear
                )}`
        );

        const inventoryData = ref<IInventory>(new Inventory());
        const archiveCode = ref<string>();
        const onArchiveChange = (data: IDropdownOption) => {
            archiveCode.value = data.code as string;
        };

        const onFundChanged = (option: IInventory) => {
            console.log(option);

            if (option) {
                inventoryData.value.fundSystemIdentifier = option.systemIdentifier;
                inventoryData.value.fundHasExternalSource = option.hasExternalSource;
                inventoryData.value.fundExternalIdentifier = option.externalIdentifier;
            } else {
                inventoryData.value.fundSystemIdentifier = undefined;
                inventoryData.value.fundHasExternalSource = undefined;
                inventoryData.value.fundExternalIdentifier = undefined;
            }
        };

        const approxmateChronologicalScopeString = (): string => {
            let date = '';
            if (inventoryData.value != null) {
                if (inventoryData.value.startDateMonth) {
                    inventoryData.value.startDateMonth = parseInt(inventoryData.value.startDateMonth.toString());
                }

                if (inventoryData.value.endDateMonth) {
                    inventoryData.value.endDateMonth = parseInt(inventoryData.value.endDateMonth.toString());
                }

                const startDay = inventoryData.value.startDateDay;
                const startMonth = inventoryData.value.startDateMonth;
                const startYear = inventoryData.value.startDateYear;
                const endDay = inventoryData.value.endDateDay;
                const endMonth = inventoryData.value.endDateMonth;
                const endYear = inventoryData.value.endDateYear;

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
            if (inventoryData.value.hasNoChronologicalScope) {
                date = 'Б.Д.';
                inventoryData.value.startDateDay = undefined;
                inventoryData.value.startDateMonth = undefined;
                inventoryData.value.startDateYear = undefined;
                inventoryData.value.endDateDay = undefined;
                inventoryData.value.endDateMonth = undefined;
                inventoryData.value.endDateYear = undefined;
            }
            inventoryData.value.approxmateChronologicalScope = date;
            return date.toString();
        };

        const submitInventoryData = async () => {
            try {
                const result = await inventoryService.createInventory(inventoryData.value);
                if (result.status == 200) {
                    console.log('created', result.data.data);
                    emit('created', result.data.data);
                }
            } catch (error) {
                console.error(error);
            }
        };

        if (props.processed) {
            inventoryData.value.descriptionLevelCode = InventoryDescriptionLevel.inventory;
        } else {
            inventoryData.value.descriptionLevelCode = InventoryDescriptionLevel.rawInventory;
        }

        return {
            archiveCode,
            dropdownService,
            fundDescLevel,
            inventoryData,
            NomenclatureCode,
            onArchiveChange,
            onCancel,
            onFundChanged,
            panel,
            showFundModal,
            submitInventoryData,
            date,
            startDayValidationString,
            endDayValidationString,
        };
    },
    methods: {
        showFundCreateModal() {
            console.log('create fund');
            this.showFundModal = true;
        },
    },
});
</script>
