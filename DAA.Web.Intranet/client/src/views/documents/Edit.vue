<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('documents.edit') }}</v-card-title>

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
                                        v-model="documentData.archiveName"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <TextField
                                        name="fldFund"
                                        :label="t('documents.columns.fund')"
                                        v-model="documentData.fundNumber"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <TextField
                                        name="fldInventory"
                                        :label="t('documents.columns.inventory')"
                                        v-model="documentData.inventoryNumber"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <TextField
                                        name="fldArchivalEntity"
                                        :label="t('documents.columns.archivalEntity')"
                                        v-model="documentData.archivalEntityNumber"
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
                                    <label for="fldDescriptionLevelCode" class="required">{{
                                        t('documents.columns.descriptionLevel')
                                    }}</label>
                                    <Dropdown
                                        :label="t('documents.columns.descriptionLevel')"
                                        name="fldDescriptionLevelCode"
                                        required="required"
                                        :modelValue="documentData.descriptionLevelCode"
                                        :items="descriptionLevels"
                                        v-model="documentData.descriptionLevelCode"
                                        :disabled="fldDescriptionLevelReadOnly"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldStatus"
                                        :label="t('documents.columns.status')"
                                        v-model="documentData.statusText"
                                        :readonly="true"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="sheets">
                        <v-expansion-panel-title>{{ t('documents.panels.sheetsNumbers') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldStartSheetNumber"
                                        :label="t('documents.columns.from')"
                                        v-model="documentData.startSheetNumber"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldEndSheetNumber"
                                        :label="t('documents.columns.to')"
                                        v-model="documentData.endSheetNumber"
                                    />
                                </v-col>
                            </v-row>
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
                                        :disabled="documentData.hasNoChronologicalScope"
                                        :validation="startDayValidationString"
                                    />
                                </v-col>
                                <v-col class="col-3">
                                    <text-field
                                        name="fldStartDateMonth"
                                        :label="t('common.month')"
                                        v-model="documentData.startDateMonth"
                                        :disabled="documentData.hasNoChronologicalScope"
                                        validation="numeric|min_value:1|max_value:12"
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
                                        :disabled="documentData.hasNoChronologicalScope"
                                        :validation="endDayValidationString"
                                    />
                                </v-col>
                                <v-col class="col-3">
                                    <text-field
                                        name="fldEndDateMonth"
                                        :label="t('common.month')"
                                        v-model="documentData.endDateMonth"
                                        :disabled="documentData.hasNoChronologicalScope"
                                        validation="numeric|min_value:1|max_value:12"
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
                                        v-model="formattedDuration"
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
                                        :readonly="true"
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
import { defineComponent, ref, onMounted, inject, Ref, computed, watch } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { Message } from '@/models/notification';

import { IMessage } from '@/interfaces/notification';
import { IArchive } from '@/interfaces/archive';
import { IDropdownOption } from '@/interfaces/dropdown';
import archiveEntityService from '@/services/archivalEntity.service';
import documentService from '@/services/document.service';
import dropdownService from '@/services/dropdown.service';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import {
    SearchedArchiveEntityRequestModel,
    //ArchiveEntityShort,
} from '@/models/archivalEntity';
import { Document, DocumentDraft } from '@/models/document';
import { NomenclatureCode } from '@/enums/nomenclature';
import { Form } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
//import AsyncDropdown from "@/components/dropdown/asyncDropdown.vue";
import Dropdown from '@/components/dropdown/dropdown.vue';
import { IDocument } from '@/interfaces/document';
import { ResponseResult } from '@/models/responseResult';
import { IProcess } from '@/interfaces/process';
import processService from '@/services/process.service';
import { BusinessObjectType } from '@/models/grid';
import { ProcessType } from '@/enums/process';
import { formatApproximateChronologicalScope, formatDuration } from '@/helpers/format.helper';
//import { useRedirect } from '@/helpers/router.helper'
import {
    transformMonth,
    stringifyYear,
    stringifyDay,
    validateDay,
    parseDuration,
    formatBytesToMB,
} from '@/helpers/format.helper';
import { useRedirectWithId } from '@/helpers/router.helper';
import { isChronologicalScopeFull, isStartDateBeforeEndDate } from '@/helpers/validate.helper';

export default defineComponent({
    name: 'EditArchive',
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
        id: {
            type: String,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();

        const message = inject('notificationMessage') as Ref<IMessage>;

        const router = useRouter();

        const goBack = () => {
            useRedirectWithId(router, 'DisplayDocument', props.id);
            //router.go(-1);
        };

        const panel = ref([
            'general',
            'documentInfo',
            'sheets',
            'chronologicalScope',
            'storage',
            'copies',
            'digitalObject',
        ]);

        const fldDescriptionLevelReadOnly = computed(
            () =>
                activeProcessData.value &&
                (activeProcessData.value?.processTypeId === ProcessType.EditData ||
                    activeProcessData.value?.processTypeId === ProcessType.EditFundData)
        );
        const fldStatusReadOnly = computed(
            () =>
                activeProcessData.value &&
                (activeProcessData.value?.processTypeId === ProcessType.EditData ||
                    activeProcessData.value?.processTypeId === ProcessType.EditFundData)
        );

        const descriptionLevels = ref<IDropdownOption[]>([]);
        const getDescriptionLevels = async () => {
            descriptionLevels.value = await dropdownService.getDocumentDescriptionLevels();
        };

        const documentData = ref<IDocument>(new Document());
        const activeProcessData = ref<IProcess>();

        const duration = ref('');
        const formattedDuration = computed({
            get() {
                // eslint-disable-next-line vue/no-side-effects-in-computed-properties
                return (duration.value = documentData.value.duration
                    ? formatDuration(documentData.value.duration)
                    : '');
            },
            set(val: string) {
                if (val) {
                    duration.value = val;
                } else {
                    duration.value = '';
                }
            },
        });

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

        const getDocumentData = async () => {
            try {
                documentData.value = await documentService.displayDocument(props.id);
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
                        BusinessObjectType.document,
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
        const changeArchiveEntities = (option: IArchive) => {
            if (option) {
                //documentData.value.archiveEntityId = option.id;
                documentData.value.archivalEntityHasExternalSource = option.hasExternalSource;
                documentData.value.archivalEntityExternalIdentifier = option.externalIdentifier;
            }
        };
        const getArchiveEntities = async (searchText: string) => {
            const requestModel = new SearchedArchiveEntityRequestModel({
                //inventoryInternalIdentifier: documentData.value.inventoryId,
                inventoryExternalIdentifier: documentData.value.inventoryExternalIdentifier,
                hasInventoryExternalSource: documentData.value.inventoryExternalIdentifier ? true : false,
                searchText: searchText,
            });
            const result = await archiveEntityService.getArchiveEntitiesShort(requestModel);
            return result;
        };

        function showHintMessageForRequiredFields() {
            message.value = new Message({
                text: t('common.requiredFields'),
                display: true,
            });
        }

        const submitDocumentData = async () => {
            if (documentData.value) {
                try {
                    if (duration.value && duration.value != '') {
                        documentData.value.duration = parseDuration(duration.value.toString());
                    } else {
                        documentData.value.duration = undefined;
                    }
                    documentData.value.approximateChronologicalScope = date.value;
                    const documentDraft = new DocumentDraft(documentData.value);
                    documentDraft.isCurrent = true;
                    documentDraft.readOnly = false;
                    const result = await documentService.updateDocument(documentDraft);
                    if (result.status == 200) {
                        message.value = new Message({
                            text: t('common.successfullyEdit'),
                            display: true,
                            type: 'success',
                            timeout: 5000,
                        });
                        goBack();
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
            }
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

        const showArchiveEntitiesAsyncDropdown = ref(false);
        //const asyncDropdownArchiveEntities = ref();
        const switchToAsyncDropdown = () => {
            showArchiveEntitiesAsyncDropdown.value = true;
            //xxx.value.change();
        };

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
        onMounted(async () => {
            window.scrollTo(0, 0);
            await getDescriptionLevels();
            await getFileTypes();
            await getOriginalities();
            await getCreationMethods();
            await getLanguages();
            await getDocumentData();
            await getActiveProcessData();
        });

        const breadcrumbItems = computed(() => getBreadcrumbs());

        const getBreadcrumbs = () => {
            if (activeProcessData.value?.id) {
                return [
                    {
                        title: documentData.value.archiveName,
                        disabled: false,
                        to: { name: 'Home' },
                    },
                    {
                        title: t('funds.fund'),
                        disabled: false,
                        to: {
                            name: 'DisplayFund',
                            params: { id: documentData.value.fundSystemIdentifier },
                            query: {
                                hasExternalSource: documentData.value.fundHasExternalSource,
                                externalIdentifier: documentData.value.fundSystemIdentifier,
                            },
                        },
                    },
                    {
                        title: t('inventories.inventory'),
                        disabled: false,
                        to: {
                            name: 'DisplayInventory',
                            params: { id: documentData.value.inventorySystemIdentifier },
                            query: {
                                hasExternalSource: documentData.value.inventoryHasExternalSource,
                                externalIdentifier: documentData.value.inventoryExternalIdentifier,
                            },
                        },
                    },
                    {
                        title: t('archiveEntities.archiveEntity'),
                        disabled: false,
                        to: {
                            name: 'DisplayArchiveEntity',
                            params: { id: documentData.value.archivalEntitySystemIdentifier },
                            query: {
                                hasExternalSource: documentData.value.archivalEntityHasExternalSource,
                                externalIdentifier: documentData.value.archivalEntityExternalIdentifier,
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
                        title: documentData.value.archiveName,
                        disabled: false,
                        to: { name: 'Home' },
                    },
                    {
                        title: t('funds.fund'),
                        disabled: false,
                        to: {
                            name: 'DisplayFund',
                            params: { id: documentData.value.fundSystemIdentifier },
                            query: {
                                hasExternalSource: documentData.value.fundHasExternalSource,
                                externalIdentifier: documentData.value.fundSystemIdentifier,
                            },
                        },
                    },
                    {
                        title: t('inventories.inventory'),
                        disabled: false,
                        to: {
                            name: 'DisplayInventory',
                            params: { id: documentData.value.inventorySystemIdentifier },
                            query: {
                                hasExternalSource: documentData.value.inventoryHasExternalSource,
                                externalIdentifier: documentData.value.inventoryExternalIdentifier,
                            },
                        },
                    },
                    {
                        title: t('archiveEntities.archiveEntity'),
                        disabled: false,
                        to: {
                            name: 'DisplayArchiveEntity',
                            params: { id: documentData.value.archivalEntitySystemIdentifier },
                            query: {
                                hasExternalSource: documentData.value.archivalEntityHasExternalSource,
                                externalIdentifier: documentData.value.archivalEntityExternalIdentifier,
                            },
                        },
                    },
                    {
                        title: t('documents.document'),
                        disabled: true,
                    },
                ];
        };
        return {
            t,
            panel,
            descriptionLevels,
            documentData,
            breadcrumbItems,
            fldDescriptionLevelReadOnly,
            fldStatusReadOnly,
            getArchiveEntities,
            changeArchiveEntities,
            submitDocumentData,
            showHintMessageForRequiredFields,
            goBack,
            fileTypes,
            originalities,
            creationMethods,
            languages,
            //preEditArchiveEntity,
            switchToAsyncDropdown,
            showArchiveEntitiesAsyncDropdown,
            approxmateChronologicalScopeString,
            date,
            startDayValidationString,
            endDayValidationString,
            chronologicalScopeLabelText,
            formattedBytes,
            formattedDuration,
            duration,
        };
    },
});
</script>

<style lang="scss" scoped>
//@import "@/assets/styles/index-doc.scss";
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs-doc.scss';
</style>
