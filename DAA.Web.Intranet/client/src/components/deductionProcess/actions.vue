<template>
    <v-row v-if="process" align="end">
        <v-col v-if="process.activeProcessStepTypeId == 32" class="d-grid gap-2 d-md-flex justify-content-center" style="gap: 20px;">
            <confirm-dialog
                :confirmationText="t('processes.buttons.undoChangesConfirmation')"
                :activatorButtonText="t('processes.buttons.undoChanges')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="undoDeductionChanges"
            />
        </v-col>
        <v-col
            v-if="userHasRole && process.activeProcessStepTypeId == 247"
            class="d-grid gap-2 d-md-flex justify-content-center"
        >
            <v-btn class="mx-2" @click="updateStep"
                >{{ t('epk.sendToComments') }}
                <v-tooltip activator="parent" location="bottom">
                    {{ t('epk.sendToCommentsTooltip') }}
                </v-tooltip>
            </v-btn></v-col
        >
        <v-col
            v-if="userHasRole && process.activeProcessStepTypeId == 34 && asgUser"
            class="d-grid gap-2 d-md-flex justify-content-center"
        >
            <v-btn class="mx-2" @click="updateStep"
                >{{ t('epk.sendToSession') }}
                <v-tooltip activator="parent" location="bottom">
                    {{ t('epk.sendToSessionTooltip') }}
                </v-tooltip>
            </v-btn></v-col
        >
    </v-row>
</template>
<script lang="ts">
import { computed, defineComponent, inject, PropType, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { IProcess } from '@/interfaces/process';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import { IMessage } from '@/interfaces/notification';
import { DeductionProcessViewModel } from '@/models/deductionProcess';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import deductionService from '@/services/deductionProcess.service';
import router from '@/router';
import { useStore } from '@/store/user';
import { RoleNames } from '@/enums/roles';
export default defineComponent({
    name: 'DeductionDataProcessActions',
    components: {
        ConfirmDialog,
    },
    props: {
        id: {
            type: String,
        },
        process: {
            type: Object as PropType<IProcess>,
        },
        businessObjectType: {
            type: String,
        },
    },

    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const deductProcessData = ref<DeductionProcessViewModel>();
        const userStore = useStore();
        const asgUser = computed(() => deductProcessData.value?.assignToUserId == userStore.getters.userId);
        const userHasRole = computed(() => userStore.getters.hasRole(RoleNames.GroupV1));

        const getDeductDataProcedureData = async () => {
            try {
                deductProcessData.value = await deductionService.getById(props.id!, props.businessObjectType);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const updateStep = async () => {
            try {
                if (
                    deductProcessData.value &&
                    (props?.process?.activeProcessStepTypeId == 247 || props?.process?.activeProcessStepTypeId == 34)
                ) {
                    await deductionService.updateStep(deductProcessData.value);
                    router.go(0);
                } else return;
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const undoChanges = () => {
            try {
                deductionService.undoChanges(deductProcessData.value!);
                router.go(0);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const undoDeductionChanges = () => {
            if (deductProcessData.value?.procedureStepId == 32) {
                undoChanges();
            }
        };

        getDeductDataProcedureData();

        return {
            userHasRole,
            asgUser,
            updateStep,
            t,
            undoDeductionChanges,
        };
    },
});
</script>
