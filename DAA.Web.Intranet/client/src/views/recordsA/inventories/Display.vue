<template>
    <Breadcrumbs :items="breadcrumbItems" />
    <v-card ref="inventoryCard" class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('inventories.display') }}</v-card-title>
        <v-container>
            <v-expansion-panels v-model="panel" multiple>
                <v-expansion-panel value="generalInfo">
                    <v-expansion-panel-title>{{ t('inventories.panels.generalInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldArchive"
                                    :label="t('funds.columns.archive')"
                                    v-model="inventoryData.archiveName"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldFund"
                                    :label="t('inventories.columns.fund')"
                                    v-model="inventoryData.fundNumber"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldNumber"
                                    :label="t('inventories.columns.number')"
                                    v-model="inventoryData.number"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldSystemIdentifier"
                                    :label="t('inventories.columns.systemIdentifier')"
                                    v-model="inventoryData.systemIdentifier"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="inventoryInfo">
                    <v-expansion-panel-title>{{ t('inventories.panels.inventoryInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldNumber"
                                    :label="t('inventories.columns.number')"
                                    v-model="inventoryData.number"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDescriptionLevel"
                                    :label="t('inventories.columns.descriptionLevel')"
                                    v-model="inventoryData.descriptionLevelText"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldAvailabilityStatus"
                                    :label="t('inventories.columns.availabilityStatus')"
                                    v-model="inventoryData.availabilityStatusText"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldStatus"
                                    :label="t('inventories.columns.status')"
                                    v-model="inventoryData.statusText"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldAcquisitionMethod"
                                    :label="t('inventories.columns.acquisitionMethod')"
                                    v-model="inventoryData.acquisitionMethodText"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <v-divider></v-divider>
                                <h6>{{ t('inventories.panels.chronologicalScope') }}</h6>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <Switch
                                    v-model="inventoryData.hasNoChronologicalScope"
                                    :label="t('inventories.columns.chronologicalScope')"
                                    :large="false"
                                    :showLabel="true"
                                    :disabled="true"
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
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateMonth"
                                    :label="t('inventories.columns.month')"
                                    v-model="inventoryData.startDateMonth"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateYear"
                                    :label="t('inventories.columns.year')"
                                    v-model="inventoryData.startDateYear"
                                    :disabled="true"
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
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateMonth"
                                    :label="t('inventories.columns.month')"
                                    v-model="inventoryData.endDateMonth"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateYear"
                                    :label="t('inventories.columns.year')"
                                    v-model="inventoryData.endDateYear"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldApproxmateChronologicalScope"
                                    :label="t('inventories.columns.approxmateChronologicalScope')"
                                    v-model="inventoryData.approxmateChronologicalScope"
                                    :disabled="true"
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
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="packageA">
                    <v-expansion-panel-title>{{ t('inventories.panels.packageA') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <PackageA
                            :packageId="inventoryData.packageAId ?? 0"
                            :packageType="'A'"
                            :inventoryId="inventoryData.systemIdentifier"
                            :readonly="true"
                            :processId="0"
                        ></PackageA>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="additionalFiles">
                    <v-expansion-panel-title>{{ t('inventories.panels.additionalFiles') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <PackageFileList 
                            :inventoryId="inventoryData.systemIdentifier"
                            :packageId="inventoryData.packageCId"
                            :packageType="packageType.PackageC"
                            :showListHeader="false" 
                            :showFileUpload="true"
                        />
                    </v-expansion-panel-text>
                </v-expansion-panel>
            </v-expansion-panels>
            <v-row class="mt-3">
                <v-col class="d-flex justify-content-center">
                    <back-btn @click="goBack">{{ t('common.back') }}</back-btn>
                </v-col>
            </v-row>
        </v-container>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, inject, computed, watch, Ref } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { validate as isValidGuid } from 'uuid';
import { Message } from '@/models/notification';

import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { BusinessObjectType } from '@/models/grid';
import { PackageType } from '@/enums/packages';
import { IInventory } from '@/interfaces/inventory';
import { Inventory } from '@/models/inventory';
import inventoryService from '@/services/inventory.service';

import TextField from '@/components/field/text.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import PackageA from '@/components/packageA/packageA.inventory.vue';
import PackageFileList from '@/components/recordsA/packageFileList.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';

export default defineComponent({
    name: 'DisplayInventory',
    components: {
        TextField,
        Switch,
        PackageA,
        PackageFileList,
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
        
        const panel = ref(['generalInfo', 'inventoryInfo']);
        
        const possibleEmptyFields = {
            fundCreatorTitleHistory: '',
            fundCreatorBiographicalHistory: '',
            history: '',
            documentsDescription: '',
            documentsAccessDescription: '',
            classificationScheme: '',
            abbreviationList: '',
            notes: '',
        };
        const lowClass = 'low';
        
        const router = useRouter();
        const goBack = () => router.go(-1);
        
        const entityType = computed(() => BusinessObjectType.inventory);
        const packageType = PackageType;

        const inventoryData = ref<IInventory>(new Inventory());

        const getInventoryData = async () => {
            try {
                inventoryData.value = await inventoryService.displayInventory(
                    props.id,
                    props.hasExternalSource,
                    props.externalIdentifier,
                    false
                );
                if (!inventoryData.value.fundCreatorTitleHistory) {
                    possibleEmptyFields.fundCreatorTitleHistory = lowClass;
                }
                if (!inventoryData.value.fundCreatorBiographicalHistory) {
                    possibleEmptyFields.fundCreatorBiographicalHistory = lowClass;
                }
                if (!inventoryData.value.history) {
                    possibleEmptyFields.history = lowClass;
                }
                if (!inventoryData.value.documentsDescription) {
                    possibleEmptyFields.documentsDescription = lowClass;
                }
                if (!inventoryData.value.documentsAccessDescription) {
                    possibleEmptyFields.documentsAccessDescription = lowClass;
                }
                if (!inventoryData.value.classificationScheme) {
                    possibleEmptyFields.classificationScheme = lowClass;
                }
                if (!inventoryData.value.abbreviationList) {
                    possibleEmptyFields.abbreviationList = lowClass;
                }
                if (!inventoryData.value.notes) {
                    possibleEmptyFields.notes = lowClass;
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };


        const breadcrumbItems = ref([
            {
                title: t('packages.recordsA'),
                disabled: false,
                to: {
                    name: 'RecordsA',
                },
            },
            {
                title: t('inventories.inventory'),
                disabled: true,
            },
        ]);

        watch(
            () => props.id,
            async (newVal, oldVal) => {
                if (newVal && newVal !== oldVal && isValidGuid(newVal)) {
                    await getInventoryData();
                }
            }
        );

        onMounted(async () => {
            await getInventoryData();
        });

        return {
            t,
            panel,
            entityType,
            packageType,
            inventoryData,
            goBack,
            breadcrumbItems,
            possibleEmptyFields,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/index-1.scss';
@import '@/assets/styles/breadcrumbs-inv.scss';

.low,
:deep(.low div),
:deep(.low textarea) {
    height: 50px;
    margin-bottom: 25px;
}
</style>
