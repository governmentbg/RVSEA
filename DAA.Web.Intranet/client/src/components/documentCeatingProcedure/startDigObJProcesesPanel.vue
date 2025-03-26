<template>
    <v-row justify="center">
        <v-dialog transition="dialog-bottom-transition" width="50%" v-model="dialog">
            <v-card width="50vh">
                <v-card-title class="text-h5 text-center">
                    {{ t('docsCreateProc.asign') }}
                </v-card-title>
                <v-card-text> </v-card-text>
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <AssignModal
                        ref="sendForApprovalModal"
                        :archiveId="archiveId"
                        :roleNames="[RoleNames.GroupZ]"
                        :showDate="false"
                        :showRoles="true"
                        :btnTitle="t('docsCreateProc.asign')"
                        :dialogTitle="t('docsCreateProc.asign')"
                        @assign="startImportDigObjProcess"
                    />
                    <v-btn class="cancel" color="green darken-1" text @click="dialog = false">
                        {{ t('common.cancel') }}
                    </v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </v-row>
</template>
<script lang="ts">
import { defineComponent, inject, Ref, ref } from 'vue';
import AssignModal from '@/components/films/assign.modal.vue';
import { Message } from '@/models/notification';
import { ProcessType } from '@/enums/process';
import { ResponseResult } from '@/models/responseResult';
import router from '@/router';
import { ProcedureCreateModel } from '@/models/documentCreateProc';
import DocumentProcedureService from '../../services/documentCreatingProcedure.service';
import { IMessage } from '@/interfaces/notification';
import { AssignModel } from '@/models/task';
import { useI18n } from 'vue-i18n';
import { RoleNames } from '@/enums/roles';
export default defineComponent({
    name: 'StartDigObJProcesesPanel',
    components: {
        AssignModal,
    },
    props: {
        archiveId: {
            type: Number,
        },
        hasExternalSource: {
            type: Boolean,
        },
        documentSystemIdentifier: {
            type: String,
        },
        showTemplate: {
            type: Boolean,
            default: false,
        },
    },

    setup(props) {
        const message = inject('notificationMessage') as Ref<IMessage>;
        const { t } = useI18n();
        const dialog = ref(false);

        const starNewtProces = (type: number) => {
            switch (type) {
                case ProcessType.ImportDigitalObject:
                    dialog.value = true;
                    break;
            }
        };

        const startImportDigObjProcess = async (assignModel?: AssignModel) => {
            const submitData = new ProcedureCreateModel();
            submitData.assignToUserId = assignModel!.assignToUserId;
            submitData.assignToRoleId = assignModel!.assignToRoleId;
            submitData.documentSys = props.documentSystemIdentifier;
            submitData.archiveId = props.archiveId;
            submitData.procedureType = ProcessType.ImportDigitalObject;
            try {
                const result = await DocumentProcedureService.startProcess(submitData);
                if (!result.success) {
                    message.value = new Message({
                        text: result.message,
                        display: true,
                    });
                } else {
                    router.go(0);
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        return { startImportDigObjProcess, dialog, starNewtProces, t, RoleNames };
    },
});
</script>
<style scoped>
:deep(.assign-modal button),
:deep(.confirm-dialog button) {
    min-width: 150px !important;
}
</style>
