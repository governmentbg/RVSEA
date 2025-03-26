<template>
    <span class="mt-2">
        <v-row class="darken">
            <v-col class="col-5">
                <div>
                    <span class="text-white">{{ comentTypeProp }}</span>
                </div>
            </v-col>
            <v-col class="col-3">
                <div>
                    <span class="text-white">{{ t('docsCreateProc.createdBy') }}</span>
                </div>
            </v-col>
            <v-col class="col-3">
                <div>
                    <span class="text-white">{{ t('docsCreateProc.createDate') }}</span>
                </div>
            </v-col>
            <v-col class="col-1">
                <div class="text-center"></div>
            </v-col>
        </v-row>
        <v-row class="mt-3" v-for="(item, index) in items" :key="index">
            <v-col class="col-5">
                <span>{{ item.text }}</span>
            </v-col>
            <v-col class="col-3">
                <span class="text-center">{{ item.createdByDisplayName }}</span>
            </v-col>
            <v-col class="col-3">
                <span>{{ formatDate(item.createdOn) }}</span>
            </v-col>
            <span v-if="showDelete && item.isDraft" class="col-1 text-center">
                <button type="button" class="btn btn-actions-bar icon-btn" @click="onClickDelete(item.id)">
                    <i class="fas fa-trash-alt text-danger"></i>
                </button>
            </span>
        </v-row>
        <slot v-if="!existComment" name="buttons"></slot>
        <slot v-if="existComment" name="secondButton"></slot>
    </span>
    <!--Dialog template-->
    <v-row justify="center">
        <v-dialog transition="dialog-bottom-transition" width="50%" v-model="dialog">
            <v-card width="50vh">
                <v-card-title class="text-h5 text-center">
                    {{ t('docsCreateProc.addComm') }}
                </v-card-title>
                <v-card-text>
                    <v-col>
                        <text-field v-model="comentDescription" />
                    </v-col>
                </v-card-text>
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <submit-btn @click="createComent(comentDescription)">
                        {{ t('common.save') }}
                    </submit-btn>
                    <cancel-btn @click="dialog = false">
                        {{ t('common.cancel') }}
                    </cancel-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </v-row>
</template>

<script lang="ts">
import { defineComponent, ref, computed, onMounted, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { CommentModel } from '../../models/comment';
import { formatDate } from '@/helpers/format.helper';
import { useStore } from '@/store/user';
import TextField from '@/components/field/textarea.field.vue';
import commentService from '@/services/comments.service';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { IMessage } from '@/interfaces/notification';
import { IComment } from '@/interfaces/comment';

export default defineComponent({
    components: { TextField },
    props: {
        showModal: {
            type: Boolean,
            default: false,
        },
        comentTypeProp: {
            type: String,
            required: true,
        },
        ProcessId: {
            type: Number,
            required: true,
        },
        ProcessStepId: {
            type: Number,
            required: true,
        },
        showDelete: {
            type: Boolean,
            default: true,
        },
    },
    setup(props, context) {
        const { t } = useI18n();
        const items = ref<IComment[]>();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const userStore = useStore();
        const userId = computed(() => userStore.getters.userId ?? userStore.getters.userId);
        const dialog = ref(false);
        const comentDescription = ref('');
        const existComment = ref(false);
        const createCommentObj = ref<CommentModel>(new CommentModel());

        const onClickDelete = async (id: number) => {
            try {
                await commentService.deleteComment(id);
                getCommentList();
                existComment.value = false;
            } catch (error: unknown) {
                message.value = new Message({
                    text: (error as ResponseResult)?.message,
                    display: true,
                });
            }
        };

        const getCommentList = async () => {
            try {
                items.value = [];
                items.value = await commentService.getAll(props.ProcessId, props.ProcessStepId);
                items.value.forEach((element) => {
                    if (element.createdBy == userId.value && element.isDraft == true) {
                        existComment.value = true;
                    }
                    context.emit('update:Items', items);
                });
            } catch (error: unknown) {
                message.value = new Message({
                    text: (error as ResponseResult)?.message,
                    display: true,
                });
            }
        };

        const create = async () => {
            try {
                await commentService.createComment(createCommentObj.value);
                getCommentList();
            } catch (error: unknown) {
                message.value = new Message({
                    text: (error as ResponseResult)?.message,
                    display: true,
                });
            }
        };

        function createComent(description: string) {
            if (description == '') {
                alert(t('docsCreateProc.emptyComment'));
            } else {
                createCommentObj.value = {
                    text: description,
                    processId: props.ProcessId,
                    processStepId: props.ProcessStepId,
                };
                create();
                dialog.value = false;
                comentDescription.value = '';
                context.emit('update:Items', items);
            }
        }
        onMounted(() => {
            getCommentList();
        });

        return {
            t,
            onClickDelete,
            formatDate,
            createComent,
            items,
            userId,
            dialog,
            existComment,
            comentDescription,
        };
    },

    watch: {
        showModal: function (val) {
            this.dialog = val;
        },
        dialog: function (val) {
            if (val == false) {
                this.comentDescription = '';
            }
            this.$emit('update:showModal', val);
        },
    },
});
</script>
<style lang="scss" scoped>
.darken {
    background-color: rgb(49, 57, 53);
}

@import '@/assets/styles/dialog.scss';
</style>
