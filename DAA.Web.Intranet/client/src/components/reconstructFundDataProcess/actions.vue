<template>
    <v-row align="end">
        <v-col class="d-grid gap-2 d-md-flex justify-content-center" style="gap: 20px;">
            <assign-modal
                v-if="showRequestAccessSuspensionBtn"
                :archiveId="process.archiveId"
                :roleNames="requestAccessSuspensionRoles"
                :btnTitle="t('processes.buttons.requestAccessSuspensionStep')"
                :dialogTitle="t('processes.steps.requestAccessSuspension')"
                :showDate="false"
                :showRoles="false"
                @assign="btnRequestAccessSuspensionStepClickHandler"
            />

            <confirm-dialog
                v-if="showSuspendAccessBtn"
                :confirmationText="t('processes.buttons.suspendAccessStepConfirmation', process.fundNumber)"
                :activatorButtonText="t('processes.buttons.suspendAccessStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnSuspendAccessStepClickHandler"
            />

            <confirm-dialog
                v-if="showStartApplyingChangesBtn"
                :confirmationText="t('processes.buttons.startApplyingChangesStepConfirmation')"
                :activatorButtonText="t('processes.buttons.startApplyingChangesStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnStartApplyingStepClickHandler(ProcessStep.ReconstructFundData_EditData)"
            />

            <confirm-dialog
                v-if="showCreateReportBtn"
                :confirmationText="t('processes.buttons.createReportStepConfirmation')"
                :activatorButtonText="t('processes.buttons.createReportStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnCreateReportStepClickHandler"
            />

            <assign-modal
                v-if="showSendReportBtn"
                :archiveId="process.archiveId"
                :roleNames="sendReportRoles"
                :btnTitle="t('processes.buttons.sendReportStep')"
                :dialogTitle="t('processes.steps.sendReport')"
                :showDate="false"
                :showRoles="false"
                @assign="btnSendReportStepClickHandler" />

            <confirm-dialog
                v-if="showChangesRequiredBtn"
                :confirmationText="t('processes.buttons.reportChangesStepConfirmation')"
                :activatorButtonText="t('processes.buttons.reportChangesStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                :commentInputEnabled="true"
                @confirm="(commentInput) => btnChangesRequiredStepClickHandler(commentInput)"
            />

            <confirm-dialog
                v-if="showStartApplyingModificationsBtn"
                :confirmationText="t('processes.buttons.startApplyingModificationsStepConfirmation')"
                :activatorButtonText="t('processes.buttons.startApplyingModificationsStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnStartApplyingStepClickHandler(ProcessStep.ReconstructFundData_DataModifications)"
            />

            <!-- <confirm-dialog
                v-if="showAddReportBtn"
                :confirmationText="t('processes.buttons.addReportToSessionAgendaStepConfirmation')"
                :activatorButtonText="t('processes.buttons.addReportToSessionAgendaStep')"
                :confirmButtonText="t('processes.buttons.addReportToSessionAgendaStep')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnAddReportStepClickHandler"
            /> -->

            <assign-modal
                v-if="showSendToAddStandpointBtn"
                :archiveId="process.archiveId"
                :roleNames="addStandpointRoles"
                :btnTitle="t('processes.buttons.sendToAddSessionAgendaStandpointStep')"
                :dialogTitle="t('processes.steps.sendToAddSessionAgendaStandpoint')"
                :showDate="true"
                :showRoles="true"
                :showUsers="false"
                @assign="btnSendToAddStandpointStepClickHandler"
            />

            <!-- <confirm-dialog
                v-if="showSendStandpointBtn"
                :confirmationText="t('processes.buttons.sendSessionAgendaStandpointStepConfirmation')"
                :activatorButtonText="t('processes.buttons.sendSessionAgendaStandpointStep')"
                :confirmButtonText="t('processes.buttons.sendSessionAgendaStandpointStep')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnSendStandpointStepClickHandler"
            /> -->

            <confirm-dialog
                v-if="showSendToAddCommentBtn"
                :confirmationText="t('processes.buttons.sendToAddSessionAgendaStandpointCommentStepConfirmation')"
                :activatorButtonText="t('processes.buttons.sendToAddSessionAgendaStandpointCommentStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnSendToAddCommentStepClickHandler"
            />

            <confirm-dialog
                v-if="showAddCommentBtn"
                :confirmationText="t('processes.buttons.addSessionAgendaStandpointCommentStepConfirmation')"
                :activatorButtonText="t('processes.buttons.addSessionAgendaStandpointCommentStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnAddCommentStepClickHandler"
            />

            <confirm-dialog
                v-if="showSendCommentBtn"
                :confirmationText="t('processes.buttons.sendSessionAgendaStandpointCommentStepConfirmation')"
                :activatorButtonText="t('processes.buttons.sendSessionAgendaStandpointCommentStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnSendCommentStepClickHandler"
            />

            <confirm-dialog
                v-if="showSetSessionAgendaItemBtn"
                :confirmationText="t('processes.buttons.setSessionAgendaItemStepConfirmation')"
                :activatorButtonText="t('processes.buttons.setSessionAgendaItemStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnSetSessionAgendaItemStepClickHandler"
            />

            <confirm-dialog
                v-if="showApplyModificationsBtn"
                :confirmationText="t('processes.buttons.applyModificationsStepConfirmation')"
                :activatorButtonText="t('processes.buttons.applyModificationsStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnApplyModificationsStepClickHandler"
            />

            <assign-modal
                v-if="showSendForModificationsRevisionBtn"
                :archiveId="process.archiveId"
                :roleNames="sendForModificationsRevisionRoles"
                :btnTitle="t('processes.buttons.sendForModificationsRevisionStep')"
                :dialogTitle="t('processes.steps.sendForModificationsRevision')"
                :showDate="false"
                :showRoles="false"
                @assign="btnSendForModificationsRevisionStepClickHandler"
            />

            <confirm-dialog
                v-if="showModificationsRevisionBtn"
                :confirmationText="t('processes.buttons.modificationsRevisionStepConfirmation')"
                :activatorButtonText="t('processes.buttons.modificationsRevisionStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnModificationsRevisionStepClickHandler"
            />

            <assign-modal
                v-if="showSendForModificationsAffirmationBtn"
                :archiveId="process.archiveId"
                :roleNames="sendForModificationsAffirmationRoles"
                :btnTitle="t('processes.buttons.sendForModificationsAffrimationStep')"
                :dialogTitle="t('processes.steps.sendForModificationsAffrimation')"
                :showDate="false"
                :showRoles="false"
                @assign="btnSendForModificationsAffirmationStepClickHandler"
            />

            <assign-modal
                v-if="showSendForRegistrationBtn"
                :archiveId="process.archiveId"
                :roleNames="sendForRegistrationRoles"
                :btnTitle="t('processes.buttons.sendForRegistrationStep')"
                :dialogTitle="t('processes.steps.sendForRegistration')"
                :showDate="false"
                :showRoles="false"
                @assign="btnSendForRegistrationStepClickHandler"
            />

            <confirm-dialog
                v-if="showStartRegistrationBtn"
                :confirmationText="t('processes.buttons.registrationStepConfirmation', {title: process.processTypeTitle})"
                :activatorButtonText="t('processes.buttons.registrationStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnStartRegistrationStepClickHandler"
            />


            <confirm-dialog
                v-if="showCompleteBtn"
                :confirmationText="t('processes.buttons.completeConfirmation', {title: process.processTypeTitle})"
                :activatorButtonText="t('processes.buttons.complete')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnCompleteProcessClickHandler"
            />
            <confirm-dialog
                v-if="showUndoChangesBtn"
                :confirmationText="t('processes.buttons.undoChangesConfirmation')"
                :activatorButtonText="t('processes.buttons.undoChanges')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnUndoChangesClickHandler"
            />
        </v-col>
    </v-row>
</template>
<script lang="ts">
import { computed, defineComponent, inject, PropType, Ref } from 'vue';
import { useI18n } from 'vue-i18n';

import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { RoleNames } from '@/enums/roles';
import { ProcessStep, ProcessType } from '@/enums/process';
import { IProcess } from '@/interfaces/process';
import { AssignModel } from '@/models/task';
import { ProcessStepModel } from '@/models/process';
import authorization from '@/helpers/authorization.helper';
import reconstructFundDataProcessService from '@/services/reconstructFundData.service';

import AssignModal from '@/components/films/assign.modal.vue';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';

export default defineComponent({
    name: "ReconstructFundDataProcessActions",
    components: {
        AssignModal,
        ConfirmDialog,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>
        },
    },
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        
        const showCompleteBtn = computed(
            () => 
                props.process 
                && props.process.processTypeId === ProcessType.ReconstructFundData
                && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_Registration
                && authorization.hasRole(RoleNames.GroupA));

        const showUndoChangesBtn = computed(
            () =>
                props.process
                && authorization.isCurrentUser(props.process.createdBy!)
                && props.process.processTypeId === ProcessType.ReconstructFundData
                && (props.process.activeProcessStepTypeId == ProcessStep.ReconstructFundData_EditData
                    || props.process.activeProcessStepTypeId == ProcessStep.ReconstructFundData_CreateReport));

        const showRequestAccessSuspensionBtn = computed(
            () =>
                props.process
                && authorization.isCurrentUser(props.process.createdBy!)
                && props.process.processTypeId === ProcessType.ReconstructFundData
                && props.process.activeProcessStepTypeId == ProcessStep.ReconstructFundData_ProcessInitiation);
        const showSuspendAccessBtn = computed(
            () =>
                props.process
                && props.process.processTypeId === ProcessType.ReconstructFundData
                && props.process.activeProcessStepTypeId == ProcessStep.ReconstructFundData_RequestPublicAccessSuspension
                && authorization.hasRole(RoleNames.GroupG)
                );
        const showStartApplyingChangesBtn = computed(
            () =>
                props.process
                && props.process.processTypeId === ProcessType.ReconstructFundData
                && props.process.activeProcessStepTypeId == ProcessStep.ReconstructFundData_SuspendPublicAccess
                && authorization.hasRole(RoleNames.GroupB));
        const showStartApplyingModificationsBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.ReconstructFundData
            && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ChangesRequired);


        const showCreateReportBtn = computed(
            () =>
                props.process
                && authorization.isCurrentUser(props.process.createdBy!)
                && props.process.processTypeId === ProcessType.ReconstructFundData
                && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_EditData);
        const showSendReportBtn = computed(
            () =>
                props.process
                && authorization.isCurrentUser(props.process.createdBy!)
                && props.process.processTypeId === ProcessType.ReconstructFundData
                && (props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_CreateReport
                    || props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_DataModifications));
        const showChangesRequiredBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.ReconstructFundData
            && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendReport
            && authorization.hasRole(RoleNames.GroupV1));

        // const showAddReportBtn = computed(() =>
        //     props.process
        //     && props.process.processTypeId === ProcessType.ReconstructFundData
        //     && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendReport);
        // const showSendToAddStandpointBtn = computed(() =>
        //     props.process
        //     && props.process.processTypeId === ProcessType.ReconstructFundData
        //     && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_AddReportToSessionAgenda);
        const showSendToAddStandpointBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.ReconstructFundData
            && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendReport
            && authorization.hasRole(RoleNames.GroupV1)
            && props.process.isCurrentUserInActiveProcessStep);
        // const showSendStandpointBtn = computed(() =>
        //     props.process
        //     && props.process.processTypeId === ProcessType.ReconstructFundData
        //     && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_AddSessionAgendaStandpoint);
        const showSendToAddCommentBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.ReconstructFundData
            && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_AddSessionAgendaStandpoint
            && authorization.hasRole(RoleNames.GroupV1)
            && props.process.isCurrentUserInActiveProcessStep);
        const showAddCommentBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.ReconstructFundData
            && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendToAddSessionAgendaStandpointComment
            && authorization.hasRole(RoleNames.GroupB));
        const showSendCommentBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.ReconstructFundData
            && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_AddSessionAgendaStandpointComment
            && authorization.hasRole(RoleNames.GroupB)
            && authorization.isCurrentUser(props.process.createdBy!));
        const showSetSessionAgendaItemBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.ReconstructFundData
            && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendSessionAgendaStandpointComment
            && authorization.hasRole(RoleNames.GroupV1)
            && props.process.isCurrentUserInActiveProcessStep);
        const showApplyModificationsBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.ReconstructFundData
            && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ReportChangesRequired
            && authorization.hasRole(RoleNames.GroupB)
            && props.process.isCurrentUserInActiveProcessStep);
        const showSendForModificationsRevisionBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.ReconstructFundData
            && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ReportModifications
            && authorization.hasRole(RoleNames.GroupB)
            && props.process.isCurrentUserInActiveProcessStep);
        const showModificationsRevisionBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.ReconstructFundData
            && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendForModificationsRevision
            && authorization.hasRole(RoleNames.GroupV1));
        const showSendForModificationsAffirmationBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.ReconstructFundData
            && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ReportApproval
            && authorization.hasRole(RoleNames.GroupV1));
        const showSendForRegistrationBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.ReconstructFundData
            && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_Affirmation
            && authorization.hasRole(RoleNames.GroupB)
            && props.process.isCurrentUserInActiveProcessStep);
        const showStartRegistrationBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.ReconstructFundData
            && props.process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendForRegistration
            && authorization.hasRole(RoleNames.GroupA));


        const btnCompleteProcessClickHandler = async () => {
            try {
                await reconstructFundDataProcessService.completeProcess(props.process!.id!);

                context.emit('complete');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnUndoChangesClickHandler = async () => {
            try {
                await reconstructFundDataProcessService.undoProcessChanges(props.process!.id!);

                context.emit('undochanges');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnRequestAccessSuspensionStepClickHandler = async (assignment: AssignModel) => {
            try {
                await reconstructFundDataProcessService.requestPublicAccessSuspension(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: ProcessStep.ReconstructFundData_RequestPublicAccessSuspension,
                        assignedToUserId: assignment.assignToUserId,
                    }));

                context.emit('accessRequest', assignment);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnSuspendAccessStepClickHandler =async () => {
            try {
                await reconstructFundDataProcessService.suspendPublicAccess(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: ProcessStep.ReconstructFundData_SuspendPublicAccess,
                    }));

                context.emit('accessSuspend');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnStartApplyingStepClickHandler =async (stepTypeId: number) => {
            try {
                await reconstructFundDataProcessService.startApplyingChanges(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: stepTypeId,
                    }));

                context.emit('applyChanges');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };


        const btnCreateReportStepClickHandler = async () => {
            try {
                await reconstructFundDataProcessService.createReport(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: ProcessStep.ReconstructFundData_CreateReport,
                }));

                context.emit('createReport');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnSendReportStepClickHandler = async (assignment: AssignModel) => {
            try {
                await reconstructFundDataProcessService.sendReport(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: ProcessStep.ReconstructFundData_SendReport,
                    assignedToUserId: assignment.assignToUserId,
                }));

                context.emit('sendReport', assignment);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnChangesRequiredStepClickHandler = async (comment?: string) => {
            try {
                await reconstructFundDataProcessService.sendReportApprovalResult(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: ProcessStep.ReconstructFundData_ChangesRequired,
                        assignedToUserId: props.process?.createdBy,
                        comment: comment,
                    }));

                context.emit('changesRequired');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        // const btnAddReportStepClickHandler =async () => {
        //     try {
        //         await reconstructFundDataProcessService.addReportToSessionAgenda(new ProcessStepModel({
        //             processId: props.process?.id,
        //             stepTypeId: ProcessStep.ReconstructFundData_AddReportToSessionAgenda,
        //         }));

        //         context.emit('addReport');
        //     } catch (error: unknown) {
        //         const errorResult = error as ResponseResult;
        //         message.value = new Message({
        //             text: errorResult.showMessage ? errorResult.message : t('error.basic'),
        //             display: true,
        //         });
        //     }
        // };

        const btnSendToAddStandpointStepClickHandler = async (assignment: AssignModel) => {
            try {
                await reconstructFundDataProcessService.sendToAddSessionAgendaItemStandpoint(new ProcessStepModel({
					processId: props.process?.id,
                    stepTypeId: ProcessStep.ReconstructFundData_SendToAddSessionAgendaStandpoint,
					assignedToRoleId: assignment.assignToRoleId,
					endDate: assignment.endDate,
				}));

                context.emit('sendforStandpoint', assignment);
			} catch (error: unknown) {
				const errorResult  = error as ResponseResult;
				message.value = new Message({
					text:  errorResult.showMessage ? errorResult.message : t('error.basic'),
					display: true,
				});
			}
        };

        // const btnSendStandpointStepClickHandler = async () => {
        //     await reconstructFundDataProcessService.sendSessionAgendaItemStandpoint(
        //         new ProcessStepModel({
        //             id: props.process?.activeProcessStepId,
        //             processId: props.process?.id,
        //             stepTypeId: props.process?.activeProcessStepTypeId,
        //         }));
        //     context.emit('sendStandpoint');
        // };

        const btnSendToAddCommentStepClickHandler = async () => {
            try {
                await reconstructFundDataProcessService.sendToAddSessionAgendaItemStandpointComment(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: ProcessStep.ReconstructFundData_SendToAddSessionAgendaStandpointComment,
                        assignedToUserId: props.process?.createdBy,
                    }));
                context.emit('sendForComment');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnAddCommentStepClickHandler = async () => {
              try {
                await reconstructFundDataProcessService.addSessionAgendaItemStandpointComment(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: ProcessStep.ReconstructFundData_AddSessionAgendaStandpointComment,
                    }));
                context.emit('addComment');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnSendCommentStepClickHandler = async () => {
              try {
                await reconstructFundDataProcessService.sendSessionAgendaItemStandpointComment(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: ProcessStep.ReconstructFundData_SendSessionAgendaStandpointComment,
                    }));
                context.emit('sendComment');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnSetSessionAgendaItemStepClickHandler = async () => {
              try {
                await reconstructFundDataProcessService.setSessionAgendaItem(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: ProcessStep.ReconstructFundData_CommissionSession,
                        assignedToUserId: props.process?.createdBy,
                    }));
                context.emit('setSessionAgenda');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnApplyModificationsStepClickHandler = async () => {
            try {
                await reconstructFundDataProcessService.applyReportModifications(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: ProcessStep.ReconstructFundData_ReportModifications,
                    }));
                context.emit('applyChanges');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnSendForModificationsRevisionStepClickHandler = async (assignment: AssignModel) => {
            try {
                await reconstructFundDataProcessService.sendForModificationsRevision(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: ProcessStep.ReconstructFundData_SendForModificationsRevision,
                    assignedToUserId: assignment.assignToUserId,
                }));

                context.emit('sendChanges', assignment);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

         const btnModificationsRevisionStepClickHandler = async () => {
            try {
                await reconstructFundDataProcessService.modificationsRevision(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: ProcessStep.ReconstructFundData_ModificationsRevision,
                }));

                context.emit('revision');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnSendForModificationsAffirmationStepClickHandler = async (assignment: AssignModel) => {
            try {
                await reconstructFundDataProcessService.sendForModificationsAffirmation(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: ProcessStep.ReconstructFundData_SendForAffirmation,
                    assignedToUserId: assignment.assignToUserId,
                }));

                context.emit('sendRevision', assignment);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnSendForRegistrationStepClickHandler = async (assignment: AssignModel) => {
            try {
                await reconstructFundDataProcessService.sendForModificationsRegistration(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: ProcessStep.ReconstructFundData_SendForRegistration,
                    assignedToUserId: assignment.assignToUserId,
                }));

                context.emit('sendForRegistration', assignment);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnStartRegistrationStepClickHandler = async () => {
            try {
                await reconstructFundDataProcessService.startModificationsRegistration(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: ProcessStep.ReconstructFundData_Registration,
                }));

                context.emit('registration');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const requestAccessSuspensionRoles = [RoleNames.GroupG]
        const sendReportRoles = [RoleNames.GroupV1];
        const addStandpointRoles = [RoleNames.GroupV4];
        const sendForModificationsRevisionRoles = [RoleNames.GroupV1];
        const sendForModificationsAffirmationRoles = [RoleNames.GroupG];
        const sendForRegistrationRoles = [RoleNames.GroupA];

        return {
            t,
            ProcessStep,
            requestAccessSuspensionRoles,
            sendReportRoles,
            addStandpointRoles,
            sendForModificationsRevisionRoles,
            sendForModificationsAffirmationRoles,
            sendForRegistrationRoles,
            showCompleteBtn,
            showUndoChangesBtn,
            showRequestAccessSuspensionBtn,
            showSuspendAccessBtn,
            showStartApplyingChangesBtn,
            showStartApplyingModificationsBtn,
            showCreateReportBtn,
            showSendReportBtn,
            showChangesRequiredBtn,
            //showAddReportBtn,
            showSendToAddStandpointBtn,
            //showSendStandpointBtn,
            showSendToAddCommentBtn,
            showAddCommentBtn,
            showSendCommentBtn,
            showSetSessionAgendaItemBtn,
            showApplyModificationsBtn,
            showSendForModificationsRevisionBtn,
            showModificationsRevisionBtn,
            showSendForModificationsAffirmationBtn,
            showSendForRegistrationBtn,
            showStartRegistrationBtn,
            btnUndoChangesClickHandler,
            btnCompleteProcessClickHandler,
            btnRequestAccessSuspensionStepClickHandler,
            btnSuspendAccessStepClickHandler,
            btnStartApplyingStepClickHandler,
            btnCreateReportStepClickHandler,
            btnSendReportStepClickHandler,
            btnChangesRequiredStepClickHandler,
            //btnAddReportStepClickHandler,
            btnSendToAddStandpointStepClickHandler,
            //btnSendStandpointStepClickHandler,
            btnSendToAddCommentStepClickHandler,
            btnAddCommentStepClickHandler,
            btnSendCommentStepClickHandler,
            btnSetSessionAgendaItemStepClickHandler,
            btnApplyModificationsStepClickHandler,
            btnSendForModificationsRevisionStepClickHandler,
            btnModificationsRevisionStepClickHandler,
            btnSendForModificationsAffirmationStepClickHandler,
            btnSendForRegistrationStepClickHandler,
            btnStartRegistrationStepClickHandler,
        }
    },
})
</script>
