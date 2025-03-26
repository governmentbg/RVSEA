<template>
    <v-tabs v-model="availabilityStatus">
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
            <ArchivalEntityDocuments
                ref="disposalDocumentList"
                :archivalEntity="archivalEntity"
                :selectionEnabled="true"
                :selectionConditions="disposalSelectionConditions"
                v-model="selectedDocuments"
            >
                <template #toolbar> </template>
                <template #actions v-if="availabilityStatus">
                    <v-row>
                        <v-col class="d-grid gap-2 d-md-flex justify-content-center">
                            <v-btn @click="btnDeductionSubmitHandler">{{
                                t('processes.buttons.markSelectedForAction', { action: availabilityStatusText })
                            }}
                                <v-tooltip
                                    activator="parent"
                                    location="bottom"
                                >
                                {{t('processes.buttons.markSelectedForActionTooltip')}}
                                </v-tooltip>
                            </v-btn>
                            <!-- <v-btn @click="clearSelection" >{{ t('common.clearSelection') }}</v-btn> -->
                        </v-col>
                    </v-row>
                </template>
            </ArchivalEntityDocuments>
        </v-window-item>
        <v-window-item :value="AvailabilityStatus.RelocationDeduction">
            <ArchivalEntityDocuments
                ref="relocationDocumentList"
                :archivalEntity="archivalEntity"
                :selectionEnabled="true"
                :selectionConditions="relocationSelectionConditions"
                v-model="selectedDocuments"
            >
                <template #toolbar> </template>
                <template #actions v-if="availabilityStatus">
                    <v-row>
                        <v-col class="d-grid gap-2 d-md-flex justify-content-center">
                            <v-btn @click="btnDeductionSubmitHandler">{{
                                t('processes.buttons.markSelectedForAction', { action: availabilityStatusText })
                            }}
                                <v-tooltip
                                    activator="parent"
                                    location="bottom"
                                >
                                {{t('processes.buttons.markSelectedForActionTooltip')}}
                                </v-tooltip>
                            </v-btn>
                            <!-- <v-btn @click="clearSelection" >{{ t('common.clearSelection') }}</v-btn> -->
                        </v-col>
                    </v-row>
                </template>
            </ArchivalEntityDocuments>
        </v-window-item>
        <v-window-item :value="AvailabilityStatus.Enrollment">
            <RelocationEnrollmentDocuments
                ref="enrollmentDocumentList"
                :process="process"
                :selectionEnabled="true"
                :selectionConditions="enrollmentSelectionConditions"
                v-model="selectedDocuments"
            >
                <template #toolbar> </template>
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
                            <!-- <v-btn @click="clearSelection" >{{ t('common.clearSelection') }}</v-btn> -->
                        </v-col>
                    </v-row>
                </template>
            </RelocationEnrollmentDocuments>
        </v-window-item>
    </v-window>
</template>
<script lang="ts">
import { computed, defineComponent, inject, PropType, ref, Ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';

import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { IProcess } from '@/interfaces/process';
import { IArchivalEntity } from '@/interfaces/archivalEntity';
import { IDocument } from '@/interfaces/document';
import { Status } from '@/enums/status';
import { AvailabilityStatus } from '@/enums/status';
import { FundReconstructionModel } from '@/models/fundReconstructions';
import fundReconstructionService from '@/services/fundReconstruction.service';

import ArchivalEntityDocuments from '@/components/document/archivalEntityDocuments.vue';
import RelocationEnrollmentDocuments from '@/components/reconstructFundDataProcess/enrollmentDocuments.vue';

export default defineComponent({
    name: 'ReconstructionDocuments',
    components: {
        ArchivalEntityDocuments,
        RelocationEnrollmentDocuments,
    },
    props: {
        archivalEntity: {
            type: Object as PropType<IArchivalEntity>,
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

        const disposalDocumentList = ref();
        const relocationDocumentList = ref();
        const enrollmentDocumentList = ref();

        const availabilityStatus = ref<number>();
        const availabilityStatusText = computed(() => {
            if (availabilityStatus.value === AvailabilityStatus.DisposalDeduction) {
                return t('processes.buttons.disposalDeduction');
            } else if (availabilityStatus.value === AvailabilityStatus.RelocationDeduction) {
                return t('processes.buttons.relocationDeduction');
            }
            return '';
        });
        const selectedDocuments = ref<string[]>([]);

        const disposalSelectionConditions = (item?: IDocument) => {
            if (!availabilityStatus.value) {
                return false;
            }

            const conditions =
                !item?.hasExternalSource &&
                item?.availabilityStatusCode !== AvailabilityStatus.RelocationDeduction &&
                item?.archivalEntityAvailabilityStatusCode !== AvailabilityStatus.RelocationDeduction &&
                item?.archivalEntityAvailabilityStatusCode !== AvailabilityStatus.DisposalDeduction &&
                item?.inventoryAvailabilityStatusCode !== AvailabilityStatus.RelocationDeduction &&
                item?.inventoryAvailabilityStatusCode !== AvailabilityStatus.DisposalDeduction &&
                item?.statusCode !== Status.Deducted &&
                item?.statusCode !== Status.Deleted;

            return conditions;
        };

        const relocationSelectionConditions = (item?: IDocument) => {
            if (!availabilityStatus.value) {
                return false;
            }

            const conditions =
                !item?.hasExternalSource &&
                item?.availabilityStatusCode !== AvailabilityStatus.DisposalDeduction &&
                item?.archivalEntityAvailabilityStatusCode !== AvailabilityStatus.RelocationDeduction &&
                item?.archivalEntityAvailabilityStatusCode !== AvailabilityStatus.DisposalDeduction &&
                item?.inventoryAvailabilityStatusCode !== AvailabilityStatus.RelocationDeduction &&
                item?.inventoryAvailabilityStatusCode !== AvailabilityStatus.DisposalDeduction &&
                item?.statusCode !== Status.Deducted &&
                item?.statusCode !== Status.Deleted &&
                item?.statusCode !== Status.Moved;

            return conditions;
        };

        const enrollmentSelectionConditions = (item?: IDocument) => {
            if (!availabilityStatus.value) {
                return false;
            }

            const conditions =
                !item?.hasExternalSource &&
                item?.availabilityStatusCode !== AvailabilityStatus.DisposalDeduction &&
                item?.archivalEntityAvailabilityStatusCode !== AvailabilityStatus.RelocationDeduction &&
                item?.archivalEntityAvailabilityStatusCode !== AvailabilityStatus.DisposalDeduction &&
                item?.inventoryAvailabilityStatusCode !== AvailabilityStatus.RelocationDeduction &&
                item?.inventoryAvailabilityStatusCode !== AvailabilityStatus.DisposalDeduction &&
                item?.statusCode !== Status.Deducted &&
                item?.statusCode !== Status.Deleted &&
                item?.statusCode !== Status.Moved;

            return conditions;
        };

        const initSelectedDocuments = async (status: number) => {
            try {
                const targetParent = status === AvailabilityStatus.Enrollment;
                const reconstructions = await fundReconstructionService.getReconstructionsByParent(
                    props.process!.id!,
                    status,
                    props.archivalEntity.inventorySystemIdentifier,
                    props.archivalEntity.systemIdentifier,
                    targetParent
                );

                if (targetParent) {
                    selectedDocuments.value = reconstructions.map((rec) => rec.targetDocumentSystemIdentifier!);
                } else {
                    selectedDocuments.value = reconstructions.map((rec) => rec.sourceDocumentSystemIdentifier!);
                }

                console.log(reconstructions);
                console.log(selectedDocuments.value);
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
                if (!selectedDocuments.value || selectedDocuments.value.length === 0) {
                    message.value = new Message({
                        type: 'warning',
                        text: t('warnings.noSelectedDocuments'),
                        display: true,
                    });
                } else {
                    const reconstructions = selectedDocuments.value.map(
                        (doc) =>
                            new FundReconstructionModel({
                                availabilityStatusCode: availabilityStatus.value,
                                processId: props.process?.id,
                                archiveId: props.process?.archiveId,
                                fundSystemIdentifier: props.process?.fundSystemIdentifier,
                                sourceInventorySystemIdentifier: props.archivalEntity.inventorySystemIdentifier,
                                sourceArchivalEntitySystemIdentifier: props.archivalEntity.systemIdentifier,
                                sourceDocumentSystemIdentifier: doc,
                            })
                    );

                    await fundReconstructionService.createOrUpdateReconstructionsBySource(reconstructions);

                    if (availabilityStatus.value === AvailabilityStatus.DisposalDeduction) {
                        await disposalDocumentList.value.searchDocuments();
                    }
                    if (availabilityStatus.value === AvailabilityStatus.RelocationDeduction) {
                        await relocationDocumentList.value.searchDocuments();
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
                if (!selectedDocuments.value || selectedDocuments.value.length === 0) {
                    message.value = new Message({
                        type: 'warning',
                        text: t('warnings.noSelectedDocuments'),
                        display: true,
                    });
                } else {
                    const reconstructions = selectedDocuments.value.map(
                        (doc) =>
                            new FundReconstructionModel({
                                availabilityStatusCode: AvailabilityStatus.RelocationDeduction,
                                processId: props.process?.id,
                                archiveId: props.process?.archiveId,
                                fundSystemIdentifier: props.process?.fundSystemIdentifier,
                                targetInventorySystemIdentifier: props.archivalEntity.inventorySystemIdentifier,
                                targetArchivalEntitySystemIdentifier: props.archivalEntity.systemIdentifier,
                                targetDocumentSystemIdentifier: doc,
                            })
                    );

                    await fundReconstructionService.updateMoveFundReconstructionsByTarget(reconstructions);

                    await enrollmentDocumentList.value.searchDocuments();

                    context.emit('enrollment', reconstructions);
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
            selectedDocuments.value = [];
        };

        watch(
            () => availabilityStatus.value,
            async (newVal, oldVal) => {
                try {
                    if (newVal && newVal !== oldVal) {
                        clearSelection();
                        await initSelectedDocuments(newVal);
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
            disposalDocumentList,
            relocationDocumentList,
            enrollmentDocumentList,
            availabilityStatus,
            selectedDocuments,
            AvailabilityStatus,
            availabilityStatusText,
            disposalSelectionConditions,
            relocationSelectionConditions,
            enrollmentSelectionConditions,
            btnDeductionSubmitHandler,
            btnEnrollmentSubmitHandler,
            clearSelection,
        };
    },
});
</script>
