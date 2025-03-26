<template>
    <v-list-group collapse-icon="" expand-icon="">
        <template v-slot:activator="{ props }">
            <v-list-item
                :class="[
                    item.statusCode === approvalStatus.Approved ? 'bg-light-green-lighten-5' : '',
                    item.statusCode === approvalStatus.Rejected ? 'bg-red-lighten-5' : '',
                ]"
            >
                <v-list-item-title class="wrap-text">{{ item.content }}</v-list-item-title>
                <v-list-item-subtitle>
                    {{ t('sessionAgenda.columns.createdBy') }} {{ item.createdByDisplayName }}
                </v-list-item-subtitle>
                <v-list-item-subtitle>
                    {{ t('sessionAgenda.columns.createdOn') }} {{ formatDateTime(item.createdOn) }}
                </v-list-item-subtitle>
                <v-list-item-subtitle v-if="item.updatedByDisplayName != null || item.updatedByDisplayName != undefined">
                    {{ t('sessionAgenda.columns.updatedBy') }} {{ item.updatedByDisplayName }}
                </v-list-item-subtitle>
                <v-list-item-subtitle v-if="item.updatedOn != null || item.updatedOn != undefined">
                    {{ t('sessionAgenda.columns.updatedOn') }} {{ formatDateTime(item.updatedOn) }}
                </v-list-item-subtitle>
                <template v-slot:append="{ isActive }">
                    <v-btn icon  color="transparent" variant="flat" v-if="isInTermForEditByUser" @click="btnReturnAsDraft">
                        <v-icon>mdi-pencil-outline</v-icon>
                        <v-tooltip
                            activator="parent"
                            location="bottom"
                        >
                        {{t('sessionAgenda.buttons.editSessionAgenda')}}
                        </v-tooltip>
                    </v-btn>
                    <v-btn icon v-bind="props" color="transparent" variant="flat" @click="btnShowCommentsClickHandler(!isActive)">
                        <v-icon>mdi-comment-text-multiple-outline</v-icon>
						<v-tooltip activator="parent" location="bottom">
                            {{ t('common.comment') + 'и' }}
                        </v-tooltip>
                    </v-btn>
                    <v-btn v-if="!readOnly && (!commentsData || commentsData.length <= 0)" 
                        icon
                        color="transparent" 
                        variant="flat"
                        @click="btnShowAddOrUpdateCommentClickHandler()"
                    >
                        <v-icon>mdi-comment-text-outline</v-icon>
                    </v-btn>
                    <v-btn
                        v-if="showStatusButtons"
                        icon
                        color="transparent" variant="flat"
                        @click="btnSetStandpointStatusClickHandler(approvalStatus.Approved)"
                    >
                        <v-icon>mdi-check</v-icon>
						<v-tooltip activator="parent" location="bottom">
                            {{ t('common.choose') }}
                        </v-tooltip>
                    </v-btn>
                    <v-btn
                        v-if="showStatusButtons"
                        icon
                        color="transparent" variant="flat"
                        @click="btnSetStandpointStatusClickHandler(approvalStatus.Rejected)"
                    >
                        <v-icon>mdi-close</v-icon>
						<v-tooltip activator="parent" location="bottom">
                            {{ t('common.close') }}
                        </v-tooltip>
                    </v-btn>
                </template>
            </v-list-item>
        </template>
        <v-list-item v-for="comm in commentsData" :key="comm.id">
            <v-list-item-title class="text-wrap">
                {{ comm.text }}
            </v-list-item-title>
            <v-list-item-subtitle>
                {{ t('sessionAgenda.columns.createdBy') }} {{ comm.createdByDisplayName }}
            </v-list-item-subtitle>
            <v-list-item-subtitle>
                {{ t('sessionAgenda.columns.createdOn') }} {{ formatDateTime(comm.createdOn) }}
            </v-list-item-subtitle>
            <v-list-item-subtitle v-if="comm.updatedByDisplayName != null || comm.updatedByDisplayName != undefined">
                {{ t('sessionAgenda.columns.updatedBy') }} {{ comm.updatedByDisplayName }}
            </v-list-item-subtitle>
            <v-list-item-subtitle v-if="comm.updatedOn != null || comm.updatedOn != undefined">
                {{ t('sessionAgenda.columns.updatedOn') }} {{ formatDateTime(comm.updatedOn) }}
            </v-list-item-subtitle>
            <template #append v-if="isAuthor(comm.createdBy) && !readOnly">
                <v-btn icon color="transparent" variant="flat" @click="btnShowDeleteCommentClickHandler(comm.id)">
                    <v-icon>mdi-delete-outline</v-icon>
					<v-tooltip activator="parent" location="bottom">
                        {{ t('common.delete') }}
                    </v-tooltip>
                </v-btn>
                <v-btn icon color="transparent" variant="flat" @click="btnShowAddOrUpdateCommentClickHandler(comm.id)">
                    <v-icon>mdi-pencil-outline</v-icon>
					<v-tooltip activator="parent" location="bottom">
                        {{ t('common.edit') }}
                    </v-tooltip>
                </v-btn>
            </template>
        </v-list-item>
    </v-list-group>
    <v-dialog v-model="showAddCommentDialog" persistent>
        <v-card width="50vh">
            <v-card-text>
                <textarea-field
                    :label="t('common.comment')"
                    v-model="commentText"
                    validation="required"
                />
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <dialog-btn @click="btnSubmitClickHandler">
                    {{ t('common.save') }}
                </dialog-btn>
                <cancel-btn class="cancel" color="secondary" @click="btnCancelClickHandler">
                    {{ t('common.cancel') }}
                </cancel-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
    <v-dialog v-model="showDeleteCommentDialog" persistent>
        <v-card>
            <v-card-text>
                {{ t('comments.buttons.deleteConfirmation') }}
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <dialog-btn @click="btnDeleteCommentClickHandler">
                    {{ t('common.delete') }}
                </dialog-btn>
                <cancel-btn text @click="btnCancelClickHandler">
                    {{ t('common.cancel') }}
                </cancel-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, PropType, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { formatDateTime } from '@/helpers/format.helper';
import authorization from '@/helpers/authorization.helper';

import { ApprovalStatus } from '@/enums/status';
import { ResponseResult } from '@/models/responseResult';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { ISessionAgendaItemStandpoint } from '@/interfaces/commission';
import { IComment } from '@/interfaces/comment';
import { CommentModel } from '@/models/comment';
import commentService from '@/services/comments.service';
import sessionAgendaService from '@/services/sessionAgenda.service';

import TextareaField from '@/components/field/textarea.field.vue';
import { isDateAtLeastNDaysFromStartDay } from '@/helpers/validate.helper';
import { useStore } from '@/store/user';
import { ProcessStep, ProcessType } from '@/enums/process';
import { IProcess } from '@/interfaces/process';

export default defineComponent({
    name: 'SessionAgendaStandpointItem',
    components: {
        TextareaField,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>,
        },
        processId: {
            type: Number,
        },
        item: {
            type: Object as PropType<ISessionAgendaItemStandpoint>,
        },
        showStatusButtons: {
            type: Boolean,
            default: false,
        },
        readOnly: {
            type: Boolean,
            default: false,
        },
    },
    emits: ['submitComment', 'editComment', 'deleteComment', 'setStatus', 'editStandpoint', 'validateCanEditStandpoint'],
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const approvalStatus = ApprovalStatus;

        const showAddCommentDialog = ref<boolean>(false);
        const showDeleteCommentDialog = ref<boolean>(false);
        const commentId = ref<number>();
        const commentText = ref<string>();

        const commentsData = ref<IComment[]>([]);

        const userStore = useStore();
        const currUserId =  userStore.getters.userId;
        const isInTermForEditByUser = ref<boolean>(false);

        const btnReturnAsDraft = async () => {
            if(props.item) {
                props.item!.isDraft = true;
                await sessionAgendaService.updateSessionAgendaItemStandpoint(props.item!);
            }
            context.emit("editStandpoint");
        }

        const validateSessionDateForEdit = async () => {
            try {

                isInTermForEditByUser.value = props.process!.activeProcessStepTypeId === ProcessStep.RefineData_AddSessionAgendaStandpoint
                                           || props.process!.activeProcessStepTypeId === ProcessStep.RefineData_SendToAddSessionAgendaStandpointComment
                                           || props.process!.activeProcessStepTypeId === ProcessStep.RefineData_AddSessionAgendaStandpointComment
                                           || props.process!.activeProcessStepTypeId === ProcessStep.EditFundData_AddSessionAgendaStandpoint
                                           || props.process!.activeProcessStepTypeId === ProcessStep.EditFundData_AddSessionAgendaStandpointComment
                                           || props.process!.activeProcessStepTypeId === ProcessStep.EditFundData_SendToAddSessionAgendaStandpointComment
                                           || props.process!.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpoint
                                           || props.process!.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpoint
                                           || props.process!.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_SendToAddSessionAgendaStandpointComment
                                           || props.process!.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_SendToAddSessionAgendaStandpointComment
                                           || props.process!.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_AddSessionAgendaStandpointComment
                                           || props.process!.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_AddSessionAgendaStandpointComment
                                           || props.process!.activeProcessStepTypeId === ProcessStep.ReconstructFundData_AddSessionAgendaStandpoint
                                           || props.process!.activeProcessStepTypeId === ProcessStep.ReconstructFundData_SendToAddSessionAgendaStandpointComment
                                           || props.process!.activeProcessStepTypeId === ProcessStep.ReconstructFundData_AddSessionAgendaStandpointComment
                                           || props.process!.activeProcessStepTypeId === ProcessStep.CommissionOpinions
                                           || props.process!.processTypeId === ProcessType.DeductData;

                const session = (await sessionAgendaService.displaySessionAgendaItemByProcess(props.processId!));
                const sDate = session == null ? null : session.sessionDate;

                if(sDate) {
                    const sDateStr = sDate.toString().split('-');
                    const sDateYear = Number(sDateStr[0]);
                    const sDateMonth = Number(sDateStr[1]);
                    const sDateDay = Number(sDateStr[2][0] + sDateStr[2][1]);
                    const today = new Date();

                    isInTermForEditByUser.value = isInTermForEditByUser.value && 
                                                  (props.item == null
                                                  || isDateAtLeastNDaysFromStartDay(today.getDate(), today.getMonth() + 1, today.getFullYear(), sDateDay, sDateMonth, sDateYear, 5)
                                                  && props.item.createdBy == currUserId);
                } else {
                    isInTermForEditByUser.value = isInTermForEditByUser.value && props.item != null && props.item.createdBy == currUserId;
                }
                context.emit('validateCanEditStandpoint');
            } catch(error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const isAuthor = (userId: string) => {
            return authorization.isCurrentUser(userId);
        };

        const getCommentsData = async () => {
            try {
                commentsData.value = await commentService.getCommentsByStandpoint(props.item!.id!);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnShowCommentsClickHandler = async (loadData: boolean) => {
            if (loadData) {
                await getCommentsData();
            }
        };

        const btnShowAddOrUpdateCommentClickHandler = async (id?: number) => {
            if (id) {
                const comment = await commentService.getComment(id);
                if (comment) {
                    commentId.value = comment.id;
                    commentText.value = comment.text;
                }
            }
            showAddCommentDialog.value = true;
        };

        const btnShowDeleteCommentClickHandler = (id: number) => {
            commentId.value = id;
            showDeleteCommentDialog.value = true;
        };

        const btnSubmitClickHandler = async () => {
            try {
                const comment = new CommentModel({
                    processId: props.processId,
                    sessionAgendaStandpointId: props.item?.id,
                    isDraft: true,
                    text: commentText.value,
                });

                if (commentId.value) {
                    comment.id = commentId.value;
                    await commentService.updateComment(comment);
                } else {
                    await commentService.createComment(comment);
                }

                context.emit('submitComment');
                showAddCommentDialog.value = false;
                commentId.value = undefined;
                commentText.value = '';

                await getCommentsData();
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnDeleteCommentClickHandler = async () => {
            try {
                await commentService.deleteComment(commentId.value!);

                context.emit('deleteComment', commentId.value);
                showDeleteCommentDialog.value = false;
                commentId.value = undefined;

                await getCommentsData();
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnCancelClickHandler = () => {
            showAddCommentDialog.value = false;
            showDeleteCommentDialog.value = false;
            commentId.value = undefined;
            commentText.value = '';
        };

        const btnSetStandpointStatusClickHandler = async (statusCode: number) => {
            try {
                if (props.item) {
                    const standpoint = props.item;
                    standpoint.statusCode = statusCode;

                    console.log(standpoint, statusCode);

                    await sessionAgendaService.setSessionAgendaItemStandpointStatus(standpoint);

                    context.emit('setStatus', standpoint);
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        onMounted(async () => {
            await getCommentsData();
            await validateSessionDateForEdit();
        });

        return {
            t,
            approvalStatus,
            commentId,
            commentText,
            commentsData,
            showAddCommentDialog,
            showDeleteCommentDialog,
            currUserId,
            isInTermForEditByUser,
            btnShowCommentsClickHandler,
            btnShowAddOrUpdateCommentClickHandler,
            btnShowDeleteCommentClickHandler,
            btnDeleteCommentClickHandler,
            btnSubmitClickHandler,
            btnCancelClickHandler,
            btnSetStandpointStatusClickHandler,
            formatDateTime,
            isAuthor,
            validateSessionDateForEdit,
            btnReturnAsDraft,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/dialog.scss';

// .floatingBtnIcon {
//     background-color: transparent !important;
//     color: var(--ISDA-main-color1) !important;
//     box-shadow: none !important;
//     margin: 15px 0px;
// }
.wrap-text {
    white-space: normal;
}
</style>
