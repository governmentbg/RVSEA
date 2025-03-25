<template>
    <v-row align="end">
        <v-col class="d-grid gap-2 d-md-flex justify-content-center">
            <confirm-dialog 
                :confirmationText="t('processes.buttons.reportApprovalStepConfirmation')"
                :activatorButtonText="t('processes.buttons.reportApprovalStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnReportApprovalStepClickHandler(ProcessStep.ReconstructFundData_ReportApproval)"
            />

            <confirm-dialog 
                :confirmationText="t('processes.buttons.reportChangesStepConfirmation')"
                :activatorButtonText="t('processes.buttons.reportChangesStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                :commentInputEnabled="true"
                @confirm="(commentInput) => btnReportApprovalStepClickHandler(ProcessStep.ReconstructFundData_ReportChangesRequired, commentInput)"
            />

            <confirm-dialog 
                :confirmationText="t('processes.buttons.reportRejectionStepConfirmation')"
                :activatorButtonText="t('processes.buttons.reportRejectionStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                :commentInputEnabled="true"
                @confirm="(commentInput) => btnReportApprovalStepClickHandler(ProcessStep.ReconstructFundData_ReportRejection, commentInput)"
            />
            
        </v-col>
    </v-row>
</template>
<script lang="ts">
import { defineComponent, inject, PropType, Ref } from 'vue';
import { useI18n } from 'vue-i18n';

import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { IProcess } from '@/interfaces/process';
import reconstructFundDataProcessService from '@/services/reconstructFundData.service';

import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import { ProcessStepModel } from '@/models/process';
import { ProcessStep } from '@/enums/process';

export default defineComponent({
    name: 'ReconstructFundDataReportApprovalActions',
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
                await reconstructFundDataProcessService.sendReportApprovalResult(
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

        

        return {
            t,
            ProcessStep,
            btnReportApprovalStepClickHandler,
        }
    },
})
</script>

// <style lang="scss" scoped>
// @import '@/assets/styles/display-create-edit.scss';
// @import '@/assets/styles/dialog.scss';
// </style>
