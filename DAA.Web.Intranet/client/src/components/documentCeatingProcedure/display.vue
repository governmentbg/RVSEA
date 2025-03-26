<template>
    <div>
        <v-expansion-panels v-model="panel" multiple>
            <!--STEP 1 изпращане на метаданни за проверка-->
            <v-expansion-panel v-if="displayModel.procedureStepTypeId == 20 || displayModel.procedureStepTypeId == 26">
                <v-expansion-panel-title>{{ t('docsCreateProc.step1') }}</v-expansion-panel-title>
                <v-expansion-panel-text>
                    <v-row align="center" justify="start">
                        <v-col cols="auto">
                            <assign-modal
                                ref="sendForApprovalModal"
                                class="mb-3"
                                :archiveId="displayModel.archiveId!"
                                :roleNames="approvalRoles"
                                :showDate="false"
                                :showRoles="true"
                                :btnTitle="t('docsCreateProc.sendToCheck')"
                                :dialogTitle="t('docsCreateProc.sendToCheck')"
                                @assign="nextStep"
                            ></assign-modal>
                        </v-col>
                        <v-col cols="auto">
                            <v-btn @click="goToEditDocument"
                                >{{ t('common.edit') }}
                                <v-tooltip activator="parent" location="bottom">
                                    {{ t('documents.buttons.editTooltip') }}
                                </v-tooltip>
                            </v-btn></v-col
                        >
                    </v-row>
                </v-expansion-panel-text>
            </v-expansion-panel>
            <!--STEP 1.5 Върнато за редакция на метаданни-->
            <v-expansion-panel v-if="displayModel.procedureStepTypeId == 22 || displayModel.procedureStepTypeId == 27">
                <v-expansion-panel-title>{{ t('docsCreateProc.stepReturned') }}</v-expansion-panel-title>
                <v-expansion-panel-text>
                    <v-row align="center" justify="start">
                        <v-col cols="auto">
                            <assign-modal
                                ref="sendForApprovalModal"
                                class="mb-3"
                                :archiveId="displayModel.archiveId!"
                                :roleNames="approvalRoles"
                                :showDate="false"
                                :showRoles="true"
                                :btnTitle="t('docsCreateProc.sendToCheck')"
                                :dialogTitle="t('docsCreateProc.sendToCheck')"
                                @assign="nextStep"
                            ></assign-modal>
                        </v-col>
                        <v-col cols="auto">
                            <v-btn @click="goToEditDocument"
                                >{{ t('common.edit') }}
                                <v-tooltip activator="parent" location="bottom">
                                    {{ t('documents.buttons.editTooltip') }}
                                </v-tooltip>
                            </v-btn></v-col
                        >
                    </v-row>
                </v-expansion-panel-text>
            </v-expansion-panel>
            <!--STEP 2 преглед на метаданните и избор на скан-->
            <v-expansion-panel v-if="displayModel.procedureStepTypeId == 21 || displayModel.procedureStepTypeId == 25">
                <v-expansion-panel-title v-if="displayModel.procedureStepTypeId == 21 || displayModel.procedureStepTypeId == 25"
                    >{{ t('docsCreateProc.step2') }}
                </v-expansion-panel-title>
                <v-expansion-panel-text>
                    <Comments
                        :ProcessId="displayModel.id!"
                        :ProcessStepId="displayModel.procedureStepTypeId"
                        :comentTypeProp="t('docsCreateProc.comment')"
                        v-model:showModal="show"
                    >
                        <template v-slot:buttons>
                            <v-row class="mb-3">
                                <v-col class="d-inline-flex gap-2 justify-content-start">
                                    <ConfirmDialog
                                        v-if="displayModel.procedureStepTypeId != 25"
                                        :activatorButtonText="t('docsCreateProc.agree')"
                                        :confirmationText="t('docsCreateProc.agreeTooltip')"
                                        :confirmButtonText="t('common.yes')"
                                        :cancelButtonText="t('common.cancel')"
                                        @confirm="nextStep"
                                        >{{ t('docsCreateProc.agree') }}</ConfirmDialog
                                    >
                                    <v-btn @click="show = true"
                                        >{{ t('docsCreateProc.returnEdit') }}
                                        <v-tooltip activator="parent" location="bottom">
                                            {{ t('docsCreateProc.returnEditTooltip') }}
                                        </v-tooltip>
                                    </v-btn>
                                    <assign-modal
                                        ref="sendForApprovalModal"
                                        :archiveId="displayModel.archiveId!"
                                        :roleNames="approvalRoles"
                                        :showDate="false"
                                        :showRoles="true"
                                        :btnTitle="t('docsCreateProc.asign')"
                                        :dialogTitle="t('docsCreateProc.asign')"
                                        @assign="nextStep"
                                    ></assign-modal>
                                </v-col>
                            </v-row>
                        </template>
                        <template v-slot:secondButton>
                            <v-row class="mb-3">
                                <v-col class="d-inline-flex gap-2 justify-content-start">
                                    <v-btn @click="saveChanges"
                                        >{{ t('common.save') }}
                                        <v-tooltip activator="parent" location="bottom">
                                            {{ t('common.saveTooltip') }}
                                        </v-tooltip>
                                    </v-btn>
                                    <v-btn v-if="displayModel.procedureStepTypeId != 25" @click="nextStep"
                                        >{{ t('docsCreateProc.agree') }}
                                        <v-tooltip activator="parent" location="bottom">
                                            {{ t('docsCreateProc.agreeTooltip') }}
                                        </v-tooltip>
                                    </v-btn>
                                    <v-btn @click="previousStep"
                                        >{{ t('docsCreateProc.returnEdit') }}
                                        <v-tooltip activator="parent" location="bottom">
                                            {{ t('docsCreateProc.returnEditTooltip') }}
                                        </v-tooltip>
                                    </v-btn>
                                </v-col>
                            </v-row>
                        </template>
                    </Comments>
                </v-expansion-panel-text>
            </v-expansion-panel>
            <!-- СТЕП 3 прикачване на файлове -->
            <v-expansion-panel
                v-if="
                    displayModel.procedureStepTypeId == 23 ||
                    displayModel.procedureStepTypeId == 28 ||
                    displayModel.procedureStepTypeId == 29 ||
                    displayModel.procedureStepTypeId == 31
                "
            >
                <v-expansion-panel-title>{{ t('docsCreateProc.step4') }}</v-expansion-panel-title>
                <v-expansion-panel-text>
                    <label>{{ t('docsCreateProc.masterFiles') }}</label>
                    <v-row>
                        <v-col cols="12">
                            <UploadFile
                                class="mt-2"
                                ref="masterFileUploader"
                                :multipleFiles="false"
                                packageType="B"
                                @change="masterFilesChanged"
                            />
                        </v-col>
                        <v-col cols="12">
                            <Switch
                                v-model="skipMasterValidation"
                                :label="t('docsCreateProc.skipMasterValidation')"
                                :large="false"
                                :showLabel="true"
                            />
                        </v-col>
                    </v-row>

                    <v-row v-for="item in masterFiles" :key="item.id">
                        <v-col class="col-12">
                            <label>{{ t('docsCreateProc.derivativesFiles') }} {{ item.name }}</label>
                            <v-row>
                                <v-col cols="12">
                                    <UploadFile
                                        class="mt-2"
                                        :multipleFiles="true"
                                        packageType="B"
                                        @change="derivativesFilesChanged"
                                    />
                                </v-col>
                                <v-col cols="12">
                                    <Switch
                                        v-model="skipDerivativeValidation"
                                        :label="t('docsCreateProc.skipDerivativeValidation')"
                                        :large="false"
                                        :showLabel="true"
                                    />
                                </v-col>
                            </v-row>
                        </v-col>
                        <v-col>
                            <label>{{ t('docsCreateProc.demoFiles') }} {{ item.name }}</label>
                            <v-row>
                                <v-col cols="12">
                                    <UploadFile
                                        class="mt-2"
                                        ref="fileUploader"
                                        :multipleFiles="true"
                                        packageType="B"
                                        @change="filesChanged"
                                    />
                                </v-col>
                                <v-col cols="12">
                                    <Switch
                                        v-model="skipDemoValidation"
                                        :label="t('docsCreateProc.skipDemoValidation')"
                                        :large="false"
                                        :showLabel="true"
                                    />
                                </v-col>
                            </v-row>
                        </v-col>
                    </v-row>
                    <v-row class="mb-3">
                        <v-col class="d-inline-flex gap-2 justify-content-start">
                            <submit-btn v-if="canSaveChanges" @click="saveChanges"
                                >{{ t('common.save') }}
                                <v-tooltip activator="parent" location="bottom">
                                    {{ t('common.saveTooltip') }}
                                </v-tooltip>
                            </submit-btn>
                            <assign-modal
                                ref="sendForApprovalModal"
                                class="mb-3"
                                :archiveId="displayModel.archiveId!"
                                :roleNames="approvalRoles"
                                :showDate="false"
                                :showRoles="true"
                                :btnTitle="t('docsCreateProc.sendToCheck')"
                                :dialogTitle="t('docsCreateProc.sendToCheck')"
                                @assign="nextStep"
                            ></assign-modal>
                        </v-col>
                    </v-row>
                </v-expansion-panel-text>
            </v-expansion-panel>
            <!--СТЕП 4 контрол на качеството-->
            <v-expansion-panel v-if="displayModel.procedureStepTypeId === 24 || displayModel.procedureStepTypeId === 30">
                <v-expansion-panel-title v-if="displayModel.procedureStepTypeId === 24 || displayModel.procedureStepTypeId === 30"
                    >{{ t('docsCreateProc.step5') }}
                </v-expansion-panel-title>
                <v-expansion-panel-title v-else-if="displayModel.procedureStepTypeId === 28 || displayModel.procedureStepTypeId === 31"
                    >{{ t('docsCreateProc.comments') }}
                </v-expansion-panel-title>
                <v-expansion-panel-text>
                    <Comments
                        :ProcessId="displayModel.id!"
                        :ProcessStepId="displayModel.procedureStepTypeId"
                        :comentTypeProp="t('docsCreateProc.comment')"
                        v-model:showModal="show"
                    >
                        <template v-slot:buttons>
                            <v-row class="mb-3" v-if="isUserRelatedToActiveProcessStep">
                                <v-col class="d-inline-flex gap-2 justify-content-start">
                                    <v-btn @click="nextStep"
                                        >{{ t('docsCreateProc.agree') }}
                                        <v-tooltip activator="parent" location="bottom">
                                            {{ t('docsCreateProc.agreeTooltip') }}
                                        </v-tooltip>
                                    </v-btn>
                                    <v-btn @click="show = true"
                                        >{{ t('docsCreateProc.returnEdit') }}
                                        <v-tooltip activator="parent" location="bottom">
                                            {{ t('docsCreateProc.returnEditTooltip') }}
                                        </v-tooltip>
                                    </v-btn>
                                </v-col>
                            </v-row>
                        </template>
                        <template v-slot:secondButton >
                            <v-row class="mb-3" v-if="isUserRelatedToActiveProcessStep">
                                <v-col class="d-inline-flex gap-2 justify-content-start">
                                    <v-btn @click="nextStep"
                                        >{{ t('docsCreateProc.agree') }}
                                        <v-tooltip activator="parent" location="bottom">
                                            {{ t('docsCreateProc.agreeTooltip') }}
                                        </v-tooltip>
                                    </v-btn>
                                    <v-btn @click="previousStep"
                                        >{{ t('docsCreateProc.returnEdit') }}
                                        <v-tooltip activator="parent" location="bottom">
                                            {{ t('docsCreateProc.returnEditTooltip') }}
                                        </v-tooltip>
                                    </v-btn>
                                </v-col>
                            </v-row>
                        </template>
                    </Comments>
                </v-expansion-panel-text>
            </v-expansion-panel>
        </v-expansion-panels>
        <Loader :isLoading="isLoading" />
    </div>
</template>

<script lang="ts">
import { PropType, computed, ref, inject, Ref, defineComponent, onMounted } from 'vue';
import { ProcedureViewModel } from '../../models/documentCreateProc';
import { useI18n } from 'vue-i18n';
import DocumentProcedureService from '../../services/documentCreatingProcedure.service';
import processService from '@/services/process.service';
import { useRedirectWithId } from '@/helpers/router.helper';
import { useRouter } from 'vue-router';
import UploadFile from '../../components/files/uploadFile.vue';
import AssignModal from '@/components/films/assign.modal.vue';
import { RoleNames } from '@/enums/roles';
import { AssignModel } from '@/models/task';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import Comments from '@/components/comments/Index.vue';
import { ResponseResult } from '@/models/responseResult';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import Loader from '@/components/loader/loader.vue';
import Switch from '@/components/checkbox/switch.vue';
import { IProcess } from '@/interfaces/process';

export default defineComponent({
    name: 'DigObJProcesesPanel',
    components: {
        UploadFile,
        ConfirmDialog,
        Comments,
        Loader,
        Switch,
        AssignModal,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>,
        },
        hasExternalSource: {
            type: Boolean,
        },
        documentSystemIdentifier: {
            type: String,
        },
    },
    setup(props) {
        const panel = ref(['general', 'chronologicalScope', 'storage', 'digitalObject']);
        const { t } = useI18n();
        const isLoading = ref(false);
        const router = useRouter();
        const displayModel = ref<ProcedureViewModel>(new ProcedureViewModel());
        const files = ref([] as File[]);
        const masterFiles = ref([] as File[]);
        const derivativesFiles = ref([] as File[]);
        const message = inject('notificationMessage') as Ref<IMessage>;
        const approvalRoles = computed(() => getRolesForCurrentStep());
        const show = ref(false);
        const canSaveChanges = computed(() => masterFiles.value.length);
        const skipMasterValidation = ref(false);
        const skipDerivativeValidation = ref(false);
        const skipDemoValidation = ref(false);
        const isUserRelatedToActiveProcessStep = ref(false);

        const getProcedureData = async () => {
            try {
                displayModel.value = await DocumentProcedureService.get(props.documentSystemIdentifier as string);
                if(displayModel.value?.id && displayModel.value?.procedureStepId){
                    isUserRelatedToActiveProcessStep.value = await processService.getIsCurrentUserInProcessStep(
                            displayModel.value.id, displayModel.value.procedureStepId
                        );
                }                
            } catch (error: unknown) {
                console.error(error);
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const getRolesForCurrentStep = () => {
            switch (displayModel.value.procedureStepTypeId) {
                case 20:
                case 22:
                case 26:
                case 27:
                    return [RoleNames.GroupG];
                case 21:
                case 25:
                    return [RoleNames.GroupZ];
                case 23:
                case 28:
                case 29:
                case 31:
                    return [RoleNames.GroupJ];
                default:
                    break;
            }
        };

        const saveChanges = async () => {
            const model = new ProcedureViewModel();
            model.id = displayModel.value.id;
            model.completed = displayModel.value.completed;
            model.procedureStepTypeId = displayModel.value.procedureStepTypeId;
            model.documentId = displayModel.value.documentId;
            model.procedureType = displayModel.value.procedureType;
            model.documentSystemIdentifier = displayModel.value.documentSystemIdentifier;
            model.files = files.value;
            model.masterFiles = masterFiles.value;
            model.derivativesFiles = derivativesFiles.value;

            model.skipMasterValidation = skipMasterValidation.value;
            model.skipDerivativeValidation = skipDerivativeValidation.value;
            model.skipDemoValidation = skipDemoValidation.value;

            try {
                isLoading.value = true;
                await DocumentProcedureService.saveChanges(model);
                router.go(0);
            } catch (error: unknown) {
                isLoading.value = false;
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const nextStep = async (assignModel?: AssignModel) => {
            const model = new ProcedureViewModel();
            model.id = displayModel.value.id;
            model.completed = displayModel.value.completed;
            model.procedureStepTypeId = displayModel.value.procedureStepTypeId;
            model.documentId = displayModel.value.documentId;
            model.assignToUserId = assignModel?.assignToUserId;
            model.assignToRoleId = assignModel?.assignToRoleId;
            model.procedureType = displayModel.value.procedureType;
            model.documentSystemIdentifier = displayModel.value.documentSystemIdentifier;
            model.files = files.value;
            model.masterFiles = masterFiles.value;
            model.derivativesFiles = derivativesFiles.value;
            try {
                isLoading.value = true;
                await DocumentProcedureService.goNextStep(model);
                router.go(0);
            } catch (error: unknown) {
                isLoading.value = false;
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const goToEditDocument = () => {
            if (props.hasExternalSource) {
                alert(t('docsCreateProc.isdaDock'));
            } else {
                useRedirectWithId(router, 'EditDocument', props.documentSystemIdentifier!);
            }
        };

        const previousStep = async () => {
            const model = new ProcedureViewModel();
            model.id = displayModel.value.id;
            model.completed = displayModel.value.completed;
            model.procedureStepTypeId = displayModel.value.procedureStepTypeId;
            model.documentId = displayModel.value.documentId;
            model.procedureType = displayModel.value.procedureType;
            model.documentSystemIdentifier = displayModel.value.documentSystemIdentifier;
            model.files = files.value;
            model.masterFiles = masterFiles.value;
            try {
                isLoading.value = true;
                await DocumentProcedureService.goPreviousStep(model);
                router.go(0);
            } catch (error: unknown) {
                isLoading.value = false;
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };
        //Производни файлове
        const derivativesFilesChanged = (model: File[]) => {
            derivativesFiles.value = model;
        };
        //Мастър файлове
        const masterFilesChanged = (model: File[]) => {
            masterFiles.value = model;
        };
        //Демо файлове
        const filesChanged = (model: File[]) => {
            files.value = model;
        };

        onMounted(async () => {
            getProcedureData();
        });

        return {
            t,
            panel,
            isLoading,
            displayModel,
            files,
            masterFiles,
            derivativesFiles,
            approvalRoles,
            show,
            canSaveChanges,
            getRolesForCurrentStep,
            saveChanges,
            nextStep,
            goToEditDocument,
            previousStep,
            derivativesFilesChanged,
            masterFilesChanged,
            filesChanged,
            skipMasterValidation,
            skipDerivativeValidation,
            skipDemoValidation,
            isUserRelatedToActiveProcessStep,
        };
    },
});
</script>

<style lang="scss" scoped>
.my-custom-dialog {
    align-self: flex-end;
}

@import '@/assets/styles/dialog.scss';

.d-flex::before,
.d-flex,
.d-flex::after {
    flex-wrap: wrap;
    justify-content: space-between !important;
}
</style>
