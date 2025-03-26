<template>
    <v-row align="end">
        <v-col class="d-grid gap-2 d-md-flex justify-content-center">

            <!-- Създаване на описи -->
            <confirm-dialog
                v-if="showCreateInventoriesBtn"
                :confirmationText="t('processes.buttons.createInventoriesStepConfirmation')"
                :activatorButtonText="t('processes.buttons.createInventoriesStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnCreateInventoriesStepClickHandler"
            />

            <!-- Създаване на доклад -->
            <confirm-dialog
                v-if="showCreateReportBtn"
                :confirmationText="t('processes.buttons.createReportStepConfirmation')"
                :activatorButtonText="t('processes.buttons.createReportStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnCreateReportStepClickHandler"
            />

            <!-- Връщане за корекции преди заседание -->
            <confirm-dialog 
                v-if="showChangesRequiredBtn"
                :confirmationText="t('processes.buttons.reportChangesStepConfirmation')"
                :activatorButtonText="t('processes.buttons.reportChangesStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                :commentInputEnabled="true"
                @confirm="(commentInput) => btnChangesRequiredStepClickHandler(commentInput)"
            />

            <!-- Извършване на корекции преди заседание -->
            <confirm-dialog 
                v-if="showStartApplyingModificationsBtn"
                :confirmationText="t('processes.buttons.startApplyingModificationsStepConfirmation')"
                :activatorButtonText="t('processes.buttons.startApplyingModificationsStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnStartApplyingStepClickHandler"
            />

            <!-- Определяне на дата за заседание -->
            <!-- <confirm-dialog
                v-if="showAddReportBtn"
                :confirmationText="t('processes.buttons.addReportToSessionAgendaStepConfirmation')"
                :activatorButtonText="t('processes.buttons.addReportToSessionAgendaStep')"
                :confirmButtonText="t('processes.buttons.addReportToSessionAgendaStep')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnAddReportStepClickHandler"
            /> -->

            <!-- Изпращане за становище -->
            <assign-modal
                v-if="showSendToAddStandpointBtn"
                :archiveId="process.archiveId"
                :roleNames="addStandpointRoles"
                :btnTitle="t('processes.buttons.sendToAddSessionAgendaStandpointStep')"
                :dialogTitle="t('processes.steps.sendToAddSessionAgendaStandpoint')"
                :showDate="false"
                :showRoles="true"
                :showUsers="false"
                @assign="btnSendToAddStandpointStepClickHandler" 
            />

            <!-- Изпращане на становище -->
            <!-- <confirm-dialog
                v-if="showSendStandpointBtn"
                :confirmationText="t('processes.buttons.sendSessionAgendaStandpointStepConfirmation')"
                :activatorButtonText="t('processes.buttons.sendSessionAgendaStandpointStep')"
                :confirmButtonText="t('processes.buttons.sendSessionAgendaStandpointStep')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnSendStandpointStepClickHandler"
            /> -->

            <!-- Изпращане за коментар -->
            <confirm-dialog
                v-if="showSendToAddCommentBtn"
                :confirmationText="t('processes.buttons.sendToAddSessionAgendaStandpointCommentStepConfirmation')"
                :activatorButtonText="t('processes.buttons.sendToAddSessionAgendaStandpointCommentStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnSendToAddCommentStepClickHandler"
            />

            <!-- Коментар по становище -->
            <confirm-dialog
                v-if="showAddCommentBtn"
                :confirmationText="t('processes.buttons.addSessionAgendaStandpointCommentStepConfirmation')"
                :activatorButtonText="t('processes.buttons.addSessionAgendaStandpointCommentStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnAddCommentStepClickHandler"
            />

            <!-- Изпращане на коментари -->
            <confirm-dialog
                v-if="showSendCommentBtn"
                :confirmationText="t('processes.buttons.sendSessionAgendaStandpointCommentStepConfirmation')"
                :activatorButtonText="t('processes.buttons.sendSessionAgendaStandpointCommentStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnSendCommentStepClickHandler"
            />

            <!-- За заседание на комисия -->
            <confirm-dialog
                v-if="showSetSessionAgendaItemBtn"
                :confirmationText="t('processes.buttons.setSessionAgendaItemStepConfirmation')"
                :activatorButtonText="t('processes.buttons.setSessionAgendaItemStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnSetSessionAgendaItemStepClickHandler"
            />

            <!-- Изпълнение на препоръки от комисия -->
            <confirm-dialog
                v-if="showApplyModificationsBtn"
                :confirmationText="t('processes.buttons.applyModificationsStepConfirmation')"
                :activatorButtonText="t('processes.buttons.applyModificationsStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnApplyModificationsStepClickHandler"
            />

            <!-- За проверка на корекции -->
            <assign-modal
                v-if="showSendForModificationsRevisionBtn"
                :archiveId="process.archiveId"
                :roleNames="sendForModificationsRevisionRoles"
                :btnTitle="t('processes.buttons.sendForModificationsRevisionStep')"
                :dialogTitle="t('processes.steps.sendForModificationsRevision')"
                :showDate="false"
                :showRoles="true"
                :showUsers="false"
                @assign="btnSendForModificationsRevisionStepClickHandler" 
            />

            <!-- Проверка на корекции -->
            <confirm-dialog
                v-if="showModificationsRevisionBtn"
                :confirmationText="t('processes.buttons.modificationsRevisionStepConfirmation')"
                :activatorButtonText="t('processes.buttons.modificationsRevisionStep')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnModificationsRevisionStepClickHandler"
            />

            <!-- За утвърждаване -->
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

            <!-- Насочване към регистратор -->
            <assign-modal
                v-if="showSendToRegistrarBtn"
                :archiveId="process.archiveId"
                :roleNames="sendToRegistrarRoles"
                :btnTitle="t('processes.buttons.sendToRegistrarStep')"
                :dialogTitle="t('processes.steps.sendToRegistrar')"
                :showDate="false"
                :showRoles="false"
                @assign="btnSendToRegistrarStepClickHandler"
            />

            <!-- Отмяна на промените -->
            <confirm-dialog
                v-if="showUndoChangesBtn"
                :confirmationText="t('processes.buttons.undoChangesConfirmation')"
                :activatorButtonText="t('processes.buttons.undoChanges')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnUndoChangesClickHandler"
            />

            <!-- Приключване на процес -->
            <confirm-dialog
                v-if="showCompleteBtn"
                :confirmationText="t('processes.buttons.completeRegistrationConfirmation')"
                :activatorButtonText="t('processes.buttons.completeRegistration')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnCompleteProcessClickHandler"
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
import { ProcessType, ProcessStep } from '@/enums/process';
import { IProcess } from '@/interfaces/process';
import { ProcessStepModel } from '@/models/process';
import processRawInventoriesProcessService from '@/services/processRawInventoriesProcess.service';
import { useStore } from '@/store/user';

import AssignModal from '@/components/films/assign.modal.vue';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';

export default defineComponent({
    name: "ProcessRawInventoriesProcessActions",
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

        const userStore = useStore();
        const hasRoleB = computed(() => userStore.getters.hasRole(RoleNames.GroupB));
        const hasRoleV1 = computed(() => userStore.getters.hasRole(RoleNames.GroupV1));
        const hasRoleV4 = computed(() => userStore.getters.hasRole(RoleNames.GroupV4));
        const hasRoleA = computed(() => userStore.getters.hasRole(RoleNames.GroupA));

        const showUndoChangesBtn = computed(() =>
            props.process && hasRoleB.value == true
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                && (props.process.activeProcessStepTypeId == ProcessStep.ProcessRawFundWithRawInventory_ChooseRawInventories ||
                    props.process.activeProcessStepTypeId == ProcessStep.ProcessRawFundWithRawInventory_CreateInventories ||
                    props.process.activeProcessStepTypeId == ProcessStep.ProcessRawFundWithRawInventory_CreateReport))
            || (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && (props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_ChooseRawInventories ||
                    props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_CreateInventories ||
                    props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_CreateReport))));

        const showCreateInventoriesBtn = computed(() =>
            props.process && hasRoleB.value == true
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                && props.process.activeProcessStepTypeId == ProcessStep.ProcessRawFundWithRawInventory_ChooseRawInventories)
            || (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && (props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_ChooseRawInventories))));

        const showCreateReportBtn = computed(() =>
            props.process && hasRoleB.value == true
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_CreateInventories)
            || ((props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_CreateInventories))));

        const showSendReportBtn = computed(() =>
            props.process
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_CreateReport)
            || (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_CreateReport)));

        const showChangesRequiredBtn = computed(() => 
            props.process && hasRoleV1.value == true
            && (props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_SendReport 
                || props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_SendReport));

        const showStartApplyingModificationsBtn = computed(() =>
            props.process && hasRoleB.value == true
            && (props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_ChangesRequired
                || props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_ChangesRequired));

        const showAddReportBtn = computed(() => 
            props.process && hasRoleV1.value == true
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_SendReport)
            || (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_SendReport)));

        const showSendToAddStandpointBtn = computed(() =>
            props.process && hasRoleV1.value == true
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_SendReport)
            || (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_SendReport)));

        const showSendStandpointBtn = computed(() =>
            props.process && (hasRoleV1.value == true || hasRoleV4.value == true)
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpoint)
            || (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpoint)));

        const showSendToAddCommentBtn = computed(() =>
            props.process && (hasRoleV1.value == true || hasRoleV4.value == true)
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpoint)
            || (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpoint)));

        const showAddCommentBtn = computed(() =>
            props.process && hasRoleB.value == true
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_SendToAddSessionAgendaStandpointComment)
            || (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_SendToAddSessionAgendaStandpointComment)));

        const showSendCommentBtn = computed(() =>
            props.process && hasRoleB.value == true
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpointComment)
            || (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpointComment)));

        const showSetSessionAgendaItemBtn = computed(() =>
            props.process && (hasRoleV1.value == true || hasRoleV4.value == true)
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_SendSessionAgendaStandpointComment)
            || (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_SendSessionAgendaStandpointComment)));

        const showApplyModificationsBtn = computed(() => 
            props.process && hasRoleB.value == true
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory 
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_ReportChangesRequired)
            || (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_ReportChangesRequired)));

        const showSendForModificationsRevisionBtn = computed(() => 
            props.process && hasRoleB.value == true
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory 
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_ReportModifications)
            || (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_ReportModifications)));

        const showModificationsRevisionBtn = computed(() => 
            props.process && hasRoleV1.value == true
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory 
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_SendForModificationsRevision)
            || (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_SendForModificationsRevision)));

        const showSendForModificationsAffirmationBtn = computed(() =>
            props.process
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_ReportApproval)
            || (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_ReportApproval)));

        const showSendToRegistrarBtn = computed(() =>
            props.process && hasRoleB.value == true
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_Affirmation)
            || (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_Affirmation)));

        const showCompleteBtn = computed(() =>
            props.process && hasRoleA.value == true
            && ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_RegisterInventories)
            || (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory
                && props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_RegisterInventories)));

        // Отмяна на промените
        const btnUndoChangesClickHandler = async () => {
            try {
                await processRawInventoriesProcessService.undoProcessChanges(props.process!.id!);
                context.emit('undochanges');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        // Създаване на описи
        const btnCreateInventoriesStepClickHandler = async () => {
            try {

                const result = await processRawInventoriesProcessService.createNormalInventories(props.process?.id || 0);
                if (result.status == 200) {
                    context.emit('createdInventories');
                } else {
                    message.value = new Message({
                        text: result.response.data.message,
                        display: true,
                    });
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        // Създаване на доклад
        const btnCreateReportStepClickHandler = async () => {
            try {
                const step = props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStep.ProcessRawFundWithRawInventory_CreateReport
                    : ProcessStep.ProcessFundWithRawInventory_CreateReport;

                await processRawInventoriesProcessService.createReport(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: step
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

        // Връщане за корекции преди заседание
        const btnChangesRequiredStepClickHandler = async (comment?: string) => {
            try {
                const step = props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStep.ProcessRawFundWithRawInventory_ChangesRequired
                    : ProcessStep.ProcessFundWithRawInventory_ChangesRequired;

                await processRawInventoriesProcessService.sendReportApprovalResult(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: step,
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

        // Извършване на корекции преди заседание
        const btnStartApplyingStepClickHandler =async () => {
            try {
                const step = props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStep.ProcessRawFundWithRawInventory_DataModifications
                    : ProcessStep.ProcessFundWithRawInventory_DataModifications;


                await processRawInventoriesProcessService.startApplyingChanges(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: step,
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

        // Определяне на дата за заседание
        const btnAddReportStepClickHandler = async () => {
            try {
                const step = props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStep.ProcessRawFundWithRawInventory_AddReportToSessionAgenda
                    : ProcessStep.ProcessFundWithRawInventory_AddReportToSessionAgenda;

                await processRawInventoriesProcessService.addReportToSessionAgenda(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: step
                }));

                context.emit('addReport');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        // Изпращане за становище
        const btnSendToAddStandpointStepClickHandler = async (assignment: AssignModel) => {
            try {
                const step = props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStep.ProcessRawFundWithRawInventory_SendToAddSessionAgendaStandpoint
                    : ProcessStep.ProcessFundWithRawInventory_SendToAddSessionAgendaStandpoint;

				await processRawInventoriesProcessService.sendToAddSessionAgendaItemStandpoint(new ProcessStepModel({
					processId: props.process?.id,
                    stepTypeId: step,
                    assignedToUserId: assignment.assignToUserId,
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

        // Изпращане на становище
        const btnSendStandpointStepClickHandler = async () => {
            await processRawInventoriesProcessService.sendSessionAgendaItemStandpoint(
                new ProcessStepModel({
                    id: props.process?.activeProcessStepId,
                    processId: props.process?.id,
                    stepTypeId: props.process?.activeProcessStepTypeId,
                }));
            context.emit('sendStandpoint');
        };

        // Изпращане за коментар
        const btnSendToAddCommentStepClickHandler = async () => {
            try {
                const step = props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStep.ProcessRawFundWithRawInventory_SendToAddSessionAgendaStandpointComment
                    : ProcessStep.ProcessFundWithRawInventory_SendToAddSessionAgendaStandpointComment;

                await processRawInventoriesProcessService.sendToAddSessionAgendaItemStandpointComment(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: step,
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

        // Коментар по становище
        const btnAddCommentStepClickHandler = async () => {
              try {
                const step = props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpointComment
                    : ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpointComment;

                await processRawInventoriesProcessService.addSessionAgendaItemStandpointComment(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: step,
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

        // Изпращане на коментари
        const btnSendCommentStepClickHandler = async () => {
              try {
                const step = props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStep.ProcessRawFundWithRawInventory_SendSessionAgendaStandpointComment
                    : ProcessStep.ProcessFundWithRawInventory_SendSessionAgendaStandpointComment;

                await processRawInventoriesProcessService.sendSessionAgendaItemStandpointComment(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: step,
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

        // За заседание на комисия
        const btnSetSessionAgendaItemStepClickHandler = async () => {
              try {
                const step = props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStep.ProcessRawFundWithRawInventory_CommissionSession
                    : ProcessStep.ProcessFundWithRawInventory_CommissionSession;

                await processRawInventoriesProcessService.setSessionAgendaItem(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: step,
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

        // Изпълнение на препоръки от комисия
        const btnApplyModificationsStepClickHandler = async () => {
            try {
                const step = props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStep.ProcessRawFundWithRawInventory_ReportModifications
                    : ProcessStep.ProcessFundWithRawInventory_ReportModifications;

                await processRawInventoriesProcessService.applyReportModifications(
                    new ProcessStepModel({
                        processId: props.process?.id,
                        stepTypeId: step,
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

        // За проверка на корекции
        const btnSendForModificationsRevisionStepClickHandler = async (assignment: AssignModel) => {
            try {
                const step = props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStep.ProcessRawFundWithRawInventory_SendForModificationsRevision
                    : ProcessStep.ProcessFundWithRawInventory_SendForModificationsRevision;

                await processRawInventoriesProcessService.sendForModificationsRevision(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: step,
                    assignedToUserId: assignment.assignToUserId,
                    assignedToRoleId: assignment.assignToRoleId
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

        // Проверка на корекции
        const btnModificationsRevisionStepClickHandler = async (assignment: AssignModel) => {
            try {
                const step = props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStep.ProcessRawFundWithRawInventory_ModificationsRevision
                    : ProcessStep.ProcessFundWithRawInventory_ModificationsRevision;

                await processRawInventoriesProcessService.modificationsRevision(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: step,
                    assignedToUserId: assignment.assignToUserId,
                    assignedToRoleId: assignment.assignToRoleId
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

        // За утвърждаване
        const btnSendForModificationsAffirmationStepClickHandler = async (assignment: AssignModel) => {
            try {
                const step = props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStep.ProcessRawFundWithRawInventory_SendForAffirmation
                    : ProcessStep.ProcessFundWithRawInventory_SendForAffirmation;

                await processRawInventoriesProcessService.sendForModificationsAffirmation(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: step,
                    assignedToUserId: assignment.assignToUserId,
                    assignedToRoleId: assignment.assignToRoleId
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

        // Насочване към регистратор
        const btnSendToRegistrarStepClickHandler = async (assignment: AssignModel) => {
            try {
                const step = props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStep.ProcessRawFundWithRawInventory_SendToRegistrar
                    : ProcessStep.ProcessFundWithRawInventory_SendToRegistrar;

                await processRawInventoriesProcessService.sendToRegistrar(new ProcessStepModel({
                    processId: props.process?.id,
                    stepTypeId: step,
                    assignedToUserId: assignment.assignToUserId,
                    assignedToRoleId: assignment.assignToRoleId
                }));

                context.emit('sendToRegistrar', assignment);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };


        // Приключване на процес
        const btnCompleteProcessClickHandler = async () => {
            try {
                await processRawInventoriesProcessService.completeProcess(props.process!.id!);

                context.emit('complete');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };


        const addStandpointRoles = [RoleNames.GroupV4];
        const sendForModificationsRevisionRoles = [RoleNames.GroupV1];
        const sendForModificationsAffirmationRoles = [RoleNames.GroupG];
        const sendToRegistrarRoles = [RoleNames.GroupA];

        return {
            t,
            addStandpointRoles,
            sendForModificationsRevisionRoles,
            sendForModificationsAffirmationRoles,
            sendToRegistrarRoles,
            showUndoChangesBtn,
            showCreateInventoriesBtn,
            showCreateReportBtn,
            showSendReportBtn,
            showChangesRequiredBtn,
            showStartApplyingModificationsBtn,
            showAddReportBtn,
            showSendStandpointBtn,
            showSendToAddStandpointBtn,
            showSendToAddCommentBtn,
            showSendCommentBtn,
            showAddCommentBtn,
            showSetSessionAgendaItemBtn,
            showApplyModificationsBtn,
            showSendForModificationsRevisionBtn,
            showModificationsRevisionBtn,
            showSendForModificationsAffirmationBtn,
            showSendToRegistrarBtn,
            showCompleteBtn,
            btnUndoChangesClickHandler,
            btnCreateInventoriesStepClickHandler,
            btnCreateReportStepClickHandler,
            btnChangesRequiredStepClickHandler,
            btnStartApplyingStepClickHandler,
            btnAddReportStepClickHandler,
            btnSendToAddStandpointStepClickHandler,
            btnSendStandpointStepClickHandler,
            btnSendToAddCommentStepClickHandler,
            btnAddCommentStepClickHandler,
            btnSendCommentStepClickHandler,
            btnSetSessionAgendaItemStepClickHandler,
            btnApplyModificationsStepClickHandler,
            btnSendForModificationsRevisionStepClickHandler,
            btnModificationsRevisionStepClickHandler,
            btnSendForModificationsAffirmationStepClickHandler,
            btnSendToRegistrarStepClickHandler,
            btnCompleteProcessClickHandler,
        }
    },
})
</script>
