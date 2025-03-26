<template>
    <v-expansion-panels v-model="panel">
        <v-expansion-panel
            v-if="
                process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_ProcessInitiation
                && process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_UndoChanges
                && process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_RequestPublicAccessSuspension
                && process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_SuspendPublicAccess" 
            :value="ProcessStep.ReconstructFundData_EditData"
        >
            <v-expansion-panel-title>{{ t('processes.steps.reconstructionTable') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <FundReconstructionsTable 
                    :process="process" 
                    :readOnly="process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_EditData 
                                && process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_DataModifications
                                && process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_ReportModifications" 
                />
            </v-expansion-panel-text>
        </v-expansion-panel>
        <v-expansion-panel
            v-if="process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_ProcessInitiation
                    && process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_EditData
                    && process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_UndoChanges
                    && process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_ProcessFinalization
                    && process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_RequestPublicAccessSuspension
                    && process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_SuspendPublicAccess"  
            :value="ProcessStep.ReconstructFundData_CreateReport"
        >
            <v-expansion-panel-title>
                {{ process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_CreateReport 
                    ? t('processes.panels.report')
                    : t('processes.steps.createReport') }}
            </v-expansion-panel-title>
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
            v-if="process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_AddReportToSessionAgenda" 
            :value="ProcessStep.RefineData_AddReportToSessionAgenda"
        >
            <v-expansion-panel-title>{{ t('processes.steps.addReportToSessionAgenda') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <session-agenda-item 
                    :process="process"
                    :readOnly="process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_AddReportToSessionAgenda"
                />
            </v-expansion-panel-text>
        </v-expansion-panel> -->
        <v-expansion-panel
            v-if="process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_AddSessionAgendaStandpoint
            || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendToAddSessionAgendaStandpointComment
            || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_AddSessionAgendaStandpointComment"
            :value="ProcessStep.RefineData_AddSessionAgendaStandpoint"
        >
            <v-expansion-panel-title>{{ t('processes.steps.addSessionAgendaStandpoint') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <session-agenda-standpoint
                    v-if="process && process.id"
                    :process="process"
                    :readOnly="process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_AddSessionAgendaStandpoint
                    && process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_SendToAddSessionAgendaStandpointComment
                    && process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_AddSessionAgendaStandpointComment"
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
            v-if="process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendToAddSessionAgendaStandpointComment
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendToAddSessionAgendaStandpointComment
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_AddSessionAgendaStandpointComment
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendSessionAgendaStandpointComment
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_CommissionSession
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SessionMinutesOfMeetingForApproval
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SessionMinutesOfMeeting
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ReportApproval
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ReportChangesRequired
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ReportRejection
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ReportModifications
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendForModificationsRevision
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ModificationsRevision
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendForAffirmation
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_Affirmation
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendForRegistration
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_Registration"
            :value="ProcessStep.ReconstructFundData_AddSessionAgendaStandpointComment"
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
            v-if="process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SessionMinutesOfMeeting
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ReportApproval
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ReportChangesRequired
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ReportRejection
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ReportModifications
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendForModificationsRevision
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ModificationsRevision
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendForAffirmation
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_Affirmation
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendForRegistration
                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_Registration"
            :value="ProcessStep.ReconstructFundData_SessionMinutesOfMeeting"
        >
            <v-expansion-panel-title>
                {{ t('processes.panels.commissionDecision') }}
            </v-expansion-panel-title>
            <v-expansion-panel-text>
                <CommissionDecision :processId="process.id">
                    <template #actions>
                        <ReconstructFundDataReportApprovalActions
                            v-if="process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SessionMinutesOfMeeting
                                    || process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_ModificationsRevision"
                            :process="process"
                            @approval="btnReportApprovalStepClickHandler"
                        />
                        <ReconstructFundDataReportAffirmationActions
                            v-if="process.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendForAffirmation"
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
import sessionAgendaService from '@/services/sessionAgenda.service';

import FundReconstructionsTable from '@/components/reconstructFundDataProcess/fundReconstructionsTable.vue';
import CommissionReport from '@/components/commission/report.vue';
//import SessionAgendaItem from '@/components/commission/sessionAgendaItem.vue';
import SessionAgendaStandpoint from '@/components/commission/sessionAgendaStandpoint.vue';
import SessionAgendaStandpoints from '@/components/commission/sessionAgendaStandpoints.vue';
import CommissionDecision from '@/components/commission/decision.vue';
import ReconstructFundDataReportApprovalActions from '@/components/reconstructFundDataProcess/reportApprovalActions.vue';
import ReconstructFundDataReportAffirmationActions from '@/components/reconstructFundDataProcess/reportAffirmationActions.vue';
import commissionReportService from '@/services/commissionReport.service';

export default defineComponent({
    name: 'ReconstructFundDataProcessSteps',
    components: {
        FundReconstructionsTable,
        CommissionReport,
        //SessionAgendaItem,
        SessionAgendaStandpoint,
        SessionAgendaStandpoints,
        CommissionDecision,
        ReconstructFundDataReportApprovalActions,
        ReconstructFundDataReportAffirmationActions,
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

        const reportIsReadOnly = computed(
            () =>
                !props.process
                || !authorization.isCurrentUser(props.process.createdBy!)
                || (props.process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_CreateReport 
                    && props.process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_DataModifications
                    && props.process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_ReportModifications)
        );

        const sessionAgendaStandpointsIsReadOnly = computed(
            () => 
                !props.process
                || props.process.activeProcessStepTypeId !== ProcessStep.ReconstructFundData_AddSessionAgendaStandpointComment
                || !authorization.isCurrentUser(props.process.createdBy!)
        );

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
        }

        const refresh = async() => {
            await commissionStandpoints.value.getStandpointData();
            await commissionStandpoint.value.getSessionAgendaItemStandpointData();
        };

        onMounted(async () => {
            panel.value = activeProcessStep.value;

            if (activeProcessStep.value === ProcessStep.ReconstructFundData_AddSessionAgendaStandpoint) {
                await getReportData();
            }

            if (activeProcessStep.value === ProcessStep.ReconstructFundData_AddSessionAgendaStandpoint
                || activeProcessStep.value === ProcessStep.ReconstructFundData_SendToAddSessionAgendaStandpointComment
                || activeProcessStep.value === ProcessStep.ReconstructFundData_AddSessionAgendaStandpointComment
                || activeProcessStep.value === ProcessStep.ReconstructFundData_SendSessionAgendaStandpointComment
                || activeProcessStep.value === ProcessStep.ReconstructFundData_CommissionSession
                || activeProcessStep.value === ProcessStep.ReconstructFundData_SessionMinutesOfMeetingForApproval
                || activeProcessStep.value === ProcessStep.ReconstructFundData_SessionMinutesOfMeeting
                || activeProcessStep.value === ProcessStep.ReconstructFundData_ReportApproval
                || activeProcessStep.value === ProcessStep.ReconstructFundData_ReportChangesRequired
                || activeProcessStep.value === ProcessStep.ReconstructFundData_ReportRejection
                || activeProcessStep.value === ProcessStep.ReconstructFundData_ReportModifications
                || activeProcessStep.value === ProcessStep.ReconstructFundData_SendForModificationsRevision
                || activeProcessStep.value === ProcessStep.ReconstructFundData_ModificationsRevision
                || activeProcessStep.value === ProcessStep.ReconstructFundData_SendForAffirmation
                || activeProcessStep.value === ProcessStep.ReconstructFundData_Affirmation) {
                await getSessionAgendaItemData();
            }
        });

        return {
            t,
            message,
            panel,
            commissionStandpoint,
            commissionStandpoints,
            ProcessType,
            ProcessStep,
            reportIsReadOnly,
            sessionAgendaStandpointsIsReadOnly,
            sessionAgendaItem,
            activeProcessStep,
            btnReportApprovalStepClickHandler,
            btnReportAffirmationStepClickHandler,
            btnCommitStandpointClickHandler,
            refresh,
        };
    },
})
</script>
