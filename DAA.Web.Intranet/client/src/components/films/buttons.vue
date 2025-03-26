<template>
    <v-row class="mt-3">
        <v-col class="d-flex justify-content-center">
            <v-btn @click="goEdit" v-if="canEdit" :disabled="isBusy">{{ t('common.edit') }}
                <v-tooltip
                    activator="parent"
                    location="bottom"
                >
                {{t('films.buttons.editTooltip')}}
                </v-tooltip>
            </v-btn>
            <v-divider vertical v-if="canEdit"></v-divider>
            <v-btn @click="goToStep(createPackagesStep, null)" v-if="canCreatePackages" :disabled="isBusy">{{
                t('films.buttons.createPackages')
            }}
                <v-tooltip
                    activator="parent"
                    location="bottom"
                >
                {{t('films.buttons.createPackagesTooltip')}}
                </v-tooltip>
            </v-btn>
            <v-divider vertical v-if="canCreatePackages"></v-divider>

            <assign-modal
                ref="sendForApprovalModal"
                v-if="canSendForApproval"
                class="mb-3"
                :archiveId="filmData.archiveId"
                :roleNames="approvalRoles"
                :btnTitle="t('films.buttons.sendForApproval')"
                :dialogTitle="t('films.buttons.sendForApproval')"
                :showDate="false"
                :showRoles="false"
                @assign="assign"
            ></assign-modal>
            <assign-modal
                ref="sendCardForApprovalModal"
                v-if="canSendCardForApproval"
                class="mb-3"
                :archiveId="filmData.archiveId"
                :roleNames="approvalRoles"
                :btnTitle="t('films.buttons.sendForApproval')"
                :dialogTitle="t('films.buttons.sendForApproval')"
                :showDate="false"
                :showRoles="false"
                @assign="assignCard"
            ></assign-modal>
            <assign-modal
                ref="sendAllForApprovalModal"
                v-if="canSendAllForApproval"
                class="mb-3"
                :archiveId="filmData.archiveId"
                :roleNames="approvalRoles"
                :btnTitle="t('films.buttons.sendForApproval')"
                :dialogTitle="t('films.buttons.sendForApproval')"
                :showDate="false"
                :showRoles="false"
                @assign="assignAll"
            ></assign-modal>

            <v-divider vertical v-if="canSendForApproval"></v-divider>
            <v-btn @click="goToStep(approveStep, null)" v-if="canApprove" :disabled="isBusy">{{ t('films.buttons.approve') }}</v-btn>
            <v-btn @click="goToStep(approveCardStep, null)" v-if="canApproveCard" :disabled="isBusy">{{ t('films.buttons.approve') }}</v-btn>
            <v-btn @click="goToStep(approveAllStep, null)" v-if="canApproveAll" :disabled="isBusy">{{ t('films.buttons.approve') }}</v-btn>
            <v-divider vertical v-if="canApprove"></v-divider>

            <v-btn @click="showModal(false, false)" v-if="canReturnForEdit" :disabled="isBusy">{{
                t('films.buttons.returnForEdit')
            }}</v-btn>
            <v-btn @click="showModal(true, false)" v-if="canReturnCardForEdit" :disabled="isBusy">{{
                t('films.buttons.returnForEdit')
            }}</v-btn>
            <v-btn @click="showModal(false, true)" v-if="canReturnAllForEdit" :disabled="isBusy">{{
                t('films.buttons.returnForEdit')
            }}</v-btn>
            <v-divider vertical v-if="canReturnForEdit"></v-divider>

            <v-btn @click="goToStep(rejectionStep, null)" v-if="canReject" :disabled="isBusy">{{ t('films.buttons.reject') }}</v-btn>
            <v-btn @click="goToStep(rejectionCardStep, null)" v-if="canRejectCard" :disabled="isBusy">{{ t('films.buttons.reject') }}</v-btn>
            <v-btn @click="goToStep(rejectionAllStep, null)" v-if="canRejectAll" :disabled="isBusy">{{ t('films.buttons.reject') }}</v-btn>
            <v-divider vertical v-if="canReject"></v-divider>
            <v-btn class="cancel" @click="goBack" :disabled="isBusy">{{ t('common.back') }}
                <v-tooltip
                    activator="parent"
                    location="bottom"
                >
                {{t('films.buttons.backTooltip')}}
                </v-tooltip>
            </v-btn>
        </v-col>
    </v-row>
    <comment-modal
        :visible="displayModal"
        :isForCard="isModalForCard"
        :isForAll="isModalForAll"
        @submitModal="submitCommentData"
        @submitCardModal="submitCardCommentData"
        @submitAllModal="submitAllCommentData"
        @closeModal="closeModal"
    />
</template>

<script lang="ts">
import { defineComponent, computed, PropType, ref, inject, Ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { Film } from '@/models/film'
import { useRouter } from 'vue-router'
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper'
import { ProcessType, ProcessStep } from '@/enums/process'
import filmService from '@/services/film.service'
import { IMessage } from '@/interfaces/notification'
import { Message } from '@/models/notification'
import { ResponseResult } from '@/models/responseResult'
import CommentModal from '@/components/films/comment.modal.vue'
import { RoleNames } from '@/enums/roles'
import { useStore } from '@/store/user'
import AssignModal from '@/components/films/assign.modal.vue'
import {FilmChangeStepModel} from "@/models/film"
import { AssignModel } from '@/models/task'

export default defineComponent({
    name: 'FilmButtons',
    components: {
        CommentModal,
        AssignModal,
    },
    emits: ['refresh'],
    props: {
        filmData: {
            type: Object as PropType<Film>,
            required: true,
        },
    },
    setup(props, context) {
        const { t } = useI18n()
        const model = computed(() => props.filmData)
        const message = inject('notificationMessage') as Ref<IMessage>
        const userStore = useStore()
        const router = useRouter()
        const isBusy = ref(false);

        const goEdit = () => {
            useRedirectWithId(router, 'EditFilm', model.value.systemIdentifier || '')
        }

        const goBack = () => {
            useRedirect(router, 'Films')
            //router.go(-1);
        }

        const hasGroupI = computed(() => userStore.getters.hasRole(RoleNames.GroupI))
        const hasGroupG = computed(() => userStore.getters.hasRole(RoleNames.GroupG))
        const approvalRoles = [RoleNames.GroupG];

        const createPackagesStep = ProcessStep.Film_CreatePackages
        const sendForApprovalStep = ProcessStep.Film_SendForApproval
        const approveStep = ProcessStep.Film_Approval
        const returnForEditStep = ProcessStep.Film_ReturnForEdit
        const rejectionStep = ProcessStep.Film_Rejection

        const sendCardForApprovalStep = ProcessStep.Film_SendCardForApproval
        const approveCardStep = ProcessStep.Film_CardApproval
        const returnCardForEditStep = ProcessStep.Film_ReturnCardForEdit
        const rejectionCardStep = ProcessStep.Film_CardRejection

        const sendAllForApprovalStep = ProcessStep.Film_SendAllForApproval
        const approveAllStep = ProcessStep.Film_AllApproval
        const returnAllForEditStep = ProcessStep.Film_ReturnAllForEdit
        const rejectionAllStep = ProcessStep.Film_AllRejection

        const displayModal = ref(false)
        const isModalForCard = ref(false)
        const isModalForAll = ref(false)

        const showModal = (forCard: boolean, forAll: boolean) => {
            isModalForCard.value = forCard == true
            isModalForAll.value = forAll == true
            displayModal.value = true
        }
        const closeModal = () => {
            displayModal.value = false
        }

        const comment = ref('')
        const submitCommentData = async (returnComment: string) => {
            comment.value = returnComment
            closeModal()
            await goToStep(returnForEditStep, null)
            comment.value = ''
        }

        const submitCardCommentData = async (returnComment: string) => {
            comment.value = returnComment
            closeModal()
            await goToStep(returnCardForEditStep, null)
            comment.value = ''
        }

        const submitAllCommentData = async (returnComment: string) => {
            comment.value = returnComment
            closeModal()
            await goToStep(returnAllForEditStep, null)
            comment.value = ''
        }

        const assign = (assignModel: AssignModel) => {
            goToStep(sendForApprovalStep, assignModel);
        }

        const assignCard = (assignModel: AssignModel) => {
            goToStep(sendCardForApprovalStep, assignModel);
        }

        const assignAll = (assignModel: AssignModel) => {
            goToStep(sendAllForApprovalStep, assignModel);
        }

        const goToStep = async (step: ProcessStep, assignModel: AssignModel | null) => {
            isBusy.value = true;
            
            try {
                const stepModel = new FilmChangeStepModel();
                stepModel.filmId = model.value.id || 0;
                stepModel.filmSystemIdentifier = model.value.systemIdentifier || '0';
                stepModel.stepType = step;
                stepModel.comment = comment.value;
                if(assignModel){
                    stepModel.assignedToUserId = assignModel.assignToUserId;
                    stepModel.assignedToRoleId = assignModel.assignToRoleId;
                    stepModel.endDate = assignModel.endDate;
                }

                const result = await filmService.changeStep(stepModel)
                isBusy.value = false;
                if (result.status == 200) {
                    if (step != ProcessStep.Film_Rejection) {
                        context.emit('refresh')
                    } else {
                        goBack()
                    }
                } else {
                    message.value = new Message({
                        text: result.response.data.message,
                        display: true,
                    })
                }
            } catch (error: unknown) {
                isBusy.value = false;
                const errorResult  = error as ResponseResult;
                message.value = new Message({
                  text:  errorResult.showMessage ? errorResult.message : t('error.basic'),
                  display: true,
                });
            }
        }
        
        const canEdit = computed(
            () =>
                !model.value.externalIdentifier &&
                hasGroupI.value == true &&
                ((model.value.currentProcessTypeId == ProcessType.FilmRegisterData &&
                    (model.value.currentStepTypeId == ProcessStep.Film_RegisterData ||
                        model.value.currentStepTypeId == ProcessStep.Film_ReturnForEdit)) ||
                    (model.value.currentProcessTypeId == ProcessType.FilmEditData &&
                        (model.value.currentStepTypeId == ProcessStep.Film_EditAllData ||
                            model.value.currentStepTypeId == ProcessStep.Film_ReturnAllForEdit)))
        )
        const canCreatePackages = computed(
            () =>
                !model.value.externalIdentifier &&
                hasGroupI.value == true &&
                model.value.currentProcessTypeId == ProcessType.FilmRegisterData &&
                (model.value.currentStepTypeId == ProcessStep.Film_RegisterData ||
                    model.value.currentStepTypeId == ProcessStep.Film_ReturnForEdit)
        )
        const canSendForApproval = computed(
            () =>
                !model.value.externalIdentifier &&
                hasGroupI.value == true &&
                model.value.currentProcessTypeId == ProcessType.FilmRegisterData &&
                model.value.currentStepTypeId == ProcessStep.Film_CreatePackages
        )
        const canApprove = computed(
            () =>
                !model.value.externalIdentifier &&
                hasGroupG.value == true &&
                model.value.currentProcessTypeId == ProcessType.FilmRegisterData &&
                model.value.currentStepTypeId == ProcessStep.Film_SendForApproval
        )
        const canReturnForEdit = computed(
            () =>
                !model.value.externalIdentifier &&
                hasGroupG.value == true &&
                model.value.currentProcessTypeId == ProcessType.FilmRegisterData &&
                model.value.currentStepTypeId == ProcessStep.Film_SendForApproval
        )
        const canReject = computed(
            () =>
                !model.value.externalIdentifier &&
                (hasGroupI.value == true || hasGroupG.value == true) &&
                model.value.currentProcessTypeId == ProcessType.FilmRegisterData /*&&
                model.value.currentStepTypeId == ProcessStep.Film_SendForApproval*/
        )

        const canSendCardForApproval = computed(
            () =>
                !model.value.externalIdentifier &&
                hasGroupI.value == true &&
                model.value.currentProcessTypeId == ProcessType.FilmRegisterCard &&
                (model.value.currentStepTypeId == ProcessStep.Film_RegisterCardData ||
                    model.value.currentStepTypeId == ProcessStep.Film_ReturnCardForEdit)
        )
        const canApproveCard = computed(
            () =>
                !model.value.externalIdentifier &&
                hasGroupG.value == true &&
                model.value.currentProcessTypeId == ProcessType.FilmRegisterCard &&
                model.value.currentStepTypeId == ProcessStep.Film_SendCardForApproval
        )
        const canReturnCardForEdit = computed(
            () =>
                !model.value.externalIdentifier &&
                hasGroupG.value == true &&
                model.value.currentProcessTypeId == ProcessType.FilmRegisterCard &&
                model.value.currentStepTypeId == ProcessStep.Film_SendCardForApproval
        )
        const canRejectCard = computed(
            () =>
                !model.value.externalIdentifier &&
                (hasGroupI.value == true || hasGroupG.value == true) &&
                model.value.currentProcessTypeId == ProcessType.FilmRegisterCard /*&&
                model.value.currentStepTypeId == ProcessStep.Film_SendCardForApproval*/
        )

        const canSendAllForApproval = computed(
            () =>
                !model.value.externalIdentifier &&
                hasGroupI.value == true &&
                model.value.currentProcessTypeId == ProcessType.FilmEditData &&
                (model.value.currentStepTypeId == ProcessStep.Film_EditAllData ||
                    model.value.currentStepTypeId == ProcessStep.Film_ReturnAllForEdit)
        )
        const canApproveAll = computed(
            () =>
                !model.value.externalIdentifier &&
                hasGroupG.value == true &&
                model.value.currentProcessTypeId == ProcessType.FilmEditData &&
                model.value.currentStepTypeId == ProcessStep.Film_SendAllForApproval
        )
        const canReturnAllForEdit = computed(
            () =>
                !model.value.externalIdentifier &&
                hasGroupG.value == true &&
                model.value.currentProcessTypeId == ProcessType.FilmEditData &&
                model.value.currentStepTypeId == ProcessStep.Film_SendAllForApproval
        )
        const canRejectAll = computed(
            () =>
                !model.value.externalIdentifier &&
                (hasGroupI.value == true || hasGroupG.value == true) &&
                model.value.currentProcessTypeId == ProcessType.FilmEditData /*&&
                model.value.currentStepTypeId == ProcessStep.Film_SendAllForApproval*/
        )

        return {
            t,
            model,
            goEdit,
            goBack,
            createPackagesStep,
            sendForApprovalStep,
            approveStep,
            returnForEditStep,
            rejectionStep,
            goToStep,
            assign,
            assignCard,
            assignAll,
            approvalRoles,
            canEdit,
            canCreatePackages,
            canSendForApproval,
            canApprove,
            canReturnForEdit,
            canReject,
            displayModal,
            showModal,
            closeModal,
            submitCommentData,
            sendCardForApprovalStep,
            approveCardStep,
            returnCardForEditStep,
            rejectionCardStep,
            canSendCardForApproval,
            canApproveCard,
            canReturnCardForEdit,
            canRejectCard,
            isModalForCard,
            submitCardCommentData,
            sendAllForApprovalStep,
            approveAllStep,
            returnAllForEditStep,
            rejectionAllStep,
            canSendAllForApproval,
            canApproveAll,
            canReturnAllForEdit,
            canRejectAll,
            submitAllCommentData,
            isModalForAll,
            isBusy,
        }
    },
})
</script>
