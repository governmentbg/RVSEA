<template>
    <v-expansion-panel :value="panelValue">
        <v-expansion-panel-title>{{
            process.activeProcessStepTypeId === ProcessStep.AcquisitionContract && processHasApplication
                ? $t('processes.steps.sendForSignature')
                : $t('processes.steps.addPackageDocuments')
        }}</v-expansion-panel-title>

        <v-expansion-panel-text>
            <v-row>
                <v-col>
                    <div v-if="loading" class="d-flex justify-content-center">
                        <v-progress-circular :size="50" color="green-lighten-2" indeterminate></v-progress-circular>
                    </div>
                    <div v-if="!loading && packageId" class="d-flex gap-2 justify-content-start">
                        <!-- <PackageAddModal
                            :packageId="packageId"
                            :processId="process.id"
                            @created="moveToNextStep"
                        ></PackageAddModal> -->
                        <PackageAddModal :packageId="packageId" :processId="process.id"></PackageAddModal>
                        <SignatureRequestDialog
                            v-if="
                                processHasApplication &&
                                process.activeProcessStepTypeId === ProcessStep.AcquisitionContract
                            "
                            :processId="process.id"
                            :packageId="packageId"
                            @send="refreshPage"
                        />
                        <!-- <assign-modal
							ref="sendForRegistrationModal"
							class="mb-3"
							:archiveId="process.archiveId"
							:roleNames="approvalRoles"
							:showDate="false"
							:showRoles="true"
							:btnTitle="'Насочи към регистратор'"
							:dialogTitle="'Насочи към регистратор'"
							@assign="onAccept"
						></assign-modal> -->
                    </div>
                </v-col>
            </v-row>
        </v-expansion-panel-text>
    </v-expansion-panel>
</template>

<script lang="ts">
import { computed, defineComponent, PropType, ref } from 'vue';
import { useI18n } from 'vue-i18n';

import { RoleNames } from '@/enums/roles';
//import { AssignModel } from '@/models/task';
import { ProcessStep } from '@/enums/process';
import { IProcess, IProcessStep } from '@/interfaces/process';
import packagesService from '@/services/packages.service';
import collectingService from '@/services/eDocsCollecting.service';

import PackageAddModal from '@/components/packageA/add.modal.vue';
//import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import SignatureRequestDialog from '@/components/eDocsCollection/signatureRequestDialog.vue';
//import AssignModal from '@/components/films/assign.modal.vue';

export default defineComponent({
    components: {
        PackageAddModal,
        //ConfirmDialog,
        SignatureRequestDialog,
        //AssignModal,
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

        const packageId = ref();
        const loading = ref(true);
        const processHasApplication = ref(false);
        const approvalRoles = computed(() => [RoleNames.GroupA]);
        const nexStep = ref({ processId: props.process.id } as IProcessStep);

        // const onAccept = (model: AssignModel) => {
        // 	nexStep.value.assignedToUserId = model.assignToUserId;
        // 	nexStep.value.assignedToRoleId = model.assignToRoleId;
        // 	moveToNextStep();
        // }
        const refreshPage = () => {
            window.location.reload();
        };
        const moveToNextStep = () => {
            loading.value = true;

            collectingService
                .sendForRegistration(nexStep.value)
                .then(() => refreshPage())
                .catch((err) => console.log(err));
        };

        collectingService
            .isExternalProcess(props.process.id!)
            .then((data) => {
                processHasApplication.value = data;
            })
            .catch((err) => console.log(err));

        packagesService
            .getPackageAIdByProcess(props.process.id!)
            .then((data) => (packageId.value = data))
            .catch((err) => console.log(err))
            .finally(() => (loading.value = false));

        return {
            t,
            ProcessStep,
            packageId,
            loading,
            processHasApplication,
            approvalRoles,
            //onAccept,
            moveToNextStep,
            refreshPage,
        };
    },
});
</script>

<style scoped></style>
