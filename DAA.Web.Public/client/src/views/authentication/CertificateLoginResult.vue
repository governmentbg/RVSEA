<template>
    <v-alert v-if="showError" type="error">{{ errorMessage }}</v-alert>
    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title 
            class="v-card-title-uppercase"
        >{{ 
            t('registration.title') 
        }}</v-card-title> 
        
        <Form
            @submit="onSubmit" 
        >
            <v-container v-if="showEmail">
                <v-alert type="warning">{{ t('registration.emailRequired') }}</v-alert>
                <v-row>
                    <v-col class="col-12 col-lg-6">
                        <text-field
                            name="fldEmail" 
                            :label="t('registration.email')" 
                            v-model="email"
                            validation="required|email|"
                        />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="col-12 d-flex justify-content-center">
                        <v-btn class="btn" type="submit">{{ t('registration.buttons.submit') }}</v-btn>
                    </v-col>
                </v-row>
            </v-container>
        </Form>
    </v-card>
</template>
<script lang="ts">
import { computed, defineComponent, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from '@/store/user';
import { useRouter } from 'vue-router';

import authenticationService from '@/services/authentication.service';
import { User } from '@/models/user';
import { ActionTypes as UserStoreActionTypes } from '@/store/user/actions';

import { Form } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';

export default defineComponent({
    name: 'RegisterCertificate',
    components: {
        Form,
        TextField,
    },
    props: {
        auth: { type: String }, 
        error: { type: Boolean }, 
        message: { type: String }, 
        requireEmail: { type: Boolean},
        isEAuth: { type: Boolean},
        certPersonIdentifier: { type: String},
        certNames: { type: String},
    },
    setup(props) {
        const { t } = useI18n();

        const showEmail = computed(() => props.requireEmail);
        const showError = computed(() => props.error);
        const errorMessage = computed(() => {
            const text = t("login.errors." + props.message);
            // Проверка дали е някакъв код, който го няма в текстовете
            if (text.indexOf("login.errors.") >= 0) {
                return t('error.basic');
            } else {
                return t("login.errors." + props.message);
            }
        });

        const email = ref('');
        const onSubmit = () => {
            if (props.isEAuth) {
                window.location.href = 
                    authenticationService.eAuthLoginWithAddedEmail(email.value, props.certPersonIdentifier!, props.certNames!);
            } else {
                window.location.href = authenticationService.loginCertUrl(email.value);
            }
        };

        const userStore = useStore();
        const router = useRouter();

        onMounted(() => {
            console.log(props);
            if (props.auth) {
                var userInfo = JSON.parse(props.auth);
                if (userInfo) {
                    const user = new User(userInfo);
                    userStore.dispatch(UserStoreActionTypes.SetUser, user);
                    if (user.profileType) {
                        router.push({name: 'Home'});
                    } else {
                        router.push({name: 'CompleteRegistration'});
                    }
                    
                }
            }
        });

        return {
            t,
            email,
            showEmail,
            showError,
            errorMessage,
            onSubmit,
        }
    },
})
</script>

<style lang="scss" scoped>

@import "@/assets/styles/display-create-edit.scss"

</style>