<template>
    <v-expansion-panel :value="panelValue" v-if="process.activeProcessStepTypeId !== ProcessStep.Registration">
        <v-expansion-panel-title>
            {{ t('processes.steps.sendForRegistration') }}
        </v-expansion-panel-title>
        <v-expansion-panel-text>
            <assign-modal
                ref="sendForRegistrationModal"
                class="mb-3"
                :archiveId="process.archiveId"
                :roleNames="approvalRoles"
                :showDate="false"
                :showRoles="true"
                :btnTitle="t('processes.buttons.sendToRegistrarStep')"
                :dialogTitle="t('processes.steps.sendToRegistrar')"
                @assign="onAccept"
            ></assign-modal>
        </v-expansion-panel-text>
    </v-expansion-panel>
    <v-expansion-panel :value="panelValue" v-else>
        <v-expansion-panel-title>{{ t('processes.steps.registration') }}</v-expansion-panel-title>
        <v-expansion-panel-text>
            <v-row>
                <v-col class="d-flex justify-content-start">
                    <confirm-dialog
                        :activatorButtonText="$t('processes.buttons.completeRegistration')"
                        :confirmationText="$t('processes.buttons.completeRegistrationConfirmation')"
                        :cancelButtonText="$t('common.cancel')"
                        :confirmButtonText="$t('common.yes')"
                        @confirm="onConfirm"
                    ></confirm-dialog>
                </v-col>
            </v-row>
        </v-expansion-panel-text>
    </v-expansion-panel>
</template>

<script lang="ts">
import { computed, defineComponent, inject, PropType, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';

import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { ProcessStep } from '@/enums/process';
import { IProcess, IProcessStep } from '@/interfaces/process';
import collectingService from '@/services/eDocsCollecting.service';

import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import AssignModal from '@/components/films/assign.modal.vue';
import { RoleNames } from '@/enums/roles';
import { AssignModel } from '@/models/task';

export default defineComponent({
    components: {
        ConfirmDialog,
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
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const approvalRoles = computed(() => [RoleNames.GroupA]);

        const nextStep = ref({ processId: props.process.id } as IProcessStep);

        const onAccept = (model: AssignModel) => {
            nextStep.value.assignedToUserId = model.assignToUserId;
            nextStep.value.assignedToRoleId = model.assignToRoleId;
            moveToNextStep();
        };

        const moveToNextStep = () => {
            collectingService
                .sendForRegistration(nextStep.value)
                .then(() => window.location.reload())
                .catch((err) => console.log(err));
        };

        const onConfirm = () => {
            collectingService
                .completeProcess(props.process.id!)
                .then(() => window.location.reload())
                .catch((err) => {
                    console.error(err);
                    const errorResult = err as ResponseResult;
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                        display: true,
                    });
                });
        };
        return {
            t,
            approvalRoles,
            ProcessStep,
            onConfirm,
            onAccept,
        };
    },
});
</script>

<style scoped></style>
