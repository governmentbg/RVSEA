<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('documents.create') }}</v-card-title>

        <Form @submit="submitDocumentData" @invalid-submit="showHintMessageForRequiredFields">
            <v-container>
                <v-expansion-panels v-model="panel" multiple>
                    <v-expansion-panel value="general">
                        <v-expansion-panel-title>{{ t('documents.panels.generalInfo') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <TextField
                                        name="fldArchive"
                                        :label="t('documents.columns.archive')"
                                        v-model="archivalEntityData.archiveName"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <TextField
                                        name="fldFund"
                                        :label="t('documents.columns.fund')"
                                        v-model="archivalEntityData.fundNumber"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <TextField
                                        name="fldInventory"
                                        :label="t('documents.columns.inventory')"
                                        v-model="archivalEntityData.inventoryNumber"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <TextField
                                        name="fldArchivalEntity"
                                        :label="t('documents.columns.archivalEntity')"
                                        v-model="archivalEntityData.number"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <TextField
                                        name="fldDocNum"
                                        :label="t('documents.columns.number')"
                                        v-model="documentData.number"
                                        validation="integer|required"
                                        appendButtonIcon="mdi-numeric"
                                        :appendButtonTooltip="t('documents.buttons.getNumberTooltip')"
                                        appendButtonCssClass="floatingBtnIcon"
                                        @click:append="getDocumentNumber"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label for="fldFileType">{{ t('documents.columns.fileFormat') }}</label>
                                    <Dropdown
                                        v-model="documentData.fileTypeCodes"
                                        name="fldFileType"
                                        :label="t('documents.columns.fileFormat')"
                                        labelProp="label"
                                        valueProp="code"
                                        :multiselect="true"
                                        :items="fileTypes"
                                        :disabled="true"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="documentInfo">
                        <v-expansion-panel-title>{{ t('documents.panels.documentInfo') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldTitle"
                                        :label="t('documents.columns.title')"
                                        v-model="documentData.title"
                                        validation="required"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <label class="required" for="fldDescriptionLevelCode">{{
                                        t('documents.columns.descriptionLevel')
                                    }}</label>
                                    <Dropdown
                                        :label="t('documents.columns.descriptionLevel')"
                                        name="fldDescriptionLevelCode"
                                        required="required"
                                        :items="descriptionLevels"
                                        v-model="documentData.descriptionLevelCode"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="sheets">
                        <v-expansion-panel-title>{{ t('documents.panels.sheetsNumbers') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldStartSheetNumber"
                                        :label="t('documents.columns.from')"
                                        v-model="documentData.startSheetNumber"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row> -->
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldEndSheetNumber"
                                        :label="t('documents.columns.to')"
                                        v-model="documentData.endSheetNumber"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row> -->
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="chronologicalScope">
                        <v-expansion-panel-title>{{
                            t('documents.panels.datePlaceOfCreation')
                        }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <Switch
                                        v-model="documentData.hasNoChronologicalScope"
                                        :label="t('documents.columns.chronologicalScope')"
                                        :large="false"
                                        :showLabel="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-3">
                                    <div>{{ t('documents.startDate') }}</div>
                                </v-col>
                                <v-col class="col-3">
                                    <text-field
                                        name="fldStartDateDay"
                                        :label="t('common.day')"
                                        v-model="documentData.startDateDay"
                                        :validation="startDayValidationString"
                                        :disabled="documentData.hasNoChronologicalScope"
                                    />
                                </v-col>
                                <v-col class="col-3">
                                    <text-field
                                        name="fldStartDateMonth"
                                        :label="t('common.month')"
                                        v-model="documentData.startDateMonth"
                                        validation="numeric|min_value:1|max_value:12"
                                        :disabled="documentData.hasNoChronologicalScope"
                                    />
                                </v-col>
                                <v-col class="col-3">
                                    <text-field
                                        name="fldStartDateYear"
                                        :label="t('common.year')"
                                        v-model="documentData.startDateYear"
                                        :disabled="documentData.hasNoChronologicalScope"
                                        :validation="
                                            !documentData.hasNoChronologicalScope
                                                ? 'required|numeric|min_value:1000|max_value:2200'
                                                : 'numeric|min_value:1000|max_value:2200'
                                        "
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-3">
                                    <div>{{ t('documents.endDate') }}</div>
                                </v-col>
                                <v-col class="col-3">
                                    <text-field
                                        name="fldEndDateDay"
                                        :label="t('common.day')"
                                        v-model="documentData.endDateDay"
                                        :validation="endDayValidationString"
                                        :disabled="documentData.hasNoChronologicalScope"
                                    />
                                </v-col>
                                <v-col class="col-3">
                                    <text-field
                                        name="fldEndDateMonth"
                                        :label="t('common.month')"
                                        v-model="documentData.endDateMonth"
                                        validation="numeric|min_value:1|max_value:12"
                                        :disabled="documentData.hasNoChronologicalScope"
                                    />
                                </v-col>
                                <v-col class="col-3">
                                    <text-field
                                        name="fldEndDateYear"
                                        :label="t('common.year')"
                                        v-model="documentData.endDateYear"
                                        :disabled="documentData.hasNoChronologicalScope"
                                        :validation="
                                            !documentData.hasNoChronologicalScope
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
                                        :label="t('documents.columns.approximateChronologicalScope')"
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
                                        :label="t('documents.columns.placeOfCreation')"
                                        v-model="documentData.location"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="storage">
                        <v-expansion-panel-title>{{ t('documents.panels.storage') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldSheetsCount"
                                        :label="t('documents.columns.sheetsCount')"
                                        v-model="documentData.sheetCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row> -->
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldDigitalDevice"
                                        :label="t('documents.columns.nonPaperCarrier')"
                                        v-model="documentData.digitalDevice"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldAuthor"
                                        :label="t('documents.columns.creator')"
                                        v-model="documentData.author"
                                    />
                                </v-col>
                            </v-row>
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldSizeCm"
                                        :label="t('documents.columns.sizeCm')"
                                        v-model="documentData.sizeCm"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row> -->
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldScale"
                                        :label="t('documents.columns.scale')"
                                        v-model="documentData.scaling"
                                    />
                                </v-col>
                            </v-row> -->
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldDuration"
                                        :label="t('documents.columns.duration')"
                                        v-model="documentData.duration"
                                        validation="duration"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldBytes"
                                        :label="t('documents.columns.bytes')"
                                        v-model="formattedBytes"
                                        :disabled="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldExtendedDescription"
                                        :label="t('documents.columns.extendedDescription')"
                                        v-model="documentData.description"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                            <!-- <v-row>
                                <v-col class="col-12">
                                    <label for="fldOriginality">{{ t('documents.columns.originality') }}</label>
                                    <Dropdown
                                        v-model="documentData.originalityCodes"
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
                                        v-model="documentData.creationMethodCodes"
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
                                    <label for="fldLanguage">{{ t('documents.columns.language') }}</label>
                                    <Dropdown
                                        v-model="documentData.languageCodes"
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
                                        :label="t('documents.columns.otherLanguage')"
                                        v-model="documentData.otherLanguage"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldAccessConditions"
                                        :label="t('documents.columns.accessConditions')"
                                        v-model="documentData.documentsAccessDescription"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldSpecifics"
                                        :label="t('documents.columns.specifics')"
                                        v-model="documentData.features"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="copies">
                        <v-expansion-panel-title>{{ t('documents.panels.copiesEligibility') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldMicrofilmedCopiesCount"
                                        :label="t('documents.columns.microfilm')"
                                        v-model="documentData.microfilmedCopyCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldDigitalCopy"
                                        :label="t('documents.columns.digitalCopy')"
                                        v-model="documentData.digitizedCopyCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldXeroxCopy"
                                        :label="t('documents.columns.xeroxCopy')"
                                        v-model="documentData.paperCopyCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldNegativeFramesCount"
                                        :label="t('documents.columns.negativeFrames')"
                                        v-model="documentData.negativeFrameCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldPositiveFramesCount"
                                        :label="t('documents.columns.positiveFrames')"
                                        v-model="documentData.positiveFrameCount"
                                        validation="numeric"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldOtherCopyCount"
                                        :label="t('documents.columns.other')"
                                        v-model="documentData.otherCopyCount"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldNotes"
                                        :label="t('documents.columns.note')"
                                        v-model="documentData.notes"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="digitalObject">
                        <v-expansion-panel-title>{{ t('documents.panels.digitalObject') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldTranscription"
                                        :label="t('documents.columns.textTranscription')"
                                        v-model="documentData.transcription"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                </v-expansion-panels>
                <v-row v-if="!IsInProcess" class="mt-3">
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
                                {{ t('documents.buttons.cancelTooltip') }}
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

import { IMessage } from '@/interfaces/notification';
import { IDropdownOption } from '@/interfaces/dropdown';
import archiveEntityService from '@/services/archivalEntity.service';
import documentService from '@/services/document.service';
import dropdownService from '@/services/dropdown.service';
import { ArchivalEntity } from '@/models/archivalEntity';
// import { FundShort } from '@/models/fund';
// import { InventoryShort } from '@/models/inventory';
import { DocumentDraft } from '@/models/document';
import { NomenclatureCode } from '@/enums/nomenclature';
import { IDocumentDraft } from '@/interfaces/document';
import { ResponseResult } from '@/models/responseResult';
import { IArchivalEntity } from '@/interfaces/archivalEntity';

import { Form } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
//import AsyncDropdown from '@/components/dropdown/asyncDropdown.vue';
import Dropdown from '@/components/dropdown/dropdown.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { ProcessType } from '@/enums/process';
import { ProcedureCreateModel } from '@/models/documentCreateProc';
import documentProcedureService from '@/services/documentCreatingProcedure.service';
import {
    transformMonth,
    stringifyDay,
    stringifyYear,
    validateDay,
    parseDuration,
    formatBytesToMB,
    formatApproximateChronologicalScope,
} from '@/helpers/format.helper';
import { isChronologicalScopeFull, isStartDateBeforeEndDate } from '@/helpers/validate.helper';
import numberService from '@/services/number.service';

export default defineComponent({
    name: 'CreateArchive',
    components: {
        Form,
        TextField,
        TextAreaField,
        Switch,
        //AsyncDropdown,
        Dropdown,
        Breadcrumbs,
    },
    props: {
        archivalEntitySystemIdentifier: {
            type: String,
            required: false,
        },
        archivalEntityHasExternalSource: {
            type: Boolean,
            required: false,
        },
        archivalEntityExternalIdentifier: {
            type: Number,
            required: false,
        },
        processType: {
            type: Number,
            required: false,
        },
    },
    setup(props) {
        const { t } = useI18n();

        const message = inject('notificationMessage') as Ref<IMessage>;

        const panel = ref([
            'general',
            'documentInfo',
            'sheets',
            'chronologicalScope',
            'storage',
            'copies',
            'digitalObject',
        ]);

        const router = useRouter();

        const IsInProcess = ref(false);

        const goBack = (val: string) => {
            if (props.archivalEntitySystemIdentifier) {
                useRedirect(
                    router,
                    'DisplayArchiveEntity',
                    { id: props.archivalEntitySystemIdentifier },
                    {
                        hasExternalSource: String(props.archivalEntityHasExternalSource),
                        externalIdentifier: props.archivalEntityExternalIdentifier,
                    }
                );
            } else {
                useRedirect(router, 'DisplayDocument', { id: val });
            }
        };

        // const archives = ref<IDropdownOption[]>([]);
        // const getArchives = async () => {
        //     archives.value = await dropdownService.getArchives();
        // };

        const descriptionLevels = ref<IDropdownOption[]>([]);
        const getDescriptionLevels = async () => {
            descriptionLevels.value = await dropdownService.getDocumentDescriptionLevels();
        };

        const fileTypes = ref<IDropdownOption[]>([]);
        const getFileTypes = async () => {
            fileTypes.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.FileType);
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

        const archivalEntityData = ref<IArchivalEntity>(new ArchivalEntity());
        const documentData = ref<IDocumentDraft>(new DocumentDraft());

        const startDayValidationString = computed(
            () =>
                `numeric|min_value:1|max_value:${validateDay(
                    documentData.value.startDateMonth,
                    documentData.value.startDateYear
                )}`
        );
        const endDayValidationString = computed(
            () =>
                `numeric|min_value:1|max_value:${validateDay(
                    documentData.value.endDateMonth,
                    documentData.value.endDateYear
                )}`
        );

        const formattedBytes = computed(() => {
            return formatBytesToMB(documentData.value.bytes || 0);
        });

        const initDocumentData = async () => {
            if (props.archivalEntitySystemIdentifier || props.archivalEntityHasExternalSource) {
                archivalEntityData.value = await archiveEntityService.displayArchivalEntity(
                    props.archivalEntitySystemIdentifier,
                    props.archivalEntityHasExternalSource,
                    props.archivalEntityExternalIdentifier
                );
                documentData.value.archiveId = archivalEntityData.value.archiveId;
                documentData.value.fundDraftId = archivalEntityData.value.fundDraftId;
                documentData.value.fundSystemIdentifier = archivalEntityData.value.fundSystemIdentifier;
                documentData.value.fundHasExternalSource = archivalEntityData.value.fundHasExternalSource;
                documentData.value.fundExternalIdentifier = archivalEntityData.value.fundExternalIdentifier;
                documentData.value.inventoryDraftId = archivalEntityData.value.inventoryDraftId;
                documentData.value.inventorySystemIdentifier = archivalEntityData.value.inventorySystemIdentifier;
                documentData.value.inventoryHasExternalSource = archivalEntityData.value.inventoryHasExternalSource;
                documentData.value.inventoryExternalIdentifier = archivalEntityData.value.inventoryExternalIdentifier;
                documentData.value.archivalEntitySystemIdentifier = archivalEntityData.value.systemIdentifier;
                documentData.value.archivalEntityHasExternalSource = archivalEntityData.value.hasExternalSource;
                documentData.value.archivalEntityExternalIdentifier = archivalEntityData.value.externalIdentifier;
                if (archivalEntityData.value.isDraft) {
                    documentData.value.archivalEntityDraftId = archivalEntityData.value.id;
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

        const submitDocumentData = async () => {
            try {
                if (chronologicalScopeLabelText.value) {
                    showHintMessageRequirements();
                    return;
                } else {
                    documentData.value.approximateChronologicalScope = date.value;
                }
                documentData.value.statusCode = '1';
                if (documentData.value.duration) {
                    documentData.value.duration = parseDuration(documentData.value.duration.toString());
                }
                const result = await documentService.createDocument(documentData.value);
                if (result.status == 200) {
                    message.value = new Message({
                        text: t('common.successfullyCreated'),
                        display: true,
                        type: 'success',
                        timeout: 5000,
                    });
                    if (
                        props.processType == ProcessType.AddDocument ||
                        props.processType == ProcessType.PreparationOfADigitalObject
                    ) {
                        const submitData = new ProcedureCreateModel();
                        submitData.documentSys = result.data.data;
                        submitData.archiveId = documentData.value.archiveId;
                        submitData.procedureType = props.processType;

                        await documentProcedureService.startProcess(submitData);

                        useRedirect(router, 'DisplayDocument', { id: result.data.data });
                    } else goBack(result.data.data);
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

        // const getFunds = async (searchText: string) => {
        //     const archiveCode = archives.value.find((arc) => arc.id === documentData.value.archiveId)?.code;
        //     if (archiveCode) {
        //         const result = await dropdownService.getFunds(searchText, Number.parseInt(String(archiveCode)));
        //         return result;
        //     }
        // };

        // const getInventories = async (searchText: string) => {
        //     const result = await dropdownService.getInventories(
        //         searchText,
        //         documentData.value.fundSystemIdentifier,
        //         documentData.value.fundHasExternalSource,
        //         documentData.value.fundExternalIdentifier
        //     );
        //     return result;

        //     // const requestModel = new SearchedInventoryRequestModel({
        //     //   fundInternalIdentifier: documentData.value.fundSystemIdentifier,
        //     //   fundExternalIdentifier: documentData.value.fundExternalIdentifier,
        //     //   hasFundExternalSource: documentData.value.fundHasExternalSource,
        //     //   searchText: searchText,
        //     // });
        //     // const result = await inventoryService.getInventoriesShort(requestModel);
        //     // return result;
        // };

        // const getArchivalEntities = async (searchText: string) => {
        //     const requestModel = new SearchedArchiveEntityRequestModel({
        //         inventoryInternalIdentifier: documentData.value.inventorySystemIdentifier,
        //         inventoryExternalIdentifier: documentData.value.inventoryExternalIdentifier,
        //         hasInventoryExternalSource: documentData.value.inventoryHasExternalSource,
        //         searchText: searchText,
        //     });
        //     const result = await archiveEntityService.getArchiveEntitiesShort(requestModel);
        //     return result;
        // };

        // const changeFunds = (option: FundShort) => {
        //     if (option) {
        //         documentData.value.fundDraftId = option.isDraft ? option.id : undefined;
        //         documentData.value.fundSystemIdentifier = option.systemIdentifier;
        //         documentData.value.fundHasExternalSource = option.hasExternalSource;
        //         documentData.value.fundExternalIdentifier = option.externalIdentifier;
        //     } else {
        //         documentData.value.fundDraftId = undefined;
        //         documentData.value.fundSystemIdentifier = undefined;
        //         documentData.value.fundHasExternalSource = undefined;
        //         documentData.value.fundExternalIdentifier = undefined;
        //     }
        //     documentData.value.inventoryDraftId = undefined;
        //     documentData.value.inventorySystemIdentifier = undefined;
        //     documentData.value.inventoryHasExternalSource = undefined;
        //     documentData.value.inventoryExternalIdentifier = undefined;
        //     documentData.value.archivalEntityDraftId = undefined;
        //     documentData.value.archivalEntitySystemIdentifier = undefined;
        //     documentData.value.archivalEntityHasExternalSource = undefined;
        //     documentData.value.archivalEntityExternalIdentifier = undefined;
        // };

        // const changeInventories = (option: InventoryShort) => {
        //     if (option) {
        //         documentData.value.inventoryDraftId = option.isDraft ? option.id : undefined;
        //         documentData.value.inventorySystemIdentifier = option.systemIdentifier;
        //         documentData.value.inventoryHasExternalSource = option.hasExternalSource;
        //         documentData.value.inventoryExternalIdentifier = option.externalIdentifier;
        //     } else {
        //         documentData.value.inventoryDraftId = undefined;
        //         documentData.value.inventorySystemIdentifier = undefined;
        //         documentData.value.inventoryHasExternalSource = undefined;
        //         documentData.value.inventoryExternalIdentifier = undefined;
        //     }
        //     documentData.value.archivalEntityDraftId = undefined;
        //     documentData.value.archivalEntitySystemIdentifier = undefined;
        //     documentData.value.archivalEntityHasExternalSource = undefined;
        //     documentData.value.archivalEntityExternalIdentifier = undefined;
        // };

        // const changeArchivalEntities = (option: ArchivalEntityShort) => {
        //     if (option) {
        //         //todo fix
        //         //documentData.value.archivalEntitySystemIdentifier = option.id;
        //         documentData.value.archivalEntityExternalIdentifier = option.externalIdentifier;
        //         documentData.value.archivalEntityHasExternalSource = option.hasExternalSource;
        //     } else {
        //         documentData.value.archivalEntityDraftId = undefined;
        //         documentData.value.archivalEntitySystemIdentifier = undefined;
        //         documentData.value.archivalEntityHasExternalSource = undefined;
        //         documentData.value.archivalEntityExternalIdentifier = undefined;
        //     }
        // };

        const approxmateChronologicalScopeString = (): string => {
            let date = '';
            if (documentData.value != null) {
                if (documentData.value.startDateMonth) {
                    documentData.value.startDateMonth = parseInt(documentData.value.startDateMonth.toString());
                }

                if (documentData.value.endDateMonth) {
                    documentData.value.endDateMonth = parseInt(documentData.value.endDateMonth.toString());
                }

                const startDay = documentData.value.startDateDay;
                const startMonth = documentData.value.startDateMonth;
                const startYear = documentData.value.startDateYear;
                const endDay = documentData.value.endDateDay;
                const endMonth = documentData.value.endDateMonth;
                const endYear = documentData.value.endDateYear;

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
            if (documentData.value.hasNoChronologicalScope) {
                date = 'Б.Д.';
                documentData.value.startDateDay = undefined;
                documentData.value.startDateMonth = undefined;
                documentData.value.startDateYear = undefined;
                documentData.value.endDateDay = undefined;
                documentData.value.endDateMonth = undefined;
                documentData.value.endDateYear = undefined;
            }

            documentData.value.approximateChronologicalScope = date;
            return date.toString();
        };

        const date = computed(() => formatApproximateChronologicalScope(approxmateChronologicalScopeString()));

        const chronologicalScopeLabelText = computed(() => {
            if (
                !isChronologicalScopeFull(
                    documentData.value.startDateDay,
                    documentData.value.startDateMonth,
                    documentData.value.startDateYear,
                    documentData.value.endDateDay,
                    documentData.value.endDateMonth,
                    documentData.value.endDateYear
                )
            ) {
                return t('common.isChronologicalScopeFullLabel');
            } else if (
                !isStartDateBeforeEndDate(
                    documentData.value.startDateDay,
                    documentData.value.startDateMonth,
                    documentData.value.startDateYear,
                    documentData.value.endDateDay,
                    documentData.value.endDateMonth,
                    documentData.value.endDateYear
                )
            ) {
                return t('common.isStartDateBeforeEndDateLabel');
            }
            return '';
        });

        const endDateIsAfterStartDate = () => {
            let ok = true;
            if (
                documentData.value.startDateDay != undefined &&
                documentData.value.startDateMonth != undefined &&
                documentData.value.endDateDay != undefined &&
                documentData.value.endDateMonth != undefined
            ) {
                if (documentData.value.endDateYear == documentData.value.startDateYear) {
                    if (
                        documentData.value.startDateMonth > documentData.value.endDateMonth ||
                        (documentData.value.startDateMonth == documentData.value.endDateMonth &&
                            documentData.value.startDateDay > documentData.value.endDateDay)
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
                    documentData.value.startDateYear &&
                    documentData.value.endDateYear &&
                    documentData.value.endDateYear.toString().length == 4
                )
                    if (documentData.value.endDateYear < documentData.value.startDateYear) {
                        message.value = new Message({
                            text: t('common.checkDate'),
                            display: true,
                        });
                    } else endDateIsAfterStartDate();
            }
        );
        const setDefaultDescLevel = () =>
            (documentData.value.descriptionLevelCode = descriptionLevels.value[0].code as string);

        const getDocumentNumber = async () => {
            try {
                documentData.value.number = await numberService.getDocumentNumberNumeric(
                    documentData.value.archiveId!,
                    documentData.value.inventorySystemIdentifier!,
                    documentData.value.archivalEntitySystemIdentifier!
                );
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('archiveEntities.errors.gettingLastNumber'),
                    display: true,
                });
            }
        };
        onMounted(async () => {
            window.scrollTo(0, 0);
            //await getArchives();
            await getDescriptionLevels();
            await getFileTypes();
            await getOriginalities();
            await getCreationMethods();
            await getLanguages();
            await initDocumentData();
            setDefaultDescLevel();
        });

        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('archives.documents'),
                disabled: false,
                to: {
                    name: 'Documents',
                },
            },
            {
                title: t('documents.create'),
                disabled: true,
            },
        ];
        return {
            t,
            panel,
            archivalEntityData,
            documentData,
            goBack,
            getDocumentNumber,
            submitDocumentData,
            showHintMessageForRequiredFields,
            descriptionLevels,
            //archives,
            fileTypes,
            originalities,
            breadcrumbItems,
            creationMethods,
            languages,
            IsInProcess,
            approxmateChronologicalScopeString,
            date,
            startDayValidationString,
            endDayValidationString,
            chronologicalScopeLabelText,
            formattedBytes,
        };
    },
});
</script>

<style lang="scss" scoped>
//@import "@/assets/styles/index-doc.scss";
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs-doc.scss';

:deep(.floatingBtnIcon) {
    margin: 0px 0px !important;
}
</style>
