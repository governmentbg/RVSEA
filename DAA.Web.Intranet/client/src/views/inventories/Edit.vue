<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('inventories.edit') }}</v-card-title>
        <Form @submit="submitInventoryData" @invalid-submit="showHintMessageForRequiredFields">
            <v-container>
                <v-expansion-panels v-model="panel" multiple>
                    <v-expansion-panel value="general">
                        <v-expansion-panel-title>{{ t('inventories.panels.general') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldArchive"
                                        :label="t('inventories.columns.archive')"
                                        v-model="inventoryData.archiveName"
                                        :readonly="true"
                                        :required="true"
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
                                    <label class="required" for="fldNumberArray">{{
                                        t('inventories.columns.numberArray')
                                    }}</label>
                                    <Dropdown
                                        v-model="inventoryData.numberArray"
                                        name="fldNumberArray"
                                        :label="t('inventories.columns.numberArray')"
                                        :items="inventoryArrays"
                                        :disabled="fldNumberReadOnly"
                                        :emptable="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12" v-if="fldNumberReadOnly">
                                    <text-field
                                        name="fldNumber"
                                        :label="t('inventories.columns.number')"
                                        v-model="inventoryData.number"
                                        :readonly="true"
                                    />
                                </v-col>
                                <v-col class="col-12" v-else>
                                    <text-field
                                        name="fldNumberNumeric"
                                        :label="t('inventories.columns.number')"
                                        v-model="inventoryData.numberNumeric"
                                        validation="integer"
                                        :readonly="!isRegistrarStep"
                                        appendButtonIcon="mdi-numeric"
                                        :appendButtonTooltip="t('inventories.buttons.getNumberTooltip')"
                                        appendButtonCssClass="floatingBtnIcon"
                                        @click:append="getInventoryNumber"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldDescriptionLevel">{{
                                        t('inventories.columns.descriptionLevel')
                                    }}</label>
                                    <!-- <Dropdown
                                        v-model="inventoryData.descriptionLevelCode"
                                        name="fldDescriptionLevel"
                                        :label="t('inventories.columns.descriptionLevel')"
                                        labelProp="label"
                                        valueProp="code"
                                        :items="descriptionLevels"
                                        :disabled="fldDescriptionLevelReadOnly || isRegistrarStep"
                                    /> -->
                                    <Dropdown
                                        v-model="inventoryData.descriptionLevelCode"
                                        name="fldDescriptionLevel"
                                        :label="t('inventories.columns.descriptionLevel')"
                                        labelProp="label"
                                        valueProp="code"
                                        :items="descriptionLevels"
                                        :disabled="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldStatus"
                                        :label="t('inventories.columns.status')"
                                        v-model="inventoryData.statusText"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row v-if="showAvailabilityStatusField">
                                <v-col class="col-12">
                                    <label for="fldAvailabilityStatus">{{
                                        t('inventories.columns.availabilityStatus')
                                    }}</label>
                                    <Dropdown
                                        v-model="inventoryData.availabilityStatusCode"
                                        name="fldAvailabilityStatus"
                                        :label="t('inventories.columns.availabilityStatus')"
                                        labelProp="label"
                                        valueProp="code"
                                        :items="availabilityStatuses"
                                        :disabled="isRegistrarStep"
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
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row v-if="applicationId">
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
                                        :required="fldApplicationRequired"
                                        :disabled="fldApplicationReadOnly || isRegistrarStep"
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
                                        :disabled="isRegistrarStep"
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
                                        :disabled="inventoryData.hasNoChronologicalScope || isRegistrarStep"
                                        :validation="startDayValidationString"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldStartDateMonth"
                                        :label="t('inventories.columns.month')"
                                        v-model="inventoryData.startDateMonth"
                                        :disabled="inventoryData.hasNoChronologicalScope || isRegistrarStep"
                                        validation="numeric|min_value:1|max_value:12"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldStartDateYear"
                                        :label="t('inventories.columns.year')"
                                        v-model="inventoryData.startDateYear"
                                        :disabled="inventoryData.hasNoChronologicalScope || isRegistrarStep"
                                        :validation="
                                            isRegistrarStep 
                                                ? 'numeric|min_value:1000|max_value:2200'
                                                : !inventoryData.hasNoChronologicalScope
                                                    ? 'required|numeric|min_value:1000|max_value:2200'
                                                    : 'numeric|min_value:1000|max_value:2200'
                                        "
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
                                        :disabled="inventoryData.hasNoChronologicalScope || isRegistrarStep"
                                        :validation="endDayValidationString"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldEndDateMonth"
                                        :label="t('inventories.columns.month')"
                                        v-model="inventoryData.endDateMonth"
                                        :disabled="inventoryData.hasNoChronologicalScope || isRegistrarStep"
                                        validation="numeric|min_value:1|max_value:12"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldEndDateYear"
                                        :label="t('inventories.columns.year')"
                                        v-model="inventoryData.endDateYear"
                                        :disabled="inventoryData.hasNoChronologicalScope || isRegistrarStep"
                                        :validation="
                                            isRegistrarStep 
                                                ? 'numeric|min_value:1000|max_value:2200' 
                                                : !inventoryData.hasNoChronologicalScope
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
                                        v-model="formattedBytes"
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
                            <!-- <v-row v-if="!isRawInventory">
                                <v-col class="col-12 col-lg-12" >
                                    <text-field
                                        name="fldLinearMeters"
                                        :label="t('inventories.columns.linearMeters')"
                                        v-model="inventoryData.linearMeters"
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row> -->
                            <v-row v-if="!isRawInventory">
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
                                        name="fldDigitalDocumentArchivalEntityCount"
                                        :label="t('inventories.columns.digitalDocumentArchivalEntityCount')"
                                        v-model="inventoryData.digitalDocumentArchivalEntityCount"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <!-- <v-row v-if="!isRawInventory">
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldBoxCount"
                                        :label="t('inventories.columns.boxCount')"
                                        v-model="inventoryData.boxCount"
                                        validation="numeric"
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldRollCount"
                                        :label="t('inventories.columns.rollCount')"
                                        v-model="inventoryData.rollCount"
                                        validation="numeric"
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row> -->
                            <!-- <v-row v-if="!isRawInventory">
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldAudioDocumentArchivalEntityCount"
                                        :label="t('inventories.columns.audioDocumentArchivalEntityCount')"
                                        v-model="inventoryData.audioDocumentArchivalEntityCount"
                                        validation="numeric"
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldPhotoDocumentArchivalEntityCount"
                                        :label="t('inventories.columns.photoDocumentArchivalEntityCount')"
                                        v-model="inventoryData.photoDocumentArchivalEntityCount"
                                        validation="numeric"
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row> -->
                            <!-- <v-row v-if="!isRawInventory">
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldVideoDocumentArchivalEntityCount"
                                        :label="t('inventories.columns.videoDocumentArchivalEntityCount')"
                                        v-model="inventoryData.videoDocumentArchivalEntityCount"
                                        validation="numeric"
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row> -->
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldFileType">{{ t('inventories.columns.fileType') }}</label>
                                    <Dropdown
                                        v-model="inventoryData.fileTypeCodes"
                                        name="fldFileType"
                                        :label="t('inventories.columns.fileType')"
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
                                        :label="t('inventories.columns.otherMetrics')"
                                        v-model="inventoryData.otherMetrics"
                                        :disabled="isRegistrarStep"
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
                                        auto-grow
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldFundCreatorBiographicalHistory"
                                        :label="t('inventories.columns.fundCreatorBiographicalHistory')"
                                        v-model="inventoryData.fundCreatorBiographicalHistory"
                                        auto-grow
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldHistory"
                                        :label="t('inventories.columns.history')"
                                        v-model="inventoryData.history"
                                        auto-grow
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldDocumentsProvider"
                                        :label="t('inventories.columns.documentsProvider')"
                                        v-model="inventoryData.documentsProvider"
                                        auto-grow
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldDocumentsDescription"
                                        :label="t('inventories.columns.documentsDescription')"
                                        v-model="inventoryData.documentsDescription"
                                        auto-grow
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <label for="fldOriginality">{{ t('inventories.columns.originality') }}</label>
                                    <Dropdown
                                        v-model="inventoryData.originalityCodes"
                                        name="fldOriginality"
                                        :label="t('inventories.columns.originality')"
                                        labelProp="label"
                                        valueProp="code"
                                        :multiselect="true"
                                        :items="originalities"
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldCreationMethod">{{ t('inventories.columns.creationMethod') }}</label>
                                    <Dropdown
                                        v-model="inventoryData.creationMethodCodes"
                                        name="fldCreationMethod"
                                        :label="t('inventories.columns.creationMethod')"
                                        labelProp="label"
                                        valueProp="code"
                                        :multiselect="true"
                                        :items="creationMethods"
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row> -->
                            <v-row>
                                <v-col class="col-12 col-lg-6">
                                    <label for="fldLanguage">{{ t('inventories.columns.language') }}</label>
                                    <Dropdown
                                        v-model="inventoryData.languageCodes"
                                        name="fldLanguage"
                                        :label="t('inventories.columns.language')"
                                        labelProp="label"
                                        valueProp="code"
                                        :multiselect="true"
                                        :items="languages"
                                        :disabled="isRegistrarStep"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-6">
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
                                        auto-grow
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldClassificationScheme"
                                        :label="t('inventories.columns.classificationScheme')"
                                        v-model="inventoryData.classificationScheme"
                                        auto-grow
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldAbbreviationList"
                                        :label="t('inventories.columns.abbreviationList')"
                                        v-model="inventoryData.abbreviationList"
                                        auto-grow
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldNotes"
                                        :label="t('inventories.columns.notes')"
                                        v-model="inventoryData.notes"
                                        auto-grow
                                        :readonly="isRegistrarStep"
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
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldDigitizedArchivalEntityCount"
                                        :label="t('inventories.columns.digitizedArchivalEntityCount')"
                                        v-model="inventoryData.digitizedArchivalEntityCount"
                                        validation="numeric"
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldPositiveFrameCount"
                                        :label="t('inventories.columns.positiveFrameCount')"
                                        v-model="inventoryData.positiveFrameCount"
                                        validation="numeric"
                                        :readonly="isRegistrarStep"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-6">
                                    <text-field
                                        name="fldNegativeFrameCount"
                                        :label="t('inventories.columns.negativeFrameCount')"
                                        v-model="inventoryData.negativeFrameCount"
                                        validation="numeric"
                                        :readonly="isRegistrarStep"
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
import { defineComponent, ref, onMounted, inject, Ref, computed, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
//import { useRedirect } from '@/helpers/router.helper';
import {
    transformMonth,
    stringifyYear,
    stringifyDay,
    validateDay,
    formatApproximateChronologicalScope,
} from '@/helpers/format.helper';

import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { NomenclatureCode } from '@/enums/nomenclature';
import { BusinessObjectType } from '@/models/grid';
import { IInventory } from '@/interfaces/inventory';
import { Inventory, InventoryDraft } from '@/models/inventory';
import { IDropdownOption } from '@/interfaces/dropdown';
import { IProcess } from '@/interfaces/process';
import { ProcessType, ProcessStep } from '@/enums/process';
import processService from '@/services/process.service';
import inventoryService from '@/services/inventory.service';
//import fundService from "@/services/fund.service";
import dropdownService from '@/services/dropdown.service';
import numberService from '@/services/number.service';

import { Form } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import Dropdown from '@/components/dropdown/dropdown.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { InventoryDescriptionLevel } from '@/enums/inventory';
import { useRedirectWithId } from '@/helpers/router.helper';
import { formatBytesToMB } from '@/helpers/format.helper';
import {
    isChronologicalScopeFull,
    isProcessStepType,
    isProcessType,
    isStartDateBeforeEndDate,
} from '@/helpers/validate.helper';
import { ApplicationType } from '@/enums/applications';

export default defineComponent({
    name: 'EditInventory',
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
        const showNumberLoading = ref(false);

        const router = useRouter();
        const goBack = () => {
            useRedirectWithId(router, 'DisplayInventory', props.id);
        };

        const panel = ref(['general', 'additional', 'chronologicalScope', 'storage', 'copies']);

        const fldNumberReadOnly = computed(
            () =>
                activeProcessData.value &&
                (activeProcessData.value?.processTypeId === ProcessType.EditData ||
                    activeProcessData.value?.processTypeId === ProcessType.RefineData)
        );
        const fldDescriptionLevelReadOnly = computed(
            () =>
                activeProcessData.value &&
                (activeProcessData.value?.processTypeId === ProcessType.EditData ||
                    activeProcessData.value?.processTypeId === ProcessType.RefineData)
        );
        const fldStatusReadOnly = computed(
            () =>
                activeProcessData.value &&
                (activeProcessData.value?.processTypeId === ProcessType.EditData ||
                    activeProcessData.value?.processTypeId === ProcessType.RefineData)
        );
        const showAvailabilityStatusField = computed(
            () => activeProcessData.value && activeProcessData.value?.processTypeId === ProcessType.ReconstructFundData
        );

        const showNumberGenerationBtn = computed(
            () =>
                activeProcessData.value && activeProcessData.value?.activeProcessStepTypeId === ProcessStep.Registration
        );

        const applicationId = ref<number | undefined>();
        const fldApplicationRequired = computed(
            () => inventoryData.value && applicationId.value !== undefined && applicationId.value !== null
        );
        const fldApplicationReadOnly = computed(
            () =>
                activeProcessData.value &&
                isProcessType(
                    activeProcessData.value,
                    ProcessType.EditData,
                    ProcessType.RefineData,
                    ProcessType.ReconstructFundData
                )
        );

        const inventoryArrays = ref<IDropdownOption[]>([]);
        const getInventoryArrays = async () => {
            inventoryArrays.value = await dropdownService.getInventoryArrays();
        };

        const descriptionLevels = ref<IDropdownOption[]>([]);
        const getDescriptionLevels = async () => {
            descriptionLevels.value = await dropdownService.getInventoryDescriptionLevels();
        };

        const availabilityStatuses = ref<IDropdownOption[]>([]);
        const getAvailabilityStatuses = async () => {
            availabilityStatuses.value = await dropdownService.getAvailabilityStatuses();
        };

        const acquisitionMethods = ref<IDropdownOption[]>([]);
        const getAcquisitionMethods = async () => {
            acquisitionMethods.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.AcquisitionMethod);
        };

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

        const applications = ref<IDropdownOption[]>([]);
        const getApplications = async (descriptionLevel: string) => {
            if (descriptionLevel) {
                const type =
                    descriptionLevel !== InventoryDescriptionLevel.inventory
                        ? ApplicationType.raw
                        : ApplicationType.assembled;
                applications.value = await dropdownService.getApprovedApplications(
                    type,
                    inventoryData.value.systemIdentifier
                );
            }
        };

        const inventoryData = ref<IInventory>(new Inventory());
        const activeProcessData = ref<IProcess>();

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
                    ProcessStep.Registration
                )
        );

        const isRawInventory = computed(
            () =>
                inventoryData.value &&
                inventoryData.value.descriptionLevelCode == InventoryDescriptionLevel.rawInventory
        );
        const formattedBytes = computed(() => {
            return formatBytesToMB(inventoryData.value.bytes || 0);
        });

        const getInventoryData = async () => {
            try {
                inventoryData.value = await inventoryService.displayInventory(props.id);
                if (inventoryData.value.descriptionLevelCode) {
                    await getApplications(inventoryData.value.descriptionLevelCode);
                }
                if (inventoryData.value.applicationId) {
                    applicationId.value = inventoryData.value.applicationId;
                }
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
                        BusinessObjectType.inventory,
                        props.id,
                        true
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

        const submitInventoryData = async () => {
            if (inventoryData.value) {
                try {
                    const inventoryDraft = new InventoryDraft(inventoryData.value);
                    inventoryDraft.isCurrent = true;
                    inventoryDraft.readOnly = false;
                    if (inventoryData.value.numberNumeric) {
                        //inventoryDraft.number = inventoryData.value.numberNumeric.toString() + (inventoryData.value.numberArray ?? '');
                        inventoryDraft.number = numberService.formatEntityNumber(
                            inventoryData.value.numberNumeric,
                            inventoryData.value.numberArray
                        );
                    } else {
                        inventoryDraft.number = '';
                    }
                    inventoryDraft.approxmateChronologicalScope = date.value;
                    const result = await inventoryService.updateInventory(inventoryDraft);
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

        const showHintMessageForRequiredFields = () => {
            message.value = new Message({
                text: t('common.requiredFields'),
                display: true,
            });
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

        const getInventoryNumber = async () => {
            try {
                showNumberLoading.value = true;
                inventoryData.value.numberNumeric = await numberService.getInventoryNumberNumeric(
                    inventoryData.value.archiveId!,
                    inventoryData.value.fundSystemIdentifier!,
                    inventoryData.value.descriptionLevelCode!,
                    inventoryData.value.numberArray!
                );
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('inventories.errors.gettingLastNumber'),
                    display: true,
                });
            } finally {
                showNumberLoading.value = false;
            }
        };

        const breadcrumbItems = computed(() => getBreadcrumbs());

        const getBreadcrumbs = () => {
            if (activeProcessData.value?.id) {
                return [
                    {
                        title: inventoryData.value.archiveName ?? t('common.start'),
                        disabled: false,
                        to: { name: 'Home' },
                    },
                    {
                        title: t('funds.fund'),
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
                        title: activeProcessData.value.processTypeTitle,
                        disabled: true,
                    },
                ];
            } else
                return [
                    {
                        title: inventoryData.value.archiveName ?? t('common.start'),
                        disabled: false,
                        to: { name: 'Home' },
                    },
                    {
                        title: t('funds.fund'),
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
                ];
        };
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

        watch(
            () => inventoryData.value.descriptionLevelCode,
            (val) => {
                if (val) {
                    getApplications(val);
                }
            }
        );

        onMounted(async () => {
            //await getArchives();
            window.scrollTo(0, 0);
            await getInventoryArrays();
            await getDescriptionLevels();
            await getAcquisitionMethods();
            await getCreationMethods();
            await getFileTypes();
            await getOriginalities();
            await getLanguages();
            await getAvailabilityStatuses();
            await getInventoryData();
            await getActiveProcessData();
        });

        return {
            activeProcessData,
            t,
            panel,
            //archives,
            inventoryArrays,
            descriptionLevels,
            availabilityStatuses,
            acquisitionMethods,
            creationMethods,
            fileTypes,
            originalities,
            languages,
            applications,
            applicationId,
            inventoryData,
            fldNumberReadOnly,
            fldDescriptionLevelReadOnly,
            fldStatusReadOnly,
            fldApplicationReadOnly,
            fldApplicationRequired,
            showAvailabilityStatusField,
            goBack,
            //getFunds,
            submitInventoryData,
            showHintMessageForRequiredFields,
            approxmateChronologicalScopeString,
            date,
            breadcrumbItems,
            getInventoryNumber,
            showNumberLoading,
            showNumberGenerationBtn,
            startDayValidationString,
            endDayValidationString,
            isRawInventory,
            formattedBytes,
            isRegistrarStep,
            chronologicalScopeLabelText,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs-inv.scss';

// .generateNumber {
//     padding-right: -52px;
// }
:deep(.floatingBtnIcon) {
    margin: 0px 0px !important;
}
</style>
