<template>
    <v-expansion-panel :value="panelValue">
        <v-expansion-panel-title>{{ $t('funds.panels.commissionDecision') }}</v-expansion-panel-title>
        <!-- <div v-if="loading" class="d-flex justify-content-center">
			<v-progress-circular :size="50" color="green-lighten-2" indeterminate></v-progress-circular>
		</div> -->
        <v-expansion-panel-text>
            <CommissionDecision :processId="process.id">
                <template v-slot:actions>
                    <v-row
                        v-if="
                            process.activeProcessStepTypeId === processStep.ConfirmedProtocol ||
                            process.activeProcessStepTypeId === processStep.CommissionCorrectionsCheck
                        "
                    >
                        <v-col class="d-flex gap-2 justify-content-start">
                            <v-btn @click="onAccept(processStep.CommissionDecision)"
                                >Приемане
                                <v-tooltip activator="parent" location="bottom">
                                    Приемане на решението на комисията
                                </v-tooltip>
                            </v-btn>
                            <v-btn @click="onAcceptAfterChange(processStep.CommissionCorrections)"
                                >Приемане след промяна
                                <v-tooltip activator="parent" location="bottom">
                                    Приемане на решението на комисията след промяна
                                </v-tooltip>
                            </v-btn>
                            <v-btn class="cancel" @click="onReject(processStep.CommissionDecision)"
                                >Отказ
                                <v-tooltip activator="parent" location="bottom">
                                    Отказ на решението на комисията
                                </v-tooltip>
                            </v-btn>

                            <assign-modal
                                v-if="showAssignForRedirectBtn"
                                ref="assignForRedirectModal"
                                class="mb-3"
                                :archiveId="process.archiveId"
                                :roleNames="redirectRoles"
                                :showDate="false"
                                :showRoles="true"
                                :btnTitle="$t('processes.buttons.assignForRedirect')"
                                :dialogTitle="$t('processes.steps.redirectToArchive')"
                                @assign="onAssignForRedirect"
                            ></assign-modal>
                        </v-col>
                    </v-row>
                    <v-row v-if="process.activeProcessStepTypeId === processStep.Affirmation">
                        <v-col class="d-grid gap-2 d-md-flex justify-content-center">
                            <confirm-dialog
                                :confirmationText="
                                    $t('processes.buttons.reconstructionModificationsAffirmationStepConfirmation')
                                "
                                :activatorButtonText="$t('processes.buttons.modificationsAffirmationStep')"
                                :confirmButtonText="$t('common.yes')"
                                :cancelButtonText="$t('common.cancel')"
                                @confirm="onAccept(processStep.Affirmation)"
                            />

                            <confirm-dialog
                                :confirmationText="$t('processes.buttons.reportChangesStepConfirmation')"
                                :activatorButtonText="$t('processes.buttons.reportChangesStep')"
                                :confirmButtonText="$t('common.yes')"
                                :cancelButtonText="$t('common.cancel')"
                                @confirm="onAcceptAfterChange(processStep.Affirmation)"
                            />
                        </v-col>
                    </v-row>
                    <v-row v-if="process.activeProcessStepTypeId === processStep.SendForRedirect">
                        <v-col class="d-grid gap-2 d-md-flex justify-content-center">
                            <choose-archive-modal
                                ref="redirectToArchiveModal"
                                class="mb-3"
                                :btnTitle="$t('processes.buttons.redirectToArchive')"
                                :dialogTitle="$t('processes.steps.redirectToArchive')"
                                @chosen="onRedirectToArchive"
                            ></choose-archive-modal>
                        </v-col>
                    </v-row>
                </template>
            </CommissionDecision>
        </v-expansion-panel-text>
    </v-expansion-panel>
</template>

<script lang="ts">
import { computed, defineComponent, inject, PropType, Ref, ref } from 'vue';
import CommissionDecision from '@/components/commission/decision.vue';
import { IProcess } from '@/interfaces/process';
import { ProcessStep, ProcessType } from '@/enums/process';
import { IProcessDecision } from '@/models/eDocsCollection';
import { IMessage } from '@/interfaces/notification';
import service from '@/services/eDocsCollecting.service';
import { ResponseResult } from '@/models/responseResult';
import { Message } from '@/models/notification';
import AssignModal from '@/components/films/assign.modal.vue';
import ChooseArchiveModal from '@/components/modals/chooseArchive.modal.vue';
import { AssignModel } from '@/models/task';
import { RoleNames } from '@/enums/roles';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import { useStore } from '@/store/user';

export default defineComponent({
    components: {
        AssignModal,
        ChooseArchiveModal,
        CommissionDecision,
        ConfirmDialog,
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
        const decision = ref({
            processId: props.process.id!,
            accepted: false,
            hasConditions: false,
            assignForRedirect: false,
        } as IProcessDecision);
        const message = inject('notificationMessage') as Ref<IMessage>;
        const approvalRoles = computed(() => [RoleNames.GroupA]);
        const redirectRoles = computed(() => [RoleNames.GroupG]);
        const isExternalProcedure = ref(false);

        service.isExternalProcess(props.process.id!).then((data) => (isExternalProcedure.value = data));

        const userStore = useStore();
        const hasRoleV1V2 = computed(
            () => userStore.getters.hasRole(RoleNames.GroupV1) || userStore.getters.hasRole(RoleNames.GroupV2)
        );
        const showAssignForRedirectBtn = computed(
            () =>
                props.process &&
                hasRoleV1V2.value == true &&
                (props.process.processTypeId === ProcessType.AddRawInventory ||
                    props.process.processTypeId === ProcessType.AddRawInventoryRaw ||
                    props.process.processTypeId === ProcessType.AddRawFundAndRawInventory ||
                    props.process.processTypeId === ProcessType.AddSystemInventory)
        );

        return {
            approvalRoles,
            redirectRoles,
            decision,
            isExternalProcedure,
            message,
            processStep: ProcessStep,
            showAssignForRedirectBtn,
        };
    },
    methods: {
        onAccept(stage: ProcessStep) {
            this.decision.accepted = true;
            //this.send(ProcessStep.CommissionDecision);
            this.send(stage);
        },
        onAcceptAfterChange(stage: ProcessStep) {
            this.decision.accepted = true;
            this.decision.hasConditions = true;
            //this.send(ProcessStep.CommissionDecision);
            this.send(stage);
        },
        onReject(stage: ProcessStep) {
            this.decision.accepted = false;
            //this.send(ProcessStep.CommissionDecision);
            this.send(stage);
        },
        onAssignForRedirect(model: AssignModel) {
            this.decision.accepted = true;
            this.decision.assignForRedirect = true;
            this.decision.assignToUserId = model.assignToUserId;
            this.decision.assignToRoleId = model.assignToRoleId;

            this.send(ProcessStep.CommissionDecision);
        },
        onRedirectToArchive(redirectArchiveId: number) {
            this.decision.redirectToArchiveId = redirectArchiveId;
            this.send(ProcessStep.SendForRedirect);
        },
        send(stage: ProcessStep) {
            service
                .processDecision(this.decision, stage)
                .then(() => {
                    //TODO
                    window.location.reload();
                })
                .catch((err) => {
                    const errorResult = err as ResponseResult;
                    this.message = new Message({
                        text: errorResult.showMessage ? errorResult.message : this.$t('error.basic'),
                        display: true,
                    });
                });
        },
    },
});
</script>

<style scoped></style>
