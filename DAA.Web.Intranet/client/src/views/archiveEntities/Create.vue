<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('archiveEntities.create') }}</v-card-title>

        <Form @submit="submitarchivalEntityData" @invalid-submit="showHintMessageForRequiredFields">
            <v-container>
                <v-expansion-panels v-model="panel" multiple>
                    <v-expansion-panel value="general">
                        <v-expansion-panel-title>{{ t('archiveEntities.panels.generalInfo') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <TextField
                                        name="fldArchive"
                                        :label="t('inventories.columns.archive')"
                                        v-model="inventoryData.archiveName"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <TextField
                                        name="fldFund"
                                        :label="t('archiveEntities.columns.fund')"
                                        v-model="inventoryData.fundNumber"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <TextField
                                        name="fldInventory"
                                        :label="t('archiveEntities.inventory')"
                                        v-model="inventoryData.number"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="archivalEntityInfo">
                        <v-expansion-panel-title>{{
                            t('archiveEntities.panels.archivalEntityInfo')
                        }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12 col-md-4 col-lg-4">
                                    <TextField
                                        name="fldNumberArray"
                                        :label="t('archiveEntities.columns.numberArray')"
                                        v-model="archivalEntityData.numberArray"
                                    />
                                </v-col>
                                <v-col class="col-12 col-md-4 col-lg-4">
                                    <TextField
                                        name="fldNumberNumeric"
                                        :label="t('archiveEntities.columns.numberNumeric')"
                                        v-model="archivalEntityData.numberNumeric"
                                        validation="integer"
                                        appendButtonIcon="mdi-numeric"
                                        :appendButtonTooltip="t('archiveEntities.buttons.getNumberTooltip')"
                                        appendButtonCssClass="floatingBtnIcon"
                                        @click:append="getArchivalEntityNumber"
                                    />
                                </v-col>
                                <v-col class="col-12 col-md-4 col-lg-4">
                                    <TextField
                                        name="fldClassificationSchemeIndex"
                                        :label="t('archiveEntities.columns.classificationSchemeIndex')"
                                        v-model="archivalEntityData.classificationSchemeIndex"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label class="required" for="fldDescriptionLevelCode">{{
                                        t('archiveEntities.columns.descriptionLevel')
                                    }}</label>
                                    <Dropdown
                                        :label="t('archiveEntities.columns.descriptionLevel')"
                                        name="fldDescriptionLevelCode"
                                        required="required"
                                        :items="descriptionLevels"
                                        v-model="archivalEntityData.descriptionLevelCode"
                                        :disabled="descriptionLevel !== undefined"
                                    />
                                </v-col>
                            </v-row>
                            <v-row
                                v-if="
                                    inventoryData.numberArray === inventoryArray.KE ||
                                    inventoryData.numberArray === inventoryArray.NE ||
                                    inventoryData.numberArray === inventoryArray.PE ||
                                    inventoryData.numberArray === inventoryArray.TE
                                "
                            >
                                <v-col class="col-12">
                                    <text-field
                                        name="fldCypher"
                                        :label="t('archiveEntities.columns.cypher')"
                                        v-model="archivalEntityData.cypher"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldTitle"
                                        :label="t('common.title')"
                                        v-model="archivalEntityData.title"
                                        validation="required"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="chronologicalScope">
                        <v-expansion-panel-title>{{
                            t('archiveEntities.panels.datePlaceOfCreation')
                        }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <Switch
                                        v-model="archivalEntityData.hasNoChronologicalScope"
                                        :label="t('archiveEntities.columns.chronologicalScope')"
                                        :large="false"
                                        :showLabel="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-3">
                                    <div>{{ t('archiveEntities.startDate') }}</div>
                                </v-col>
                                <v-col class="col-3">
                                    <text-field
                                        name="fldStartDateDay"
                                        :label="t('common.day')"
                                        v-model="archivalEntityData.startDateDay"
                                        :disabled="archivalEntityData.hasNoChronologicalScope"
                                        :validation="startDayValidationString"
                                    />
                                </v-col>
                                <v-col class="col-3">
                                    <text-field
                                        name="fldStartDateMonth"
                                        :label="t('common.month')"
                                        v-model="archivalEntityData.startDateMonth"
                                        :disabled="archivalEntityData.hasNoChronologicalScope"
                                        validation="numeric|min_value:1|max_value:12"
                                    />
                                </v-col>
                                <v-col class="col-3">
                                    <text-field
                                        name="fldStartDateYear"
                                        :label="t('common.year')"
                                        v-model="archivalEntityData.startDateYear"
                                        :disabled="archivalEntityData.hasNoChronologicalScope"
                                        :validation="
                                            !archivalEntityData.hasNoChronologicalScope
                                                ? 'required|numeric|min_value:1000|max_value:2200'
                                                : 'numeric|min_value:1000|max_value:2200'
                                        "
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-3">
                                    <div>{{ t('archiveEntities.endDate') }}</div>
                                </v-col>
                                <v-col class="col-3">
                                    <text-field
                                        name="fldEndDateDay"
                                        :label="t('common.day')"
                                        v-model="archivalEntityData.endDateDay"
                                        :disabled="archivalEntityData.hasNoChronologicalScope"
                                        :validation="endDayValidationString"
                                    />
                                </v-col>
                                <v-col class="col-3">
                                    <text-field
                                        name="fldEndDateMonth"
                                        :label="t('common.month')"
                                        v-model="archivalEntityData.endDateMonth"
                                        :disabled="archivalEntityData.hasNoChronologicalScope"
                                        validation="numeric|min_value:1|max_value:12"
                                    />
                                </v-col>
                                <v-col class="col-3">
                                    <text-field
                                        name="fldEndDateYear"
                                        :label="t('common.year')"
                                        v-model="archivalEntityData.endDateYear"
                                        :disabled="archivalEntityData.hasNoChronologicalScope"
                                        :validation="
                                            !archivalEntityData.hasNoChronologicalScope
                                                ? 'required|numeric|min_value:1000|max_value:2200'
                                                : 'numeric|min_value:1000|max_value:2200'
                                        "
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldApproximateChronologicalScope"
                                        :label="t('archiveEntities.columns.approximateChronologicalScope')"
                                        v-model="date"
                                        :readonly="true"
                                    />
                                    <label style="color: red">{{ chronologicalScopeLabelText }}</label>
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldLocation"
                                        :label="t('archiveEntities.columns.placeOfCreation')"
                                        v-model="archivalEntityData.location"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="storage">
                        <v-expansion-panel-title>{{ t('archiveEntities.panels.storage') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldBytes"
                                        :label="t('archiveEntities.columns.bytes')"
                                        v-model="formattedBytes"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldSheetsCount"
                                        :label="t('archiveEntities.columns.sheetsCount')"
                                        v-model="archivalEntityData.sheetCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row> -->
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldMagneticTapesCount"
                                        :label="t('archiveEntities.columns.magneticTapesQuantity')"
                                        v-model="archivalEntityData.tapeCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row> -->
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldMicrofilmsQuantity"
                                        :label="t('archiveEntities.columns.microfilmsQuantity')"
                                        v-model="archivalEntityData.microfilmCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row> -->
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldFramesCount"
                                        :label="t('archiveEntities.columns.framesCount')"
                                        v-model="archivalEntityData.frameCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row> -->
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldVideoTapesCount"
                                        :label="t('archiveEntities.columns.videoTapesQuantity')"
                                        v-model="archivalEntityData.videoTapeCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row> -->
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldDigitalDevicesCount"
                                        :label="t('archiveEntities.columns.digitalDevicesQuantity')"
                                        v-model="archivalEntityData.digitalDeviceCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row> -->
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldOther"
                                        :label="t('archiveEntities.columns.other')"
                                        v-model="archivalEntityData.otherMetrics"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldAuthor"
                                        :label="t('archiveEntities.columns.creator')"
                                        v-model="archivalEntityData.author"
                                    />
                                </v-col>
                            </v-row>
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldSizeCm"
                                        :label="t('archiveEntities.columns.sizeCm')"
                                        v-model="archivalEntityData.sizeCm"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row> -->
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldScale"
                                        :label="t('archiveEntities.columns.scale')"
                                        v-model="archivalEntityData.scaling"
                                    />
                                </v-col>
                            </v-row> -->
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldExtendedDescription"
                                        :label="t('archiveEntities.columns.extendedDescription')"
                                        v-model="archivalEntityData.description"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <label for="fldOriginality">{{ t('documents.columns.originality') }}</label>
                                    <Dropdown
                                        v-model="archivalEntityData.originalityCodes"
                                        name="fldOriginality"
                                        :label="t('documents.columns.originality')"
                                        labelProp="label"
                                        valueProp="code"
                                        :multiselect="true"
                                        :items="originalities"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldCreationMethod">{{ t('documents.columns.creationMethod') }}</label>
                                    <Dropdown
                                        v-model="archivalEntityData.creationMethodCodes"
                                        name="fldCreationMethod"
                                        :label="t('documents.columns.creationMethod')"
                                        labelProp="label"
                                        valueProp="code"
                                        :multiselect="true"
                                        :items="creationMethods"
                                    />
                                </v-col>
                            </v-row> -->
                            <v-row>
                                <v-col class="col-6">
                                    <label for="fldLanguage">{{ t('archiveEntities.columns.language') }}</label>
                                    <Dropdown
                                        v-model="archivalEntityData.languageCodes"
                                        name="fldLanguage"
                                        :label="t('documents.columns.language')"
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
                                        :label="t('archiveEntities.columns.otherLanguage')"
                                        v-model="archivalEntityData.otherLanguage"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldAccessConditions"
                                        :label="t('archiveEntities.columns.accessConditions')"
                                        v-model="archivalEntityData.documentsAccessDescription"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldSpecifics"
                                        :label="t('archiveEntities.columns.specifics')"
                                        v-model="archivalEntityData.features"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldPhysicalCondition"
                                        :label="t('archiveEntities.columns.physicalCondition')"
                                        v-model="archivalEntityData.condition"
                                    />
                                </v-col>
                            </v-row> -->
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="copies">
                        <v-expansion-panel-title>{{
                            t('archiveEntities.panels.copiesEligibility')
                        }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldMicrofilmedCopiesCount"
                                        :label="t('archiveEntities.columns.microfilm')"
                                        v-model="archivalEntityData.microfilmedCopyCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldDigitalCopy"
                                        :label="t('archiveEntities.columns.digitalCopy')"
                                        v-model="archivalEntityData.digitizedCopyCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldXeroxCopy"
                                        :label="t('archiveEntities.columns.xeroxCopy')"
                                        v-model="archivalEntityData.paperCopyCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldNegativeFramesCount"
                                        :label="t('archiveEntities.columns.negativeFrames')"
                                        v-model="archivalEntityData.negativeFrameCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldPositiveFramesCount"
                                        :label="t('archiveEntities.columns.positiveFrames')"
                                        v-model="archivalEntityData.positiveFrameCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col>
                                    <text-field
                                        name="fldOtherCopyCount"
                                        :label="t('archiveEntities.columns.other')"
                                        v-model="archivalEntityData.otherCopyCount"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldNotes"
                                        :label="t('archiveEntities.columns.notes')"
                                        v-model="archivalEntityData.notes"
                                    />
                                </v-col>
                            </v-row>
                            <v-row
                                v-if="
                                    inventoryData.numberArray === inventoryArray.KE ||
                                    inventoryData.numberArray === inventoryArray.TE
                                "
                            >
                                <v-col class="col-12">
                                    <text-field
                                        name="fldStage"
                                        :label="t('archiveEntities.columns.stage')"
                                        v-model="archivalEntityData.stage"
                                    />
                                </v-col>
                            </v-row>
                            <v-row v-if="inventoryData.numberArray === inventoryArray.PE">
                                <v-col class="col-12 col-md-6">
                                    <text-field
                                        name="fldPhase"
                                        :label="t('archiveEntities.columns.phase')"
                                        v-model="archivalEntityData.phase"
                                    />
                                </v-col>
                                <v-col class="col-12 col-md-6">
                                    <text-field
                                        name="fldPart"
                                        :label="t('archiveEntities.columns.part')"
                                        v-model="archivalEntityData.part"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="availability">
                        <v-expansion-panel-title>{{
                            t('archiveEntities.panels.eligibilityChange')
                        }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12 col-md-6">
                                    <text-field
                                        name="fldEnrolledLinearMeters"
                                        :label="t('archiveEntities.columns.enrolledLinearMeters')"
                                        v-model="archivalEntityData.enrolledLinearMeters"
                                        validation="float"
                                    />
                                </v-col>
                                <v-col class="col-12 col-md-6">
                                    <text-field
                                        name="fldDeductedLinearMeters"
                                        :label="t('archiveEntities.columns.deductedLinearMeters')"
                                        v-model="archivalEntityData.deductedLinearMeters"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12 col-md-6">
                                    <text-field
                                        name="fldEnrolledDocumentCount"
                                        :label="t('archiveEntities.columns.enrolledDocumentsCount')"
                                        v-model="archivalEntityData.enrolledDocumentCount"
                                        validation="numeric"
                                    />
                                </v-col>

                                <v-col class="col-12 col-md-6">
                                    <text-field
                                        name="fldDeductedDocumentsCount"
                                        :label="t('archiveEntities.columns.deductedDocumentsCount')"
                                        v-model="archivalEntityData.deductedDocumentCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldDeductedMB"
                                        :label="t('archiveEntities.columns.deductedMB')"
                                        v-model="formattedDeductedBytes"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <!-- няма ги в базата: -->
                    <!-- <v-expansion-panel value="general">
            <v-expansion-panel-title>{{  t('archiveEntities.panels.participationInAnnotatedLists') }}</v-expansion-panel-title>
            <v-expansion-panel-text>         
            </v-expansion-panel-text> 
          </v-expansion-panel> -->
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
                                {{ t('archiveEntities.buttons.cancelTooltip') }}
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
import {
    transformMonth,
    stringifyDay,
    stringifyYear,
    validateDay,
    formatBytesToMB,
    formatApproximateChronologicalScope,
} from '@/helpers/format.helper';
import { isChronologicalScopeFull, isStartDateBeforeEndDate } from '@/helpers/validate.helper';
import { Message } from '@/models/notification';

import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { IDropdownOption } from '@/interfaces/dropdown';
import { InventoryArray } from '@/enums/inventory';
import { IInventory } from '@/interfaces/inventory';
import { IArchivalEntityDraft } from '@/interfaces/archivalEntity';
import { ArchivalEntityDraft } from '@/models/archivalEntity';
import { Inventory } from '@/models/inventory';
import { NomenclatureCode } from '@/enums/nomenclature';
import archiveEntityService from '@/services/archivalEntity.service';
import inventoryService from '@/services/inventory.service';
import dropdownService from '@/services/dropdown.service';

import { Form } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import Dropdown from '@/components/dropdown/dropdown.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import numberService from '@/services/number.service';

export default defineComponent({
    name: 'CreateArchiveEntity',
    components: {
        Form,
        TextField,
        TextAreaField,
        Switch,
        Dropdown,
        Breadcrumbs,
    },
    props: {
        inventorySystemIdentifier: {
            type: String,
            required: false,
        },
        inventoryHasExternalSource: {
            type: Boolean,
            required: false,
        },
        inventoryExternalIdentifier: {
            type: Number,
            required: false,
        },
        descriptionLevel: {
            type: String,
            required: false,
        },
    },
    setup(props) {
        const { t } = useI18n();

        const message = inject('notificationMessage') as Ref<IMessage>;

        const panel = ref(['general', 'archivalEntityInfo', 'chronologicalScope', 'storage', 'copies', 'availability']);

        const inventoryArray = InventoryArray;

        const router = useRouter();

        const goBack = (val: string) => {
            if (props.inventorySystemIdentifier) {
                useRedirect(
                    router,
                    'DisplayInventory',
                    { id: props.inventorySystemIdentifier },
                    {
                        hasExternalSource: String(props.inventoryHasExternalSource),
                        externalIdentifier: props.inventoryExternalIdentifier,
                    }
                );
            } else {
                useRedirect(router, 'DisplayArchiveEntity', { id: val });
            }
        };

        const isFundDisabled = ref(true);

        const descriptionLevels = ref<IDropdownOption[]>([]);
        const getDescriptionLevels = async () => {
            descriptionLevels.value = await dropdownService.getArchiveEntitiesDescriptionLevels();
        };

        const inventoryData = ref<IInventory>(new Inventory());

        const archivalEntityData = ref<IArchivalEntityDraft>(new ArchivalEntityDraft());
        archivalEntityData.value.descriptionLevelCode = props.descriptionLevel?.toString();

        const startDayValidationString = computed(
            () =>
                `numeric|min_value:1|max_value:${validateDay(
                    archivalEntityData.value.startDateMonth,
                    archivalEntityData.value.startDateYear
                )}`
        );
        const endDayValidationString = computed(
            () =>
                `numeric|min_value:1|max_value:${validateDay(
                    archivalEntityData.value.endDateMonth,
                    archivalEntityData.value.endDateYear
                )}`
        );

        const formattedBytes = computed(() => {
            return formatBytesToMB(archivalEntityData.value.bytes || 0);
        });
        const formattedDeductedBytes = computed(() => {
            return formatBytesToMB(archivalEntityData.value.deductedBytes || 0);
        });

        const initArchivalEntityData = async () => {
            if (props.inventorySystemIdentifier || props.inventoryHasExternalSource) {
                inventoryData.value = await inventoryService.displayInventory(
                    props.inventorySystemIdentifier,
                    props.inventoryHasExternalSource,
                    props.inventoryExternalIdentifier
                );
                archivalEntityData.value.archiveId = inventoryData.value.archiveId;
                archivalEntityData.value.fundDraftId = inventoryData.value.fundDraftId;
                archivalEntityData.value.fundSystemIdentifier = inventoryData.value.fundSystemIdentifier;
                archivalEntityData.value.fundHasExternalSource = inventoryData.value.fundHasExternalSource;
                archivalEntityData.value.fundExternalIdentifier = inventoryData.value.fundExternalIdentifier;
                archivalEntityData.value.inventorySystemIdentifier = inventoryData.value.systemIdentifier;
                archivalEntityData.value.inventoryHasExternalSource = inventoryData.value.hasExternalSource;
                archivalEntityData.value.inventoryExternalIdentifier = inventoryData.value.externalIdentifier;
                if (inventoryData.value.isDraft) {
                    archivalEntityData.value.inventoryDraftId = inventoryData.value.id;
                }
            }
        };

        const showHintMessageForRequiredFields = () => {
            message.value = new Message({
                text: t('common.requiredFields'),
                display: true,
            });
        };

        const getArchivalEntityNumber = async () => {
            try {
                archivalEntityData.value.numberNumeric = await numberService.getArchivalEnitityNumberNumeric(
                    archivalEntityData.value.archiveId!,
                    archivalEntityData.value.inventorySystemIdentifier!,
                    archivalEntityData.value.descriptionLevelCode!
                );
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('archiveEntities.errors.gettingLastNumber'),
                    display: true,
                });
            }
        };
        const showHintMessageRequirements = () => {
            message.value = new Message({
                text: t('common.requirements'),
                display: true,
            });
        };

        const submitarchivalEntityData = async () => {
            try {
                if (chronologicalScopeLabelText.value) {
                    showHintMessageRequirements();
                    return;
                }
                archivalEntityData.value.approximateChronologicalScope = date.value;
                archivalEntityData.value.statusCode = '1';
                archivalEntityData.value.number = `${
                    archivalEntityData.value.numberNumeric ? archivalEntityData.value.numberNumeric.toString() : ''
                }${archivalEntityData.value.numberArray ? archivalEntityData.value.numberArray.trim() : ''}`;

                const result = await archiveEntityService.createArchivalEntity(archivalEntityData.value);
                if (result.status == 200) {
                    message.value = new Message({
                        text: t('common.successfullyCreated'),
                        display: true,
                        type: 'success',
                        timeout: 5000,
                    });
                    goBack(result.data.data);
                } else {
                    message.value = new Message({
                        text: result.response.data.message,
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

        const originalities = ref<IDropdownOption[]>([]);
        const getOriginalities = async () => {
            originalities.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.Originality);
        };
        const creationMethods = ref<IDropdownOption[]>([]);
        const getCreationMethods = async () => {
            creationMethods.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.CreationMethod);
        };
        const languages = ref<IDropdownOption[]>([]);
        const getLanguages = async () => {
            languages.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.Language);
        };

        const approxmateChronologicalScopeString = (): string => {
            let date = '';
            if (archivalEntityData.value != null) {
                if (archivalEntityData.value.startDateMonth) {
                    archivalEntityData.value.startDateMonth = parseInt(
                        archivalEntityData.value.startDateMonth.toString()
                    );
                }

                if (archivalEntityData.value.endDateMonth) {
                    archivalEntityData.value.endDateMonth = parseInt(archivalEntityData.value.endDateMonth.toString());
                }

                const startDay = archivalEntityData.value.startDateDay;
                const startMonth = archivalEntityData.value.startDateMonth;
                const startYear = archivalEntityData.value.startDateYear;
                const endDay = archivalEntityData.value.endDateDay;
                const endMonth = archivalEntityData.value.endDateMonth;
                const endYear = archivalEntityData.value.endDateYear;

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
            if (archivalEntityData.value.hasNoChronologicalScope) {
                date = 'Б.Д.';
                archivalEntityData.value.startDateDay = undefined;
                archivalEntityData.value.startDateMonth = undefined;
                archivalEntityData.value.startDateYear = undefined;
                archivalEntityData.value.endDateDay = undefined;
                archivalEntityData.value.endDateMonth = undefined;
                archivalEntityData.value.endDateYear = undefined;
            }
            archivalEntityData.value.approximateChronologicalScope = date;
            return date.toString();
        };

        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('archiveEntities.archivalEntities'),
                disabled: false,
                to: { name: 'ArchiveEntities' },
            },
            {
                title: t('archiveEntities.create'),
                disabled: true,
            },
        ];

        const date = computed(() => formatApproximateChronologicalScope(approxmateChronologicalScopeString()));

        const chronologicalScopeLabelText = computed(() => {
            if (
                !isChronologicalScopeFull(
                    archivalEntityData.value.startDateDay,
                    archivalEntityData.value.startDateMonth,
                    archivalEntityData.value.startDateYear,
                    archivalEntityData.value.endDateDay,
                    archivalEntityData.value.endDateMonth,
                    archivalEntityData.value.endDateYear
                )
            ) {
                return t('common.isChronologicalScopeFullLabel');
            } else if (
                !isStartDateBeforeEndDate(
                    archivalEntityData.value.startDateDay,
                    archivalEntityData.value.startDateMonth,
                    archivalEntityData.value.startDateYear,
                    archivalEntityData.value.endDateDay,
                    archivalEntityData.value.endDateMonth,
                    archivalEntityData.value.endDateYear
                )
            ) {
                return t('common.isStartDateBeforeEndDateLabel');
            }
            return '';
        });

        const endDateIsAfterStartDate = () => {
            let ok = true;
            if (
                archivalEntityData.value.startDateDay != undefined &&
                archivalEntityData.value.startDateMonth != undefined &&
                archivalEntityData.value.endDateDay != undefined &&
                archivalEntityData.value.endDateMonth != undefined
            ) {
                if (archivalEntityData.value.endDateYear == archivalEntityData.value.startDateYear) {
                    if (
                        archivalEntityData.value.startDateMonth > archivalEntityData.value.endDateMonth ||
                        (archivalEntityData.value.startDateMonth == archivalEntityData.value.endDateMonth &&
                            archivalEntityData.value.startDateDay > archivalEntityData.value.endDateDay)
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
                    archivalEntityData.value.startDateYear &&
                    archivalEntityData.value.endDateYear &&
                    archivalEntityData.value.endDateYear.toString().length == 4
                )
                    if (archivalEntityData.value.endDateYear < archivalEntityData.value.startDateYear) {
                        message.value = new Message({
                            text: t('common.checkDate'),
                            display: true,
                        });
                    } else endDateIsAfterStartDate();
            }
        );

        const setDefaultDescLevel = () =>
            (archivalEntityData.value.descriptionLevelCode = descriptionLevels.value[0].code as string);

        onMounted(async () => {
            window.scrollTo(0, 0);
            await getDescriptionLevels();
            await getOriginalities();
            await getCreationMethods();
            await getLanguages();
            await initArchivalEntityData();
            setDefaultDescLevel();
        });

        return {
            t,
            panel,
            descriptionLevels,
            showHintMessageForRequiredFields,
            inventoryData,
            archivalEntityData,
            isFundDisabled,
            getArchivalEntityNumber,
            submitarchivalEntityData,
            goBack,
            originalities,
            creationMethods,
            languages,
            breadcrumbItems,
            approxmateChronologicalScopeString,
            date,
            startDayValidationString,
            endDayValidationString,
            chronologicalScopeLabelText,
            formattedBytes,
            formattedDeductedBytes,
            inventoryArray,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs-ae.scss';

:deep(.floatingBtnIcon) {
    margin: 0px 0px !important;
}
</style>
