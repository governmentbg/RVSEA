<template>
    <v-row align="end">
        <v-col class="d-grid gap-2 d-md-flex justify-content-center">
            <confirm-dialog 
                :confirmationText="t('processes.buttons.modificationsAffirmationStepConfirmation')"
                :activatorButtonText="t('processes.buttons.modificationsAffirmationStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnReportAffirmationStepClickHandler(ProcessStep.EditFundData_Affirmation)"
            />

            <confirm-dialog 
                :confirmationText="t('processes.buttons.reportChangesStepConfirmation')"
                :activatorButtonText="t('processes.buttons.reportChangesStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                :commentInputEnabled="true"
                :commentInputRequired="true"
                @confirm="(commentInput) => btnReportAffirmationStepClickHandler(ProcessStep.EditFundData_ReportChangesRequired, commentInput)"
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
import editFundDataProcessService from '@/services/editFundDataProcess.service';

import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import { ProcessStepModel } from '@/models/process';
import { ProcessStep } from '@/enums/process';

export default defineComponent({
    name: 'EditFundDataReportAffirmationActions',
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
        
        const btnReportAffirmationStepClickHandler = async (stepTypeId: number, comment?: string) => {
            try {
                await editFundDataProcessService.sendModificationsAffirmationResult(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: stepTypeId,
                        assignedToUserId: props.process?.createdBy,
                        comment: comment,
                    }));

                context.emit('affirmation', stepTypeId);
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
            btnReportAffirmationStepClickHandler,
        }
    },
})
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/dialog.scss';
</style>
