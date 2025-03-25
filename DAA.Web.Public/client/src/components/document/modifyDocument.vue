<template>
    <Loader :isLoading="isLoading" />
    <v-card class="col-12 col-md-10 col-lg-10 ma-auto">
        <Form @submit="submitDocumentData" @invalid-submit="showHintMessageForRequiredFields">
            <v-container>
                <v-expansion-panels v-model="panel" multiple>
                    <v-expansion-panel value="documentInfo">
                        <v-expansion-panel-title>{{ $t('documents.panels.documentInfo') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12 col-md-4 col-lg-4">
                                    <TextField
                                        name="fldDocNum"
                                        :label="t('documents.columns.number')"
                                        v-model="documentData.number"
                                        validation="required|integer|min_value:1"
                                        appendButtonIcon="mdi-numeric"
                                        :appendButtonTooltip="t('documents.buttons.getNumberTooltip')"
                                        appendButtonCssClass="floatingBtnIcon"
                                        @click:append="getDocumentNumber"
                                    />
                                </v-col>
                                
                                <v-col class="col-12 col-md-4 col-lg-4"
                                    v-if="
                                        documentData.inventoryNumberArray === inventoryArray.KE ||
                                        documentData.inventoryNumberArray === inventoryArray.NE ||
                                        documentData.inventoryNumberArray === inventoryArray.PE ||
                                        documentData.inventoryNumberArray === inventoryArray.TE
                                    ">
                                    <text-field
                                        name="fldCypher"
                                        :label="t('documents.columns.cypher')"
                                        v-model="documentData.cypher"
                                    />
                                </v-col>
                            </v-row>
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
                                    <text-field
                                        name="fldDescriptionAuthor"
                                        :label="t('documents.columns.descriptionAuthor')"
                                        v-model="documentData.descriptionAuthor"
                                        auto-grow
                                        :validation="'max:250'"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="chronologicalScope">
                        <v-expansion-panel-title>{{
                            $t('documents.panels.datePlaceOfCreation')
                        }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12 col-lg-3 text-end">
                                    <div>{{ t('documents.startDate') }}</div>
                                </v-col>
                                <v-col class="col-12 col-md-4 col-lg-3">
                                    <text-field
                                        name="fldStartDateDay"
                                        :label="t('common.day')"
                                        v-model="documentData.startDateDay"
                                        :validation="startDayValidationString"
                                    />
                                </v-col>
                                <v-col class="col-12 col-md-4 col-lg-3">
                                    <text-field
                                        name="fldStartDateMonth"
                                        :label="t('common.month')"
                                        v-model="documentData.startDateMonth"
                                        validation="numeric|min_value:1|max_value:12"
                                    />
                                </v-col>
                                <v-col class="col-12 col-md-4 col-lg-3">
                                    <text-field
                                        name="fldStartDateYear"
                                        :label="t('common.year')"
                                        v-model="documentData.startDateYear"
                                        validation="required|numeric|min_value:1000|max_value:2200"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12 col-lg-3 text-end">
                                    <div>{{ t('documents.endDate') }}</div>
                                </v-col>
                                <v-col class="col-12 col-md-4 col-lg-3">
                                    <text-field
                                        name="fldEndDateDay"
                                        :label="t('common.day')"
                                        v-model="documentData.endDateDay"
                                        :validation="endDayValidationString"
                                    />
                                </v-col>
                                <v-col class="col-12 col-md-4 col-lg-3">
                                    <text-field
                                        name="fldEndDateMonth"
                                        :label="t('common.month')"
                                        v-model="documentData.endDateMonth"
                                        validation="numeric|min_value:1|max_value:12"
                                    />
                                </v-col>
                                <v-col class="col-12 col-md-4 col-lg-3">
                                    <text-field
                                        name="fldEndDateYear"
                                        :label="t('common.year')"
                                        v-model="documentData.endDateYear"
                                        validation="required|numeric|min_value:1000|max_value:2200"
                                    />
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
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldAuthor"
                                        :label="t('documents.columns.creator')"
                                        v-model="documentData.author"
                                    />
                                </v-col>
                            </v-row>
                            <v-row
                                v-if="
                                    documentData.inventoryNumberArray === inventoryArray.KE ||
                                    documentData.inventoryNumberArray === inventoryArray.NE ||
                                    documentData.inventoryNumberArray === inventoryArray.PE ||
                                    documentData.inventoryNumberArray === inventoryArray.TE
                                "
                            >
                                <v-col class="col-12 col-md-6">
                                    <text-field
                                        name="fldTextDocsCount"
                                        :label="t('documents.columns.textDocsCount')"
                                        v-model="documentData.textDocsCount"
                                        :validation="'integer|min_value:0'"
                                    />
                                </v-col>
                                <v-col class="col-12 col-md-6">
                                    <text-field
                                        name="fldGraphicalDocsCount"
                                        :label="t('documents.columns.graphicalDocsCount')"
                                        v-model="documentData.graphicalDocsCount"
                                        :validation="'integer|min_value:0'"
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="storage">
                        <v-expansion-panel-title>{{ $t('documents.panels.storage') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldOther"
                                        :label="t('documents.columns.other')"
                                        v-model="documentData.otherMetrics"
                                        :validation="'max:256'"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldScaling"
                                        :label="t('documents.columns.scale')"
                                        v-model="documentData.scaling"
                                        :validation="'max:256'"
                                    />
                                </v-col>
                            </v-row>
                            <v-row
                                v-if="
                                    documentData.inventoryNumberArray === inventoryArray.KE ||
                                    documentData.inventoryNumberArray === inventoryArray.TE
                                "
                            >
                                <v-col class="col-12">
                                    <text-field
                                        name="fldStage"
                                        :label="t('documents.columns.stage')"
                                        v-model="documentData.stage"
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
                            <v-row>
                                <v-col class="col-12 col-lg-6">
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
                                <v-col class="col-12 col-lg-6">
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
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="copies">
                        <v-expansion-panel-title>{{ $t('documents.panels.copiesEligibility') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldNotes"
                                        :label="t('documents.columns.note')"
                                        v-model="documentData.notes"
                                    />
                                </v-col>
                            </v-row>
                            <v-row v-if="documentData.inventoryNumberArray === inventoryArray.PE">
                                <v-col class="col-12 col-md-6">
                                    <text-field
                                        name="fldPhase"
                                        :label="t('documents.columns.phase')"
                                        v-model="documentData.phase"
                                    />
                                </v-col>
                                <v-col class="col-12 col-md-6">
                                    <text-field
                                        name="fldPart"
                                        :label="t('documents.columns.part')"
                                        v-model="documentData.part"
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
                                {{ t('documents.buttons.cancelTooltip') }}
                            </v-tooltip>
                        </v-btn>
                    </v-col>
                </v-row>
            </v-container>
        </Form>
    </v-card>
</template>



<script lang="ts">
import { defineComponent, ref, computed, inject, Ref, onMounted, watch } from 'vue';
import { useI18n } from 'vue-i18n';

import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';

import { NomenclatureCode } from '@/enums/nomenclature';
import { InventoryArray } from '@/enums/inventory';

import { IDropdownOption } from '@/interfaces/dropdown';
import { IDocument } from '@/interfaces/document';
import { Document } from '@/models/document';

import documentService from '@/services/document.service';
import dropdownService from '@/services/dropdown.service';
import numberService from '@/services/number.service';

import { Form } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Dropdown from '@/components/dropdown/dropdown.vue';
import Loader from '@/components/loader/loader.vue';

import { validateDay, getApproximateChronologicalScopeString } from '@/helpers/format.helper';
import { isStartDateBeforeEndDate } from '@/helpers/validate.helper';

export default defineComponent({
    name: 'ModifyDocumentCard',
    components: {
        Dropdown,
        Form,
        TextField,
        TextAreaField,
        Loader,
    },
    props: {
        sysId: {
            type: String,
            required: true,
        },
    },
    emits: ['modified', 'cancel'],
    setup(props, { emit }) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const panel = ref(['documentInfo', 'chronologicalScope', 'storage', 'copies']);
        const onCancel = () => emit('cancel');

        const isLoading = ref(false);

        const inventoryArray = InventoryArray;

        const languages = ref<IDropdownOption[]>([]);
        const getLanguages = async () => {
            try {
                isLoading.value = true;
                languages.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.Language);
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
                    text: errorResult.showMessage ? errorResult.message : t('error.gettingLastNumber'),
                    display: true,
                });
            }
        };

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

        const documentData = ref<IDocument>(new Document());

        const getDocumentData = async () => {
            try {
                isLoading.value = true;
                documentData.value = await documentService.displayDocumentDraft(props.sysId);
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

        const submitDocumentData = async () => {
            if (!documentData.value) {
                return;
            }

            try {
                documentData.value.approximateChronologicalScope = date.value;
                const result = await documentService.modifyDocumentDraft(documentData.value);

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

                emit('modified', result.data.data);
            } catch (error: unknown) {
                console.error(error);
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        
        const showHintMessageForRequiredFields = () => {
            message.value = new Message({
                text: t('common.requiredFields'),
                display: true,
            });
        };

        const date = computed(() =>
            getApproximateChronologicalScopeString(
                documentData.value.startDateDay,
                documentData.value.startDateMonth,
                documentData.value.startDateYear,
                documentData.value.endDateDay,
                documentData.value.endDateMonth,
                documentData.value.endDateYear
            )
        );

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
                    } else {
                        if (
                            isStartDateBeforeEndDate(
                                documentData.value.startDateDay,
                                documentData.value.startDateMonth,
                                documentData.value.startDateYear,
                                documentData.value.endDateDay,
                                documentData.value.endDateMonth,
                                documentData.value.endDateYear
                            ) == false
                        ) {
                            message.value = new Message({
                                text: t('common.checkDate'),
                                display: true,
                            });
                        }
                    }
            }
        );

        onMounted(async () => {
            window.scrollTo(0, 0);
            await getLanguages();
            await getDocumentData();
        });

        return {
            t,
            dropdownService,
            documentData,
            NomenclatureCode,
            onCancel,
            panel,
            submitDocumentData,
            startDayValidationString,
            endDayValidationString,
            languages,
            showHintMessageForRequiredFields,
            isLoading,
            inventoryArray,
            getDocumentNumber,
        };
    },
});
</script>
