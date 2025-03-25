<template>
    <v-expansion-panel>
        <v-expansion-panel-title>{{ 'Прикачи печат на инвентарен опис' }}</v-expansion-panel-title>
        <v-expansion-panel-text>
            <v-row>
                <v-col>
                    <div v-if="loading" class="d-flex justify-content-center">
                        <v-progress-circular :size="50" color="green-lighten-2" indeterminate></v-progress-circular>
                    </div>
                    <div v-if="!loading && packageId" class="d-flex justify-content-start">
                        <PackageAddModal :packageId="packageId" :processId="process.id"></PackageAddModal>
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
import { IProcess } from '@/interfaces/process';
import packagesService from '@/services/packages.service';
import collectingService from '@/services/eDocsCollecting.service';
import PackageAddModal from '@/components/packageA/add.modal.vue';

export default defineComponent({
    components: {
        PackageAddModal,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const packageId = ref();
        const loading = ref(true);
        const processHasApplication = ref(false);
        const approvalRoles = computed(() => [RoleNames.GroupA]);

        const refreshPage = () => {
            window.location.reload();
        };
        collectingService
            .isExternalProcess(props.process.id!)
            .then((data) => (processHasApplication.value = data))
            .catch((err) => console.log(err));

        packagesService
            .getPackageAIdByProcess(props.process.id!)
            .then((data) => (packageId.value = data))
            .catch((err) => console.log(err))
            .finally(() => (loading.value = false));

        return {
            t,
            packageId,
            loading,
            processHasApplication,
            approvalRoles,
            refreshPage,
        };
    },
});
</script>

<style scoped></style>
