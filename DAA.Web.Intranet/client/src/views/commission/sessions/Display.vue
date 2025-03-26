<template>
    <Breadcrumbs :items="breadcrumbItems" />
    <v-card class="mt-3 col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('sessions.display') }}</v-card-title>
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
                        <v-row>
                            <v-col class="col-12 col-lg-3">
                                <a
                                    class="a"
                                    style="color: #069"
                                    v-if="
                                        sessionData.minutesOfMeetingId &&
                                        sessionData.minutesOfMeetingStatus !== minutesOdMeetingStatus.New
                                    "
                                    @click="showUploadProtocolModal = true"
                                    >{{ t('sessions.buttons.uploadProtocol') }}
                                </a>
                            </v-col>
                            <v-col class="col-12 col-lg-3">
                                <div
                                    class="a"
                                    style="color: #069"
                                    v-if="sessionData.minutesOfMeetingHasFile"
                                    @click="downloadProtocol(sessionData.id)"
                                >
                                    {{ t('sessions.buttons.downloadProtocol') }}
                                </div>
                            </v-col></v-row
                        >
                        <v-row
                            v-if="
                                sessionData.minutesOfMeetingStatus === minutesOdMeetingStatus.Rejected ||
                                sessionData.minutesOfMeetingStatus === minutesOdMeetingStatus.SubmittedForApproval
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
                                <!-- <confirm-dialog
                                    v-if="
                                        (userIsChairmanOrSecretary &&
                                            !sessionData.minutesOfMeetingHasFile &&
                                            sessionData.minutesOfMeetingStatus !=
                                                minutesOdMeetingStatus.SubmittedForApproval &&
                                            sessionData.minutesOfMeetingStatus != minutesOdMeetingStatus.Approved) ||
                                        (userIsChairmanOrSecretary &&
                                            sessionData.minutesOfMeetingStatus == minutesOdMeetingStatus.Rejected)
                                    "
                                    :confirmationText="
                                        !sessionData.minutesOfMeetingNumber
                                            ? t('sessions.buttons.createMinutesOfMeetingConfirmation')
                                            : t('sessions.buttons.setMinutesOfMeetingProtocolConfirmation')
                                    "
                                    :activatorButtonText="t('sessions.buttons.createMinutesOfMeeting')"
                                    :confirmButtonText="t('sessions.buttons.createMinutesOfMeeting')"
                                    :cancelButtonText="t('common.cancel')"
                                    @confirm="goGenerateProtocol = true"
                                />
                                <v-btn
                                    v-if="
                                        (sessionData.minutesOfMeetingId &&
                                            userIsChairmanOrSecretary &&
                                            !sessionData.minutesOfMeetingHasFile &&
                                            sessionData.minutesOfMeetingStatus !=
                                                minutesOdMeetingStatus.SubmittedForApproval &&
                                            sessionData.minutesOfMeetingStatus != minutesOdMeetingStatus.Approved) ||
                                        (userIsChairmanOrSecretary &&
                                            sessionData.minutesOfMeetingStatus == minutesOdMeetingStatus.Rejected)
                                    "
                                    @click="editSessionProtocol(sessionData.minutesOfMeetingId)"
                                    >{{ t('sessions.buttons.editMinutesOfMeeting') }}</v-btn
                                > -->
                                <v-btn
                                    v-if="sessionData.minutesOfMeetingId && itemForTranscript.length"
                                    @click="readOrPrintSelectedStandPoints(sessionData.id)"
                                    >{{ t('sessions.buttons.printMinutesOfMeeting') }}</v-btn
                                >
                                <!-- <confirm-dialog
                                    v-if="
                                        userIsChairmanOrSecretary &&
                                        sessionData.minutesOfMeetingNumber &&
                                        sessionData.minutesOfMeetingStatus !=
                                            minutesOdMeetingStatus.SubmittedForApproval &&
                                        sessionData.minutesOfMeetingStatus != minutesOdMeetingStatus.Approved
                                    "
                                    :confirmationText="t('sessions.buttons.setMinutesOfMeetingConfirmation')"
                                    :activatorButtonText="t('sessions.buttons.setMinutesOfMeeting')"
                                    :confirmButtonText="t('sessions.buttons.setMinutesOfMeeting')"
                                    :cancelButtonText="t('common.cancel')"
                                    @confirm="sendProtocolForApproval"
                                />
                                <v-btn
                                    v-if="
                                        userIsArchiveManager &&
                                        sessionData.minutesOfMeetingStatus ==
                                            minutesOdMeetingStatus.SubmittedForApproval
                                    "
                                    @click="dialog = true"
                                    >{{ t('sessions.buttons.rejectProtocol') }}
                                </v-btn>
                                <confirm-dialog
                                    v-if="
                                        userIsArchiveManager &&
                                        sessionData.minutesOfMeetingStatus ==
                                            minutesOdMeetingStatus.SubmittedForApproval
                                    "
                                    :confirmationText="t('sessions.buttons.sendMinutesOfMeetingConfirmation')"
                                    :activatorButtonText="t('sessions.buttons.sendMinutesOfMeeting')"
                                    :confirmButtonText="t('sessions.buttons.sendMinutesOfMeeting')"
                                    :cancelButtonText="t('common.cancel')"
                                    @confirm="approvalProtocol"
                                /> -->
                            </v-col>
                        </v-row>
                        <UploadProtocolOnPiecePaper
                            v-if="sessionData.minutesOfMeetingId"
                            :sessionId="id"
                            v-model:showModal="showUploadProtocolModal"
                        />
                        <!-- <v-row justify="center">
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
                                        <v-btn color="green darken-1" text @click="rejectProtocol">
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
                         
                        </v-row> -->
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="sessionAgenda">
                    <v-expansion-panel-title>{{ t('sessions.panels.sessionAgenda') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <session-agenda-list
                            v-if="sessionData && sessionData.id"
                            :sessionId="sessionData.id"
                            :showDecision="true"
                            :showStandpoint="true"
                            :readOnly="true"
                            :showSelectButton="
                                sessionData.minutesOfMeetingId !== null || sessionData.minutesOfMeetingId !== undefined
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
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { useRouter } from 'vue-router';
import { useStore } from '@/store/user';
import { formatDate, returnSessionTypeName } from '@/helpers/format.helper';

import { ResponseResult } from '@/models/responseResult';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ICommissionSession } from '@/interfaces/commission';
import { CommissionSessionModel } from '@/models/commission';
import { RoleNames } from '@/enums/roles';
import { SessionType } from '@/enums/sessionTypes';
import { MinutesOfMeetingStatus } from '@/enums/minutesOfMeetingStatus';
import commissionSessionService from '@/services/commissionSession.service';

import UploadProtocolOnPiecePaper from '@/components/sessionProtocol/upload.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import GenerateProtocol from '@/components/protocol/protocolTemplate.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import TextField from '@/components/field/text.field.vue';
import SessionAgendaList from '@/components/commission/sessionAgendaList.vue';
//import ConfirmDialog from '@/components/confirm/confirmDialog.vue';

export default defineComponent({
    name: 'DisplaySession',
    components: {
        TextAreaField,
        TextField,
        SessionAgendaList,
        //ConfirmDialog,
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
        const sessionData = ref<ICommissionSession>(new CommissionSessionModel());
        const template = ref();
        const router = useRouter();
        const protocolContent = ref();
        const userStore = useStore();
        const userIsArchiveManager = userStore.getters.hasRole(RoleNames.GroupG);
        const userIsChairmanOrSecretary = computed(() => ChairmanOrSecretary());
        const showUploadProtocolModal = ref(false);
        const minutesOdMeetingStatus = MinutesOfMeetingStatus;
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
        function ChairmanOrSecretary() {
            let inRole = false;
            switch (sessionData.value.sessionTypeCode) {
                case SessionType.EPC:
                    inRole = userStore.getters.hasRole(RoleNames.GroupV1);
                    return inRole;
                case SessionType.EOC:
                    inRole = userStore.getters.hasRole(RoleNames.GroupV2);
                    return inRole;
                case SessionType.REOC:
                    inRole = userStore.getters.hasRole(RoleNames.GroupV3);
                    return inRole;
                default:
                    return false;
            }
        }
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
            }
        };
        const switchStatusText = (val: string) => {
            switch (val) {
                case minutesOdMeetingStatus.New:
                    return 'Нов';
                case minutesOdMeetingStatus.SubmittedForApproval:
                    return 'Изпратен за утвърждаване';
                case minutesOdMeetingStatus.Approved:
                    return 'Утвърден';
                case minutesOdMeetingStatus.Rejected:
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
                to: { name: 'PastSessions' },
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
            minutesOdMeetingStatus,
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
