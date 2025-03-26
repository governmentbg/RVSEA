<template>
    <v-expansion-panels v-model="panel" multiple>
        <!--STEP 1-->
        <v-expansion-panel v-if="displayModel.procedureStepId != 36 && displayModel.procedureStepId != 246">
            <v-expansion-panel-title>{{ t('deduction.steps.step1') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <EpkReport :processData="process" :readonly="displayModel.procedureStepId != 32" @send="updateStep" />
            </v-expansion-panel-text>
        </v-expansion-panel>
        <!--STEP 1.5-->
        <v-expansion-panel v-if="displayModel.procedureStepId == 246">
            <v-expansion-panel-title>{{ t('deduction.steps.stepC') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <Comments
                    :comentTypeProp="t('docsCreateProc.comment')"
                    :ProcessId="displayModel.id"
                    :ProcessStepId="33"
                    :showDelete="false"
                />
            </v-expansion-panel-text>
        </v-expansion-panel>
        <v-expansion-panel v-if="displayModel.procedureStepId == 246">
            <v-expansion-panel-title>{{ t('deduction.steps.step15') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <EpkReport :processData="process" :readonly="!showAddComments" @send="updateStep" />
            </v-expansion-panel-text>
        </v-expansion-panel>
        <!--STEP 2-->
        <v-expansion-panel v-if="displayModel.procedureStepId == 33">
            <v-expansion-panel-title>{{ t('deduction.steps.step2') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <Comments
                    :comentTypeProp="t('docsCreateProc.comment')"
                    v-model:showModal="show"
                    :ProcessId="displayModel.id"
                    :ProcessStepId="displayModel.procedureStepId"
                >
                    <template v-slot:buttons>
                        <v-col class="mt-2 mb-2 px-2">
                            <v-btn class="mx-2" @click="show = true">{{ t('common.add') }}</v-btn>
                            <assign-modal
                                ref="sendForApprovalModal"
                                class="mb-3"
                                :archiveId="displayModel.archiveId"
                                :roleNames="approvalRoles"
                                :showDate="false"
                                :showRoles="true"
                                :btnTitle="t('sessionAgenda.buttons.sendForStandpoints')"
                                :dialogTitle="t('common.send')"
                                @assign="updateStep"
                            ></assign-modal>
                        </v-col>
                    </template>
                    <template v-slot:secondButton>
                        <v-col class="mt-2 mb-2 px-2">
                            <v-btn class="mx-2" @click="decrementStep">{{ t('docsCreateProc.returnEdit') }}</v-btn>

                            <assign-modal
                                ref="sendForApprovalModal"
                                class="mb-3"
                                :archiveId="displayModel.archiveId"
                                :roleNames="approvalRoles"
                                :showDate="false"
                                :showRoles="true"
                                :btnTitle="t('sessionAgenda.buttons.sendForStandpoints')"
                                :dialogTitle="t('common.send')"
                                @assign="updateStep"
                            ></assign-modal>
                        </v-col>
                    </template>
                </Comments>
            </v-expansion-panel-text>
        </v-expansion-panel>
        <v-expansion-panel v-if="displayModel.procedureStepId == 247 || displayModel.procedureStepId == 248">
            <v-expansion-panel-title>{{
                displayModel.procedureStepId == 247 ? t('deduction.steps.step3') : t('deduction.steps.step31')
            }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <SessionAgendaStandpoint
                    :process="process"
                    ref="commissionStandpoint"
                    @commit="btnCommitStandpointClickHandler"
                />
                <SessionAgendaStandpoints
                    :process="process"
                    :readOnly="true"
                    ref="commissionStandpoints"
                    @editStandpoint="refresh"
                />
            </v-expansion-panel-text>
        </v-expansion-panel>
        <!--STEP 2.2 Въвеждане на коментари по становища ! !!!-->
        <!-- ТУКА НЕ СЕ ПИПА -->
        <v-expansion-panel v-if="displayModel.procedureStepId == 248">
            <v-expansion-panel-title>{{ t('deduction.steps.step248') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <v-row>
                    <span class="mt-2 mb-3"></span>
                </v-row>
                <SessionAgendaStandpoints
                    :process="process"
                    :readOnly="!showAddComments"
                    ref="commissionStandpoints"
                    @editStandpoint="refresh"
                />
                <v-row v-if="userHasRole">
                    <v-col class="col-2">
                        <assign-modal
                            ref="sendForApprovalModal"
                            :archiveId="displayModel.archiveId"
                            class="col-10"
                            :roleNames="approvalRoles"
                            :showDate="false"
                            :showRoles="false"
                            :btnTitle="t('common.send')"
                            :dialogTitle="t('deduction.button.sendTo')"
                            @assign="updateStep"
                        ></assign-modal>
                    </v-col>
                </v-row>
            </v-expansion-panel-text>
        </v-expansion-panel>
        <!--STEP 3-->
        <v-expansion-panel v-if="displayModel.procedureStepId == 34">
            <v-expansion-panel-title>{{ t('deduction.steps.step3') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <v-row>
                    <span class="mt-2 mb-3"></span>
                </v-row>
                <SessionAgendaStandpoint
                    :process="process"
                    ref="commissionStandpoint"
                    @commit="btnCommitStandpointClickHandler"
                />

                <SessionAgendaStandpoints
                    :process="process"
                    :readOnly="true"
                    ref="commissionStandpoints"
                    @editStandpoint="refresh"
                />
            </v-expansion-panel-text>
        </v-expansion-panel>
        <!--STEP 4-->
        <v-expansion-panel v-if="displayModel.procedureStepId == 151">
            <v-expansion-panel-title>{{ t('deduction.steps.step8') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <SessionAgendaStandpoint
                    :process="process"
                    :readOnly="true"
                    ref="commissionStandpoint"
                    @commit="btnCommitStandpointClickHandler"
                />
            </v-expansion-panel-text>
        </v-expansion-panel>
        <v-expansion-panel v-if="displayModel.procedureStepId == 151">
            <v-expansion-panel-title>{{ t('deduction.steps.step4') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <epk-decision :processId="displayModel.id">
                    <template v-slot:actions>
                        <v-col class="mt-2 mb-2 px-2">
                            <v-btn class="mx-2" @click="decrementStep"
                                >{{ t('docsCreateProc.returnEdit') }}
                                <v-tooltip activator="parent" location="bottom">
                                    {{ t('docsCreateProc.returnEditTooltip') }}
                                </v-tooltip>
                            </v-btn>
                            <v-btn class="mx-2" @click="updateStep"
                                >{{ t('docsCreateProc.agree') }}
                                <v-tooltip activator="parent" location="bottom">
                                    {{ t('docsCreateProc.agreeTooltip') }}
                                </v-tooltip>
                            </v-btn>
                            <v-btn class="mx-2 cancel" @click="terminate"
                                >{{ t('common.cancel') }}
                                <v-tooltip activator="parent" location="bottom">
                                    {{ t('common.cancel') }}
                                </v-tooltip>
                            </v-btn>
                        </v-col>
                    </template>
                </epk-decision>
            </v-expansion-panel-text>
        </v-expansion-panel>
        <!--STEP 5-->
        <v-expansion-panel v-if="displayModel.procedureStepId == 36">
            <v-expansion-panel-title>{{ t('epkProtocol.decision') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <epk-decision :processId="displayModel.id" />
            </v-expansion-panel-text>
        </v-expansion-panel>
        <v-expansion-panel v-if="displayModel.procedureStepId == 36">
            <v-expansion-panel-title>{{ t('docsCreateProc.comments') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <Comments
                    :comentTypeProp="t('docsCreateProc.comment')"
                    v-model:showModal="show"
                    :ProcessId="displayModel.id"
                    :ProcessStepId="currentComentStep"
                />
            </v-expansion-panel-text>
        </v-expansion-panel>
        <v-expansion-panel v-if="displayModel.procedureStepId == 36">
            <v-expansion-panel-title>{{ t('deduction.steps.step5') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <EpkReport
                    :processData="process"
                    :readonly="displayModel.procedureStepId != 32 && displayModel.procedureStepId != 36"
                    @send="updateStep"
                />
            </v-expansion-panel-text>
        </v-expansion-panel>
        <!--STEP 6-->
        <v-expansion-panel v-if="displayModel.procedureStepId == 37">
            <v-expansion-panel-title>{{ t('deduction.steps.step6') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <v-row>
                    <span class="mt-2 mb-3"></span>
                </v-row>
                <Comments
                    :comentTypeProp="t('docsCreateProc.comment')"
                    v-model:showModal="show"
                    :ProcessId="displayModel.id"
                    :ProcessStepId="displayModel.procedureStepId"
                >
                    <template v-slot:buttons>
                        <v-col class="mt-2 mb-2 px-2">
                            <v-btn class="mx-2" @click="show = true">{{ t('common.add') }}</v-btn>
                            <assign-modal
                                ref="sendForApprovalModal"
                                class="mb-1"
                                :archiveId="displayModel.archiveId"
                                :roleNames="approvalRoles"
                                :showDate="false"
                                :showRoles="true"
                                :btnTitle="t('films.buttons.approve')"
                                :dialogTitle="t('films.buttons.approve')"
                                @assign="updateStep"
                            ></assign-modal>
                        </v-col>
                    </template>
                    <template v-slot:secondButton>
                        <v-col class="mt-2 mb-2 px-2">
                            <v-btn class="mx-2" @click="save"
                                >{{ t('common.save') }}
                                <v-tooltip activator="parent" location="bottom">
                                    {{ t('common.saveTooltip') }}
                                </v-tooltip>
                            </v-btn>
                            <assign-modal
                                ref="sendForApprovalModal"
                                class="mb-1"
                                :archiveId="displayModel.archiveId"
                                :roleNames="approvalRoles"
                                :showDate="false"
                                :showRoles="true"
                                :btnTitle="t('films.buttons.approve')"
                                :dialogTitle="t('films.buttons.approve')"
                                @assign="updateStep"
                            ></assign-modal>
                            <v-btn class="mx-2" @click="decrementStep"
                                >{{ t('docsCreateProc.returnEdit') }}
                                <v-tooltip activator="parent" location="bottom">
                                    {{ t('docsCreateProc.returnEditTooltip') }}
                                </v-tooltip>
                            </v-btn>
                        </v-col>
                    </template>
                </Comments>
            </v-expansion-panel-text>
        </v-expansion-panel>
        <!--STEP 7-->
        <v-expansion-panel v-if="displayModel.procedureStepId == 38">
            <v-expansion-panel-title>{{ t('deduction.steps.step7') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <v-row>
                    <span class="mt-2 mb-3"></span>
                </v-row>
                <Comments
                    :comentTypeProp="t('docsCreateProc.comment')"
                    :ProcessId="displayModel.id"
                    :ProcessStepId="displayModel.procedureStepId"
                    v-model:showModal="show"
                >
                    <template v-slot:buttons>
                        <v-col class="mt-2 mb-2 px-2">
                            <v-btn class="mx-2" @click="show = true">{{ t('common.add') }}</v-btn>
                            <v-btn class="mx-2" @click="updateStep">{{ t('deduction.button.confirmed') }}</v-btn>
                        </v-col>
                    </template>
                    <template v-slot:secondButton>
                        <v-col class="mt-2 mb-2 px-2">
                            <v-btn class="mx-2" @click="save"
                                >{{ t('common.save') }}
                                <v-tooltip activator="parent" location="bottom">
                                    {{ t('common.saveTooltip') }}
                                </v-tooltip>
                            </v-btn>
                            <v-btn class="mx-2" @click="updateStep">{{ t('deduction.button.confirmed') }}</v-btn>
                            <assign-modal
                                ref="sendForApprovalModal"
                                class="mx-2"
                                :archiveId="displayModel.archiveId"
                                :roleNames="approvalRoles"
                                :showDate="false"
                                :showRoles="true"
                                :btnTitle="t('docsCreateProc.returnEdit')"
                                :dialogTitle="t('docsCreateProc.returnEdit')"
                                @assign="decrementStep"
                            ></assign-modal>
                        </v-col>
                    </template>
                </Comments>
            </v-expansion-panel-text>
        </v-expansion-panel>
        <!--STEP 7A-->
        <v-expansion-panel v-if="displayModel.procedureStepId == 39">
            <v-expansion-panel-title>{{ t('docsCreateProc.comments') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <v-row>
                    <span class="mt-2 mb-3"></span>
                </v-row>
                <Comments
                    :comentTypeProp="t('docsCreateProc.comment')"
                    :ProcessId="displayModel.id"
                    :ProcessStepId="38"
                />
            </v-expansion-panel-text>
        </v-expansion-panel>
        <v-expansion-panel v-if="displayModel.procedureStepId == 39">
            <v-expansion-panel-title>{{ t('deduction.steps.step7a') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <v-row>
                    <span class="mt-2 mb-3"></span>
                </v-row>
                <Comments
                    :comentTypeProp="t('docsCreateProc.comment')"
                    :ProcessId="displayModel.id"
                    :ProcessStepId="displayModel.procedureStepId"
                    v-model:showModal="show"
                >
                    <template v-slot:buttons>
                        <v-col class="mt-2 mb-2 px-2">
                            <v-btn class="mx-2" @click="show = true">{{ t('deduction.button.addComment') }}</v-btn>
                            <v-btn class="mx-2" @click="decrementStep"
                                >{{ t('docsCreateProc.returnEdit') }}
                                <v-tooltip activator="parent" location="bottom">
                                    {{ t('docsCreateProc.returnEditTooltip') }}
                                </v-tooltip>
                            </v-btn>
                            <assign-modal
                                ref="sendForApprovalModal"
                                :archiveId="displayModel.archiveId"
                                class="mx-2"
                                :roleNames="approvalRoles"
                                :showDate="false"
                                :showRoles="true"
                                :btnTitle="t('deduction.button.noCorrectionsNeeded')"
                                :dialogTitle="t('deduction.button.noCorrectionsNeeded')"
                                @assign="updateStep"
                            ></assign-modal>
                        </v-col>
                    </template>
                    <template v-slot:secondButton>
                        <v-col class="mt-2 mb-2 px-2">
                            <v-btn class="mx-2" @click="save"
                                >{{ t('common.save') }}
                                <v-tooltip activator="parent" location="bottom">
                                    {{ t('common.saveTooltip') }}
                                </v-tooltip>
                            </v-btn>
                            <v-btn class="mx-2" @click="decrementStep"
                                >{{ t('docsCreateProc.returnEdit') }}
                                <v-tooltip activator="parent" location="bottom">
                                    {{ t('docsCreateProc.returnEditTooltip') }}
                                </v-tooltip>
                            </v-btn>
                            <assign-modal
                                ref="sendForApprovalModal"
                                :archiveId="displayModel.archiveId"
                                class="col-10"
                                :roleNames="approvalRoles"
                                :showDate="false"
                                :showRoles="false"
                                :btnTitle="t('deduction.button.noCorrectionsNeeded')"
                                :dialogTitle="t('deduction.button.noCorrectionsNeeded')"
                                @assign="updateStep"
                            ></assign-modal>
                        </v-col>
                    </template>
                </Comments>
            </v-expansion-panel-text>
        </v-expansion-panel>
    </v-expansion-panels>
</template>

<script lang="ts">
import { defineComponent, PropType, computed, ref, onMounted, inject, Ref } from 'vue';
import { CommentModel } from '@/models/comment';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import EpkReport from '@/components/commission/report.vue';
import { CommissionDecisionModel, CommissionReportModel } from '@/models/commission';
import Comments from '@/components/comments/Index.vue';
import { DeductionProcessViewModel } from '@/models/deductionProcess';
import deductionProcessService from '@/services/deductionProcess.service';
import AssignModal from '@/components/films/assign.modal.vue';
import { AssignModel } from '@/models/task';
import { RoleNames } from '@/enums/roles';
import EpkDecision from '@/components/commission/decision.vue';
import commissionDecisionService from '@/services/commissionDecision.service';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { useStore } from '@/store/user';
import SessionAgendaStandpoints from '@/components/commission/sessionAgendaStandpoints.vue';
import SessionAgendaService from '@/services/sessionAgenda.service';
import SessionAgendaStandpoint from '@/components/commission/sessionAgendaStandpoint.vue';
import { IProcess } from '@/interfaces/process';
import processService from '@/services/process.service';
import { ProcessTimeline } from '@/models/process';
import { ResponseResult } from '@/models/responseResult';
import { BusinessObjectType } from '@/models/grid';
export default defineComponent({
    components: {
        EpkReport,
        Comments,
        AssignModal,
        EpkDecision,
        SessionAgendaStandpoints,
        SessionAgendaStandpoint,
    },
    props: {
        modelProp: {
            type: Object as PropType<DeductionProcessViewModel>,
            required: false,
        },
        process: {
            type: Object as PropType<IProcess>,
        },
        externalSource: {
            type: Number,
        },
        documentIdProp: {
            type: Number,
            default: 0,
        },
        entityType: {
            type: String,
        },
        undoChanges: {
            type: Boolean,
        },
    },
    setup(props) {
        const panel = ref();
        const { t } = useI18n();
        const router = useRouter();
        const userStore = useStore();
        const Items = ref<CommentModel[]>();
        const displayModel = ref<DeductionProcessViewModel>(new DeductionProcessViewModel());
        const showAddComments = computed(() => currUserId == displayModel.value.epkReportModel.createdBy);
        const redirectLink = window.window.location.href;
        const reportModel = ref<CommissionReportModel>(new CommissionReportModel());
        const comments = ref<CommentModel[]>();
        const userHasRole = userStore.getters.hasRole(RoleNames.GroupV1);
        const show = ref(false);
        const entityLink = ref('');
        const approvalRoles = computed(() => getCurrentRoles());
        const decisionModel = ref<CommissionDecisionModel>(new CommissionDecisionModel());
        const message = inject('notificationMessage') as Ref<IMessage>;
        const currUserId = userStore.getters.userId;
        const sessionAgenda = ref();
        const currentComentStep = ref(0);
        const commissionStandpoints = ref();
        const commissionStandpoint = ref();

        const updateStep = async (assignModel?: AssignModel) => {
            try {
                displayModel.value.entityType = props.entityType;
                displayModel.value.assignToUserId = assignModel!.assignToUserId;
                displayModel.value.assignToRoleId = assignModel!.assignToRoleId;
                if (displayModel.value.procedureStepId == 35) {
                    if (
                        displayModel.value.procedureStepId == 35 &&
                        (decisionModel.value.decisionText == null ||
                            decisionModel.value.minutesOfMeetingNumber == null ||
                            decisionModel.value.minutesOfMeetingDate == null ||
                            decisionModel.value.deadlineForApproval == null)
                    ) {
                        alert(t('epkProtocol.alert'));
                        return;
                    } else {
                        decisionModel.value.sessionAgendaId = displayModel.value.epkReportModel.id;
                        displayModel.value.decisionModelId = await commissionDecisionService.createOrUpdate(
                            decisionModel.value
                        );
                    }
                }
                await deductionProcessService.updateStep(displayModel.value);
                router.go(0);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };
        const agreeButton = async (assignModel?: AssignModel) => {
            displayModel.value.assignToUserId = assignModel!.assignToUserId;
            displayModel.value.assignToRoleId = assignModel!.assignToRoleId;
            router.go(0);
        };
        const decrementStep = async () => {
            displayModel.value.entityType = props.entityType;
            if (
                displayModel.value.procedureStepId == 35 &&
                (decisionModel.value.decisionText == null ||
                    decisionModel.value.minutesOfMeetingNumber == null ||
                    decisionModel.value.minutesOfMeetingDate == null ||
                    decisionModel.value.deadlineForApproval == null)
            ) {
                alert(t('epkProtocol.alert'));
            } else {
                try {
                    await deductionProcessService.stepBack(displayModel.value);
                    router.go(0);
                } catch (error: unknown) {
                    const errorResult = error as ResponseResult;
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                        display: true,
                    });
                }
            }
        };
        const save = async () => {
            displayModel.value.entityType = props.entityType;
            if (displayModel.value.procedureStepId == 35) {
                decisionModel.value.sessionAgendaId = displayModel.value.epkReportModel.id;
                displayModel.value.decisionModelId = await commissionDecisionService.createOrUpdate(
                    decisionModel.value
                );
            } else if (displayModel.value.procedureStepId == 33) {
                if (displayModel.value.secretarOpinion == null || displayModel.value.sessionId == null) {
                    console.log(displayModel.value.secretarOpinion);
                    alert(t('epkProtocol.alert'));
                    return;
                } else {
                    await deductionProcessService.saveChanges(displayModel.value);
                    message.value = new Message({
                        text: t('deduction.mess.succ'),
                        display: true,
                        type: 'success',
                        timeout: 5000,
                    });
                    return;
                }
            } else {
                await deductionProcessService.saveChanges(displayModel.value);

                router.go(0);
            }
        };
        const terminate = async () => {
            try {
                displayModel.value.entityType = props.entityType;
                save();
                await deductionProcessService.terminateProcess(displayModel.value);
                router.go(0);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };
        const getSessions = async () => {
            try {
                // epkSessions.value = await dropdownService.getEPKSessions(displayModel.value.archiveId as number);

                if (displayModel.value.procedureStepId == 151) {
                    decisionModel.value = await commissionDecisionService.getDecisionById(
                        displayModel.value.decisionModelId as number
                    );
                    if (decisionModel.value != null) {
                        decisionModel.value.minutesOfMeetingDate = decisionModel.value.minutesOfMeetingDate?.toString();
                        decisionModel.value.deadlineForApproval = decisionModel.value.deadlineForApproval?.toString();
                    } else decisionModel.value = new CommissionDecisionModel();
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };
        const getCurrentRoles = () => {
            if (displayModel.value.procedureStepId == 32) {
                return [RoleNames.GroupV1];
            } else if (displayModel.value.procedureStepId == 33) {
                return [RoleNames.GroupV4];
            } else if (displayModel.value.procedureStepId == 34) {
                //
            } else if (displayModel.value.procedureStepId == 35) {
                return [RoleNames.GroupG];
            } else if (displayModel.value.procedureStepId == 36) {
                //
            } else if (displayModel.value.procedureStepId == 37 || displayModel.value.procedureStepId == 39) {
                return [RoleNames.GroupG];
            } else if (displayModel.value.procedureStepId == 38) {
                return [RoleNames.GroupV1];
            } else if (displayModel.value.procedureStepId == 248) {
                return [RoleNames.GroupV1];
            }
        };
        const get = () => {
            if (displayModel.value.sessionAgendaId) {
                SessionAgendaService.displaySessionAgendaItem(displayModel.value.sessionAgendaId as number).then(
                    (resolve) => (sessionAgenda.value = resolve)
                );
            }
        };

        const items = ref<ProcessTimeline[]>();
        items.value = [];
        const getTimeline = async () => {
            processService.getTimeline(displayModel.value.id!).then((result: ProcessTimeline[]) => {
                items.value = [];
                result.forEach((item) => {
                    items.value?.push(item);
                });
                currentComentStep.value = items.value[items.value.length - 2]?.stepTypeId as number;
            });
        };

        const refresh = async () => {
            await commissionStandpoints.value.getStandpointData();
            await commissionStandpoint.value.getSessionAgendaItemStandpointData();
        };

        const btnCommitStandpointClickHandler = async () => {
            if (commissionStandpoints.value) {
                await commissionStandpoints.value.getStandpointData();
            }
        };

        const getDeductDataProcedureData = async () => {
            try {
                switch (props.entityType) {
                    case BusinessObjectType.document:
                        if (props.process?.documentSystemIdentifier)
                            displayModel.value = await deductionProcessService.getById(
                                props.process?.documentSystemIdentifier,
                                BusinessObjectType.document.toString()
                            );
                        break;
                    case BusinessObjectType.archivalEntity:
                        if (props.process?.archivalEntitySystemIdentifier)
                            displayModel.value = await deductionProcessService.getById(
                                props.process?.archivalEntitySystemIdentifier,
                                BusinessObjectType.archivalEntity.toString()
                            );
                        break;
                    case BusinessObjectType.inventory:
                        if (props.process?.inventorySystemIdentifier)
                            displayModel.value = await deductionProcessService.getById(
                                props.process?.inventorySystemIdentifier,
                                BusinessObjectType.inventory.toString()
                            );
                        break;
                    case BusinessObjectType.fund:
                        if (props.process?.fundSystemIdentifier)
                            displayModel.value = await deductionProcessService.getById(
                                props.process?.fundSystemIdentifier,
                                BusinessObjectType.fund.toString()
                            );
                        break;
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        onMounted(() => {
            getSessions();
            get();
            getDeductDataProcedureData();
            if (displayModel.value.procedureStepId == 36) {
                getTimeline();
            }
        });

        return {
            t,
            updateStep,
            agreeButton,
            save,
            terminate,
            decrementStep,
            refresh,
            btnCommitStandpointClickHandler,
            currUserId,
            userHasRole,
            currentComentStep,
            Items,
            showAddComments,
            //  epkSessions,
            redirectLink,
            displayModel,
            panel,
            reportModel,
            comments,
            show,
            entityLink,
            approvalRoles,
            decisionModel,
            sessionAgenda,
            commissionStandpoint,
            commissionStandpoints,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/dialog.scss';
</style>
