<template>
    <v-expansion-panels v-model="panel" multiple>
        <v-expansion-panel v-if="process.activeProcessStepTypeId >= processStep.CommissionReport" value="report">
            <v-expansion-panel-title>{{ $t('funds.panels.report') }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <CommissionReportPanel
                    :readonly="
                        process.activeProcessStepTypeId !== processStep.CommissionReport &&
                        process.activeProcessStepTypeId !== processStep.CommissionReportEdit &&
                        process.activeProcessStepTypeId !== processStep.CommissionCorrections
                    "
                    :processData="process"
                    :sendEnabled="
                        process.activeProcessStepTypeId === processStep.CommissionReport ||
                        process.activeProcessStepTypeId === processStep.CommissionReportEdit
                    "
                    @send="refresh"
                ></CommissionReportPanel>
            </v-expansion-panel-text>
        </v-expansion-panel>
        <CommisionDatePanel
            panelValue="commisionDate"
            :process="process"
            v-if="process.activeProcessStepTypeId == processStep.CommissionReviewDate"
        ></CommisionDatePanel>
        <StandpointsPanel
            panelValue="standpointsPanel"
            :process="process"
            v-if="process.activeProcessStepTypeId >= processStep.CommissionOpinions"
        ></StandpointsPanel>
        <CommissionDecisionPanel
            panelValue="commissionDecisionPanel"
            :process="process"
            v-if="process.activeProcessStepTypeId >= processStep.CommissionDecision"
        ></CommissionDecisionPanel>
        <CommisionCorrectionsPanel
            panelValue="commisionCorrectionsPanel"
            :process="process"
            v-if="process.activeProcessStepTypeId == processStep.CommissionCorrections"
        ></CommisionCorrectionsPanel>
        <!-- <CommisionCorrectionsCheckPanel
			:process="process"
			v-if="process.activeProcessStepTypeId == processStep.CommissionCorrectionsCheck"
		></CommisionCorrectionsCheckPanel> -->
        <AcquisitionContractPanel
            panelValue="acquisitionContractPanel"
            :process="process"
            v-if="
                process.activeProcessStepTypeId == processStep.Affirmation ||
                process.activeProcessStepTypeId == processStep.AcquisitionContract
            "
        ></AcquisitionContractPanel>
        <SendForAffirmationPanel
            panelValue="sendForAffirmationPanel"
            :process="process"
            v-if="
                process.activeProcessStepTypeId == processStep.AcquisitionContract ||
                process.activeProcessStepTypeId == processStep.SignedDocuments
            "
            @sendForAffirmation="refresh"
        />
        <RegistrationPanel
            panelValue="registrationPanel"
            :process="process"
            v-if="
                process.activeProcessStepTypeId === processStep.Registration ||
                process.activeProcessStepTypeId === processStep.SendForRegistration
            "
        ></RegistrationPanel>
    </v-expansion-panels>
</template>

<script lang="ts">
import { IProcess } from '@/interfaces/process';
import { defineComponent, onMounted, PropType, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { ProcessStep } from '@/enums/process';
import CommissionReportPanel from '@/components/commission/report.vue';
import CommisionDatePanel from './commissionDatePanel.vue';
import StandpointsPanel from './commisionStandpointsPanel.vue';
import CommissionDecisionPanel from './commisionDecisionPanel.vue';
import AcquisitionContractPanel from './AcquisitionContractPanel.vue';
import RegistrationPanel from './registrationPanel.vue';
import CommisionCorrectionsPanel from './commisionCorrectionsPanel.vue';
import SendForAffirmationPanel from '@/components/eDocsCollection/sendForAffirmationPanel.vue';

export default defineComponent({
    name: 'EDocsCollectingPanels',
    components: {
        AcquisitionContractPanel,
        CommisionCorrectionsPanel,
        CommisionDatePanel,
        CommissionDecisionPanel,
        CommissionReportPanel,
        RegistrationPanel,
        StandpointsPanel,
        SendForAffirmationPanel,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const panel = ref();

        const refresh = () => {
            window.location.reload();
        };

        const expandPanels = (val: number) => {
            switch (val) {
                case ProcessStep.CommissionReport:
                case ProcessStep.CommissionReportEdit:
                    panel.value = 'report';
                    break;
                case ProcessStep.CommissionReviewDate:
                    panel.value = ['report', 'commisionDate'];
                    break;
                case ProcessStep.CommissionOpinions:
                    panel.value = ['report', 'standpointsPanel'];
                    break;
                case ProcessStep.ConfirmedProtocol:
                    panel.value = ['report', 'standpointsPanel', 'commissionDecisionPanel'];
                    break;
                case ProcessStep.CommissionCorrections:
                    panel.value = [
                        'report',
                        'standpointsPanel',
                        'commissionDecisionPanel',
                        'commisionCorrectionsPanel',
                    ];
                    break;
                case ProcessStep.Affirmation:
                    panel.value = ['report', 'standpointsPanel', 'commissionDecisionPanel', 'acquisitionContractPanel'];
                    break;
                case ProcessStep.AcquisitionContract:
                    panel.value = [
                        'report',
                        'standpointsPanel',
                        'commissionDecisionPanel',
                        'acquisitionContractPanel',
                        'sendForAffirmationPanel',
                    ];
                    break;
                case ProcessStep.SignedDocuments:
                    panel.value = [
                        'report',
                        'standpointsPanel',
                        'commissionDecisionPanel',
                        'acquisitionContractPanel',
                        'sendForAffirmationPanel',
                    ];
                    break;
                case ProcessStep.Registration:
                case ProcessStep.SendForRegistration:
                    panel.value = ['report', 'standpointsPanel', 'commissionDecisionPanel', 'registrationPanel'];
                    break;
            }
        };

        watch(
            () => props.process.activeProcessStepTypeId,
            (val) => {
                expandPanels(val as number);
            }
        );

        onMounted(() => {
            expandPanels(props.process.activeProcessStepTypeId!);
        });

        return {
            t,
            panel,
            processStep: ProcessStep,
            refresh,
        };
    },
});
</script>

<style scoped></style>
