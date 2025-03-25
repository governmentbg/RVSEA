<template>
    <v-expansion-panels v-model="panel" multiple>
        <v-expansion-panel
            v-if="
                process.activeProcessStepTypeId !== ProcessStep.RefineData_ProcessInitiation &&
                process.activeProcessStepTypeId !== ProcessStep.RefineData_EditData &&
                process.activeProcessStepTypeId !== ProcessStep.RefineData_UndoChanges &&
                process.activeProcessStepTypeId !== ProcessStep.RefineData_ProcessFinalization
            "
            :value="ProcessStep.RefineData_CreateReport"
        >
            <v-expansion-panel-title>
                {{
                    process.activeProcessStepTypeId !== ProcessStep.RefineData_CreateReport
                        ? t('processes.panels.report')
                        : t('processes.steps.createReport')
                }}
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
            v-if="process.activeProcessStepTypeId === ProcessStep.RefineData_AddReportToSessionAgenda" 
            :value="ProcessStep.RefineData_AddReportToSessionAgenda"
        >
            <v-expansion-panel-title>{{ t('processes.steps.addReportToSessionAgenda') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <session-agenda-item 
                    :process="process"
                    :readOnly="process.activeProcessStepTypeId !== ProcessStep.RefineData_AddReportToSessionAgenda"
                />
            </v-expansion-panel-text>
        </v-expansion-panel> -->
        <v-expansion-panel
            v-if="
                process.activeProcessStepTypeId === ProcessStep.RefineData_AddSessionAgendaStandpoint ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_SendToAddSessionAgendaStandpointComment ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_AddSessionAgendaStandpointComment
            "
            :value="ProcessStep.RefineData_AddSessionAgendaStandpoint"
        >
            <v-expansion-panel-title>{{ t('processes.steps.addSessionAgendaStandpoint') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <session-agenda-standpoint
                    v-if="process && process.id"
                    :process="process"
                    :readOnly="
                        process.activeProcessStepTypeId !== ProcessStep.RefineData_AddSessionAgendaStandpoint &&
                        process.activeProcessStepTypeId !==
                            ProcessStep.RefineData_SendToAddSessionAgendaStandpointComment &&
                        process.activeProcessStepTypeId !== ProcessStep.RefineData_AddSessionAgendaStandpointComment
                    "
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
            v-if="
                process.activeProcessStepTypeId === ProcessStep.RefineData_SendToAddSessionAgendaStandpointComment ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_SendToAddSessionAgendaStandpointComment ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_AddSessionAgendaStandpointComment ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_SendSessionAgendaStandpointComment ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_CommissionSession ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_SessionMinutesOfMeetingForApproval ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_SessionMinutesOfMeeting ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_ReportApproval ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_ReportChangesRequired ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_ReportRejection ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_ReportModifications ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_SendForModificationsRevision ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_ModificationsRevision ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_SendForAffirmation ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_Affirmation
            "
            :value="ProcessStep.RefineData_AddSessionAgendaStandpointComment"
        >
            <v-expansion-panel-title>
                {{
                    process.activeProcessStepTypeId !== ProcessStep.RefineData_AddSessionAgendaStandpointComment
                        ? t('processes.panels.standpoints')
                        : t('processes.steps.addSessionAgendaStandpointComment')
                }}
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
            v-if="
                process.activeProcessStepTypeId === ProcessStep.RefineData_SendForAffirmation ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_Affirmation
            "
            :value="ProcessStep.AcquisitionContract"
        >
            <v-expansion-panel-title>
                {{ t('processes.steps.addPackageDocuments') }}
            </v-expansion-panel-title>
            <v-expansion-panel-text>
                <PackageAddModal
                    :packageId="packageAId"
                    :showAttachSignatureFile="true"
                    :processId="process.id"
                    :inventoryIdentifier="process?.inventorySystemIdentifier"
                ></PackageAddModal>
            </v-expansion-panel-text>
        </v-expansion-panel>
        <v-expansion-panel
            v-if="
                process.activeProcessStepTypeId === ProcessStep.RefineData_SessionMinutesOfMeeting ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_ReportApproval ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_ReportChangesRequired ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_ReportRejection ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_ReportModifications ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_SendForModificationsRevision ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_ModificationsRevision ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_SendForAffirmation ||
                process.activeProcessStepTypeId === ProcessStep.RefineData_Affirmation
            "
            :value="ProcessStep.RefineData_SessionMinutesOfMeeting"
        >
            <v-expansion-panel-title>{{ t('processes.panels.commissionDecision') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <CommissionDecision :processId="process.id">
                    <template #actions>
                        <RefineDataReportApprovalActions
                            v-if="
                                process.activeProcessStepTypeId === ProcessStep.RefineData_SessionMinutesOfMeeting ||
                                process.activeProcessStepTypeId === ProcessStep.RefineData_ModificationsRevision
                            "
                            :process="process"
                            @approval="btnReportApprovalStepClickHandler"
                        />
                        <RefineDataReportAffirmationActions
                            v-if="process.activeProcessStepTypeId === ProcessStep.RefineData_SendForAffirmation"
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
import { computed, defineComponent, inject, onMounted, PropType, Ref, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { Message } from '@/models/notification';

import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { IProcess } from '@/interfaces/process';
import { ProcessType, ProcessStep } from '@/enums/process';
import { ICommissionReport, ISessionAgendaItem } from '@/interfaces/commission';
import { CommissionReportModel, SessionAgendaItem as SessionAgendaItemModel } from '@/models/commission';
import authorization from '@/helpers/authorization.helper';
import sessionAgendaService from '@/services/sessionAgenda.service';
import commissionReportService from '@/services/commissionReport.service';

import CommissionReport from '@/components/commission/report.vue';
//import SessionAgendaItem from '@/components/commission/sessionAgendaItem.vue';
import SessionAgendaStandpoint from '@/components/commission/sessionAgendaStandpoint.vue';
import SessionAgendaStandpoints from '@/components/commission/sessionAgendaStandpoints.vue';
import CommissionDecision from '@/components/commission/decision.vue';
import RefineDataReportApprovalActions from '@/components/refineDataProcess/reportApprovalActions.vue';
import RefineDataReportAffirmationActions from '@/components/refineDataProcess/reportAffirmationActions.vue';
import PackageAddModal from '@/components/packageA/add.modal.vue';
import packagesService from '@/services/packages.service';
import { displayMessage } from '@/helpers/notification.helper';

export default defineComponent({
    name: 'RefineDataProcessSteps',
    components: {
        CommissionReport,
        //SessionAgendaItem,
        SessionAgendaStandpoint,
        SessionAgendaStandpoints,
        CommissionDecision,
        RefineDataReportApprovalActions,
        RefineDataReportAffirmationActions,
        PackageAddModal,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>,
        },
    },
    setup(props, context) {
        const { t } = useI18n();

        const message = inject('notificationMessage') as Ref<IMessage>;

        const activeProcessStep = computed(() => props.process?.activeProcessStepTypeId);
        const panel = ref();

        const commissionStandpoints = ref();
        const commissionStandpoint = ref();

        const reportIsReadOnly = computed(
            () =>
                !props.process ||
                !authorization.isCurrentUser(props.process.createdBy!) ||
                (props.process.activeProcessStepTypeId !== ProcessStep.RefineData_CreateReport &&
                    props.process.activeProcessStepTypeId !== ProcessStep.RefineData_DataModifications &&
                    props.process.activeProcessStepTypeId !== ProcessStep.RefineData_ReportModifications)
        );

        const sessionAgendaStandpointsIsReadOnly = computed(
            () =>
                !props.process ||
                props.process.activeProcessStepTypeId !== ProcessStep.RefineData_AddSessionAgendaStandpointComment ||
                !authorization.isCurrentUser(props.process.createdBy!)
        );

        const report = ref<ICommissionReport>(new CommissionReportModel());
        const getReportData = async () => {
            try {
                const reportData = await commissionReportService.getByProcessId(props.process!.id!);
                if (reportData) {
                    report.value = reportData;
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const sessionAgendaItem = ref<ISessionAgendaItem>(new SessionAgendaItemModel());
        const getSessionAgendaItemData = async () => {
            try {
                const sessionAgendaItemData = await sessionAgendaService.displaySessionAgendaItemByProcess(
                    props.process!.id!
                );
                if (sessionAgendaItemData) {
                    sessionAgendaItem.value = sessionAgendaItemData;
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const packageAId = ref<number>(-1);
        const getPackageAId = async () => {
            try {
                packageAId.value = await packagesService.getPackageAIdByProcess(props.process!.id!);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            }
        };

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

        const refresh = async () => {
            await commissionStandpoints.value.getStandpointData();
            await commissionStandpoint.value.getSessionAgendaItemStandpointData();
        };

        watch(
            () => activeProcessStep.value,
            (activeStep) => {
                console.log(activeStep);
                switch (activeStep) {
                    case ProcessStep.RefineData_SendReport:
                    case ProcessStep.RefineData_ChangesRequired:
                    case ProcessStep.RefineData_DataModifications:
                    case ProcessStep.RefineData_SendToAddSessionAgendaStandpoint:
                        panel.value = ProcessStep.RefineData_CreateReport;
                        break;
                    case ProcessStep.RefineData_AddSessionAgendaStandpoint:
                        panel.value = [
                            ProcessStep.RefineData_CreateReport,
                            ProcessStep.RefineData_AddSessionAgendaStandpoint,
                        ];
                        break;
                    case ProcessStep.RefineData_SendToAddSessionAgendaStandpointComment:
                    case ProcessStep.RefineData_SendSessionAgendaStandpointComment:
                        panel.value = ProcessStep.RefineData_AddSessionAgendaStandpointComment;
                        break;
                    case ProcessStep.RefineData_ReportChangesRequired:
                    case ProcessStep.RefineData_ReportModifications:
                    case ProcessStep.RefineData_SendForModificationsRevision:
                    case ProcessStep.RefineData_ModificationsRevision:
                        panel.value = ProcessStep.RefineData_SessionMinutesOfMeeting;
                        break;
                    case ProcessStep.RefineData_SendForAffirmation:
                    case ProcessStep.RefineData_Affirmation:
                        panel.value = [ProcessStep.AcquisitionContract, ProcessStep.RefineData_SessionMinutesOfMeeting];
                        break;
                    default:
                        panel.value = activeStep;
                        break;
                }
            }
        );

        onMounted(async () => {
            switch (activeProcessStep.value) {
                case ProcessStep.RefineData_SendReport:
                case ProcessStep.RefineData_ChangesRequired:
                case ProcessStep.RefineData_DataModifications:
                case ProcessStep.RefineData_SendToAddSessionAgendaStandpoint:
                    panel.value = ProcessStep.RefineData_CreateReport;
                    break;
                case ProcessStep.RefineData_AddSessionAgendaStandpoint:
                    panel.value = [
                        ProcessStep.RefineData_CreateReport,
                        ProcessStep.RefineData_AddSessionAgendaStandpoint,
                    ];
                    break;
                case ProcessStep.RefineData_SendToAddSessionAgendaStandpointComment:
                case ProcessStep.RefineData_SendSessionAgendaStandpointComment:
                    panel.value = ProcessStep.RefineData_AddSessionAgendaStandpointComment;
                    break;
                case ProcessStep.RefineData_ReportChangesRequired:
                case ProcessStep.RefineData_ReportModifications:
                case ProcessStep.RefineData_SendForModificationsRevision:
                case ProcessStep.RefineData_ModificationsRevision:
                    panel.value = ProcessStep.RefineData_SessionMinutesOfMeeting;
                    break;
                case ProcessStep.RefineData_SendForAffirmation:
                case ProcessStep.RefineData_Affirmation:
                    panel.value = [ProcessStep.AcquisitionContract, ProcessStep.RefineData_SessionMinutesOfMeeting];
                    break;
                default:
                    panel.value = activeProcessStep.value;
                    break;
            }

            if (activeProcessStep.value === ProcessStep.RefineData_AddSessionAgendaStandpoint) {
                await getReportData();
            }

            if (
                activeProcessStep.value === ProcessStep.RefineData_AddSessionAgendaStandpoint ||
                activeProcessStep.value === ProcessStep.RefineData_SendToAddSessionAgendaStandpointComment ||
                activeProcessStep.value === ProcessStep.RefineData_AddSessionAgendaStandpointComment ||
                activeProcessStep.value === ProcessStep.RefineData_SendSessionAgendaStandpointComment ||
                activeProcessStep.value === ProcessStep.RefineData_CommissionSession ||
                activeProcessStep.value === ProcessStep.RefineData_SessionMinutesOfMeetingForApproval ||
                activeProcessStep.value === ProcessStep.RefineData_SessionMinutesOfMeeting ||
                activeProcessStep.value === ProcessStep.RefineData_ReportApproval ||
                activeProcessStep.value === ProcessStep.RefineData_ReportChangesRequired ||
                activeProcessStep.value === ProcessStep.RefineData_ReportRejection ||
                activeProcessStep.value === ProcessStep.RefineData_ReportModifications ||
                activeProcessStep.value === ProcessStep.RefineData_SendForModificationsRevision ||
                activeProcessStep.value === ProcessStep.RefineData_ModificationsRevision ||
                activeProcessStep.value === ProcessStep.RefineData_SendForAffirmation ||
                activeProcessStep.value === ProcessStep.RefineData_Affirmation
            ) {
                await getSessionAgendaItemData();
            }

            if (activeProcessStep.value === ProcessStep.RefineData_SendForAffirmation) {
                await getPackageAId();
            }
        });

        return {
            t,
            message,
            panel,
            commissionStandpoint,
            commissionStandpoints,
            packageAId,
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
});
</script>
