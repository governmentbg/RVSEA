<template>
    <Loader :isLoading="isLoading" />
    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <Form @submit="submitInventoryData" @invalid-submit="showHintMessageForRequiredFields">
            <v-container>
                <v-expansion-panels v-model="panel" multiple>
                    <v-expansion-panel value="general">
                        <v-expansion-panel-title>{{ $t('inventories.panels.generalInfo') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
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
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                    <v-expansion-panel value="chronologicalScope">
                        <v-expansion-panel-title>{{
                            $t('inventories.panels.chronologicalScope')
                        }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
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
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldStartDateMonth"
                                        :label="t('inventories.columns.month')"
                                        v-model="inventoryData.startDateMonth"
                                        validation="numeric|min_value:1|max_value:12"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldStartDateYear"
                                        :label="t('inventories.columns.year')"
                                        v-model="inventoryData.startDateYear"
                                        validation="required|numeric|min_value:1000|max_value:2200"
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
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldEndDateMonth"
                                        :label="t('inventories.columns.month')"
                                        v-model="inventoryData.endDateMonth"
                                        validation="numeric|min_value:1|max_value:12"
                                    />
                                </v-col>
                                <v-col class="col-12 col-lg-4">
                                    <text-field
                                        name="fldEndDateYear"
                                        :label="t('inventories.columns.year')"
                                        v-model="inventoryData.endDateYear"
                                        validation="required|numeric|min_value:1000|max_value:2200"
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
                                        name="fldOtherMetrics"
                                        :label="t('inventories.columns.otherMetrics')"
                                        v-model="inventoryData.otherMetrics"
                                        :validation="'max:256'"
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
                                        :label="t('inventories.columns.fundCreatorTitleHistory')"
                                        v-model="inventoryData.fundCreatorTitleHistory"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldFundCreatorBiographicalHistory"
                                        :label="t('inventories.columns.fundCreatorBiographicalHistory')"
                                        v-model="inventoryData.fundCreatorBiographicalHistory"
                                        :validation="'required'"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldHistory"
                                        :label="t('inventories.columns.history')"
                                        v-model="inventoryData.history"
                                        :validation="'required'"
                                        auto-grow
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
</template>



<script lang="ts">
import { defineComponent, ref, computed, inject, Ref, onMounted, watch } from 'vue';
import { useI18n } from 'vue-i18n';

import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';

import { NomenclatureCode } from '@/enums/nomenclature';

import { IDropdownOption } from '@/interfaces/dropdown';
import { IInventory } from '@/interfaces/inventory';
import { Inventory } from '@/models/inventory';

import inventoryService from '@/services/inventory.service';
import dropdownService from '@/services/dropdown.service';

import { Form } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Dropdown from '@/components/dropdown/dropdown.vue';
import Loader from '@/components/loader/loader.vue';

import { validateDay, getApproximateChronologicalScopeString } from '@/helpers/format.helper';
import { isStartDateBeforeEndDate } from '@/helpers/validate.helper';

export default defineComponent({
    name: 'ModifyInventoryCard',
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

        const panel = ref(['general', 'additional', 'chronologicalScope', 'storage']);
        const onCancel = () => emit('cancel');

        const isLoading = ref(false);

        const acquisitionMethods = ref<IDropdownOption[]>([]);
        const getAcquisitionMethods = async () => {
            try {
                isLoading.value = true;
                acquisitionMethods.value = await dropdownService.getNomenclaturesByCode(
                    NomenclatureCode.AcquisitionMethod
                );
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

        const getInventoryData = async () => {
            try {
                isLoading.value = true;
                inventoryData.value = await inventoryService.displayInventoryDraft(props.sysId);
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

        const submitInventoryData = async () => {
            if (!inventoryData.value) {
                return;
            }

            try {
                inventoryData.value.approxmateChronologicalScope = date.value;
                const result = await inventoryService.modifyInventoryDraft(inventoryData.value);

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
                inventoryData.value.startDateDay,
                inventoryData.value.startDateMonth,
                inventoryData.value.startDateYear,
                inventoryData.value.endDateDay,
                inventoryData.value.endDateMonth,
                inventoryData.value.endDateYear
            )
        );

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
                    } else {
                        if (
                            isStartDateBeforeEndDate(
                                inventoryData.value.startDateDay,
                                inventoryData.value.startDateMonth,
                                inventoryData.value.startDateYear,
                                inventoryData.value.endDateDay,
                                inventoryData.value.endDateMonth,
                                inventoryData.value.endDateYear
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
            await getAcquisitionMethods();
            await getInventoryData();
        });

        return {
            t,
            dropdownService,
            inventoryData,
            NomenclatureCode,
            onCancel,
            panel,
            submitInventoryData,
            startDayValidationString,
            endDayValidationString,
            acquisitionMethods,
            showHintMessageForRequiredFields,
            isLoading,
        };
    },
});
</script>
