<template>
    <div v-if="loading" class="d-flex justify-content-center">
        <v-progress-circular :size="50" color="green-lighten-2" indeterminate></v-progress-circular>
    </div>
    <div v-if="!loading">
        <v-row>
            <v-col class="col-12 col-lg-3">
                <text-field
                    v-model="decisionData.minutesOfMeetingNumber"
                    :disabled="true"
                    :label="t('sessions.columns.minutesOfMeetingNumber')"
                />
            </v-col>
            <v-col class="col-12 col-lg-4">
                <text-field
                    :modelValue="formatDate(decisionData.minutesOfMeetingDate)"
                    :disabled="true"
                    :label="t('sessions.columns.minutesOfMeetingDate')"
                />
            </v-col>
            <v-col class="col-12 col-lg-4">
                <text-field
                    :modelValue="formatDate(decisionData.deadlineForApproval)"
                    :disabled="true"
                    :label="t('sessionAgenda.columns.deadlineForApproval')"
                />
            </v-col>
        </v-row>
        <v-row>
            <v-col>
                <text-area-field
                    v-model="decisionData.decisionText"
                    :readOnly="true"
                    :label="t('sessionAgenda.columns.decision')"
                />
            </v-col>
        </v-row>
        <v-row>
            <v-col v-if="decisionData.minutesOfMeetingHasFile" class="col-12 col-lg-4">
                <v-btn @click="downloadProtocol()"
                    >{{ t('sessions.buttons.downloadProtocol')
                    }}<i class="fa fa-download" aria-hidden="true"></i>
                    <v-tooltip
                        activator="parent"
                        location="bottom"
                    >
                    {{t('sessions.buttons.downloadProtocol')}}
                    </v-tooltip>
                    </v-btn
            ></v-col>
        </v-row>
        <slot name="actions"></slot>
    </div>
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, Ref, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { formatDate } from '@/helpers/format.helper';

import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { Message } from '@/models/notification';
import { ICommissionDecision } from '@/interfaces/commission';
import { CommissionDecisionModel } from '@/models/commission';
import commissionDecisionService from '@/services/commissionDecision.service';

import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';

export default defineComponent({
    name: 'CommissionDecision',
    components: {
        TextField,
        TextAreaField,
    },
    props: {
        processId: {
            type: Number,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const loading = ref(true);
        const decisionData = ref<ICommissionDecision>(new CommissionDecisionModel());

        const downloadProtocol = async () => {
            try {
                const url = await commissionDecisionService.getFileDownloadUrl(
                    decisionData.value.sessionAgendaId as number
                );
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
        const getDecisionData = async () => {
            try {
                const decision = await commissionDecisionService.getDecisionByProcessId(props.processId);

                if (decision) {
                    decisionData.value = decision;
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            } finally {
                loading.value = false;
            }
        };

        onMounted(async () => {
            await getDecisionData();
        });

        return {
            t,
            formatDate,
            downloadProtocol,
            loading,
            decisionData,
        };
    },
});
</script>
