<template>
    <v-row align="end">
        <v-col class="d-flex justify-content-center" style="gap: 20px;">
            <confirm-dialog 
                v-if="showCompleteBtn"
                :confirmationText="t('processes.buttons.completeConfirmation', {title: process.processTypeTitle})"
                :activatorButtonText="t('processes.buttons.complete')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnCompleteProcessClickHandler"
            />
            <confirm-dialog 
                v-if="showUndoChangesBtn"
                :confirmationText="t('processes.buttons.undoChangesConfirmation')"
                :activatorButtonText="t('processes.buttons.undoChanges')"
                :confirmButtonText="t('common.yes')"
                :cancelButtonText="t('common.cancel')"
                @confirm="btnUndoChangesClickHandler"
            />
        </v-col>
    </v-row>
</template>
<script lang="ts">
import { computed, defineComponent, inject, PropType, Ref } from 'vue';
import { useI18n } from 'vue-i18n';

import { RoleNames } from '@/enums/roles';
import { ResponseResult } from '@/models/responseResult';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ProcessStep, ProcessType } from '@/enums/process';
import { IProcess } from '@/interfaces/process';
import authorization from '@/helpers/authorization.helper';
import editDataProcessService from '@/services/editDataProcess.service';

import ConfirmDialog from '@/components/confirm/confirmDialog.vue';

export default defineComponent({
    name: "EditDataProcessActions",
    components: {
        ConfirmDialog,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>
        },
    },
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        
        //TODO Fix check for active step
        const showCompleteBtn = computed(() => 
            props.process 
            && authorization.hasRole(RoleNames.GroupB1)
            && props.process.processTypeId === ProcessType.EditData);
        const showUndoChangesBtn = computed(() => 
            props.process 
            && authorization.hasRole(RoleNames.GroupB1)
            && props.process.processTypeId === ProcessType.EditData
            && props.process.activeProcessStepTypeId === ProcessStep.EditData_EditData);
        
        const btnCompleteProcessClickHandler = async () => {
            try {
                await editDataProcessService.completeProcess(props.process!.id!);

                context.emit('complete');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnUndoChangesClickHandler = async () => {
            try {
                await editDataProcessService.undoProcessChanges(props.process!.id!);

                context.emit('undochanges');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        return {
            t,
            showCompleteBtn,
            showUndoChangesBtn,
            btnUndoChangesClickHandler,
            btnCompleteProcessClickHandler,
        }
    },
})
</script>

<style lang="scss" scoped>
.assign-modal button,
.confirm-dialog button {
    min-width: 150px;
}
</style>
