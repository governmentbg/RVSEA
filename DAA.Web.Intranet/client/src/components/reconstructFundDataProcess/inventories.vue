<template>
    <v-tabs
        v-model="availabilityStatus"
    >
        <v-tab :value="AvailabilityStatus.DisposalDeduction">
            {{ t('processes.buttons.disposalDeduction') }}
        </v-tab>
        <v-tab :value="AvailabilityStatus.RelocationDeduction">
            {{ t('processes.buttons.relocationDeduction') }}
        </v-tab>
    </v-tabs>
    <v-window v-model="availabilityStatus">
        <v-window-item :value="AvailabilityStatus.DisposalDeduction">
            <FundInventories
                ref="disposalInventoryList"
                :fund="fund"
                :selectionEnabled="true"
                :selectionConditions="disposalSelectionConditions"
                v-model="selectedInventories"
            >
                <template #toolbar>
                </template>
                <template #actions v-if="availabilityStatus">
                    <v-row>
                        <v-col class="d-grid gap-2 d-md-flex justify-content-center">
                            <v-btn @click="btnSubmitHandler">{{ t('processes.buttons.markSelectedForAction', { action: availabilityStatusText }) }}
                                <v-tooltip
                                    activator="parent"
                                    location="bottom"
                                >
                                {{t('processes.buttons.markSelectedForActionTooltip', { action: availabilityStatusText })}}
                                </v-tooltip>
                            </v-btn>
                            <!-- <v-btn @click="clearSelection" >{{ t('common.clearSelection') }}</v-btn> -->
                        </v-col>
                    </v-row>
                </template>
            </FundInventories>
        </v-window-item>
        <v-window-item
            :value="AvailabilityStatus.RelocationDeduction"
        >
            <FundInventories
                ref="relocationInventoryList"
                :fund="fund"
                :selectionEnabled="true"
                :selectionConditions="relocationSelectionConditions"
                v-model="selectedInventories"
            >
                <template #toolbar>
                    <v-toolbar density="compact" color="transparent" v-if="addInventoryEnabled">
                        <v-btn
                            variant="flat"
                            class="me-3"
                            @click="goAddInventory"
                        >{{
                            t('inventories.create')
                        }}
                            <v-tooltip
                                activator="parent"
                                location="bottom"
                            >
                            {{t('inventories.buttons.createTooltip')}}
                            </v-tooltip>
                        </v-btn>
                    </v-toolbar>
                </template>
                <template #actions v-if="availabilityStatus">
                    <v-row>
                        <v-col class="d-grid gap-2 d-md-flex justify-content-center">
                            <v-btn @click="btnSubmitHandler">{{ t('processes.buttons.markSelectedForAction', { action: availabilityStatusText }) }}
                                <v-tooltip
                                    activator="parent"
                                    location="bottom"
                                >
                                {{t('processes.buttons.markSelectedForActionTooltip', { action: availabilityStatusText })}}
                                </v-tooltip>
                            </v-btn>
                            <!-- <v-btn @click="clearSelection" >{{ t('common.clearSelection') }}</v-btn> -->
                        </v-col>
                    </v-row>
                </template>
            </FundInventories>
        </v-window-item>
    </v-window>
</template>
<script lang="ts">
import { computed, defineComponent, inject, PropType, ref, Ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';

import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { IFund } from '@/interfaces/fund';
import { IProcess } from '@/interfaces/process';
import { IInventory } from '@/interfaces/inventory';
import { Status } from '@/enums/status';
import { AvailabilityStatus } from '@/enums/status';
import fundReconstructionService from '@/services/fundReconstruction.service';

import FundInventories from '@/components/inventory/fundInventories.vue';
import { FundReconstructionModel } from '@/models/fundReconstructions';
import { ProcessStep, ProcessType } from '@/enums/process';
import { LocationQueryRaw, useRouter } from 'vue-router';
import { InventoryDescriptionLevel } from '@/enums/inventory';
import { useRedirect } from '@/helpers/router.helper';

export default defineComponent({
    name: "ReconstructionInventories",
    components : {
        FundInventories,
    },
    props: {
        fund: {
            type: Object as PropType<IFund>,
            required: true,
        },
        process: {
            type: Object as PropType<IProcess>,
        },
    },
    emits: ['markForDeduction'],
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const disposalInventoryList = ref();
        const relocationInventoryList = ref();

        const availabilityStatus = ref<number>();
        const availabilityStatusText = computed(() => {
            if (availabilityStatus.value === AvailabilityStatus.DisposalDeduction) {
                return t('processes.buttons.disposalDeduction');
            } else if (availabilityStatus.value === AvailabilityStatus.RelocationDeduction) {
                return t('processes.buttons.relocationDeduction');
            }
            return '';
        });

        const addInventoryEnabled = computed(
            () =>
                props.process &&
                props.process.processTypeId === ProcessType.ReconstructFundData &&
                (props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_EditData ||
                    props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ReportModifications)
        );

        const router = useRouter();
        const goAddInventory = () => {
            const routeQuery: LocationQueryRaw = {
                fundSystemIdentifier: props.fund.systemIdentifier,
                fundHasExternalSource: String(props.fund.hasExternalSource),
                fundExternalIdentifier: props.fund.externalIdentifier,
                descriptionLevel: InventoryDescriptionLevel.inventory,
            };

            useRedirect(router, 'CreateInventory', undefined, routeQuery);
        };

        const selectedInventories = ref<string[]>([]);

        const disposalSelectionConditions = (item?: IInventory) => {
			if (!availabilityStatus.value) {
                return false;
            }

            const conditions =
                !item?.hasExternalSource
                && item?.descriptionLevelCode === InventoryDescriptionLevel.inventory
                && item?.availabilityStatusCode !== AvailabilityStatus.RelocationDeduction
                && item?.statusCode !== Status.Deducted
                && item?.statusCode !== Status.Deleted;

			return conditions;
		};

        const relocationSelectionConditions = (item?: IInventory) => {
			if (!availabilityStatus.value) {
                return false;
            }

            const conditions =
                !item?.hasExternalSource
                && item?.descriptionLevelCode === InventoryDescriptionLevel.inventory
                && item?.availabilityStatusCode !== AvailabilityStatus.DisposalDeduction
                && item?.statusCode !== Status.Deducted
                && item?.statusCode !== Status.Deleted;

			return conditions;
		};

        const initSelectedInventories = async (status: number) => {
			try {
                const reconstructions =
                    await fundReconstructionService.getReconstructionsByParent(
                        props.process!.id!,
                        status);

                selectedInventories.value = reconstructions.map(rec => rec.sourceInventorySystemIdentifier!);

                console.log(reconstructions);
                console.log(selectedInventories.value);
			} catch (error: unknown) {
				const errorResult = error as ResponseResult;
				message.value = new Message({
					text: errorResult.showMessage ? errorResult.message : t('error.basic'),
					display: true,
				});
			}
		};

        const btnSubmitHandler = async () => {
             try {
                if (!selectedInventories.value || selectedInventories.value.length === 0) {
                    message.value = new Message({
                        type: "warning",
                        text: t('warnings.noSelectedInventories'),
                        display: true,
                    });
                } else {
                    const reconstructions = selectedInventories.value.map(
                        inv =>
                        new FundReconstructionModel({
                            availabilityStatusCode: availabilityStatus.value,
                            processId: props.process?.id,
                            archiveId: props.process?.archiveId,
                            fundSystemIdentifier: props.process?.fundSystemIdentifier,
                            sourceInventorySystemIdentifier: inv,
                    }));

                    await fundReconstructionService.createOrUpdateReconstructionsBySource(reconstructions);
                    if (availabilityStatus.value === AvailabilityStatus.DisposalDeduction) {
                        await disposalInventoryList.value.getFundInventoryData();
                    }
                    if (availabilityStatus.value === AvailabilityStatus.RelocationDeduction) {
                        await relocationInventoryList.value.getFundInventoryData();
                    }

                    context.emit('markForDeduction', reconstructions);
                }
            } catch (error: unknown) {
				const errorResult = error as ResponseResult;
				message.value = new Message({
					text: errorResult.showMessage ? errorResult.message : t('error.basic'),
					display: true,
				});
			}
        };

        const clearSelection = async () => {
            selectedInventories.value = [];
        };

        watch(
            () => availabilityStatus.value,
            async (newVal,oldVal) => {
                try {
                    if (newVal) {
                        clearSelection();
                        await initSelectedInventories(newVal);
                    }
                    console.log('newVal', newVal);
                    console.log('oldVal', oldVal);
                } catch (error: unknown) {
                    const errorResult = error as ResponseResult;
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                        display: true,
                    });
                }
            }
        );

        return {
            t,
            addInventoryEnabled,
            disposalInventoryList,
            relocationInventoryList,
            availabilityStatus,
            selectedInventories,
            disposalSelectionConditions,
            relocationSelectionConditions,
            AvailabilityStatus,
            availabilityStatusText,
            btnSubmitHandler,
            clearSelection,
            goAddInventory,
        }

    },
})
</script>

<style lang="scss" scoped>
// .v-tab {
//     background-color: var(--ISDA-main-color2-1);
//     color: var(--ISDA-main-color-1) !important;
//     box-shadow: none;
// }
</style>
