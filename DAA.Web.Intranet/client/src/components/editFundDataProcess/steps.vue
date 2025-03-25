<template>
    <v-expansion-panels v-model="panel">
        <v-expansion-panel
            v-if="process.activeProcessStepTypeId !== ProcessStep.EditFundData_ProcessInitiation
                    && process.activeProcessStepTypeId !== ProcessStep.EditFundData_EditData
                    && process.activeProcessStepTypeId !== ProcessStep.EditFundData_UndoChanges
                    && process.activeProcessStepTypeId !== ProcessStep.EditFundData_ProcessFinalization" 
            :value="ProcessStep.EditFundData_CreateReport"
        >
            <v-expansion-panel-title>
                {{ process.activeProcessStepTypeId !== ProcessStep.EditFundData_CreateReport 
                    ? t('processes.panels.report')
                    : t('processes.steps.createReport') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <CommissionReport 
                    :processData="process" 
                    :sendEnabled="false"
                    :printEnabled="false"
                    :readonly="reportIsReadOnly" 
                />
            </v-expansion-panel-text>
        </v-expansion-panel>
        <!-- <v-expansion-panel
            v-if="process.activeProcessStepTypeId === ProcessStep.EditFundData_AddReportToSessionAgenda" 
            :value="ProcessStep.EditFundData_AddReportToSessionAgenda"
        >
            <v-expansion-panel-title>{{ t('processes.steps.addReportToSessionAgenda') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <session-agenda-item 
                    :process="process"
                    :readOnly="process.activeProcessStepTypeId !== ProcessStep.EditFundData_AddReportToSessionAgenda"
                />
            </v-expansion-panel-text>
        </v-expansion-panel> -->
        <v-expansion-panel
            v-if="process.activeProcessStepTypeId === ProcessStep.EditFundData_AddSessionAgendaStandpoint
            || process.activeProcessStepTypeId === ProcessStep.EditFundData_AddSessionAgendaStandpointComment
            || process.activeProcessStepTypeId === ProcessStep.EditFundData_SendToAddSessionAgendaStandpointComment"
            :value="ProcessStep.EditFundData_AddSessionAgendaStandpoint"
        >
            <v-expansion-panel-title>{{ t('processes.steps.addSessionAgendaStandpoint') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <session-agenda-standpoint
                    v-if="process && process.id"
                    :process="process"
                    :readOnly="process.activeProcessStepTypeId !== ProcessStep.EditFundData_AddSessionAgendaStandpoint
                    && process.activeProcessStepTypeId !== ProcessStep.EditFundData_AddSessionAgendaStandpointComment
                    && process.activeProcessStepTypeId !== ProcessStep.EditFundData_SendToAddSessionAgendaStandpointComment"
                    @commit="btnCommitStandpointClickHandler"
                    ref="commissionStandpoint"
                />

                <session-agenda-standpoints
                    ref="commissionStandpoints"
                    v-if="process && process.id"
                    :process="process"
                    :readOnly="true"
                    @editStandpoint="refresh"
                />
            </v-expansion-panel-text>
        </v-expansion-panel>
        <v-expansion-panel
            v-if="process.activeProcessStepTypeId === ProcessStep.EditFundData_AddSessionAgendaStandpointComment
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_SendToAddSessionAgendaStandpointComment
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_SendSessionAgendaStandpointComment
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_CommissionSession
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_SessionMinutesOfMeetingForApproval
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_SessionMinutesOfMeeting
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_ReportApproval
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_ReportChangesRequired
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_ReportRejection
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_ReportModifications
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_SendForModificationsRevision
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_ModificationsRevision
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_SendForAffirmation
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_Affirmation"
            :value="ProcessStep.EditFundData_AddSessionAgendaStandpointComment"
        >
            <v-expansion-panel-title>
                {{ process.activeProcessStepTypeId !== ProcessStep.EditFundData_AddSessionAgendaStandpointComment 
                    ? t('processes.panels.standpoints')
                    : t('processes.steps.addSessionAgendaStandpointComment') }}
            </v-expansion-panel-title>
            <v-expansion-panel-text>
                <session-agenda-standpoints
                    ref="commissionStandpoints"
                    @editStandpoint="refresh"
                    v-if="process && process.id"
                    :process="process"
                    :readOnly="sessionAgendaStandpointsIsReadOnly"
                />
            </v-expansion-panel-text>
        </v-expansion-panel>
        <v-expansion-panel
            v-if="process.activeProcessStepTypeId === ProcessStep.EditFundData_SessionMinutesOfMeeting
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_ReportApproval
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_ReportChangesRequired
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_ReportRejection
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_ReportModifications
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_SendForModificationsRevision
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_ModificationsRevision
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_SendForAffirmation
                    || process.activeProcessStepTypeId === ProcessStep.EditFundData_Affirmation"
            :value="ProcessStep.EditFundData_SessionMinutesOfMeeting"
        >
            <v-expansion-panel-title>{{ t('processes.panels.commissionDecision') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <CommissionDecision :processId="process.id">
                    <template #actions>
                        <EditFundDataReportApprovalActions
                            v-if="showApprovalActions"
                            :process="process"
                            @approval="btnReportApprovalStepClickHandler"
                        />
                        <EditFundDataReportAffirmationActions
                            v-if="process.activeProcessStepTypeId === ProcessStep.EditFundData_SendForAffirmation"
                            :process="process"
                            @affirmation="btnReportAffirmationStepClickHandler"
                        />
                    </template>
                </CommissionDecision>
            </v-expansion-panel-text>
        </v-expansion-panel>
    </v-expansion-panels>
</template>
<script lang="ts">
import { computed, defineComponent, inject, onMounted, PropType, Ref, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { Message } from "@/models/notification";

import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { IProcess } from '@/interfaces/process';
import { ProcessType, ProcessStep } from '@/enums/process';
import { ICommissionReport, ISessionAgendaItem } from '@/interfaces/commission';
import { CommissionReportModel, SessionAgendaItem as SessionAgendaItemModel } from '@/models/commission';
import authorization from '@/helpers/authorization.helper';
import commissionReportService from '@/services/commissionReport.service';
import sessionAgendaService from '@/services/sessionAgenda.service';

import CommissionReport from '@/components/commission/report.vue';
//import SessionAgendaItem from '@/components/commission/sessionAgendaItem.vue';
import SessionAgendaStandpoint from '@/components/commission/sessionAgendaStandpoint.vue';
import SessionAgendaStandpoints from '@/components/commission/sessionAgendaStandpoints.vue';
import CommissionDecision from '@/components/commission/decision.vue';
import EditFundDataReportApprovalActions from '@/components/editFundDataProcess/reportApprovalActions.vue';
import EditFundDataReportAffirmationActions from '@/components/editFundDataProcess/reportAffirmationActions.vue';
import { RoleNames } from '@/enums/roles';

export default defineComponent({
    name: 'EditFundDataProcessSteps',
    components: {
        CommissionReport,
        //SessionAgendaItem,
        SessionAgendaStandpoint,
        SessionAgendaStandpoints,
        CommissionDecision,
        EditFundDataReportApprovalActions,
        EditFundDataReportAffirmationActions,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>
        },
    },
    setup(props, context) {
        const { t } = useI18n();

        const message = inject("notificationMessage") as Ref<IMessage>;

        const activeProcessStep = computed(() => props.process?.activeProcessStepTypeId);
        const panel = ref();

        const commissionStandpoints = ref();
        const commissionStandpoint = ref();

        const showApprovalActions = computed(() => 
            props.process
            && authorization.hasRole(RoleNames.GroupV1)
            && (props.process.activeProcessStepTypeId === ProcessStep.EditFundData_SessionMinutesOfMeeting 
                || props.process.activeProcessStepTypeId === ProcessStep.EditFundData_ModificationsRevision)
        );

        const reportIsReadOnly = computed(
            () =>
                !props.process
                || !authorization.isCurrentUser(props.process.createdBy!)
                || (props.process.activeProcessStepTypeId !== ProcessStep.EditFundData_CreateReport 
                    && props.process.activeProcessStepTypeId !== ProcessStep.EditFundData_DataModifications
                    && props.process.activeProcessStepTypeId !== ProcessStep.EditFundData_ReportModifications)
        );

        const sessionAgendaStandpointsIsReadOnly = computed(
            () => 
                !props.process
                || props.process.activeProcessStepTypeId !== ProcessStep.EditFundData_AddSessionAgendaStandpointComment 
                || !authorization.isCurrentUser(props.process.createdBy!)
        );

        const refresh = async() => {
            await commissionStandpoints.value.getStandpointData();
            await commissionStandpoint.value.getSessionAgendaItemStandpointData();
            await commissionStandpoint.value.validateSessionDateForEdit();
        };

        const report = ref<ICommissionReport>(new CommissionReportModel());
        const getReportData = async () => {
            try {
                const reportData = await commissionReportService.getByProcessId(props.process!.id!);
                if (reportData) {
                    report.value = reportData;
                }
            } catch (error: unknown) {
                const errorResult  = error as ResponseResult;
                    message.value = new Message({
                    text:  errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const sessionAgendaItem = ref<ISessionAgendaItem>(new SessionAgendaItemModel());
        const getSessionAgendaItemData = async () => {
            try {
                const sessionAgendaItemData = await sessionAgendaService.displaySessionAgendaItemByProcess(props.process!.id!);
                if (sessionAgendaItemData) {
                    sessionAgendaItem.value = sessionAgendaItemData;
                }
            } catch (error: unknown) {
                const errorResult  = error as ResponseResult;
                    message.value = new Message({
                    text:  errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        }

        const btnCommitStandpointClickHandler = async () => {
            if (commissionStandpoints.value) {
                await commissionStandpoints.value.getStandpointData();
            }
        };

        const btnReportApprovalStepClickHandler = () => {
            context.emit('approval');
        };

        const btnReportAffirmationStepClickHandler = () => {
            context.emit('affirmation');
        };

        onMounted(async () => {
            panel.value = activeProcessStep.value;
            
            if (activeProcessStep.value === ProcessStep.EditFundData_AddSessionAgendaStandpoint) {
                await getReportData();
            }

            if (activeProcessStep.value === ProcessStep.EditFundData_AddSessionAgendaStandpoint
                || activeProcessStep.value === ProcessStep.EditFundData_SendToAddSessionAgendaStandpointComment
                || activeProcessStep.value === ProcessStep.EditFundData_AddSessionAgendaStandpointComment
                || activeProcessStep.value === ProcessStep.EditFundData_SendSessionAgendaStandpointComment
                || activeProcessStep.value === ProcessStep.EditFundData_CommissionSession
                || activeProcessStep.value === ProcessStep.EditFundData_SessionMinutesOfMeetingForApproval
                || activeProcessStep.value === ProcessStep.EditFundData_SessionMinutesOfMeeting
                || activeProcessStep.value === ProcessStep.EditFundData_ReportApproval
                || activeProcessStep.value === ProcessStep.EditFundData_ReportChangesRequired
                || activeProcessStep.value === ProcessStep.EditFundData_ReportRejection
                || activeProcessStep.value === ProcessStep.EditFundData_ReportModifications
                || activeProcessStep.value === ProcessStep.EditFundData_SendForModificationsRevision
                || activeProcessStep.value === ProcessStep.EditFundData_ModificationsRevision
                || activeProcessStep.value === ProcessStep.EditFundData_SendForAffirmation
                || activeProcessStep.value === ProcessStep.EditFundData_Affirmation) {
                await getSessionAgendaItemData();
            }
        });

        return {
            t,
            message,
            panel,
            commissionStandpoints,
            commissionStandpoint,
            ProcessType,
            ProcessStep,
            reportIsReadOnly,
            sessionAgendaStandpointsIsReadOnly,
            sessionAgendaItem,
            activeProcessStep,
            showApprovalActions,
            btnCommitStandpointClickHandler,
            btnReportApprovalStepClickHandler,
            btnReportAffirmationStepClickHandler,
            refresh,
        };
    },
})
</script>
