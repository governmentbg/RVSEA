<template>
    <v-row align="end">
        <v-col class="d-grid gap-2 d-md-flex justify-content-center">

            <!-- Утвърждаване на промени -->
            <confirm-dialog 
                :confirmationText="t('processes.buttons.modificationsAffirmationStepConfirmation')"
                :activatorButtonText="t('processes.buttons.modificationsAffirmationStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnReportAffirmationStepClickHandler(affirmationStep)"
            />

            <!-- Връщане за корекции -->
            <!-- <confirm-dialog 
                :confirmationText="t('processes.buttons.reportChangesStepConfirmation')"
                :activatorButtonText="t('processes.buttons.reportChangesStep')"
                :confirmButtonText="t('processes.buttons.reportChangesStep')"
                :cancelButtonText="t('common.cancel')"
                :commentInputEnabled="true"
                :commentInputRequired="true"
                @confirm="(commentInput) => btnReportAffirmationStepClickHandler(changesStep, commentInput)"
            /> -->
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
    name: 'ProcessRawInventoriesReportAffirmationActions',
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
        
        const btnReportAffirmationStepClickHandler = async (stepTypeId: number) => {
            try {
                await processRawInventoriesProcessService.sendModificationsAffirmationResult(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: stepTypeId,
                        assignedToUserId: props.process?.createdBy,
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

        const affirmationStep = computed(() => 
            props.process?.processTypeId == ProcessType.ProcessRawFundWithRawInventory 
            ? ProcessStep.ProcessRawFundWithRawInventory_Affirmation
            : ProcessStep.ProcessFundWithRawInventory_Affirmation);

        const changesStep = computed(() => 
            props.process?.processTypeId == ProcessType.ProcessRawFundWithRawInventory 
            ? ProcessStep.ProcessRawFundWithRawInventory_ReportChangesRequired
            : ProcessStep.ProcessFundWithRawInventory_ReportChangesRequired);

        return {
            t,
            ProcessStep,
            btnReportAffirmationStepClickHandler,
            affirmationStep,
            changesStep,
        }
    },
})
</script>
