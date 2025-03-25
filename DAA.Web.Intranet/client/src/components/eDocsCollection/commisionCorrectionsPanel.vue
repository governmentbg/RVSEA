<template>
    <v-expansion-panel :value="panelValue">
        <v-expansion-panel-title>{{ $t('funds.panels.commissionCorrections') }}</v-expansion-panel-title>
        <!-- <div v-if="loading" class="d-flex justify-content-center">
			<v-progress-circular :size="50" color="green-lighten-2" indeterminate></v-progress-circular>
		</div> -->
        <v-expansion-panel-text>
            <CommissionDecision :processId="process.id">
                <template v-slot:actions>
                    <v-row class="mt-3">
                        <v-col class="d-flex gap-2 justify-content-start">
                            <ConfirmDialog
                                :confirmationText="'Сигурни ли сте, че искате да изпратите промените за одобрение?'"
                                activatorButtonText="Изпрати промените за одобрение"
                                :confirmButtonText="$t('common.yes')"
                                :cancelButtonText="$t('common.cancel')"
                                @confirm="send"
                            ></ConfirmDialog>
                            <ConfirmDialog
                                v-if="
                                    processHasApplication &&
                                    (processApplicationStatus === ApplicationStatus.awaitingCommittee ||
                                        processApplicationStatus === ApplicationStatus.modificationApplied)
                                "
                                :confirmationText="'Изпращане за корекции към фондообразувател'"
                                :activatorButtonText="'Изпрати за корекции към фондообразувател'"
                                :confirmButtonText="$t('common.yes')"
                                :cancelButtonText="$t('common.cancel')"
                                :commentInputEnabled="true"
                                :commentInputRequired="true"
                                @confirm="sendToFundCreator"
                            ></ConfirmDialog>
                            <v-alert
                                v-if="
                                    processHasApplication &&
                                    processApplicationStatus === ApplicationStatus.modificationRequest
                                "
                                type="info"
                                density="compact"
                                variant="outlined"
                                >{{ 'Изпратени са препоръки от ЕПК/ЕОК/РЕОК към фондообразувател' }}</v-alert
                            >
                        </v-col>
                    </v-row>
                </template>
            </CommissionDecision>
            <div v-if="comments && comments.length > 0">
                <v-divider />
                <v-list>
                    <v-list-subheader>{{ $t('epkReport.comments') }}</v-list-subheader>
                    <v-list-item v-for="c in comments" :key="c.id">
                        <v-list-item-title>{{ c.text }}</v-list-item-title>

                        <v-list-item-subtitle>
                            <div>{{ c.createdByDisplayName }} / {{ formatDateTime(c.createdOn) }}</div>
                        </v-list-item-subtitle>
                    </v-list-item>
                </v-list>
            </div>
        </v-expansion-panel-text>
    </v-expansion-panel>
</template>

<script lang="ts">
import { defineComponent, inject, PropType, Ref, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { formatDate, formatDateTime } from '@/helpers/format.helper';

import { ResponseResult } from '@/models/responseResult';
import { Message } from '@/models/notification';
import { IProcess, IProcessStep } from '@/interfaces/process';
import { ProcessStepModel } from '@/models/process';
import { ProcessStep } from '@/enums/process';
import { IMessage } from '@/interfaces/notification';
import { IComment } from '@/interfaces/comment';
import { Status as ApplicationStatus } from '@/enums/applications';
import service from '@/services/eDocsCollecting.service';
import commentService from '@/services/comments.service';

import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import CommissionDecision from '@/components/commission/decision.vue';

export default defineComponent({
    components: {
        CommissionDecision,
        ConfirmDialog,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>,
            required: true,
        },
        panelValue: {
            type: String,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const processStep = ref<IProcessStep>(
            new ProcessStepModel({
                id: props.process.activeProcessStepId,
                processId: props.process.id,
                stepTypeId: ProcessStep.CommissionCorrectionsCheck,
            })
        );
        const comments = ref([] as IComment[]);
        const processHasApplication = ref(false);
        const processApplicationStatus = ref<number>();

        service
            .isExternalProcess(props.process.id!)
            .then((data) => {
                processHasApplication.value = data;
            })
            .catch((err) => {
                const errorResult = err as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            });

        service
            .getApplicationStatus(props.process.id!)
            .then((data) => {
                processApplicationStatus.value = data;
            })
            .catch((err) => {
                const errorResult = err as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            });

        return {
            formatDate,
            formatDateTime,
            ApplicationStatus,
            message,
            processStep,
            comments,
            processHasApplication,
            processApplicationStatus,
        };
    },
    methods: {
        send() {
            service
                .moveToNextStep(this.processStep)
                .then(() => {
                    //TODO
                    window.location.reload();
                })
                .catch((err) => {
                    const errorResult = err as ResponseResult;
                    this.message = new Message({
                        text: errorResult.showMessage ? errorResult.message : this.$t('error.basic'),
                        display: true,
                    });
                });
        },
        sendToFundCreator(comment: string) {
            service
                .sendModificationRequest(this.process.id!, comment)
                .then(() => {
                    window.location.reload();
                })
                .catch((err) => {
                    const errorResult = err as ResponseResult;
                    this.message = new Message({
                        text: errorResult.showMessage ? errorResult.message : this.$t('error.basic'),
                        display: true,
                    });
                });
        },
        loadComments() {
            commentService.getAll(this.process!.id!, this.process!.activeProcessStepTypeId!).then((data) => {
                this.comments = data;
            });
        },
    },
    mounted() {
        this.loadComments();
    },
});
</script>

<style scoped></style>
