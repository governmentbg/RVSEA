<template>
    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase"
            >{{ t('registration.index.grid.titles.resetPasswordOf') }}&ensp;<b>{{ userData.userName }}</b></v-card-title
        >
        <Form @submit="onSubmit">
            <v-container>
                <v-row class="mt-3">
                    <v-col class="col-12 col-lg-6">
                        <text-field
                            name="fldPassword"
                            :label="t('registration.index.grid.cols.newPassword')"
                            v-model="model.password"
                            type="password"
                            :validation="'required'"
                        />
                    </v-col>
                    <v-col class="col-12 col-lg-6">
                        <text-field
                            name="fldPasswordConfirmation"
                            :label="t('registration.index.grid.cols.passwordConfirmation')"
                            v-model="model.passwordConfirmation"
                            type="password"
                            :validation="'required|confirmed:@fldPassword'"
                        />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="col-12 d-flex justify-content-center">
                        <v-btn class="mr-4" @click="changePassword"
                            >{{ t('registration.index.grid.btn.changePassword') }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('registration.index.grid.btn.changePasswordTooltip') }}
                            </v-tooltip>
                        </v-btn>
                        <v-divider vertical></v-divider>
                        <v-btn class="clear bg-secondary" @click="goBack"
                            >{{ t('common.cancel') }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('registration.index.grid.btn.cancelTooltip') }}
                            </v-tooltip>
                        </v-btn>
                    </v-col>
                </v-row>
            </v-container>
        </Form>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, inject, ref, Ref, onMounted } from 'vue';

import { IUserInfo, IChangeUserPassword } from '@/interfaces/userInfo';
import { UserInfo } from '@/models/userInfo';
import userService from '@/services/user.service';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect } from '@/helpers/router.helper';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import TextField from '@/components/field/text.field.vue';
import { Form } from 'vee-validate';
import { IMessage } from '@/interfaces/notification';
import { ChangeUserPassword } from '@/models/authentication';

export default defineComponent({
    name: 'EditReaderUser',
    components: {
        Form,
        TextField,
    },
    props: {
        userid: { type: String, required: true },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const model = ref<IChangeUserPassword>(new ChangeUserPassword());

        const router = useRouter();
        const goBack = () => {
            useRedirect(router, 'ReaderUsers');
        };

        const userData = ref<IUserInfo>(new UserInfo());
        const getUserData = async () => {
            try {
                userData.value = await userService.displayUserReader(props.userid);
                console.log(userData.value);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const changePassword = async () => {
            if (userData.value && model.value) {
                try {
                    model.value.id = userData.value.id;
                    model.value.userName = userData.value.userName;
                    const result = await userService.changeUserPassword(model.value);
                    if (result.status == 200) {
                        if (result.data.message) {
                            message.value = new Message({
                                text: result.data.message,
                                display: true,
                            });
                        } else {
                            message.value = new Message({
                                text: t('common.successfullyEdit'),
                                display: true,
                                type: 'success',
                                timeout: 5000,
                            });
                            goBack();
                        }
                    } else {
                        message.value = new Message({
                            text: result.data.message,
                            display: true,
                        });
                    }
                } catch (error) {
                    console.log(error);
                    message.value = new Message({
                        text: error.response.data.message,
                        display: true,
                    });
                }
            }
        };
        onMounted(() => {
            getUserData();
        });

        return {
            t,
            model,
            goBack,
            userData,
            changePassword,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
</style>
