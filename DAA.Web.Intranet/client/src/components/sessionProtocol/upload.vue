<template>
    <v-row justify="center">
        <v-dialog transition="dialog-bottom-transition" width="50%" v-model="dialog">
            <v-card width="50vh">
                <v-card-title class="text-h5 text-center">
                    {{ t('files.upload') }}
                </v-card-title>
                <v-card-text>
                    <v-col>
                        <v-row>
                            <UploadFile
                                class="mt-2"
                                ref="fileUploader"
                                :multipleFiles="false"
                                packageType="B"
                                @change="filesChanged"
                            />
                        </v-row>
                    </v-col>
                </v-card-text>
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn color="green darken-1" text @click="uploadProtocol">
                        {{ t('files.upload') }}
                    </v-btn>
                    <v-btn class="cancel" color="green darken-1" text @click="dialog = false">
                        {{ t('common.cancel') }}
                    </v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </v-row>
</template>

<script lang="ts">
import { defineComponent, ref, computed, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from '@/store/user';
import UploadFile from '../files/uploadFile.vue';
import { SessionProtocolUploadFileModel } from '@/models/protocol';
import commissionSessionService from '@/services/commissionSession.service';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { IMessage } from '@/interfaces/notification';
import router from '@/router';
export default defineComponent({
    name: 'UploadProtocolOnPiecePaper',
    components: { UploadFile },
    props: {
        showModal: {
            type: Boolean,
            default: false,
        },
        sessionId: {
            type: Number,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const dialog = ref(false);
        const uploadModel = ref<SessionProtocolUploadFileModel>(new SessionProtocolUploadFileModel());
        const message = inject('notificationMessage') as Ref<IMessage>;
        // da se ograni4i dostupa do butona za roli koito mogat da go izpolzvat
        const userStore = useStore();
        const userId = computed(() => userStore.getters.userId ?? userStore.getters.userId);
        ///

        const uploadProtocol = async () => {
            uploadModel.value.sessionId = props.sessionId;
            try {
                await commissionSessionService.uploadSessionProtocol(uploadModel.value);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
            dialog.value = false;
            router.go(0);
        };
        const filesChanged = (model: File[]) => {
            uploadModel.value.files = model;
        };
        return {
            t,
            uploadProtocol,
            filesChanged,
            userId,
            dialog,
        };
    },
    watch: {
        showModal: function (val) {
            this.dialog = val;
        },
        dialog: function (val) {
            this.$emit('update:showModal', val);
        },
    },
});
</script>
<style lang="scss" scoped>
@import '@/assets/styles/dialog.scss';
</style>