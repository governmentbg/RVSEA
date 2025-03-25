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
                            name="fldUsername"
                            :label="t('login.username')"
                            v-model="model.username"
                            :validation="'required'"
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
            </v-container>
        </Form>
        <!-- <v-overlay :model-value="loading" class="align-center justify-center">
			<v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
		</v-overlay> -->
    </v-card>

    <form
        id="eauth-form"
        action="https://eauthn.egov.bg:9445/eAuthenticator/eAuthenticator.seam"
        method="post"
        ref="eauth"
    >
        <input hidden ref="samlRequest" type="text" name="SAMLRequest" id="SAMLRequest" />
    </form>
</template>

<script lang="ts">
import { defineComponent, inject, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { Message } from '@/models/notification';
import { LoginReaderModel } from '@/models/authentication';
import authenticationService from '@/services/authentication.service';
import { ResponseResult } from '@/models/responseResult';
import TextField from '@/components/field/text.field.vue';
import { Form } from 'vee-validate';
import { IMessage } from '@/interfaces/notification';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'LoginUsername',
    components: {
        Form,
        TextField,
        Loader
    },
    setup() {
        const { t } = useI18n();

        const message = inject('notificationMessage') as Ref<IMessage>;

        const router = useRouter();
        //const route = useRoute();
		const loading = ref(false);

        const model = ref(new LoginReaderModel());

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
                await authenticationService.loginUsernameUrl(model.value);
                // const redirect = route.query.redirect?.toString();
                // router.push(redirect || { name: 'FilmsForReader' });
                router.push({ name: 'FilmsForReader' });
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
            loading.value = false;
        };

        const samlRequest = ref();
        const eauth = ref();

        return {
            t,
            model,
            onSubmit,
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
.v-card {
    margin-top: 50px !important;
    border-radius: 6px;
    box-shadow: gray 0px 0px 3px 0px;
    background-color: var(--ISDA-main-color2-1);
}

button.btn-orange,
div.btn-orange > a {
    background-color: var(--ISDA-main-color4-rgb-op) !important;
    color: var(-ISDA-main-color1) !important;
}

button[type='submit'] {
    background-color: var(--ISDA-main-color4) !important;
}

.btn-f-pass {
    color: var(--ISDA-main-color4) !important;
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