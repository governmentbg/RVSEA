<template>
    <v-expansion-panel :value="panelValue">
        <v-expansion-panel-title>{{
            process.activeProcessStepTypeId !== processStep.CommissionOpinions
                ? $t('processes.panels.standpoints')
                : $t('processes.steps.addSessionAgendaStandpoint')
        }}</v-expansion-panel-title>
        <div v-if="loading" class="d-flex justify-content-center">
            <v-progress-circular :size="50" color="green-lighten-2" indeterminate></v-progress-circular>
        </div>
        <v-expansion-panel-text v-if="!loading">
            <StandpointComponent
                :process="process"
                :readOnly="readonly"
                @commit="refresh"
                ref="currentStandpoint"
            ></StandpointComponent>
            <StandpointsList
                :process="process"
                :readOnly="readonly"
                @editStandpoint="refresh"
                @validateCanEditStandpoint="refresh"
                ref="standPointList"
            >
            </StandpointsList>
        </v-expansion-panel-text>
    </v-expansion-panel>
</template>

<script lang="ts">
import { IProcess } from '@/interfaces/process';
import { computed, defineComponent, PropType, ref } from 'vue';
import { ProcessStep } from '@/enums/process';
import StandpointsList from '@/components/commission/sessionAgendaStandpoints.vue';
import { ISessionAgendaItem } from '@/interfaces/commission';
import sessionAgendaService from '@/services/sessionAgenda.service';
import StandpointComponent from '@/components/commission/sessionAgendaStandpoint.vue';

export default defineComponent({
    name: 'CommissionDatePanel',
    components: {
        StandpointComponent,
        StandpointsList,
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
        const sessionAgendaItem = ref<ISessionAgendaItem>();
        const readonly = computed(() => props.process.activeProcessStepTypeId !== ProcessStep.CommissionOpinions);
        const loading = ref(true);
        const standPointList = ref();
        const currentStandpoint = ref();

        // readonly.value =
        //     props.process.activeProcessStepId === ProcessStep.CommissionOpinions ||
        //     //���� ��� � ������� ������ ��� 3611 !!
        //     props.process.activeProcessStepTypeId === ProcessStep.ConfirmedProtocol;

        sessionAgendaService
            .displaySessionAgendaItemByProcess(props.process.id!)
            .then((item) => (sessionAgendaItem.value = item))
            .finally(() => (loading.value = false));

        return {
            loading,
            processStep: ProcessStep,
            readonly,
            sessionAgendaItem,
            standPointList,
            currentStandpoint,
        };
    },
    methods: {
        async refresh() {
            await this.standPointList.getStandpointData();
            await this.currentStandpoint.getSessionAgendaItemStandpointData();
            //window.location.reload();
        },
    },
});
</script>

<style scoped></style>
