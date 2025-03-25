<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="mt-3 col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('sessions.session') }}</v-card-title>
        <v-container>
            <v-expansion-panels v-model="panel" multiple>
                <v-expansion-panel value="sessionInfo">
                    <v-expansion-panel-title>{{ t('sessions.panels.sessionInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldSessionDate"
                                    :label="t('sessions.columns.date')"
                                    :modelValue="formatDate(sessionData.sessionDate)"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldSessionDate"
                                    :label="t('sessions.columns.type')"
                                    :modelValue="returnSessionTypeName(sessionData.sessionTypeCode)"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="archiveName"
                                    :label="t('documents.columns.archive')"
                                    :modelValue="sessionData.archiveName"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldSessionChairman"
                                    :label="t('sessions.columns.chairman')"
                                    :modelValue="sessionData.chairmanDisplayName"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldSessionSecretary"
                                    :label="t('sessions.columns.secretary')"
                                    :modelValue="sessionData.secretaryDisplayName"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row v-if="sessionData.minutesOfMeetingId">
                            <v-col class="col-12 col-lg-3">
                                <text-field
                                    name="fldMinutesOfMeetingNumber"
                                    :label="t('sessions.columns.minutesOfMeetingNumber')"
                                    :modelValue="sessionData.minutesOfMeetingNumber"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-3">
                                <text-field
                                    name="fldMinutesOfMeetingStatus"
                                    :label="t('sessions.columns.minutesOfMeetingStatus')"
                                    :modelValue="switchStatusText(sessionData.minutesOfMeetingStatus)"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-3">
                                <a
                                    class="a"
                                    style="color: #069"
                                    @click="readOrPrintProtocol(sessionData.minutesOfMeetingId)"
                                    >{{ t('sessions.buttons.viewProtocol') }}
                                </a>
                            </v-col>
                        </v-row>
                        <v-row class="col" v-if="sessionData.minutesOfMeetingId">
                            <v-col
                                v-if="sessionData.minutesOfMeetingStatus != minutesOfMeetingStatus.Approved"
                                class="col-12 col-lg-3"
                            >
                                <a class="a" style="color: #069" @click="showUploadProtocolModal = true"
                                    >{{ t('sessions.buttons.uploadProtocol') }}
                                </a>
                            </v-col>
                            <v-col class="col-6 col-lg-3">
                                <div
                                    class="a"
                                    style="color: #069"
                                    v-if="sessionData.minutesOfMeetingHasFile"
                                    @click="downloadProtocol(sessionData.id)"
                                >
                                    {{ t('sessions.buttons.downloadProtocol') }}
                                </div>
                            </v-col>
                        </v-row>
                        <v-row
                            v-if="
                                sessionData.minutesOfMeetingStatus === minutesOfMeetingStatus.Rejected ||
                                sessionData.minutesOfMeetingStatus === minutesOfMeetingStatus.SubmittedForApproval
                            "
                        >
                            <v-col>
                                <text-area-field
                                    name=""
                                    :label="t('sessions.minutesOfMeetingRejectReason')"
                                    :modelValue="sessionData.minutesOfMeetingRejectReason"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="d-grid gap-2 d-md-flex justify-content-start protocol-buttons">
                                <confirm-dialog
                                    v-if="
                                        (userIsChairmanOrSecretary &&
                                            !sessionData.minutesOfMeetingHasFile &&
                                            sessionData.minutesOfMeetingStatus !=
                                                minutesOfMeetingStatus.SubmittedForApproval &&
                                            sessionData.minutesOfMeetingStatus != minutesOfMeetingStatus.Approved) ||
                                        (userIsChairmanOrSecretary &&
                                            sessionData.minutesOfMeetingStatus == minutesOfMeetingStatus.Rejected)
                                    "
                                    :confirmationText="
                                        !sessionData.minutesOfMeetingNumber
                                            ? t('sessions.buttons.createMinutesOfMeetingConfirmation')
                                            : t('sessions.buttons.setMinutesOfMeetingProtocolConfirmation')
                                    "
                                    :activatorButtonText="t('sessions.buttons.createMinutesOfMeeting')"
                                    :confirmButtonText="t('common.yes')"
                                    :cancelButtonText="t('common.cancel')"
                                    @confirm="createSessionMinutesOfMeeting"
                                />
                                <v-btn
                                    v-if="
                                        (sessionData.minutesOfMeetingId &&
                                            userIsChairmanOrSecretary &&
                                            !sessionData.minutesOfMeetingHasFile &&
                                            sessionData.minutesOfMeetingStatus !=
                                                minutesOfMeetingStatus.SubmittedForApproval &&
                                            sessionData.minutesOfMeetingStatus != minutesOfMeetingStatus.Approved) ||
                                        (userIsChairmanOrSecretary &&
                                            sessionData.minutesOfMeetingStatus == minutesOfMeetingStatus.Rejected)
                                    "
                                    @click="editSessionProtocol(sessionData.minutesOfMeetingId)"
                                    >{{ t('sessions.buttons.editMinutesOfMeeting') }}</v-btn
                                >
                                <v-btn
                                    v-if="sessionData.minutesOfMeetingId && itemForTranscript.length"
                                    @click="readOrPrintSelectedStandPoints(sessionData.id)"
                                    >{{ t('sessions.buttons.printMinutesOfMeeting') }}</v-btn
                                >
                                <confirm-dialog
                                    v-if="
                                        userIsChairmanOrSecretary &&
                                        sessionData.minutesOfMeetingNumber &&
                                        sessionData.minutesOfMeetingStatus !=
                                            minutesOfMeetingStatus.SubmittedForApproval &&
                                        sessionData.minutesOfMeetingStatus != minutesOfMeetingStatus.Approved
                                    "
                                    :confirmationText="t('sessions.buttons.setMinutesOfMeetingConfirmation')"
                                    :activatorButtonText="t('sessions.buttons.setMinutesOfMeeting')"
                                    :confirmButtonText="t('common.yes')"
                                    :cancelButtonText="t('common.cancel')"
                                    @confirm="sendProtocolForApproval"
                                />
                                <v-btn
                                    v-if="
                                        userIsArchiveManager &&
                                        sessionData.minutesOfMeetingStatus ==
                                            minutesOfMeetingStatus.SubmittedForApproval
                                    "
                                    @click="dialog = true"
                                    >{{ t('sessions.buttons.rejectProtocol') }}
                                </v-btn>
                                <confirm-dialog
                                    v-if="
                                        userIsArchiveManager &&
                                        sessionData.minutesOfMeetingStatus ==
                                            minutesOfMeetingStatus.SubmittedForApproval
                                    "
                                    :confirmationText="t('sessions.buttons.sendMinutesOfMeetingConfirmation')"
                                    :activatorButtonText="t('sessions.buttons.sendMinutesOfMeeting')"
                                    :confirmButtonText="t('common.yes')"
                                    :cancelButtonText="t('common.cancel')"
                                    @confirm="approvalProtocol"
                                />
                            </v-col>
                        </v-row>
                        <v-row justify="center">
                            <v-dialog transition="dialog-bottom-transition" v-model="dialog">
                                <v-card class="vw-50">
                                    <v-card-title class="text-h5 text-center">
                                        {{ t('sessions.rejectReason') }}
                                    </v-card-title>
                                    <v-card-text>
                                        <v-col>
                                            <text-area-field v-model="rejectReason" />
                                        </v-col>
                                    </v-card-text>
                                    <v-card-actions>
                                        <v-spacer></v-spacer>
                                        <v-btn
                                            :disabled="disabledRejectProtocolSaveBtn"
                                            color="green darken-1"
                                            text
                                            @click="rejectProtocol"
                                        >
                                            {{ t('common.save') }}
                                        </v-btn>
                                        <v-btn
                                            class="cancel"
                                            color="green darken-1"
                                            text
                                            @click="(dialog = false), (rejectReason = null)"
                                        >
                                            {{ t('common.cancel') }}
                                        </v-btn>
                                    </v-card-actions>
                                </v-card>
                            </v-dialog>
                            <UploadProtocolOnPiecePaper
                                v-if="sessionData.minutesOfMeetingId"
                                :sessionId="id"
                                v-model:showModal="showUploadProtocolModal"
                            />
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="sessionAgenda">
                    <v-expansion-panel-title>{{ t('sessions.panels.sessionAgenda') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <session-agenda-list
                            v-if="sessionData && sessionData.id"
                            :sessionId="sessionData.id"
                            :showDecisionButton="
                                sessionData.minutesOfMeetingId === null ||
                                sessionData.minutesOfMeetingId === undefined ||
                                sessionData.minutesOfMeetingStatus === minutesOfMeetingStatus.New
                            "
                            :showSelectButton="
                                sessionData.minutesOfMeetingId !== null && sessionData.minutesOfMeetingId !== undefined
                            "
                            @select="getItemsForPrinting"
                        />
                    </v-expansion-panel-text>
                </v-expansion-panel>
            </v-expansion-panels>
            <GenerateProtocol v-if="sessionData.id" :sessionId="sessionData.id" v-model:generate="goGenerateProtocol" />
        </v-container>
    </v-card>
</template>
<script lang="ts">
import { computed, defineComponent, inject, onMounted, Ref, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { formatDate, returnSessionTypeName } from '@/helpers/format.helper';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';

import { ResponseResult } from '@/models/responseResult';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { RoleNames } from '@/enums/roles';
import { SessionType } from '@/enums/sessionTypes';
import { MinutesOfMeetingStatus } from '@/enums/minutesOfMeetingStatus';
import { ICommissionSession } from '@/interfaces/commission';
import { CommissionSessionModel } from '@/models/commission';
import authorization from '@/helpers/authorization.helper';
import commissionSessionService from '@/services/commissionSession.service';
import commissionDecisionService from '@/services/commissionDecision.service';

import TextAreaField from '@/components/field/textarea.field.vue';
import TextField from '@/components/field/text.field.vue';
import SessionAgendaList from '@/components/commission/sessionAgendaList.vue';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import UploadProtocolOnPiecePaper from '@/components/sessionProtocol/upload.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import GenerateProtocol from '@/components/protocol/protocolTemplate.vue';
import sessionAgendaService from '@/services/sessionAgenda.service';

export default defineComponent({
    name: 'CurrentSession',
    components: {
        TextAreaField,
        TextField,
        SessionAgendaList,
        ConfirmDialog,
        UploadProtocolOnPiecePaper,
        Breadcrumbs,
        GenerateProtocol,
    },
    props: {
        id: {
            type: Number,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const panel = ref(['sessionInfo', 'sessionAgenda']);
        const template = ref();
        const protocolContent = ref();
        const disabledRejectProtocolSaveBtn = ref<boolean>(false);
        const sessionData = ref<ICommissionSession>(new CommissionSessionModel());

        const router = useRouter();

        const userIsArchiveManager = computed(() => authorization.hasRole(RoleNames.GroupG));
        const userIsChairmanOrSecretary = computed(() => ChairmanOrSecretary());
        const showUploadProtocolModal = ref(false);
        const minutesOfMeetingStatus = MinutesOfMeetingStatus;
        const rejectReason = ref('');
        const dialog = ref(false);
        const goGenerateProtocol = ref(false);
        const itemForTranscript = ref<number[]>([]);

        const getItemsForPrinting = (arr: number[]) => {
            itemForTranscript.value = arr;

            console.log(itemForTranscript.value);
        };

        const getCommissionSessionData = async () => {
            try {
                sessionData.value = await commissionSessionService.getSession(props.id);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };
        const ChairmanOrSecretary = () => {
            let inRole = false;
            switch (sessionData.value.sessionTypeCode) {
                case SessionType.EPC:
                    inRole = authorization.hasRole(RoleNames.GroupV1);
                    return inRole;
                case SessionType.EOC:
                    inRole = authorization.hasRole(RoleNames.GroupV2);
                    return inRole;
                case SessionType.REOC:
                    inRole = authorization.hasRole(RoleNames.GroupV3);
                    return inRole;
                default:
                    return false;
            }
        };

        const createSessionMinutesOfMeeting = async () => {
            try {
                const decisionCount = await commissionDecisionService.getDecisionCountBySessionId(props.id);
                const sessionAgendaItemCount = await sessionAgendaService.getSessionAgendaItemCount(props.id);
                if (sessionAgendaItemCount > 0 && decisionCount > 0 && decisionCount == sessionAgendaItemCount) {
                    goGenerateProtocol.value = true;
                } else {
                    if (sessionAgendaItemCount <= 0) {
                        message.value = new Message({
                            text: t('warnings.noSessionAgendaItems'),
                            display: true,
                        });
                    } else {
                        message.value = new Message({
                            text: t('warnings.noSessionAgendaItemDecisions'),
                            display: true,
                            type: 'warning',
                        });
                    }
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const editSessionProtocol = (val: string) => {
            useRedirectWithId(router, 'EditProtocol', val);
        };

        const readOrPrintProtocol = (val: string) => {
            useRedirectWithId(router, 'ViewProtocol', val);
        };

        const readOrPrintSelectedStandPoints = (val: string) => {
            useRedirect(router, 'PrintTranscript', { id: val, items: itemForTranscript.value });
        };

        const approvalProtocol = async () => {
            try {
                await commissionSessionService.approvalProtocol(props.id);
                router.go(0);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };
        const downloadProtocol = async (Id: number) => {
            try {
                const url = await commissionSessionService.getFileDownloadUrl(Id);
                const link = document.createElement('a');
                link.href = url;
                document.body.appendChild(link);
                link.click();
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const sendProtocolForApproval = async () => {
            try {
                await commissionSessionService.sendProtocolForApproval(props.id);
                router.go(0);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const rejectProtocol = async () => {
            disabledRejectProtocolSaveBtn.value = true;
            try {
                if (rejectReason.value == '' || rejectReason.value == null) {
                    message.value = new Message({
                        text: t('sessions.emptyReason'),
                        display: true,
                    });
                    return;
                }
                await commissionSessionService.rejectProtocol(props.id, rejectReason.value);
                dialog.value = false;
                router.go(0);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            } finally {
                disabledRejectProtocolSaveBtn.value = false;
            }
        };

        const switchStatusText = (val: string) => {
            switch (val) {
                case minutesOfMeetingStatus.New:
                    return 'Нов';
                case minutesOfMeetingStatus.SubmittedForApproval:
                    return 'Изпратен за утвърждаване';
                case minutesOfMeetingStatus.Approved:
                    return 'Утвърден';
                case minutesOfMeetingStatus.Rejected:
                    return 'Върнат за корекции';

                default:
                    break;
            }
        };
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('sessions.sessions'),
                disabled: false,
                to: { name: 'UpcomingSessions' },
            },
            {
                title: t('sessions.session'),
                disabled: true,
            },
        ];

        onMounted(async () => {
            await getCommissionSessionData();
        });

        return {
            t,
            formatDate,
            returnSessionTypeName,
            goGenerateProtocol,
            sendProtocolForApproval,
            readOrPrintProtocol,
            readOrPrintSelectedStandPoints,
            editSessionProtocol,
            approvalProtocol,
            downloadProtocol,
            rejectProtocol,
            switchStatusText,
            minutesOfMeetingStatus,
            breadcrumbItems,
            dialog,
            panel,
            template,
            sessionData,
            protocolContent,
            userIsArchiveManager,
            userIsChairmanOrSecretary,
            showUploadProtocolModal,
            rejectReason,
            itemForTranscript,
            getItemsForPrinting,
            createSessionMinutesOfMeeting,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/dialog.scss';
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';

.a {
    background: none !important;
    border: none !important;
    // border-color: transparent !important;
    padding: 0 !important;
    text-decoration: underline;
    cursor: pointer;
    color: inherit;
}
.vw-50 {
    width: 90vw;
    min-height: 100vh;
}
:deep(.protocol-buttons) {
    display: flex;
    flex-wrap: wrap !important;
    justify-content: space-evenly !important;
    margin: auto;
    margin-bottom: 15px;
}
</style>
