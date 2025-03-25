<template>
    <v-expansion-panels v-model="panel">

        <!-- Доклад -->
        <v-expansion-panel value="report" v-if="showReportPanel">
            <v-expansion-panel-title>
                {{ t('funds.panels.report') }}
            </v-expansion-panel-title>
            <v-expansion-panel-text>
                <CommissionReport
                    :readonly="comissionReportIsReadonly"
                    :processData="process"
                    :sendEnabled="comissionReportSendEnabled"
                    :printEnabled="false"
                    :assignToUsers="false"
                    @send="sendReport"
                ></CommissionReport>
            </v-expansion-panel-text>
        </v-expansion-panel>
        
        <!-- Определяне на дата за заседание -->
        <v-expansion-panel
            v-if="showAddReportToSessionAgenda" 
            :value="addReportToSessionAgendaValue"
        >
            <v-expansion-panel-title>{{ t('processes.steps.addReportToSessionAgenda') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <session-agenda-item 
                    :process="process"
                    :readOnly="addReportToSessionAgendaReadonly"
                />
            </v-expansion-panel-text>
        </v-expansion-panel>


        <!-- Добавяне на становище по точка от дневен ред -->
        <v-expansion-panel
            v-if="showAddSessionAgendaStandpoint"
            :value="addSessionAgendaStandpointValue"
        >
            <v-expansion-panel-title>{{ t('processes.steps.addSessionAgendaStandpoint') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <session-agenda-standpoint
                    v-if="process && process.id"
                    :process="process"
                    ref="commissionStandpoint"
                    @commit="refresh"
                />

                <session-agenda-standpoints
                    v-if="process && process.id"
                    :process="process"
                    :readOnly="true"
                    ref="commissionStandpoints"
                    @editStandpoint="refresh"
                />
            </v-expansion-panel-text>
        </v-expansion-panel>


        <!-- Добавяне на коментар към становище -->
        <v-expansion-panel
            v-if="showAddSessionAgendaStandpointComment"
            :value="addSessionAgendaStandpointCommentValue"
        >
            <v-expansion-panel-title>{{ t('processes.steps.addSessionAgendaStandpointComment') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <session-agenda-standpoints
                    ref="commissionStandpoints"
                    @editStandpoint="refresh"
                    v-if="process && process.id"
                    :process="process"
                    :readOnly="addSessionAgendaStandpointCommentReadonly"
                />
            </v-expansion-panel-text>
        </v-expansion-panel>

        <!-- Становища -->
        <v-expansion-panel
            v-if="showStandpoints"
            :value="ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpointComment"
        >
            <v-expansion-panel-title>
                {{t('processes.panels.standpoints')}}
            </v-expansion-panel-title>
            <v-expansion-panel-text>
                <session-agenda-standpoints
                    v-if="process && process.id"
                    :process="process"
                    :readOnly="process.activeProcessStepTypeId !== ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpointComment &&
                                process.activeProcessStepTypeId !== ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpointComment"
                />
            </v-expansion-panel-text>
        </v-expansion-panel>


        <!-- Решение на комисия-->
        <v-expansion-panel value="commissionDecision" v-if="showDecisionPanel">
            <v-expansion-panel-title>
                {{ t('funds.panels.commissionDecision') }}
            </v-expansion-panel-title>
            <v-expansion-panel-text>
                <CommissionDecision :processId="process.id">
                    <template #actions>
                        <ProcessRawInventoriesReportApprovalActions
                            v-if="showProcessRawInventoriesReportApprovalActions"
                            :process="process"
                            @approval="approve"
                        />
                        <ProcessRawInventoriesReportAffirmationActions
                            v-if="showProcessRawInventoriesReportAffirmationActions"
                            :process="process"
                            @affirmation="affirm"
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
import { CommissionReportModel } from '@/models/commission';
import { IProcess } from '@/interfaces/process';
import { ProcessType, ProcessStep } from '@/enums/process';
import { ISessionAgendaItem } from '@/interfaces/commission';
import { SessionAgendaItem as SessionAgendaItemModel } from '@/models/commission';
import sessionAgendaService from '@/services/sessionAgenda.service';
import commissionReportSevice from '@/services/commissionReport.service';

import SessionAgendaItem from '@/components/commission/sessionAgendaItem.vue';
import SessionAgendaStandpoint from '@/components/commission/sessionAgendaStandpoint.vue';
import SessionAgendaStandpoints from '@/components/commission/sessionAgendaStandpoints.vue';
import CommissionReport from '@/components/commission/report.vue';
import CommissionDecision from '@/components/commission/decision.vue';
import ProcessRawInventoriesReportApprovalActions from '@/components/processRawInventoriesProcess/reportApprovalActions.vue';
import ProcessRawInventoriesReportAffirmationActions from '@/components/processRawInventoriesProcess/reportAffirmationActions.vue';

import { useStore } from '@/store/user';
import { RoleNames } from '@/enums/roles';

export default defineComponent({
    name: 'ProcessRawInventoriesProcessSteps',
    components: {
        SessionAgendaItem,
        SessionAgendaStandpoint,
        SessionAgendaStandpoints,
        CommissionReport,
        CommissionDecision,
        ProcessRawInventoriesReportApprovalActions,
        ProcessRawInventoriesReportAffirmationActions,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>
        },
    },
    setup(props, context) {
        const { t } = useI18n();

        const message = inject("notificationMessage") as Ref<IMessage>;

        const userStore = useStore();
        const hasRoleB = computed(() => userStore.getters.hasRole(RoleNames.GroupB));
        const hasRoleV1 = computed(() => userStore.getters.hasRole(RoleNames.GroupV1));
        const hasRoleG = computed(() => userStore.getters.hasRole(RoleNames.GroupG));

        const activeProcessStep = computed(() => props.process?.activeProcessStepTypeId);
        const panel = ref();

        const commissionStandpoints = ref();
        const commissionStandpoint = ref();

        const report = ref(new CommissionReportModel());

        const getReportData = async () => {
            try {
                const reportData = await commissionReportSevice.getByProcessId(props.process!.id!);
                if (reportData) {
                    report.value = reportData;
                } else {
                    report.value.title = props.process?.processTypeTitle;
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
                else {
                    console.log('no sessionAgendaItemData');
                }
            } catch (error: unknown) {
                const errorResult  = error as ResponseResult;
                    message.value = new Message({
                    text:  errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        }
        const refresh = async() => {
            await commissionStandpoints.value.getStandpointData();
            await commissionStandpoint.value.getSessionAgendaItemStandpointData();
        };

        const showReportPanel = computed(() => 
            props.process 
            && props.process.activeProcessStepTypeId != ProcessStep.ProcessRawFundWithRawInventory_ChooseRawInventories
            && props.process.activeProcessStepTypeId != ProcessStep.ProcessRawFundWithRawInventory_CreateInventories
            && props.process.activeProcessStepTypeId != ProcessStep.ProcessFundWithRawInventory_ChooseRawInventories
            && props.process.activeProcessStepTypeId != ProcessStep.ProcessFundWithRawInventory_CreateInventories);

        const showDecisionPanel = computed(() => 
            props.process 
            && (props.process.activeProcessStepTypeId == ProcessStep.ProcessRawFundWithRawInventory_ConfirmedProtocol
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessRawFundWithRawInventory_ModificationsRevision
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessRawFundWithRawInventory_SendForAffirmation
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessRawFundWithRawInventory_ReportChangesRequired
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessRawFundWithRawInventory_ReportModifications
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessRawFundWithRawInventory_SendForModificationsRevision
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessRawFundWithRawInventory_ReportApproval
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessRawFundWithRawInventory_Affirmation
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessRawFundWithRawInventory_RegisterInventories

            || props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_ConfirmedProtocol
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_ModificationsRevision
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_SendForAffirmation
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_ReportChangesRequired
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_ReportModifications
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_SendForModificationsRevision
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_ReportApproval
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_Affirmation
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_RegisterInventories));

        const showAddReportToSessionAgenda = computed(() => 
            props.process 
            && (props.process.activeProcessStepTypeId == ProcessStep.ProcessRawFundWithRawInventory_AddReportToSessionAgenda 
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_AddReportToSessionAgenda ));
        
        const showAddSessionAgendaStandpoint = computed(() => 
            props.process 
            && (props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpoint
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpoint
            || props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_SendToAddSessionAgendaStandpointComment
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_SendToAddSessionAgendaStandpointComment
            || props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpointComment
            || props.process.activeProcessStepTypeId == ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpointComment));

        const showAddSessionAgendaStandpointComment = computed(() => 
            props.process 
            && (props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpointComment
            || props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpointComment));



        const comissionReportIsReadonly = computed(
            () =>
                !props.process || hasRoleB.value == false ||
                (props.process.activeProcessStepTypeId !== ProcessStep.ProcessRawFundWithRawInventory_CreateReport &&
                props.process.activeProcessStepTypeId !== ProcessStep.ProcessRawFundWithRawInventory_DataModifications &&
                props.process.activeProcessStepTypeId !== ProcessStep.ProcessRawFundWithRawInventory_ReportModifications &&
				props.process.activeProcessStepTypeId !== ProcessStep.ProcessFundWithRawInventory_CreateReport &&
                props.process.activeProcessStepTypeId !== ProcessStep.ProcessFundWithRawInventory_DataModifications &&
                props.process.activeProcessStepTypeId !== ProcessStep.ProcessFundWithRawInventory_ReportModifications)
        );

        const comissionReportSendEnabled = computed(
            () =>
                !props.process || hasRoleB.value == false ||
                props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_CreateReport ||
                props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_DataModifications ||
                props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_CreateReport ||
                props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_DataModifications
        );

        const showProcessRawInventoriesReportApprovalActions = computed(
            () =>
                props.process && 
                ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory &&
                    (props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_ConfirmedProtocol ||
                     props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_ModificationsRevision)) ||
                    (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory &&
                        (props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_ConfirmedProtocol ||
                        props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_ModificationsRevision)))
        );

        const showProcessRawInventoriesReportAffirmationActions = computed(
            () =>
                props.process && hasRoleG.value == true &&
                ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory &&
                 props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_SendForAffirmation) ||
                 (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory &&
                 props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_SendForAffirmation))
        );

        
        const showStandpoints = computed(
            () =>
                props.process && 
                ((props.process.processTypeId === ProcessType.ProcessRawFundWithRawInventory &&
                 props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_SendToAddSessionAgendaStandpointComment
                //  || props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpoint
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_SendSessionAgendaStandpointComment
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_CommissionSession
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_ConfirmationProtocolSent
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_ConfirmedProtocol
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_ReportChangesRequired
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_ReportModifications
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_SendForModificationsRevision
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_ModificationsRevision
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_ReportApproval
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_SendForAffirmation
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_Affirmation
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_RegisterInventories) ||

                 (props.process.processTypeId === ProcessType.ProcessFundWithRawInventory &&
                 props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_SendToAddSessionAgendaStandpointComment
                //  || props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpoint
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_SendSessionAgendaStandpointComment
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_CommissionSession
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_ConfirmationProtocolSent
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_ConfirmedProtocol
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_ReportChangesRequired
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_ReportModifications
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_SendForModificationsRevision
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_ModificationsRevision
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_ReportApproval
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_SendForAffirmation
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_Affirmation
                 || props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_RegisterInventories))
        );

        const addReportToSessionAgendaValue = computed(() => 
            props.process?.processTypeId == ProcessType.ProcessRawFundWithRawInventory 
            ? ProcessStep.ProcessRawFundWithRawInventory_AddReportToSessionAgenda
            : ProcessStep.ProcessFundWithRawInventory_AddReportToSessionAgenda);

        const addSessionAgendaStandpointValue = computed(() => 
            props.process?.processTypeId == ProcessType.ProcessRawFundWithRawInventory 
            ? ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpoint
            : ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpoint);

        const addSessionAgendaStandpointCommentValue = computed(() => 
            props.process?.processTypeId == ProcessType.ProcessRawFundWithRawInventory 
            ? ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpointComment
            : ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpointComment);



        const addReportToSessionAgendaReadonly = computed(() => 
            hasRoleV1.value == false ||
            (props.process?.activeProcessStepTypeId !== ProcessStep.ProcessRawFundWithRawInventory_AddReportToSessionAgenda &&
            props.process?.activeProcessStepTypeId !== ProcessStep.ProcessFundWithRawInventory_AddReportToSessionAgenda));

        const addSessionAgendaStandpointReadonly = computed(() => 
            props.process?.activeProcessStepTypeId !== ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpoint &&
            props.process?.activeProcessStepTypeId !== ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpoint);

        const addSessionAgendaStandpointCommentReadonly = computed(() => 
            props.process?.activeProcessStepTypeId !== ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpointComment &&
            props.process?.activeProcessStepTypeId !== ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpointComment);


        const sendReport = () =>{
            context.emit('sendReport');
        }

        const approve = () =>{
            context.emit('approve');
        }

        const affirm = () =>{
            context.emit('affirm');
        }

        onMounted(async () => {
            panel.value = activeProcessStep.value;

            if (activeProcessStep.value == ProcessStep.ProcessRawFundWithRawInventory_CreateReport ||
                activeProcessStep.value == ProcessStep.ProcessFundWithRawInventory_CreateReport) {
                await getReportData();
            }

            if (activeProcessStep.value === ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpoint
                || activeProcessStep.value === ProcessStep.ProcessRawFundWithRawInventory_SendToAddSessionAgendaStandpointComment
                || activeProcessStep.value === ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpointComment
                || activeProcessStep.value === ProcessStep.ProcessRawFundWithRawInventory_SendSessionAgendaStandpointComment
                || activeProcessStep.value === ProcessStep.ProcessRawFundWithRawInventory_CommissionSession
                || activeProcessStep.value === ProcessStep.ProcessRawFundWithRawInventory_ConfirmationProtocolSent
                || activeProcessStep.value === ProcessStep.ProcessRawFundWithRawInventory_ConfirmedProtocol
                || activeProcessStep.value === ProcessStep.ProcessRawFundWithRawInventory_ReportChangesRequired
                || activeProcessStep.value === ProcessStep.ProcessRawFundWithRawInventory_ReportModifications
                || activeProcessStep.value === ProcessStep.ProcessRawFundWithRawInventory_SendForModificationsRevision
                || activeProcessStep.value === ProcessStep.ProcessRawFundWithRawInventory_ModificationsRevision
                || activeProcessStep.value === ProcessStep.ProcessRawFundWithRawInventory_ReportApproval
                || activeProcessStep.value === ProcessStep.ProcessRawFundWithRawInventory_SendForAffirmation
                || activeProcessStep.value === ProcessStep.ProcessRawFundWithRawInventory_Affirmation
                || activeProcessStep.value === ProcessStep.ProcessRawFundWithRawInventory_RegisterInventories

                || activeProcessStep.value === ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpoint
                || activeProcessStep.value === ProcessStep.ProcessFundWithRawInventory_SendToAddSessionAgendaStandpointComment
                || activeProcessStep.value === ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpointComment
                || activeProcessStep.value === ProcessStep.ProcessFundWithRawInventory_SendSessionAgendaStandpointComment
                || activeProcessStep.value === ProcessStep.ProcessFundWithRawInventory_CommissionSession
                || activeProcessStep.value === ProcessStep.ProcessFundWithRawInventory_ConfirmationProtocolSent
                || activeProcessStep.value === ProcessStep.ProcessFundWithRawInventory_ConfirmedProtocol
                || activeProcessStep.value === ProcessStep.ProcessFundWithRawInventory_ReportChangesRequired
                || activeProcessStep.value === ProcessStep.ProcessFundWithRawInventory_ReportModifications
                || activeProcessStep.value === ProcessStep.ProcessFundWithRawInventory_SendForModificationsRevision
                || activeProcessStep.value === ProcessStep.ProcessFundWithRawInventory_ModificationsRevision
                || activeProcessStep.value === ProcessStep.ProcessFundWithRawInventory_ReportApproval
                || activeProcessStep.value === ProcessStep.ProcessFundWithRawInventory_SendForAffirmation
                || activeProcessStep.value === ProcessStep.ProcessFundWithRawInventory_Affirmation
                || activeProcessStep.value === ProcessStep.ProcessFundWithRawInventory_RegisterInventories) {
                await getSessionAgendaItemData();
            }
        });

        return {
            t,
            message,
            panel,
            ProcessType,
            ProcessStep,
            report,
            sessionAgendaItem,
            activeProcessStep,
            showReportPanel,
            showDecisionPanel,
            showProcessRawInventoriesReportApprovalActions,
            showProcessRawInventoriesReportAffirmationActions,
            showAddReportToSessionAgenda,
            showAddSessionAgendaStandpoint,
            showAddSessionAgendaStandpointComment,
            showStandpoints,
            comissionReportIsReadonly,
            comissionReportSendEnabled,
            addReportToSessionAgendaValue,
            addSessionAgendaStandpointValue,
            addSessionAgendaStandpointCommentValue,
            addReportToSessionAgendaReadonly,
            addSessionAgendaStandpointReadonly,
            addSessionAgendaStandpointCommentReadonly,
            commissionStandpoints,
            commissionStandpoint,
            sendReport,
            approve, 
            affirm,
            refresh,
        };
    },
})
</script>
