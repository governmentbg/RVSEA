<template>
<Loader :isLoading="isLoading" />
    <Breadcrumbs :items="breadcrumbItems" />
    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('documents.display') }}</v-card-title>
        <v-container>
            <v-expansion-panels v-model="panel" multiple>
                <v-expansion-panel value="general">
                    <v-expansion-panel-title>{{
                        t('documents.panels.archivalEntityBasicInfo')
                    }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    v-if="documentData.archiveName"
                                    name="fldArchive"
                                    :label="t('documents.archive')"
                                    v-model="documentData.archiveName"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldFundNumber"
                                    :label="t('documents.fund')"
                                    v-model="documentData.fundNumber"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldInventoryNumber"
                                    :label="t('documents.inventory')"
                                    v-model="documentData.inventoryNumber"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldArchiveEntityNumber"
                                    :label="t('documents.archiveEntity')"
                                    v-model="documentData.archivalEntityNumber"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldNumber"
                                    :label="t('documents.columns.number')"
                                    v-model="documentData.number"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="chronologicalScope">
                    <v-expansion-panel-title>{{
                        t('documents.panels.documentInfo')
                    }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col :class="possibleEmptyFields.title">
                                <text-area-field
                                    name="fldTitle"
                                    :label="t('documents.columns.title')"
                                    v-model="documentData.title"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDescriptionLevel"
                                    :label="t('documents.columns.descriptionLevel')"
                                    v-model="documentData.descriptionLevelText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldFileFormat"
                                    :label="t('documents.columns.fileFormat')"
                                    v-model="documentData.fileTypeText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="processInfo">
                    <v-expansion-panel-title>{{ t('documents.panels.sheetsNumbers') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldStartSheetNumber"
                                    :label="t('documents.columns.from')"
                                    v-model="documentData.startSheetNumber"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldEndSheetNumber"
                                    :label="t('documents.columns.to')"
                                    v-model="documentData.endSheetNumber"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="startProcess">
                    <v-expansion-panel-title>{{ t('documents.panels.datePlaceOfCreation') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <v-col class="col-12">
                                    <Switch
                                        v-model="documentData.hasNoChronologicalScope"
                                        :label="t('documents.columns.chronologicalScope')"
                                        :large="false"
                                        :showLabel="true"
                                        :disabled="true"
                                    />
                                </v-col>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <label>{{ t('documents.startDate') }}</label>
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateDay"
                                    :label="t('common.day')"
                                    v-model="documentData.startDateDay"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateMonth"
                                    :label="t('common.month')"
                                    v-model="documentData.startDateMonth"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateYear"
                                    :label="t('common.year')"
                                    v-model="documentData.startDateYear"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <label>{{ t('documents.endDate') }}</label>
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateDay"
                                    :label="t('common.day')"
                                    v-model="documentData.endDateDay"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateMonth"
                                    :label="t('common.month')"
                                    v-model="documentData.endDateMonth"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateYear"
                                    :label="t('common.year')"
                                    v-model="documentData.endDateYear"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldApproximateChronologicalScope"
                                    :label="t('documents.columns.approximateChronologicalScope')"
                                    v-model="documentData.approximateChronologicalScope"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12">
                                <text-area-field
                                    name="fldLocation"
                                    :label="t('documents.columns.placeOfCreation')"
                                    v-model="documentData.location"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="storage">
                    <v-expansion-panel-title>{{ t('documents.panels.storage') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldSheetsCount"
                                    :label="t('documents.columns.sheetsCount')"
                                    v-model="documentData.sheetCount"
                                    validation="numeric"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDigitalDevice"
                                    :label="t('documents.columns.nonPaperCarrier')"
                                    v-model="documentData.digitalDevice"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldAuthor"
                                    :label="t('documents.columns.creator')"
                                    v-model="documentData.author"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldSizeCm"
                                    :label="t('documents.columns.sizeCm')"
                                    v-model="documentData.sizeCm"
                                    validation="numeric"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldScale"
                                    :label="t('documents.columns.scale')"
                                    v-model="documentData.scaling"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDuration"
                                    :label="t('documents.columns.duration')"
                                    v-model="formattedDuration"
                                    :readonly="true"
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
                            <v-col :class="possibleEmptyFields.extendedDescription">
                                <text-area-field
                                    name="fldExtendedDescription"
                                    :label="t('documents.columns.extendedDescription')"
                                    v-model="documentData.description"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldOriginality"
                                    :label="t('documents.columns.originality')"
                                    v-model="documentData.originalityText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldCreationMethod"
                                    :label="t('documents.columns.creationMethod')"
                                    v-model="documentData.creationMethodText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldLanguage"
                                    :label="t('documents.columns.language')"
                                    v-model="documentData.languageText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldAccessConditions"
                                    :label="t('documents.columns.accessConditions')"
                                    v-model="documentData.documentsAccessDescription"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.specifics">
                                <text-area-field
                                    name="fldSpecifics"
                                    :label="t('documents.columns.specifics')"
                                    v-model="documentData.features"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="externalSource">
                    <v-expansion-panel-title>{{ t('documents.panels.copiesEligibility') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldMicrofilmedCopiesCount"
                                    :label="t('documents.columns.microfilm')"
                                    v-model="documentData.microfilmedCopyCount"
                                    validation="numeric"
                                    :readonly="true"
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
                                    :readonly="true"
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
                                    :readonly="true"
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
                                    :readonly="true"
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
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldOtherCopyCount"
                                    :label="t('documents.columns.other')"
                                    v-model="documentData.otherCopyCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.notes">
                                <text-area-field
                                    name="fldNotes"
                                    :label="t('documents.columns.note')"
                                    v-model="documentData.notes"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="digitalObjects" v-if="renderPanel">
                    <v-expansion-panel-title>{{ t('digitalObjects.docFilesList') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <document-digital-objects :document="documentData" />
                    </v-expansion-panel-text>
                </v-expansion-panel>
            </v-expansion-panels>
        </v-container>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, inject, Ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { IDocument } from '@/interfaces/document';
import documentService from '@/services/document.service';
import { Document } from '@/models/document';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import Switch from '@/components/checkbox/switch.vue';
import { ResponseResult } from '@/models/responseResult';
import documentDigitalObjects from '@/components/digitalObjects/documentDigitalObjects.vue';
import { formatBytesToMB, formatDuration } from '@/helpers/format.helper';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'DisplayDocument',
    components: {
        Loader,
        TextField,
        TextAreaField,
        Switch,
        documentDigitalObjects,
        Breadcrumbs,
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
        const router = useRouter();
        const documentData = ref<IDocument>(new Document());

        const possibleEmptyFields = {
            title: '',
            extendedDescription: '',
            specifics: '',
            notes: '',
        };
        const formattedDuration = computed(() => formatDuration(documentData.value.duration as number));
        const lowClass = 'low';
        const isLoading = ref(false);
        const renderPanel = computed(
            () =>
                documentData.value.systemIdentifier ||
                (documentData.value.hasExternalSource && documentData.value.externalIdentifier)
        );

        const formattedBytes = computed(() => {
            return formatBytesToMB(documentData.value.bytes || 0);
        });

        const goBack = () => {
            router.go(-1);
        };

        const panel = ref(['general', 'chronologicalScope', 'storage', 'digitalObject', 'digitalObjects']);

        const getDocumentData = async () => {
            try {
                isLoading.value = true;
                documentData.value = await documentService.displayDocument(
                    props.id,
                    props.hasExternalSource,
                    props.externalIdentifier
                );

                if (!documentData.value.title) {
                    possibleEmptyFields.title = lowClass;
                }
                if (!documentData.value.description) {
                    possibleEmptyFields.extendedDescription = lowClass;
                }
                if (!documentData.value.features) {
                    possibleEmptyFields.specifics = lowClass;
                }
                if (!documentData.value.notes) {
                    possibleEmptyFields.notes = lowClass;
                }

                if (
                    documentData.value.resultMessage &&
                    documentData.value.resultMessage === 'ISDADataCannotBeDisplayed'
                ) {
                    message.value = new Message({
                        text: t('warnings.ISDADataCannotBeDisplayed'),
                        display: true,
                        type: 'warning',
                    });
                }
                if (documentData.value.sheetCount) {
                    documentData.value.startSheetNumber = 1;
                    documentData.value.endSheetNumber = documentData.value.sheetCount;
                }
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

        const breadcrumbItems = computed(() => [
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
                        externalIdentifier: documentData.value.fundExternalIdentifier,
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
                    name: 'DisplayArchivalEntity',
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
        ]);

        onMounted(async () => {
            window.scrollTo(0, 0);
            await getDocumentData();
        });

        return {
            t,
            goBack,
            formattedDuration,
            panel,
            documentData,
            message,
            breadcrumbItems,
            possibleEmptyFields,
            renderPanel,
            formattedBytes,
            isLoading,
        };
    },
});
</script>

<style lang="scss" scoped>
//@import '@/assets/styles/index.scss';
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs-doc.scss';

:deep(.input-group) {
    background-color: white !important;
}
:deep(.v-container),
.v-container,
:deep(.v-expansion-panels),
:deep(.v-expansion-panel-text),
:deep(.v-expansion-panel-title) {
    margin: 0px !important;
}

:deep(.text-undefined) {
    background-color: white !important;
}

:deep(.float-right button) {
    margin: 0px;
}

.v-expansion-panel--active:has(table) {
    margin-top: 20px !important;
}
:deep(.float-right button) {
    margin: 0px;
}

.low,
:deep(.low div),
:deep(.low textarea) {
    height: 50px;
    margin-bottom: 25px;
}
</style>
