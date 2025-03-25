<template>
    <v-expansion-panel :value="panelValue">
        <v-expansion-panel-title>{{ $t('processes.steps.sendForModificationsAffrimation') }}</v-expansion-panel-title>
        <v-expansion-panel-text>
            <assign-modal
                :archiveId="process.archiveId"
                :roleNames="sendForAffirmationRoles"
                :btnTitle="$t('processes.buttons.sendForModificationsAffrimationStep')"
                :dialogTitle="$t('processes.steps.sendForModificationsAffrimation')"
                :showDate="false"
                :showRoles="true"
                @assign="btnSendForAffirmationClickHandler"
            />
        </v-expansion-panel-text>
    </v-expansion-panel>
</template>
<script lang="ts">
import { defineComponent, inject, PropType, Ref } from 'vue';
import { useI18n } from 'vue-i18n';

import { ResponseResult } from '@/models/responseResult';
import { IMessage } from '@/interfaces/notification';
import { RoleNames } from '@/enums/roles';
import { IProcess } from '@/interfaces/process';
import { ProcessStepModel } from '@/models/process';
import { ProcessStep } from '@/enums/process';
import { AssignModel } from '@/models/task';
import collectingService from '@/services/eDocsCollecting.service';

import AssignModal from '@/components/films/assign.modal.vue';
import { displayMessage } from '@/helpers/notification.helper';

export default defineComponent({
    name: 'SendForAffirmationPanel',
    components: {
        AssignModal,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>,
            required: true,
        },
        panelValue: {
            type: String,
            required: true,
        },
    },
    setup(props, context) {
        const { t } = useI18n();

        const message = inject('notificationMessage') as Ref<IMessage>;

        const sendForAffirmationRoles = [RoleNames.GroupG];

        const btnSendForAffirmationClickHandler = async (assignment: AssignModel) => {
            try {
                await collectingService.moveToNextStep(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: ProcessStep.Affirmation,
                        assignedToUserId: assignment.assignToUserId,
                        assignedToRoleId: assignment.assignToRoleId,
                    })
                );

                context.emit('sendForAffirmation', assignment);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            }
        };

        return {
            sendForAffirmationRoles,
            btnSendForAffirmationClickHandler,
        };
    },
});
</script>
