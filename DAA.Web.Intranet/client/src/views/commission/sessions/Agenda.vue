<template>
    <Breadcrumbs :items="breadcrumbItems" />
    <v-card class="mt-3 col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('sessions.manageSessionAgenda') }}</v-card-title>
        <v-container>
            <v-expansion-panels v-model="panel" multiple>
                <v-expansion-panel value="sessionInfo">
                    <v-expansion-panel-title>{{ t('sessions.panels.sessionInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="archiveName"
                                    :label="t('documents.columns.archive')"
                                    :modelValue="sessionData.archiveName"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldSessionDate"
                                    :label="t('sessions.columns.date')"
                                    :modelValue="formatDate(sessionData.sessionDate)"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldSessionType"
                                    :label="t('sessions.columns.type')"
                                    :modelValue="returnSessionTypeName(sessionData.sessionTypeCode)"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldChairman"
                                    :label="t('sessions.columns.chairman')"
                                    v-model="sessionData.chairmanDisplayName"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldSecretary"
                                    :label="t('sessions.columns.secretary')"
                                    v-model="sessionData.secretaryDisplayName"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="d-grid gap-2 d-md-flex justify-content-center">
                                <v-btn @click="goToCurrentSession">{{ t('sessions.buttons.goToCurrentSession') }}</v-btn>
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="commissionReports">
                    <v-expansion-panel-title>{{ t('sessions.panels.commissionReports') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <SessionReportList
                            ref="commissionReports"
                            v-if="sessionData && sessionData.archiveId"
                            :session="sessionData"
                            :showAddButton="true"
                            @add="refreshAgendaData"
                        />
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="sessionAgenda">
                    <v-expansion-panel-title>{{ t('sessions.panels.sessionAgenda') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <SessionAgendaList
                            ref="sessionAgendaItems"
                            v-if="sessionData && sessionData.id"
                            :sessionId="sessionData.id"
                            :showDecision="false"
                            :showDecisionButton="false"
                            :showDeleteButton="true"
                            @delete="refreshReportData"
                        />
                    </v-expansion-panel-text>
                </v-expansion-panel>
            </v-expansion-panels>
        </v-container>
    </v-card>
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, Ref, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { formatDate, returnSessionTypeName } from '@/helpers/format.helper';
import { useRedirectWithId } from '@/helpers/router.helper';

import { ResponseResult } from '@/models/responseResult';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ICommissionSession } from '@/interfaces/commission';
import { CommissionSessionModel } from '@/models/commission';
import commissionSessionService from '@/services/commissionSession.service';

import TextField from '@/components/field/text.field.vue';
import SessionAgendaList from '@/components/commission/sessionAgendaList.vue';
import SessionReportList from '@/components/commission/sessionReportList.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';

export default defineComponent({
    name: 'ManageSessionAgenda',
    components: {
        TextField,
        SessionAgendaList,
        Breadcrumbs,
        SessionReportList,
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

        const panel = ref(['sessionInfo', 'commissionReports', 'sessionAgenda']);
        const commissionReports = ref();
        const sessionAgendaItems = ref();

        const router = useRouter();

        const goToCurrentSession = () => {
            if (sessionAgendaItems.value && sessionAgendaItems.value.sessionAgendaData.length <= 0) {
                message.value = new Message({
                    text: t('warnings.noSessionAgendaItems'),
                    display: true,
                });
            } else {
                useRedirectWithId(router, 'CurrentSession', props.id);
            }
            
        };

        const sessionData = ref<ICommissionSession>(new CommissionSessionModel());

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

        const refreshAgendaData = () => {
            if (sessionAgendaItems.value) {
                sessionAgendaItems.value.getSessionAgendaData();
            }
        };

        const refreshReportData = () => {
            if (commissionReports.value) {
                commissionReports.value.getArchiveReportData();
            }
        };

        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.sessions'),
                disabled: false,
                to: { name: 'Sessions' },
            },
            {
                title: t('sessions.manageSessionAgenda'),
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
            sessionData,
            breadcrumbItems,
            panel,
            commissionReports,
            sessionAgendaItems,
            refreshAgendaData,
            refreshReportData,
            goToCurrentSession,
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
