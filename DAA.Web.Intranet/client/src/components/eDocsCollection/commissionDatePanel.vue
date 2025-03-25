<template>
    <v-expansion-panel :value="panelValue">
        <v-expansion-panel-title>{{ $t('eDocsCollection.steps.reportApproval') }}</v-expansion-panel-title>
        <div v-if="loading" class="d-flex justify-content-center">
            <v-progress-circular :size="50" color="primary-lighten-2" indeterminate></v-progress-circular>
        </div>
        <v-expansion-panel-text v-if="!loading">
            <assign-modal
                ref="sendForApprovalModal"
                class="mb-3"
                :archiveId="process.archiveId"
                :roleNames="approvalRoles"
                :showDate="false"
                :showRoles="true"
                :btnTitle="$t('sessionAgenda.buttons.sendForStandpoints')"
                :dialogTitle="$t('common.send')"
                @assign="sendForStandings"
            ></assign-modal>
            <ConfirmDialog
                :activatorButtonText="'Върни за корекции'"
                activatorButtonCssClass="ms-2"
                :commentInputEnabled="true"
                :confirmButtonText="$t('common.yes')"
                :cancelButtonText="$t('common.cancel')"
                :confirmationText="''"
                @confirm="returnForCorrections"
            ></ConfirmDialog>
        </v-expansion-panel-text>
    </v-expansion-panel>
</template>

<script lang="ts">
import { IProcess } from '@/interfaces/process';
import { defineComponent, PropType, ref } from 'vue';
import { ProcessStep } from '@/enums/process';
import { RoleNames } from '@/enums/roles';
import { IDropdownOption } from '@/interfaces/dropdown';
import AssignModal from '@/components/films/assign.modal.vue';
import { AssignModel } from '@/models/task';
// import sessionAgendaService from '@/services/sessionAgenda.service';
// import { ISessionAgendaItem, ISessionAgendaItemStandpoint } from '@/interfaces/commission';
import eDocsCollectingService from '@/services/eDocsCollecting.service';
import { CommissionReportSubmitModel } from '@/models/commission';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';

export default defineComponent({
    name: 'CommissionDatePanel',
    components: {
        AssignModal,
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
        const epkSessions = ref<IDropdownOption[]>([]);
        const readonly = ref(true);
        readonly.value = props.process.activeProcessStepTypeId !== ProcessStep.CommissionReviewDate;

        return {
            epkSessions,
            processStep: ProcessStep,
            readonly,
        };
    },
    data() {
        return {
            approvalRoles: [RoleNames.GroupV4],
            loading: false,
        };
    },
    methods: {
        sendForStandings(assign: AssignModel) {
            const data = new CommissionReportSubmitModel({
                assignToUserId: assign.assignToUserId,
                assignToRoleId: assign.assignToRoleId,
                processId: this.process.id,
            });
            eDocsCollectingService.sendForStandings(data).then(() => window.location.reload());
        },
        returnForCorrections(comment: string) {
            eDocsCollectingService.returnReport(this.process.id!, comment).then(() => window.location.reload());
        },
    },
});
</script>

<style scoped></style>
