<template>
    <Breadcrumbs :items="breadcrumbItems" />
    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('inventories.create') }}</v-card-title>

        <Form @submit="submitInventoryData" @invalid-submit="showHintMessageForRequiredFields">
            <v-container>
                <v-expansion-panels v-model="panel" multiple>
                    <v-expansion-panel value="general">
                        <v-expansion-panel-title>{{ t('inventories.panels.general') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <!-- <v-row v-if="fundData && (fundData.systemIdentifier !== undefined || fundData.hasExternalSource)"> -->
                            <v-row>
                                <v-col class="col-12">
                                    <TextField
                                        name="fldArchive"
                                        :label="t('inventories.columns.archive')"
                                        v-model="fundData.archiveName"
                                        :readonly="true"
                                        :required="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <TextField
                                        name="fldFund"
                                        :label="t('inventories.columns.fund')"
                                        v-model="fundData.number"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label class="required" for="fldNumberArray">{{
                                        t('inventories.columns.numberArray')
                                    }}</label>
                                    <Dropdown
                                        v-model="inventoryData.numberArray"
                                        name="fldNumberArray"
                                        :label="t('inventories.columns.numberArray')"
                                        :items="inventoryArrays"
                                        :required="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldDescriptionLevel">{{
                                        t('inventories.columns.descriptionLevel')
                                    }}</label>
                                    <Dropdown
                                        v-model="inventoryData.descriptionLevelCode"
                                        name="fldDescriptionLevel"
                                        :label="t('inventories.columns.descriptionLevel')"
                                        labelProp="label"
                                        valueProp="code"
                                        :items="descriptionLevels"
                                        :disabled="descriptionLevel !== undefined"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldAcquisitionMethod">{{
                                        t('inventories.columns.acquisitionMethod')
                                    }}</label>
                                    <Dropdown
                                        v-model="inventoryData.acquisitionMethodId"
                                        name="fldAcquisitionMethod"
                                        :label="t('inventories.columns.acquisitionMethod')"
                                        labelProp="label"
                                        valueProp="id"
                                        :items="acquisitionMethods"
                                        :multiselect="false"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldApplication">{{ t('inventories.columns.application') }}</label>
                                    <Dropdown
                                        v-model="inventoryData.applicationId"
                                        name="fldApplication"
                                        :label="t('inventories.columns.application')"
                                        labelProp="label"
                                        valueProp="id"
                                        :items="applications"
                                        :multiselect="false"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="chronologicalScope">
                        <v-expansion-panel-title>{{
                            t('inventories.panels.chronologicalScope')
                        }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <Switch
                                        v-model="inventoryData.hasNoChronologicalScope"
                                        :label="t('inventories.columns.chronologicalScope')"
                                        :large="false"
                                        :showLabel="true"
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
                                        :validation="startDayValidationString"
                                        :disabled="inventoryData.hasNoChronologicalScope"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldStartDateMonth"
                                        :label="t('inventories.columns.month')"
                                        v-model="inventoryData.startDateMonth"
                                        validation="numeric|min_value:1|max_value:12"
                                        :disabled="inventoryData.hasNoChronologicalScope"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldStartDateYear"
                                        :label="t('inventories.columns.year')"
                                        :validation="
                                            !inventoryData.hasNoChronologicalScope
                                                ? 'required|numeric|min_value:1000|max_value:2200'
                                                : 'numeric|min_value:1000|max_value:2200'
                                        "
                                        v-model="inventoryData.startDateYear"
                                        :disabled="inventoryData.hasNoChronologicalScope"
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
                                        :validation="endDayValidationString"
                                        :disabled="inventoryData.hasNoChronologicalScope"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldEndDateMonth"
                                        :label="t('inventories.columns.month')"
                                        validation="numeric|min_value:1|max_value:12"
                                        v-model="inventoryData.endDateMonth"
                                        :disabled="inventoryData.hasNoChronologicalScope"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldEndDateYear"
                                        :label="t('inventories.columns.year')"
                                        v-model="inventoryData.endDateYear"
                                        :validation="
                                            !inventoryData.hasNoChronologicalScope
                                                ? 'required|numeric|min_value:1000|max_value:2200'
                                                : 'numeric|min_value:1000|max_value:2200'
                                        "
                                        :disabled="inventoryData.hasNoChronologicalScope"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldApproxmateChronologicalScope"
                                        :label="t('inventories.columns.approxmateChronologicalScope')"
                                        v-model="date"
                                        :readonly="true"
                                    />
                                    <label style="color: red">{{ chronologicalScopeLabelText }}</label>
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
                                        v-model="inventoryData.bytes"
                                        validation="numeric"
                                        :readonly="!isInventory"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldDocumentCount"
                                        :label="t('inventories.columns.documentCount')"
                                        v-model="inventoryData.documentCount"
                                        validation="numeric"
                                        :readonly="!isInventory"
                                    />
                                </v-col>
                            </v-row>
                            <v-row v-if="isInventory">
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldLinearMeters"
                                        :label="t('inventories.columns.linearMeters')"
                                        v-model="inventoryData.linearMeters"
                                        validation="float"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldArchivalEntityCount"
                                        :label="t('inventories.columns.archivalEntityCount')"
                                        v-model="inventoryData.archivalEntityCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row v-if="isInventory">
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldBoxCount"
                                        :label="t('inventories.columns.boxCount')"
                                        v-model="inventoryData.boxCount"
                                        validation="numeric"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldRollCount"
                                        :label="t('inventories.columns.rollCount')"
                                        v-model="inventoryData.rollCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row v-if="isInventory">
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldAudioDocumentArchivalEntityCount"
                                        :label="t('inventories.columns.audioDocumentArchivalEntityCount')"
                                        v-model="inventoryData.audioDocumentArchivalEntityCount"
                                        validation="numeric"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldPhotoDocumentArchivalEntityCount"
                                        :label="t('inventories.columns.photoDocumentArchivalEntityCount')"
                                        v-model="inventoryData.photoDocumentArchivalEntityCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row v-if="isInventory">
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldVideoDocumentArchivalEntityCount"
                                        :label="t('inventories.columns.videoDocumentArchivalEntityCount')"
                                        v-model="inventoryData.videoDocumentArchivalEntityCount"
                                        validation="numeric"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldDigitalDocumentArchivalEntityCount"
                                        :label="t('inventories.columns.digitalDocumentArchivalEntityCount')"
                                        v-model="inventoryData.digitalDocumentArchivalEntityCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldOtherMetrics"
                                        :label="t('inventories.columns.otherMetrics')"
                                        v-model="inventoryData.otherMetrics"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="additional">
                        <v-expansion-panel-title>{{ t('inventories.panels.additional') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldFundCreatorTitleHistory"
                                        :label="t('inventories.columns.fundCreatorTitleHistory')"
                                        v-model="inventoryData.fundCreatorTitleHistory"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldFundCreatorBiographicalHistory"
                                        :label="t('inventories.columns.fundCreatorBiographicalHistory')"
                                        v-model="inventoryData.fundCreatorBiographicalHistory"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldHistory"
                                        :label="t('inventories.columns.history')"
                                        v-model="inventoryData.history"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldDocumentsProvider"
                                        :label="t('inventories.columns.documentsProvider')"
                                        v-model="inventoryData.documentsProvider"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldDocumentsDescription"
                                        :label="t('inventories.columns.documentsDescription')"
                                        v-model="inventoryData.documentsDescription"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-6">
                                    <label for="fldLanguage">{{ t('inventories.columns.language') }}</label>
                                    <Dropdown
                                        v-model="inventoryData.languageCodes"
                                        name="fldLanguage"
                                        :label="t('inventories.columns.language')"
                                        labelProp="label"
                                        valueProp="code"
                                        :multiselect="true"
                                        :items="languages"
                                    />
                                </v-col>
                                <v-col class="col-6">
                                    <label for="fldOtherLanguage"></label>
                                    <text-field
                                        name="fldOtherLanguage"
                                        :label="t('inventories.columns.otherLanguage')"
                                        v-model="inventoryData.otherLanguage"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldDocumentsAccessDescription"
                                        :label="t('inventories.columns.documentsAccessDescription')"
                                        v-model="inventoryData.documentsAccessDescription"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldClassificationScheme"
                                        :label="t('inventories.columns.classificationScheme')"
                                        v-model="inventoryData.classificationScheme"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldAbbreviationList"
                                        :label="t('inventories.columns.abbreviationList')"
                                        v-model="inventoryData.abbreviationList"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldNotes"
                                        :label="t('inventories.columns.notes')"
                                        v-model="inventoryData.notes"
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
                                        validation="numeric"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldPositiveFrameCount"
                                        :label="t('inventories.columns.positiveFrameCount')"
                                        v-model="inventoryData.positiveFrameCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldNegativeFrameCount"
                                        :label="t('inventories.columns.negativeFrameCount')"
                                        v-model="inventoryData.negativeFrameCount"
                                        validation="numeric"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldDigitizedArchivalEntityCount"
                                        :label="t('inventories.columns.digitizedArchivalEntityCount')"
                                        v-model="inventoryData.digitizedArchivalEntityCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="externalSource">
                        <v-expansion-panel-title>{{ t('inventories.panels.externalSource') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <Switch
                                        :label="t('inventories.columns.hasExternalSource')"
                                        v-model="inventoryData.hasExternalSource"
                                        :large="false"
                                        :showLabel="true"
                                        :disabled="true"
                                    />
                                </v-col>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldExternalIdentifier"
                                        :label="t('inventories.columns.externalIdentifier')"
                                        v-model="inventoryData.externalIdentifier"
                                        :validation="inventoryData.hasExternalSource ? 'required|numeric' : 'numeric'"
                                        :disabled="true"
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
                                {{ t('inventories.buttons.cancelTooltip') }}
                            </v-tooltip>
                        </cancel-btn>
                    </v-col>
                </v-row>
            </v-container>
        </Form>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, inject, onMounted, Ref, computed, watch } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useRedirect } from '@/helpers/router.helper';
import { Message } from '@/models/notification';
import {
    transformMonth,
    stringifyDay,
    stringifyYear,
    validateDay,
    formatApproximateChronologicalScope,
} from '@/helpers/format.helper';
import { isChronologicalScopeFull, isStartDateBeforeEndDate } from '@/helpers/validate.helper';

import { Status } from '@/enums/status';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { NomenclatureCode } from '@/enums/nomenclature';
import { InventoryDescriptionLevel } from '@/enums/inventory';
import { ApplicationType } from '@/enums/applications';
import { IFund } from '@/interfaces/fund';
import { Fund } from '@/models/fund';
import { IInventoryDraft } from '@/interfaces/inventory';
import { InventoryDraft } from '@/models/inventory';
import { IDropdownOption } from '@/interfaces/dropdown';
import inventoryService from '@/services/inventory.service';
import dropdownService from '@/services/dropdown.service';
import fundService from '@/services/fund.service';

import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { Form } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import Dropdown from '@/components/dropdown/dropdown.vue';

export default defineComponent({
    name: 'CreateInventory',
    components: {
        Form,
        TextField,
        TextAreaField,
        Switch,
        Dropdown,
        Breadcrumbs,
    },
    props: {
        fundSystemIdentifier: {
            type: String,
            required: false,
        },
        fundHasExternalSource: {
            type: Boolean,
            required: false,
        },
        fundExternalIdentifier: {
            type: Number,
            required: false,
        },
        descriptionLevel: {
            type: String,
            required: false,
        },
        startProcess: {
            type: Boolean,
            default: false,
        },
    },
    setup(props) {
        const { t } = useI18n();

        const message = inject('notificationMessage') as Ref<IMessage>;
        const date = computed(() => formatApproximateChronologicalScope(approxmateChronologicalScopeString()));
        const chronologicalScopeLabelText = computed(() => {
            if (
                !isChronologicalScopeFull(
                    inventoryData.value.startDateDay,
                    inventoryData.value.startDateMonth,
                    inventoryData.value.startDateYear,
                    inventoryData.value.endDateDay,
                    inventoryData.value.endDateMonth,
                    inventoryData.value.endDateYear
                )
            ) {
                return t('common.isChronologicalScopeFullLabel');
            } else if (
                !isStartDateBeforeEndDate(
                    inventoryData.value.startDateDay,
                    inventoryData.value.startDateMonth,
                    inventoryData.value.startDateYear,
                    inventoryData.value.endDateDay,
                    inventoryData.value.endDateMonth,
                    inventoryData.value.endDateYear
                )
            ) {
                return t('common.isStartDateBeforeEndDateLabel');
            }
            return '';
        });
        const panel = ref(['general', 'additional', 'chronologicalScope', 'storage', 'copies']);

        const router = useRouter();
        const goBack = (val: string) => {
            if (props.fundSystemIdentifier) {
                useRedirect(
                    router,
                    'DisplayFund',
                    { id: props.fundSystemIdentifier },
                    {
                        hasExternalSource: String(props.fundHasExternalSource),
                        externalIdentifier: props.fundExternalIdentifier,
                    }
                );
            } else {
                useRedirect(router, 'DisplayInventory', { id: val });
            }
        };

        const fundData = ref<IFund>(new Fund());
        const inventoryData = ref<IInventoryDraft>(new InventoryDraft());
        inventoryData.value.descriptionLevelCode = props.descriptionLevel?.toString();

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

        const isInventory = computed(
            () => inventoryData.value && inventoryData.value.descriptionLevelCode == InventoryDescriptionLevel.inventory
        );

        const initInventoryData = async () => {
            if (props.fundSystemIdentifier || props.fundHasExternalSource) {
                fundData.value = await fundService.displayFund(
                    props.fundSystemIdentifier,
                    props.fundHasExternalSource,
                    props.fundExternalIdentifier
                );
                inventoryData.value.archiveId = fundData.value.archiveId;
                inventoryData.value.fundSystemIdentifier = fundData.value.systemIdentifier;
                inventoryData.value.fundHasExternalSource = fundData.value.hasExternalSource;
                inventoryData.value.fundExternalIdentifier = fundData.value.externalIdentifier;
                if (fundData.value.isDraft) {
                    inventoryData.value.fundDraftId = fundData.value.id;
                }
            }
        };

        const inventoryArrays = ref<IDropdownOption[]>([]);
        const getInventoryArrays = async () => {
            inventoryArrays.value = await dropdownService.getInventoryArrays();
        };

        const descriptionLevels = ref<IDropdownOption[]>([]);
        const getDescriptionLevels = async () => {
            descriptionLevels.value = await dropdownService.getInventoryDescriptionLevels();
        };

        const acquisitionMethods = ref<IDropdownOption[]>([]);
        const getAcquisitionMethods = async () => {
            acquisitionMethods.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.AcquisitionMethod);
        };

        const applications = ref<IDropdownOption[]>([]);
        watch(
            () => [inventoryData.value.descriptionLevelCode, fundData.value.archiveId],
            ([descriptionLevelCode, archiveId]) => {
                if (descriptionLevelCode && archiveId) {
                    const type =
                        descriptionLevelCode !== InventoryDescriptionLevel.inventory
                            ? ApplicationType.raw
                            : ApplicationType.assembled;
                    dropdownService
                        .getApprovedApplications(type, undefined, fundData.value.archiveId)
                        .then((data) => (applications.value = data));
                }
            }
        );

        // duplicates the above code
        // if (inventoryData.value.descriptionLevelCode) {
        //     const type =
        //         inventoryData.value.descriptionLevelCode !== InventoryDescriptionLevel.inventory
        //             ? ApplicationType.raw
        //             : ApplicationType.assembled;
        //     dropdownService.getApprovedApplications(type, undefined, fundData.value.archiveId).then((data) => (applications.value = data));
        // }

        const creationMethods = ref<IDropdownOption[]>([]);
        const getCreationMethods = async () => {
            creationMethods.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.CreationMethod);
        };

        const fileTypes = ref<IDropdownOption[]>([]);
        const getFileTypes = async () => {
            fileTypes.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.FileType);
        };

        const originalities = ref<IDropdownOption[]>([]);
        const getOriginalities = async () => {
            originalities.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.Originality);
        };

        const languages = ref<IDropdownOption[]>([]);
        const getLanguages = async () => {
            languages.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.Language);
        };

        const submitInventoryData = async () => {
            try {
                if (chronologicalScopeLabelText.value) {
                    showHintMessageRequirements();
                    return;
                }

                inventoryData.value.approxmateChronologicalScope = date.value;
                inventoryData.value.statusCode = Status.New; //Status New

                const result = await inventoryService.createInventory(inventoryData.value, props.startProcess);
                if (result.status == 200) {
                    goBack(result.data.data);
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
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

        const breadcrumbItems = computed(() => [
            {
                title: fundData.value.archiveName ?? t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('funds.fund'),
                disabled: false,
                to: {
                    name: 'DisplayFund',
                    params: {
                        id: inventoryData.value.fundSystemIdentifier,
                    },
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

        const endDateIsAfterStartDate = () => {
            let ok = true;
            if (
                inventoryData.value.startDateDay != undefined &&
                inventoryData.value.startDateMonth != undefined &&
                inventoryData.value.endDateDay != undefined &&
                inventoryData.value.endDateMonth != undefined
            ) {
                if (inventoryData.value.endDateYear == inventoryData.value.startDateYear) {
                    if (
                        inventoryData.value.startDateMonth > inventoryData.value.endDateMonth ||
                        (inventoryData.value.startDateMonth == inventoryData.value.endDateMonth &&
                            inventoryData.value.startDateDay > inventoryData.value.endDateDay)
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
        const showHintMessageForRequiredFields = () => {
            message.value = new Message({
                text: t('common.requiredFields'),
                display: true,
            });
        };
        const showHintMessageRequirements = () => {
            message.value = new Message({
                text: t('common.requirements'),
                display: true,
            });
        };
        watch(
            () => date.value,
            () => {
                if (
                    inventoryData.value.startDateYear &&
                    inventoryData.value.endDateYear &&
                    inventoryData.value.endDateYear.toString().length == 4
                )
                    if (inventoryData.value.endDateYear < inventoryData.value.startDateYear) {
                        message.value = new Message({
                            text: t('common.checkDate'),
                            display: true,
                        });
                    } else endDateIsAfterStartDate();
            }
        );
        onMounted(async () => {
            window.scrollTo(0, 0);
            //await getArchives();
            await getInventoryArrays();
            await getDescriptionLevels();
            await getAcquisitionMethods();
            await getCreationMethods();
            await getFileTypes();
            await getOriginalities();
            await getLanguages();
            await initInventoryData();
        });

        return {
            applications,
            breadcrumbItems,
            t,
            panel,
            fundData,
            inventoryData,
            //archives,
            inventoryArrays,
            descriptionLevels,
            acquisitionMethods,
            creationMethods,
            fileTypes,
            originalities,
            languages,
            //getFunds,
            submitInventoryData,
            showHintMessageForRequiredFields,
            goBack,
            //onFundChanged,
            approxmateChronologicalScopeString,
            date,
            startDayValidationString,
            endDayValidationString,
            isInventory,
            chronologicalScopeLabelText,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs-inv.scss';
</style>
