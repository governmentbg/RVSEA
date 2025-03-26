<template>
    <v-row align="end">
        <v-col class="d-grid gap-2 d-md-flex justify-content-center">
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
                @assign="btnSendReportStepClickHandler"
            />

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
                @confirm="btnStartApplyingStepClickHandler"
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
                :dialogTitle="t('processes.buttons.sendToAddSessionAgendaStandpointStepConfirmation')"
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

import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { RoleNames } from '@/enums/roles';
import { AssignModel } from '@/models/task';
import { ProcessStep, ProcessType } from '@/enums/process';
import { IProcess } from '@/interfaces/process';
import { ProcessStepModel } from '@/models/process';
import authorization from '@/helpers/authorization.helper';
//import processService from '@/services/process.service';
import editFundDataProcessService from '@/services/editFundDataProcess.service';

import AssignModal from '@/components/films/assign.modal.vue';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';


export default defineComponent({
    name: "EditFundDataProcessActions",
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
        //TODO Fix check for active step
        const showCompleteBtn = computed(
            () => 
                // props.process 
                // && props.process.processTypeId === ProcessType.EditFundData
                false);
        const showUndoChangesBtn = computed(
            () =>
                props.process
                && authorization.isCurrentUser(props.process.createdBy!)
                && props.process.processTypeId === ProcessType.EditFundData
                && (props.process.activeProcessStepTypeId == ProcessStep.EditFundData_EditData
                    || props.process.activeProcessStepTypeId == ProcessStep.EditFundData_CreateReport));
        const showCreateReportBtn = computed(
            () =>
                props.process
                && authorization.isCurrentUser(props.process.createdBy!)
                && props.process.processTypeId === ProcessType.EditFundData
                && props.process.activeProcessStepTypeId === ProcessStep.EditFundData_EditData);
        const showSendReportBtn = computed(
            () =>
                props.process
                && authorization.isCurrentUser(props.process.createdBy!)
                && props.process.processTypeId === ProcessType.EditFundData
                && (props.process.activeProcessStepTypeId === ProcessStep.EditFundData_CreateReport
                    || props.process.activeProcessStepTypeId === ProcessStep.EditFundData_DataModifications));
        const showStartApplyingModificationsBtn = computed(
            () =>
                props.process
                && authorization.isCurrentUser(props.process.createdBy!)
                && props.process.processTypeId === ProcessType.EditFundData
                && props.process.activeProcessStepTypeId === ProcessStep.EditFundData_ChangesRequired);
        const showChangesRequiredBtn = computed(
            () =>
                props.process
                && props.process.processTypeId === ProcessType.EditFundData
                && props.process.activeProcessStepTypeId === ProcessStep.EditFundData_SendReport
                && props.process.isCurrentUserInActiveProcessStep
                && authorization.hasRole(RoleNames.GroupV1));
        // const showAddReportBtn = computed(
        //     () =>
        //         props.process
        //         && props.process.processTypeId === ProcessType.EditFundData
        //         && props.process.activeProcessStepTypeId === ProcessStep.EditFundData_SendReport);
        // const showSendToAddStandpointBtn = computed(() =>
        //     props.process
        //     && props.process.processTypeId === ProcessType.EditFundData
        //     && props.process.activeProcessStepTypeId === ProcessStep.EditFundData_AddReportToSessionAgenda);
        const showSendToAddStandpointBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.EditFundData
            && props.process.activeProcessStepTypeId === ProcessStep.EditFundData_SendReport
            && authorization.hasRole(RoleNames.GroupV1)
            && props.process.isCurrentUserInActiveProcessStep);
        // const showSendStandpointBtn = computed(() =>
        //     props.process
        //     && props.process.processTypeId === ProcessType.EditFundData
        //     && props.process.activeProcessStepTypeId === ProcessStep.EditFundData_AddSessionAgendaStandpoint);
        const showSendToAddCommentBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.EditFundData
            && props.process.activeProcessStepTypeId === ProcessStep.EditFundData_AddSessionAgendaStandpoint
            && authorization.hasRole(RoleNames.GroupV1)
            && props.process.isCurrentUserInActiveProcessStep);
        const showAddCommentBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.EditFundData
            && props.process.activeProcessStepTypeId === ProcessStep.EditFundData_SendToAddSessionAgendaStandpointComment
            && authorization.hasRole(RoleNames.GroupB));
        const showSendCommentBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.EditFundData
            && props.process.activeProcessStepTypeId === ProcessStep.EditFundData_AddSessionAgendaStandpointComment
            && authorization.hasRole(RoleNames.GroupB)
            && authorization.isCurrentUser(props.process.createdBy!));
        const showSetSessionAgendaItemBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.EditFundData
            && props.process.activeProcessStepTypeId === ProcessStep.EditFundData_SendSessionAgendaStandpointComment
            && authorization.hasRole(RoleNames.GroupV1)
            && props.process.isCurrentUserInActiveProcessStep);
        const showApplyModificationsBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.EditFundData
            && props.process.activeProcessStepTypeId === ProcessStep.EditFundData_ReportChangesRequired
            && authorization.hasRole(RoleNames.GroupB)
            && props.process.isCurrentUserInActiveProcessStep);
        const showSendForModificationsRevisionBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.EditFundData
            && props.process.activeProcessStepTypeId === ProcessStep.EditFundData_ReportModifications
            && authorization.hasRole(RoleNames.GroupB)
            && props.process.isCurrentUserInActiveProcessStep);
        const showModificationsRevisionBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.EditFundData
            && props.process.activeProcessStepTypeId === ProcessStep.EditFundData_SendForModificationsRevision
            && authorization.hasRole(RoleNames.GroupV1));
        const showSendForModificationsAffirmationBtn = computed(() =>
            props.process
            && props.process.processTypeId === ProcessType.EditFundData
            && props.process.activeProcessStepTypeId === ProcessStep.EditFundData_ReportApproval
            && authorization.hasRole(RoleNames.GroupV1));



        const btnCompleteProcessClickHandler = async () => {
            try {
                await editFundDataProcessService.completeProcess(props.process!.id!);

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
                await editFundDataProcessService.undoProcessChanges(props.process!.id!);

                context.emit('undochanges');
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
                await editFundDataProcessService.createReport(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: ProcessStep.EditFundData_CreateReport
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
                await editFundDataProcessService.sendReport(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: ProcessStep.EditFundData_SendReport,
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

        const btnStartApplyingStepClickHandler =async () => {
            try {
                await editFundDataProcessService.startApplyingChanges(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: ProcessStep.EditFundData_DataModifications,
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

        const btnChangesRequiredStepClickHandler = async (comment?: string) => {
            try {
                await editFundDataProcessService.sendReportApprovalResult(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: ProcessStep.EditFundData_ChangesRequired,
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

        // const btnAddReportStepClickHandler = async () => {
        //     try {
        //         await editFundDataProcessService.addReportToSessionAgenda(new ProcessStepModel({
        //             processId: props.process?.id,
        //             stepTypeId: ProcessStep.EditFundData_AddReportToSessionAgenda,
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
				await editFundDataProcessService.sendToAddSessionAgendaItemStandpoint(new ProcessStepModel({
					processId: props.process?.id,
                    stepTypeId: ProcessStep.EditFundData_SendToAddSessionAgendaStandpoint,
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
        //     await editFundDataProcessService.sendSessionAgendaItemStandpoint(
        //         new ProcessStepModel({
        //             id: props.process?.activeProcessStepId,
        //             processId: props.process?.id,
        //             stepTypeId: props.process?.activeProcessStepTypeId,
        //         }));
        //     context.emit('sendStandpoint');
        // };

        const btnSendToAddCommentStepClickHandler = async () => {
            try {
                await editFundDataProcessService.sendToAddSessionAgendaItemStandpointComment(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: ProcessStep.EditFundData_SendToAddSessionAgendaStandpointComment,
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
        }

        const btnAddCommentStepClickHandler = async () => {
              try {
                await editFundDataProcessService.addSessionAgendaItemStandpointComment(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: ProcessStep.EditFundData_AddSessionAgendaStandpointComment,
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
                await editFundDataProcessService.sendSessionAgendaItemStandpointComment(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: ProcessStep.EditFundData_SendSessionAgendaStandpointComment,
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
                await editFundDataProcessService.setSessionAgendaItem(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: ProcessStep.EditFundData_CommissionSession,
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
                await editFundDataProcessService.applyReportModifications(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: ProcessStep.EditFundData_ReportModifications,
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
                await editFundDataProcessService.sendForModificationsRevision(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: ProcessStep.EditFundData_SendForModificationsRevision,
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

        const btnModificationsRevisionStepClickHandler = async (assignment: AssignModel) => {
            try {
                await editFundDataProcessService.modificationsRevision(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: ProcessStep.EditFundData_ModificationsRevision,
                }));

                context.emit('revision', assignment);
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
                await editFundDataProcessService.sendForModificationsAffirmation(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: ProcessStep.EditFundData_SendForAffirmation,
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


        const sendReportRoles = [RoleNames.GroupV1];
        const addStandpointRoles = [RoleNames.GroupV4];
        const sendForModificationsRevisionRoles = [RoleNames.GroupV1];
        const sendForModificationsAffirmationRoles = [RoleNames.GroupG];

        return {
            t,
            sendReportRoles,
            addStandpointRoles,
            sendForModificationsRevisionRoles,
            sendForModificationsAffirmationRoles,
            showCompleteBtn,
            showUndoChangesBtn,
            showCreateReportBtn,
            showSendReportBtn,
            showStartApplyingModificationsBtn,
            showChangesRequiredBtn,
            //showAddReportBtn,
            //showSendStandpointBtn,
            showSendToAddStandpointBtn,
            showSendToAddCommentBtn,
            showSendCommentBtn,
            showAddCommentBtn,
            showSetSessionAgendaItemBtn,
            showApplyModificationsBtn,
            showSendForModificationsRevisionBtn,
            showModificationsRevisionBtn,
            showSendForModificationsAffirmationBtn,
            btnUndoChangesClickHandler,
            btnCompleteProcessClickHandler,
            btnCreateReportStepClickHandler,
            btnSendReportStepClickHandler,
            btnStartApplyingStepClickHandler,
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
        }
    },
})
</script>
