<template>
    <v-row align="end">
        <v-col class="d-grid gap-2 d-md-flex justify-content-center">

            <!-- Одобрение на доклад -->
            <confirm-dialog 
                :confirmationText="t('processes.buttons.reportApprovalStepConfirmation')"
                :activatorButtonText="t('processes.buttons.reportApprovalStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnReportApprovalStepClickHandler(approvalStep)"
            />

            <!-- Връщане за корекции -->
            <confirm-dialog 
                :confirmationText="t('processes.buttons.reportChangesStepConfirmation')"
                :activatorButtonText="t('processes.buttons.reportChangesStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                :commentInputEnabled="true"
                @confirm="(commentInput) => btnReportApprovalStepClickHandler(changesStep, commentInput)"
            />

            <!-- Отхвърляне на доклад -->
            <confirm-dialog 
                :confirmationText="t('processes.buttons.reportRejectionStepConfirmation')"
                :activatorButtonText="t('processes.buttons.reportRejectionStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                :commentInputEnabled="true"
                @confirm="(commentInput) => btnReportApprovalStepClickHandler(rejectionStep, commentInput)"
            />
            
        </v-col>
    </v-row>
</template>
<script lang="ts">
import { defineComponent, inject, PropType, Ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';

import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { IProcess } from '@/interfaces/process';
import processRawInventoriesProcessService from '@/services/processRawInventoriesProcess.service';

import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import { ProcessStepModel } from '@/models/process';
import { ProcessStep, ProcessType } from '@/enums/process';

export default defineComponent({
    name: 'ProcessRawInventoriesReportApprovalActions',
    components: {
        ConfirmDialog,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>,
        }
    },
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        
        const btnReportApprovalStepClickHandler = async (stepTypeId: number, comment?: string) => {
            try {
                await processRawInventoriesProcessService.sendReportApprovalResult(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: stepTypeId,
                        assignedToUserId: props.process?.createdBy,
                        comment: comment,
                    }));

                context.emit('approval', stepTypeId);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const approvalStep = computed(() => 
            props.process?.processTypeId == ProcessType.ProcessRawFundWithRawInventory 
            ? ProcessStep.ProcessRawFundWithRawInventory_ReportApproval
            : ProcessStep.ProcessFundWithRawInventory_ReportApproval);

        const changesStep = computed(() => 
            props.process?.processTypeId == ProcessType.ProcessRawFundWithRawInventory 
            ? ProcessStep.ProcessRawFundWithRawInventory_ReportChangesRequired
            : ProcessStep.ProcessFundWithRawInventory_ReportChangesRequired);

        const rejectionStep = computed(() => 
            props.process?.processTypeId == ProcessType.ProcessRawFundWithRawInventory 
            ? ProcessStep.ProcessRawFundWithRawInventory_ReportRejection
            : ProcessStep.ProcessFundWithRawInventory_ReportRejection);

        return {
            t,
            ProcessStep,
            btnReportApprovalStepClickHandler,
            approvalStep,
            changesStep,
            rejectionStep,
        }
    },
})
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/dialog.scss';
</style>
