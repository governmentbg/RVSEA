<template>
<Loader :isLoading="loading" />
    <v-card class="col-12 col-md-9 col-lg-6 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('login.title') }}</v-card-title>
        <div class="loader" v-if="loading"></div>
        <Form @submit="onSubmit" id="x">
            <v-container>
                <v-row>
                    <v-col>
                        <text-field
                            name="fldEmail"
                            :label="t('login.email')"
                            v-model="model.email"
                            validation="required|email"
                        />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col>
                        <div class="div-pass">
                            <text-field
                                name="fldPassword"
                                :label="t('login.password')"
                                v-model="model.password"
                                type="password"
                                :validation="'required'"
                            />
                            <i v-if="!isPassVisible" class="fa fa-eye" @click="seeOrHidePassword"></i>
                            <i v-if="isPassVisible" class="fa fa-eye-slash" @click="seeOrHidePassword"></i>
                        </div>
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="d-flex justify-content-center">
                        <v-btn class="btn-orange" type="submit">{{ t('login.submit') }}</v-btn>
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="d-flex justify-content-end btn-f-pass">
                        <v-btn variant="plain" @click="resetPassword">{{ t('login.forgottenPassword') }}</v-btn>
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="d-flex justify-content-center">
                        <v-btn block class="btn-orange" :href="certificateLoginUrl">{{ t('login.certificate') }}</v-btn>
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="d-flex justify-content-center">
                        <v-btn block class="btn-orange" @click="eAuthLogin">{{ t('login.eAuth') }}</v-btn>
                    </v-col>
                </v-row>
            </v-container>
        </Form>

        <form
            id="eauth-form"
            action="https://eauthn.egov.bg:9445/eAuthenticator/eAuthenticator.seam"
            method="post"
            ref="eauth"
        >
            <input hidden ref="samlRequest" type="text" name="SAMLRequest" id="SAMLRequest" />
        </form>
        <!-- <v-overlay :model-value="loading" class="align-center justify-center">
			<v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
		</v-overlay> -->
    </v-card>
</template>

<script lang="ts">
import { computed, defineComponent, inject, onMounted, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';
import { Message } from '@/models/notification';
import { LoginModel, EAuthRequestModel } from '@/models/authentication';
import authenticationService from '@/services/authentication.service';
import { ResponseResult } from '../../models/responseResult';
import TextField from '@/components/field/text.field.vue';
import { Form } from 'vee-validate';
import { useRedirect } from '@/helpers/router.helper';
import { IMessage } from '../../interfaces/notification';
import authorization from '@/helpers/authorization.helper';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'Login',
    components: {
        Form,
        TextField,
        Loader,
    },
    setup() {
        const { t } = useI18n();

        const message = inject('notificationMessage') as Ref<IMessage>;
        const isAuthenticated = computed(() => authorization.isAuthenticated());

        const certificateLoginUrl = computed(() => authenticationService.loginCertUrl());

        const router = useRouter();
        const route = useRoute();
		const loading = ref(false);

        const model = ref(new LoginModel());

        const isPassVisible = ref(false);
        const seeOrHidePassword = () => {
            let passElement = document.querySelector(`.div-pass input`);
            if (isPassVisible.value) {
                passElement?.setAttribute('type', 'password');
                isPassVisible.value = false;
            } else {
                passElement?.setAttribute('type', 'text');
                isPassVisible.value = true;
            }
        };

        const onSubmit = async () => {
            try {
                loading.value = true;
                await authenticationService.login(model.value, message);

                const redirect = route.query.redirect?.toString();
                router.push(redirect || { name: 'Home' });
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                const text = t('login.errors.' + errorResult.message);
                // Проверка дали е някакъв код, който го няма в текстовете
                if (text.indexOf('login.errors.') >= 0) {
                    message.value = new Message({
                        text: t('error.basic'),
                        display: true,
                    });
                } else {
                    message.value = new Message({
                        text: errorResult.showMessage ? t('login.errors.' + errorResult.message) : t('error.basic'),
                        display: true,
                    });
                }
            }
            loading.value = false;
        };

        const samlRequest = ref();
        const eauth = ref();
        const eAuthLogin = async () => {
            loading.value = true;
            authenticationService
                .eAuthLogin(model.value.email)
                .then((result: EAuthRequestModel) => {
                    (samlRequest.value as HTMLInputElement)!.value =
                        result.samlRequest == null ? '' : result.samlRequest;
                    const form = eauth.value as HTMLFormElement & { submit: () => boolean };
                    if (form) {
                        form.submit();
                    }
                    loading.value = false;
                })
                .catch(() => {
                    message.value = new Message({
                        text: t('error.basic'),
                        display: true,
                    });
                });
        };

        const resetPassword = () => {
            useRedirect(router, 'ResetPassword');
        };

        onMounted(() => {
            if (isAuthenticated.value) {
                useRedirect(router, 'Home');
            }
        });

        return {
            t,
            model,
            onSubmit,
            resetPassword,
            certificateLoginUrl,
            eAuthLogin,
            samlRequest,
            eauth,
            isPassVisible,
            seeOrHidePassword,
            loading,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';

.v-card {
    margin-top: 50px !important;
    border-radius: 6px;
    box-shadow: gray 0px 0px 3px 0px;
    background-color: var(--ISDA-main-color2-1);
}

button.btn-orange,
.btn-orange,
div.btn-orange > a,
button,
a {
    background-color: var(--ISDA-main-color4-rgb-op) !important;
    color: white !important;
}

button[type='submit'] {
    background-color: var(--ISDA-main-color4) !important;
}

.btn-f-pass > button {
    color: var(--ISDA-main-color4) !important;
    background-color: var(--ISDA-main-color2-1) !important;
    box-shadow: none;
}

.div-pass {
    position: relative;
}

.div-pass > div {
    width: 100%;
}

.fa-eye,
.fa-eye-slash {
    position: absolute !important;
    right: 10px;
    top: 20px;
}

.loader {
    border-top: 2px solid var(--ISDA-main-color4) !important;
    border-right: 2px solid var(--ISDA-main-color4) !important;
}

</style>
