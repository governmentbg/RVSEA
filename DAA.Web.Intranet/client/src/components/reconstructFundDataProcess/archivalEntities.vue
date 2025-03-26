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
        <v-tab :value="AvailabilityStatus.Enrollment">
            {{ t('processes.buttons.enrollment') }}
        </v-tab>
    </v-tabs>
    <v-window v-model="availabilityStatus">
        <v-window-item :value="AvailabilityStatus.DisposalDeduction">
            <InventoryArchivalEntities 
                ref="disposalAEList"
                :inventory="inventory"
                :selectionEnabled="true"
                :selectionConditions="disposalSelectionConditions"
                v-model="selectedArchivalEntities"
            >
                <template #toolbar>
                </template>
                <template #actions v-if="availabilityStatus">
                    <v-row>
                        <v-col class="d-grid gap-2 d-md-flex justify-content-center">
                            <v-btn @click="btnDeductionSubmitHandler">{{ t('processes.buttons.markSelectedForAction', { action: availabilityStatusText }) }}
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
            </InventoryArchivalEntities>
        </v-window-item>
        <v-window-item
            :value="AvailabilityStatus.RelocationDeduction"
        >
            <InventoryArchivalEntities 
                ref="relocationAEList"
                :inventory="inventory"
                :selectionEnabled="true"
                :selectionConditions="relocationSelectionConditions"
                v-model="selectedArchivalEntities"
            >
                <template #toolbar>
                    <v-toolbar color="transparent" v-if="addArchivalEntityEnabled">
                        <v-btn 
                            @click="goAddArchivalEntity"
                            variant="flat"
                        >{{
                            t('archiveEntities.create')
                        }}
                            <v-tooltip
                                activator="parent"
                                location="bottom"
                            >
                            {{t('archiveEntities.buttons.createTooltip')}}
                            </v-tooltip>
                        </v-btn>
                    </v-toolbar>
                </template>
                <template #actions v-if="availabilityStatus">
                    <v-row>
                        <v-col class="d-grid gap-2 d-md-flex justify-content-center">
                            <v-btn @click="btnDeductionSubmitHandler">{{ t('processes.buttons.markSelectedForAction', { action: availabilityStatusText }) }}
                                <v-tooltip
                                    activator="parent"
                                    location="bottom"
                                >{{
                                    t('processes.buttons.markSelectedForActionTooltip', { action: availabilityStatusText })
                                }}</v-tooltip>
                            </v-btn>
                        </v-col>
                    </v-row>
                </template>
            </InventoryArchivalEntities>
        </v-window-item>
        <v-window-item
            :value="AvailabilityStatus.Enrollment"
        >
            <RelocationEnrollmentArchivalEntities 
                ref="enrollmentArchivalEntityList"
                :process="process"
                :selectionEnabled="true"
                :selectionConditions="enrollmentSelectionConditions"
                v-model="selectedArchivalEntities"
            >
                <template #toolbar>
                </template>
                <template #actions v-if="availabilityStatus">
                    <v-row>
                        <v-col class="d-grid gap-2 d-md-flex justify-content-center">
                            <v-btn @click="btnEnrollmentSubmitHandler">{{ t('processes.buttons.relocation') }}
                                <v-tooltip
                                        activator="parent"
                                        location="bottom"
                                    >
                                    {{t('processes.buttons.relocationTooltip')}}
                                </v-tooltip>
                            </v-btn>
                        </v-col>
                    </v-row>
                </template>
            </RelocationEnrollmentArchivalEntities>
        </v-window-item>
    </v-window>
</template>
<script lang="ts">
    import { computed, defineComponent, inject, PropType, ref, Ref, watch } from 'vue';
    import { useI18n } from 'vue-i18n';
    import { LocationQueryRaw, useRouter } from 'vue-router';
    import { useRedirect } from '@/helpers/router.helper';

    import { IMessage } from '@/interfaces/notification';
    import { Message } from '@/models/notification';
    import { ResponseResult } from '@/models/responseResult';
    import { IProcess } from '@/interfaces/process';
    import { IInventory } from '@/interfaces/inventory';
    import { IArchivalEntity } from '@/interfaces/archivalEntity';
    import { Status } from '@/enums/status';
    import { AvailabilityStatus } from '@/enums/status';
    import { FundReconstructionModel } from '@/models/fundReconstructions';
    import { ProcessStep, ProcessType } from '@/enums/process';
    import { ArchivalEntityDescriptionLevel } from '@/enums/archivalEntity';
    import fundReconstructionService from '@/services/fundReconstruction.service';

    import InventoryArchivalEntities from '@/components/archivalEntity/inventoryArchivalEntities.vue';
    import RelocationEnrollmentArchivalEntities from '@/components/reconstructFundDataProcess/enrollmentArchivalEntities.vue';
    
    export default defineComponent({
        name: "ReconstructionArchivalEntities",
        components : {
            InventoryArchivalEntities,
            RelocationEnrollmentArchivalEntities,
        },
        props: {
            inventory: {
                type: Object as PropType<IInventory>,
                required: true,
            },
            process: {
                type: Object as PropType<IProcess>,
            },
        },
        emits: ['markForDeduction', 'enrollment'],
        setup(props, context) {
            const { t } = useI18n();
            const message = inject('notificationMessage') as Ref<IMessage>;

            const disposalAEList = ref();
            const relocationAEList = ref();
            const enrollmentAEList = ref();

            const availabilityStatus = ref<number>();
            const availabilityStatusText = computed(() => {
                if (availabilityStatus.value === AvailabilityStatus.DisposalDeduction) {
                    return t('processes.buttons.disposalDeduction');
                } else if (availabilityStatus.value === AvailabilityStatus.RelocationDeduction) {
                    return t('processes.buttons.relocationDeduction');
                }
                return '';
            });

            const addArchivalEntityEnabled = computed(
                () => 
                    props.process && 
                    props.process.processTypeId === ProcessType.ReconstructFundData &&
                    (props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_EditData ||
                        props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ReportModifications)
            );

            const router = useRouter();
			const goAddArchivalEntity = () => {
				const routeQuery: LocationQueryRaw = {
					inventorySystemIdentifier: props.inventory?.systemIdentifier,
					inventoryHasExternalSource: String(props.inventory?.hasExternalSource),
					inventoryExternalIdentifier: props.inventory?.externalIdentifier,
                    descriptionLevel: ArchivalEntityDescriptionLevel.archivalEntity,
				};

				useRedirect(router, 'CreateArchiveEntity', undefined, routeQuery);
			};

            const selectedArchivalEntities = ref<string[]>([]);
            
            const disposalSelectionConditions = (item?: IArchivalEntity) => {
                if (!availabilityStatus.value) {
                    return false;
                }

                const conditions = 
                !item?.hasExternalSource 
                && item?.availabilityStatusCode !== AvailabilityStatus.RelocationDeduction
                && item?.inventoryAvailabilityStatusCode !== AvailabilityStatus.RelocationDeduction
                && item?.inventoryAvailabilityStatusCode !== AvailabilityStatus.DisposalDeduction
                && item?.statusCode !== Status.Deducted
                && item?.statusCode !== Status.Deleted;
            
                return conditions;
            };

            const relocationSelectionConditions = (item?: IArchivalEntity) => {
                if (!availabilityStatus.value) {
                    return false;
                }

                const conditions = 
                !item?.hasExternalSource 
                && item?.availabilityStatusCode !== AvailabilityStatus.DisposalDeduction
                && item?.inventoryAvailabilityStatusCode !== AvailabilityStatus.RelocationDeduction
                && item?.inventoryAvailabilityStatusCode !== AvailabilityStatus.DisposalDeduction
                && item?.statusCode !== Status.Deducted
                && item?.statusCode !== Status.Deleted
                && item?.statusCode !== Status.Moved;
                
                return conditions;
            };

            const enrollmentSelectionConditions = (item?: IArchivalEntity) => {
			if (!availabilityStatus.value) {
                return false;
            }

            const conditions = 
                !item?.hasExternalSource 
                && item?.availabilityStatusCode !== AvailabilityStatus.DisposalDeduction
                && item?.inventoryAvailabilityStatusCode !== AvailabilityStatus.RelocationDeduction
                && item?.inventoryAvailabilityStatusCode !== AvailabilityStatus.DisposalDeduction
                && item?.statusCode !== Status.Deducted
                && item?.statusCode !== Status.Moved;

			return conditions;
		};

            const initSelectedArchivalEntities = async (status: number) => {
                try {
                    const targetParent = status === AvailabilityStatus.Enrollment;
                    const reconstructions = 
                        await fundReconstructionService.getReconstructionsByParent(
                            props.process!.id!, 
                            status, 
                            props.inventory.systemIdentifier, 
                            undefined,
                            targetParent);
                    
                    if(targetParent) {
                        selectedArchivalEntities.value = reconstructions.map(rec => rec.targetArchivalEntitySystemIdentifier!);
                    } else {
                        selectedArchivalEntities.value = reconstructions.map(rec => rec.sourceArchivalEntitySystemIdentifier!);
                    }

                    console.log(reconstructions);
                    console.log(selectedArchivalEntities.value);
                } catch (error: unknown) {
                    const errorResult = error as ResponseResult;
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                        display: true,
                    });
                }
            };

            const btnDeductionSubmitHandler = async () => {
                try {
                    if (!selectedArchivalEntities.value || selectedArchivalEntities.value.length === 0) {
                        message.value = new Message({
                            type: "warning",
                            text: t('warnings.noSelectedArchivalEntities'),
                            display: true,
                        });
                    } else {
                        const reconstructions = selectedArchivalEntities.value.map(
                            ae => 
                            new FundReconstructionModel({
                                availabilityStatusCode: availabilityStatus.value,
                                processId: props.process?.id,
                                archiveId: props.process?.archiveId,
                                fundSystemIdentifier: props.process?.fundSystemIdentifier,
                                sourceInventorySystemIdentifier: props.inventory.systemIdentifier,
                                sourceArchivalEntitySystemIdentifier: ae,
                        }));
                        
                        await fundReconstructionService.createOrUpdateReconstructionsBySource(reconstructions);
                        
                        if (availabilityStatus.value === AvailabilityStatus.DisposalDeduction) {
                            await disposalAEList.value.searchArchivalEntities();
                        }
                        if (availabilityStatus.value === AvailabilityStatus.RelocationDeduction) {
                            await relocationAEList.value.searchArchivalEntities();
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

            const btnEnrollmentSubmitHandler = async () => {
                try {
                    if (!selectedArchivalEntities.value || selectedArchivalEntities.value.length === 0) {
                        message.value = new Message({
                            type: "warning",
                            text: t('warnings.noSelectedArchivalEntities'),
                            display: true,
                        });
                    } else {
                        const reconstructions = selectedArchivalEntities.value.map(
                            ae => 
                            new FundReconstructionModel({
                                availabilityStatusCode: AvailabilityStatus.RelocationDeduction,
                                processId: props.process?.id,
                                archiveId: props.process?.archiveId,
                                fundSystemIdentifier: props.process?.fundSystemIdentifier,
                                targetInventorySystemIdentifier: props.inventory.systemIdentifier,
                                targetArchivalEntitySystemIdentifier: ae,
                        }));
                        
                        await fundReconstructionService.updateMoveFundReconstructionsByTarget(reconstructions);
                        
                        //await enrollmentAEList.value.searchArchivalEntities();

                        context.emit('enrollment', reconstructions);
                    }
                } catch (error: unknown) {
                    const errorResult = error as ResponseResult;
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                        display: true,
                    });
                } finally {
                    await enrollmentAEList.value.searchArchivalEntities();
                }
            };

            const clearSelection = async () => {
                selectedArchivalEntities.value = [];
            };

            watch(
                () => availabilityStatus.value,
                async (newVal,oldVal) => {
                    try {
                        if (newVal) {
                            clearSelection();
                            await initSelectedArchivalEntities(newVal);
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
                disposalAEList,
                relocationAEList,
                enrollmentAEList,
                availabilityStatus,
                selectedArchivalEntities,
                addArchivalEntityEnabled,
                disposalSelectionConditions,
                relocationSelectionConditions,
                enrollmentSelectionConditions,
                AvailabilityStatus,
                availabilityStatusText,
                goAddArchivalEntity,
                btnDeductionSubmitHandler,
                btnEnrollmentSubmitHandler,
                clearSelection,
            }
            
        },
    })
</script>
