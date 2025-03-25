<template>
    <Loader :isLoading="isLoading" />
    <v-card class="col-12 col-md-10 col-lg-10 ma-auto">
        <Form @submit="submitArchivalEntityData" @invalid-submit="showHintMessageForRequiredFields">
            <v-container>
                <v-expansion-panels v-model="panel" multiple>
                    <v-expansion-panel value="archivalEntityInfo">
                        <v-expansion-panel-title>{{ $t('archiveEntities.panels.archivalEntityInfo') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12 col-md-4 col-lg-4">
                                    <TextField
                                        name="fldNumberArray"
                                        :label="t('archiveEntities.columns.numberArray')"
                                        v-model="archivalEntityData.numberArray"
                                        validation="max:250"
                                    />
                                </v-col>
                                <v-col class="col-12 col-md-4 col-lg-4">
                                    <TextField
                                        name="fldNumberNumeric"
                                        :label="t('archiveEntities.columns.numberNumeric')"
                                        v-model="archivalEntityData.numberNumeric"
                                        validation="required|integer|min_value:1"
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
                                        validation="max:250"
                                    />
                                </v-col>
                            </v-row>
                            <v-row
                                v-if="
                                    archivalEntityData.inventoryNumberArray === inventoryArray.KE ||
                                    archivalEntityData.inventoryNumberArray === inventoryArray.NE ||
                                    archivalEntityData.inventoryNumberArray === inventoryArray.PE ||
                                    archivalEntityData.inventoryNumberArray === inventoryArray.TE
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
                            $t('archiveEntities.panels.datePlaceOfCreation')
                        }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12 col-lg-3">
                                    <div>{{ t('archiveEntities.startDate') }}</div>
                                </v-col>
                                <v-col class="col-12 col-md-4 col-lg-3">
                                    <text-field
                                        name="fldStartDateDay"
                                        :label="t('common.day')"
                                        v-model="archivalEntityData.startDateDay"
                                        :validation="startDayValidationString"
                                    />
                                </v-col>
                                <v-col class="col-12 col-md-4 col-lg-3">
                                    <text-field
                                        name="fldStartDateMonth"
                                        :label="t('common.month')"
                                        v-model="archivalEntityData.startDateMonth"
                                        validation="numeric|min_value:1|max_value:12"
                                    />
                                </v-col>
                                <v-col class="col-12 col-md-4 col-lg-3">
                                    <text-field
                                        name="fldStartDateYear"
                                        :label="t('common.year')"
                                        v-model="archivalEntityData.startDateYear"
                                        validation="required|numeric|min_value:1000|max_value:2200"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12 col-lg-3">
                                    <div>{{ t('archiveEntities.endDate') }}</div>
                                </v-col>
                                <v-col class="col-12 col-md-4 col-lg-3">
                                    <text-field
                                        name="fldEndDateDay"
                                        :label="t('common.day')"
                                        v-model="archivalEntityData.endDateDay"
                                        :validation="endDayValidationString"
                                    />
                                </v-col>
                                <v-col class="col-12 col-md-4 col-lg-3">
                                    <text-field
                                        name="fldEndDateMonth"
                                        :label="t('common.month')"
                                        v-model="archivalEntityData.endDateMonth"
                                        validation="numeric|min_value:1|max_value:12"
                                    />
                                </v-col>
                                <v-col class="col-12 col-md-4 col-lg-3">
                                    <text-field
                                        name="fldEndDateYear"
                                        :label="t('common.year')"
                                        v-model="archivalEntityData.endDateYear"
                                        validation="required|numeric|min_value:1000|max_value:2200"
                                    />
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
                        <v-expansion-panel-title>{{ $t('archiveEntities.panels.storage') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row
                                v-if="
                                    archivalEntityData.inventoryNumberArray === inventoryArray.KE ||
                                    archivalEntityData.inventoryNumberArray === inventoryArray.NE ||
                                    archivalEntityData.inventoryNumberArray === inventoryArray.PE ||
                                    archivalEntityData.inventoryNumberArray === inventoryArray.TE
                                "
                            >
                                <v-col class="col-12 col-md-6">
                                    <text-field
                                        name="fldTextDocsCount"
                                        :label="t('archiveEntities.columns.textDocsCount')"
                                        v-model="archivalEntityData.textDocsCount"
                                        :validation="'integer|min_value:0'"
                                    />
                                </v-col>
                                <v-col class="col-12 col-md-6">
                                    <text-field
                                        name="fldGraphicalDocsCount"
                                        :label="t('archiveEntities.columns.graphicalDocsCount')"
                                        v-model="archivalEntityData.graphicalDocsCount"
                                        :validation="'integer|min_value:0'"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldOther"
                                        :label="t('archiveEntities.columns.other')"
                                        v-model="archivalEntityData.otherMetrics"
                                        :validation="'max:256'"
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
                            <v-row>
                                <v-col class="col-12">
                                    <text-field
                                        name="fldScaling"
                                        :label="t('archiveEntities.columns.scale')"
                                        v-model="archivalEntityData.scaling"
                                        :validation="'max:256'"
                                    />
                                </v-col>
                            </v-row>
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
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldDescriptionAuthor"
                                        :label="t('archiveEntities.columns.descriptionAuthor')"
                                        v-model="archivalEntityData.descriptionAuthor"
                                        auto-grow
                                        :validation="'max:250'"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12 col-lg-6">
                                    <label for="fldLanguage">{{ t('archiveEntities.columns.language') }}</label>
                                    <Dropdown
                                        v-model="archivalEntityData.languageCodes"
                                        name="fldLanguage"
                                        :label="t('archiveEntities.columns.language')"
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
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="copies">
                        <v-expansion-panel-title>{{ $t('archiveEntities.panels.copiesEligibility') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
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
                                    archivalEntityData.inventoryNumberArray === inventoryArray.KE ||
                                    archivalEntityData.inventoryNumberArray === inventoryArray.TE
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
                            <v-row v-if="archivalEntityData.inventoryNumberArray === inventoryArray.PE">
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
                                {{ t('archiveEntities.buttons.cancelTooltip') }}
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
import { IArchivalEntity } from '@/interfaces/archivalEntity';
import { ArchivalEntity } from '@/models/archivalEntity';

import archiveEntityService from '@/services/archivalEntity.service';
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
    name: 'ModifyArchivalEntityCard',
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

        const panel = ref(['archivalEntityInfo', 'additional', 'chronologicalScope', 'storage', 'copies']);
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
                    text: errorResult.showMessage ? errorResult.message : t('error.gettingLastNumber'),
                    display: true,
                });
            }
        };

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

        const archivalEntityData = ref<IArchivalEntity>(new ArchivalEntity());

        const getArchivalEntityData = async () => {
            try {
                isLoading.value = true;
                archivalEntityData.value = await archiveEntityService.displayArchivalEntityDraft(props.sysId);
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

        const submitArchivalEntityData = async () => {
            if (!archivalEntityData.value) {
                return;
            }

            try {
                archivalEntityData.value.approximateChronologicalScope = date.value;
                const result = await archiveEntityService.modifyArchivalEntityDraft(archivalEntityData.value);

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
                archivalEntityData.value.startDateDay,
                archivalEntityData.value.startDateMonth,
                archivalEntityData.value.startDateYear,
                archivalEntityData.value.endDateDay,
                archivalEntityData.value.endDateMonth,
                archivalEntityData.value.endDateYear
            )
        );

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
                    } else {
                        if (
                            isStartDateBeforeEndDate(
                                archivalEntityData.value.startDateDay,
                                archivalEntityData.value.startDateMonth,
                                archivalEntityData.value.startDateYear,
                                archivalEntityData.value.endDateDay,
                                archivalEntityData.value.endDateMonth,
                                archivalEntityData.value.endDateYear
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
            await getArchivalEntityData();
        });

        return {
            t,
            dropdownService,
            archivalEntityData,
            NomenclatureCode,
            onCancel,
            panel,
            submitArchivalEntityData,
            startDayValidationString,
            endDayValidationString,
            languages,
            showHintMessageForRequiredFields,
            isLoading,
            inventoryArray,
            getArchivalEntityNumber,
        };
    },
});
</script>
