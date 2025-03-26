<template>
    <div v-if="loading" class="d-flex justify-content-center">
        <v-progress-circular :size="50" color="green-lighten-2" indeterminate></v-progress-circular>
    </div>

    <div v-if="!loading">
        <Form @submit="onSubmit" ref="reportForm">
            <v-row>
                <v-col class="col-12 col-lg-3">
                    <TextField
                        :label="$t('epkReport.createdOn')"
                        :modelValue="formatDate(model.createdOn)"
                        :readonly="true"
                    />
                </v-col>
                <v-col class="col-12 col-lg-3">
                    <TextField :label="$t('epkReport.number')" v-model="model.number" :readonly="true" />
                </v-col>
                <v-col class="col-12 col-lg-6">
                    <TextField
                        :label="$t('epkReport.createdBy')"
                        v-model="model.createdByDisplayName"
                        :readonly="true"
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col>
                    <TextField
                        :label="$t('epkReport.about')"
                        v-model="model.title"
                        :readonly="true"
                        validation="required"
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col>
                    <TextAreaField
                        :label="$t('epkReport.content')"
                        v-model="model.content"
                        :readonly="readonly"
                        validation="required"
                    />
                </v-col>
            </v-row>
            <v-row v-if="!readonly && fileUploadEnabled">
                <v-col>
                    <FileUpload
                        ref="fileUploader"
                        :multipleFiles="true"
                        :label="$t('epkReport.fileUpload')"
                        icon="mdi-paperclip"
                        @change="fileChanged"
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col>
                    <v-list v-if="modelFiles && modelFiles.length > 0" density="compact">
                        <v-list-subheader>{{ $t('epkReport.files') }}</v-list-subheader>
                        <v-list-item
                            density="compact"
                            v-for="item in modelFiles"
                            :key="item.id"
                            :value="item.id"
                            :title="item.sourceName"
                        >
                            <template #append>
                                <v-btn icon flat color="transparent" @click="downloadFile(item.id, item.sourceName)">
                                    <v-icon>mdi-download</v-icon>
                                    <v-tooltip activator="parent" location="bottom">
                                        {{ t('common.downloadTooltip') }}
                                    </v-tooltip>
                                </v-btn>
                                <ConfirmDialog
                                    v-if="!readonly"
                                    :confirmationText="
                                        $t('epkReport.buttons.deleteConfirmation', { title: item.sourceName })
                                    "
                                    :confirmButtonText="$t('common.yes')"
                                    :cancelButtonText="$t('common.cancel')"
                                    activatorButtonIcon="mdi-delete-outline"
                                    activatorButtonColor="transparent"
                                    activatorButtonVariant="flat"
                                    @confirm="deleteFile(item.id)"
                                />
                            </template>
                        </v-list-item>
                    </v-list>
                </v-col>
            </v-row>
            <v-row>
                <v-col class="d-grid gap-2 d-md-flex justify-content-center">
                    <v-btn v-if="!readonly" color="green-darken-1" class="me-md-2" type="submit"
                        >{{ $t('common.save') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('common.saveTooltip') }}
                        </v-tooltip>
                    </v-btn>
                    <assign-modal
                        v-if="!readonly && sendEnabled && hasData"
                        ref="sendForApprovalModal"
                        class="mb-3"
                        :archiveId="processData.archiveId"
                        :roleNames="approvalRoles"
                        :showDate="false"
                        :showRoles="true"
                        :showUsers="assignToUsers"
                        :btnTitle="$t('docsCreateProc.sendToCheck')"
                        :dialogTitle="$t('docsCreateProc.sendToCheck')"
                        @assign="send"
                    ></assign-modal>
                    <!-- <v-btn v-if="printEnabled" color="cyan-darken-1" @click="print">{{ $t('common.print') }}</v-btn> -->
                </v-col>
            </v-row>
        </Form>
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
    </div>
</template>

<script lang="ts">
import { computed, defineComponent, ref, PropType, inject, Ref } from 'vue';
import { useStore } from '@/store/app';
import commissionReportService from '@/services/commissionReport.service';
import eDocsCollectingService from '@/services/eDocsCollecting.service';
import processRawInventoriesProcessService from '@/services/processRawInventoriesProcess.service';
import { formatBytesToMB, formatDate, formatDateTime } from '@/helpers/format.helper';
import { CommissionReportModel, CommissionReportSubmitModel } from '@/models/commission';
import { ICommissionReportFile } from '@/interfaces/commission';
import { IProcess } from '@/interfaces/process';
import { RoleNames } from '@/enums/roles';
import { AssignModel } from '@/models/task';
import { ProcessType } from '@/enums/process';

import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import FileUpload from '@/components/files/uploadFile.vue';
import { Form } from 'vee-validate';
import AssignModal from '@/components/films/assign.modal.vue';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';

import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { useI18n } from 'vue-i18n';
import commentService from '@/services/comments.service';
import { IComment } from '@/interfaces/comment';
import { getTotalUploadFileSizeForFiles } from '@/helpers/file.helper';

export default defineComponent({
    name: 'CommissionReport',
    emits: ['send'],
    components: {
        AssignModal,
        TextAreaField,
        TextField,
        FileUpload,
        Form,
        ConfirmDialog,
    },
    props: {
        processData: {
            type: Object as PropType<IProcess>,
        },
        readonly: {
            type: Boolean,
            default: false,
        },
        sendEnabled: {
            type: Boolean,
            default: true,
        },
        printEnabled: {
            type: Boolean,
            default: true,
        },
        fileUploadEnabled: {
            type: Boolean,
            default: true,
        },
        assignToUsers: {
            type: Boolean,
            default: true,
        },
    },
    setup(props, context) {
        const model = ref(
            new CommissionReportModel({ processId: props.processData?.id, title: props.processData?.processTypeTitle })
        );
        const modelFiles = ref<Array<ICommissionReportFile>>([]);
        const filesToUpload = ref<Array<File>>([]);
        const store = useStore();

        const loading = ref(true);
        const showAssignTo = ref(false);
        const approvalRoles = computed(() => [RoleNames.GroupV1]);
        const hasData = computed(() => model.value.id && model.value.id > 0);
        const comments = ref([] as IComment[]);

        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const showError = (error: unknown) => {
            const errorResult = error as ResponseResult;
            message.value = new Message({
                text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                display: true,
            });
        };

        const refresh = () => {
            commissionReportService
                .getByProcessId(props.processData?.id || 0)
                .then((data) => {
                    if (data) {
                        model.value = new CommissionReportModel(data);

                        getFiles(data.id!);
                    }
                })
                .catch((err) => console.log(err))
                .then(() => (loading.value = false));
        };

        refresh();

        const emitSend = () => {
            context.emit('send');
        };

        const reportForm = ref();
        const isValidData = () => {
            (reportForm.value! as typeof Form).validate();
            return true;
        };

        const fileChanged = (files: File[]) => {
            filesToUpload.value = [];
            if (files) {
                filesToUpload.value = files;
            }
        };

        const getFiles = (reportId: number) => {
            commissionReportService
                .getFiles(reportId)
                .then((fileData) => {
                    if (fileData) {
                        modelFiles.value = fileData;
                    }
                })
                .catch((err) => showError(err));
        };

        const uploadFiles = (reportId: number) => {
            if (filesToUpload.value && filesToUpload.value.length > 0) {
                commissionReportService
                    .uploadFiles(filesToUpload.value, reportId)
                    .then(() => {
                        getFiles(reportId);
                    })
                    .catch((error: unknown) => showError(error))
                    .then(() => (filesToUpload.value = []));
            }
        };

        const downloadFile = (id: number, name: string) => {
            const url = commissionReportService.reportFileDownloadUrl(id, model.value.id!, props.processData!.id!);
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', name);
            document.body.appendChild(link);
            link.click();
        };

        const deleteFile = (id: number) => {
            commissionReportService
                .deleteFile(id, model.value.id!)
                .then(() => {
                    getFiles(model.value.id!);
                })
                .catch((error: unknown) => showError(error));
        };

        return {
            t,
            approvalRoles,
            comments,
            commissionReportService,
            formatDate,
            formatDateTime,
            loading,
            model,
            modelFiles,
            filesToUpload,
            showAssignTo,
            refresh,
            emitSend,
            showError,
            hasData,
            reportForm,
            isValidData,
            fileChanged,
            uploadFiles,
            downloadFile,
            deleteFile,
            store,
            message,
        };
    },
    mounted() {
        this.loadComments();
    },
    methods: {
        onSubmit() {
            if (!this.isValidData()) {
                return false;
            }

            console.log('submit', this.model);
            this.loading = true;

            const totalFileSize = getTotalUploadFileSizeForFiles(this.filesToUpload);
            const totalInMB = formatBytesToMB(totalFileSize);

            if (totalInMB >= this.store.getters.maxPackageBFileSizeInMB) {
                this.message = new Message({
                    text: this.$t('error.fileSizeOverLimit', {
                        fileSize: totalInMB,
                        limit: this.store.getters.maxPackageBFileSizeInMB,
                    }),
                    display: true,
                });
                this.loading = false;
                return;
            }

            if (this.model.id) {
                //Edit
                console.log('Edit: ', this.model);
                this.loading = true;
                this.commissionReportService
                    .update(this.model)
                    .then(() => {
                        this.uploadFiles(this.model.id!);
                    })
                    .catch((error: unknown) => this.showError(error))
                    .then(() => (this.loading = false));
            } else {
                //Create
                console.log('Create: ', this.model);

                this.loading = true;
                this.commissionReportService
                    .create(this.model)
                    .then((entityId) => {
                        this.model.id = entityId;

                        this.uploadFiles(entityId);

                        this.refresh();
                        //TODO show message
                    })
                    .catch((error: unknown) => this.showError(error))
                    .then(() => (this.loading = false));
            }
        },
        print() {
            console.log('print');
        },
        send(assign: AssignModel) {
            console.log('send');
            this.loading = true;
            const data = new CommissionReportSubmitModel(this.model);
            data.assignToUserId = assign.assignToUserId;
            data.assignToRoleId = assign.assignToRoleId;

            if (
                this.processData?.processTypeId == ProcessType.ProcessRawFundWithRawInventory ||
                this.processData?.processTypeId == ProcessType.ProcessFundWithRawInventory
            ) {
                processRawInventoriesProcessService
                    .sendReport(data)
                    .then(() => {
                        this.emitSend();
                    })
                    .catch((error: unknown) => this.showError(error))
                    .then(() => (this.loading = false));
            } else if (this.processData?.processTypeId == ProcessType.DeductData) {
                this.$emit('send', assign);
            } else {
                eDocsCollectingService
                    .submitReport(data)
                    .then(() => {
                        this.emitSend();
                        //TODO Show message
                    })
                    .catch((error: unknown) => this.showError(error))
                    .then(() => (this.loading = false));
            }
        },
        loadComments() {
            commentService.getAll(this.processData!.id!, this.processData!.activeProcessStepTypeId!).then((data) => {
                this.comments = data;
            });
        },
    },
});
</script>

<style scoped></style>
