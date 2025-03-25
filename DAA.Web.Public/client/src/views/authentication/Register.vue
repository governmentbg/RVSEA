<template>
    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('registration.titles.registration') }}</v-card-title>

        <Form @submit="onSubmit">
            <v-container>
                <v-tabs v-model="registrationProfile" right>
                    <v-tab :value="profileType.CardHolder">{{ t('registration.cardHolder') }}</v-tab>
                    <v-tab :value="profileType.FundCreator">{{ t('registration.fundCreator') }}</v-tab>
                </v-tabs>
                <v-window v-model="registrationProfile">
                    <v-window-item :value="profileType.CardHolder">
                        <v-row class="mt-3">
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldFirstName"
                                    :label="t('registration.columns.firstName')"
                                    v-model="model.firstName"
                                    validation="required"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldSurname"
                                    :label="t('registration.columns.surname')"
                                    v-model="model.surname"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldLastName"
                                    :label="t('registration.columns.lastName')"
                                    v-model="model.lastName"
                                    validation="required"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldLibraryCardNumber"
                                    :label="t('registration.columns.libraryCardNumber')"
                                    v-model="model.libraryCardNumber"
                                    :validation="registrationProfile == profileType.CardHolder ? 'required' : ''"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldEmail"
                                    :label="t('registration.columns.email')"
                                    v-model="model.email"
                                    validation="required|email|"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldEmailConfirmation"
                                    :label="t('registration.columns.emailConfirmation')"
                                    v-model="model.emailConfirmation"
                                    validation="required|email|confirmed:@fldEmail"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <div class="div-pass1">
                                    <text-field
                                        name="fldPassword"
                                        :label="t('registration.columns.password')"
                                        v-model="model.password"
                                        type="password"
                                        :validation="'required|password'"
                                    />

                                    <i v-if="!isPassVisible1" class="fa fa-eye one" @click="seeOrHidePassword1"></i>
                                    <i
                                        v-if="isPassVisible1"
                                        class="fa fa-eye-slash one"
                                        @click="seeOrHidePassword1"
                                    ></i>
                                </div>
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <div class="div-pass2">
                                    <text-field
                                        name="fldPasswordConfirmation"
                                        :label="t('registration.columns.passwordConfirmation')"
                                        v-model="model.passwordConfirmation"
                                        type="password"
                                        :validation="'required|confirmed:@fldPassword'"
                                    />

                                    <i v-if="!isPassVisible2" class="fa fa-eye two" @click="seeOrHidePassword2"></i>
                                    <i
                                        v-if="isPassVisible2"
                                        class="fa fa-eye-slash two"
                                        @click="seeOrHidePassword2"
                                    ></i>
                                </div>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="phone"
                                    :label="t('registration.columns.phone')"
                                    v-model="model.phone"
                                    validation="numeric"
                                />
                            </v-col>
                        </v-row>
                    </v-window-item>
                    <v-window-item :value="profileType.FundCreator">
                        <v-row class="mt-3">
                            <v-col class="col-12">
                                <v-radio-group v-model="model.profileEntityType" inline>
                                    <v-radio
                                        :label="t('registration.individual')"
                                        :value="profileEntityType.Individual"
                                    ></v-radio>
                                    <v-radio
                                        :label="t('registration.legalEntity')"
                                        :value="profileEntityType.LegalEntity"
                                    ></v-radio>
                                </v-radio-group>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldFirstName"
                                    :label="t('registration.columns.firstName')"
                                    v-model="model.firstName"
                                    validation="required"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldSurname"
                                    :label="t('registration.columns.surname')"
                                    v-model="model.surname"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldLastName"
                                    :label="t('registration.columns.lastName')"
                                    v-model="model.lastName"
                                    validation="required"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    v-if="model.profileEntityType == profileEntityType.LegalEntity"
                                    name="fldOrganization"
                                    :label="t('registration.columns.organization')"
                                    v-model="model.organization"
                                    validation="required"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    v-if="model.profileEntityType == profileEntityType.LegalEntity"
                                    name="fldDepartment"
                                    :label="t('registration.columns.department')"
                                    v-model="model.department"
                                    validation="required"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    v-if="model.profileEntityType == profileEntityType.LegalEntity"
                                    name="fldJobTitle"
                                    :label="t('registration.columns.jobTitle')"
                                    v-model="model.jobTitle"
                                    validation="required"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    v-if="model.profileEntityType == profileEntityType.LegalEntity"
                                    name="eik"
                                    :label="t('registration.columns.eik')"
                                    v-model="model.eik"
                                    validation="required|numeric"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldAddress"
                                    :label="t('registration.columns.address')"
                                    v-model="model.address"
                                    validation="required"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldEmail"
                                    :label="t('registration.columns.email')"
                                    v-model="model.email"
                                    validation="required|email|"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldEmailConfirmation"
                                    :label="t('registration.columns.emailConfirmation')"
                                    v-model="model.emailConfirmation"
                                    validation="required|email|confirmed:@fldEmail"
                                />
                            </v-col>
                        </v-row>
                        <div class="pass">
                            <v-row>
                                <v-col class="col-12 col-lg-6">
                                    <div class="div-pass3">
                                        <text-field
                                            name="fldPassword"
                                            :label="t('registration.columns.password')"
                                            v-model="model.password"
                                            type="password"
                                            :validation="'required|password'"
                                        />
                                        <i
                                            v-if="!isPassVisible3"
                                            class="fa fa-eye three"
                                            @click="seeOrHidePassword3"
                                        ></i>
                                        <i
                                            v-if="isPassVisible3"
                                            class="fa fa-eye-slash three"
                                            @click="seeOrHidePassword3"
                                        ></i>
                                    </div>
                                </v-col>
                                <v-col class="col-12 col-lg-6">
                                    <div class="div-pass4">
                                        <text-field
                                            name="fldPasswordConfirmation"
                                            :label="t('registration.columns.passwordConfirmation')"
                                            v-model="model.passwordConfirmation"
                                            type="password"
                                            :validation="'required|confirmed:@fldPassword'"
                                        />

                                        <i
                                            v-if="!isPassVisible4"
                                            class="fa fa-eye four"
                                            @click="seeOrHidePassword4"
                                        ></i>
                                        <i
                                            v-if="isPassVisible4"
                                            class="fa fa-eye-slash four"
                                            @click="seeOrHidePassword4"
                                        ></i>
                                    </div>
                                </v-col>
                            </v-row>
                        </div>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="phone"
                                    :label="t('registration.columns.phone')"
                                    v-model="model.phone"
                                    validation="numeric"
                                />
                            </v-col>
                        </v-row>
                    </v-window-item>
                </v-window>
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
import { computed, defineComponent, inject, ref, Ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect } from '@/helpers/router.helper';
import authenticationService from '@/services/authentication.service';
import { RegistrationModel } from '@/models/authentication';
import { ProfileType, ProfileEntityType } from '@/enums/profile';
import { Message } from '@/models/notification';
import { ResponseResult } from '../../models/responseResult';
import TextField from '@/components/field/text.field.vue';
import { Form } from 'vee-validate';
import { IMessage } from '../../interfaces/notification';

export default defineComponent({
    name: 'Register',
    components: {
        Form,
        TextField,
    },
    props: {
        regType: {
            type: String,
        },
    },
    setup() {
        const { t } = useI18n();

        const router = useRouter();

        const registrationProfile = ref(ProfileType.CardHolder);
        const model = ref(new RegistrationModel());
        const profileType = computed(() => ProfileType);
        const profileEntityType = computed(() => ProfileEntityType);

        const message = inject('notificationMessage') as Ref<IMessage>;

        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const onSubmit = async (values: any, formActions: any) => {
            console.log('values', values);
            console.log('resetForm', formActions);

            try {
                if (registrationProfile.value) {
                    model.value.profileType = registrationProfile.value;
                }

                let result = await authenticationService.register(model.value);
                if (result.message && result.message === "cannotValidateLibraryCardBecauseOfISDAConnectionMissing") {
                    message.value = new Message({
                        title: t('registration.errors.isdaConnectionMissing'),
                        text: t('registration.errors.cannotValidateLibraryCardBecauseOfISDAConnectionMissing'),
                        display: true,
                    });

                    return;
                }
                
                message.value = new Message({
                    title: t('registration.buttons.successResultTitle'),
                    text: t('registration.buttons.successResultMessage'),
                    type: 'success',
                    display: true,
                    timeout: 5000,
                });

                useRedirect(router, 'Login');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                const text = t('registration.errors.' + errorResult.message);
                // Проверка дали е някакъв код, който го няма в текстовете
                if (text.indexOf('registration.errors.') >= 0) {
                    message.value = new Message({
                        text: t('error.basic'),
                        display: true,
                    });
                } else {
                    message.value = new Message({
                        text: errorResult.showMessage
                            ? t('registration.errors.' + errorResult.message)
                            : t('error.basic'),
                        display: true,
                    });
                }
            }
        };

        const isPassVisible1 = ref(false);
        const isPassVisible2 = ref(false);
        const isPassVisible3 = ref(false);
        const isPassVisible4 = ref(false);
        const seeOrHidePassword = (isPassVisible: Ref<boolean>, divClass: string) => {
            let passElement = document.querySelector(`${divClass} input`);
            if (isPassVisible.value) {
                passElement?.setAttribute('type', 'password');
                isPassVisible.value = false;
            } else {
                passElement?.setAttribute('type', 'text');
                isPassVisible.value = true;
            }
        };

        const seeOrHidePassword1 = () => seeOrHidePassword(isPassVisible1, '.div-pass1');
        const seeOrHidePassword2 = () => seeOrHidePassword(isPassVisible2, '.div-pass2');
        const seeOrHidePassword3 = () => seeOrHidePassword(isPassVisible3, '.div-pass3');
        const seeOrHidePassword4 = () => seeOrHidePassword(isPassVisible4, '.div-pass4');

        watch(
            () => model.value.profileEntityType,
            () => {
                model.value.eik = undefined;
                model.value.jobTitle = undefined;
                model.value.organization = undefined;
                model.value.department = undefined;
            }
        );

        return {
            t,
            registrationProfile,
            model,
            profileType,
            profileEntityType,
            message,
            onSubmit,
            seeOrHidePassword,
            seeOrHidePassword1,
            seeOrHidePassword2,
            seeOrHidePassword3,
            seeOrHidePassword4,
            isPassVisible1,
            isPassVisible2,
            isPassVisible3,
            isPassVisible4,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';

.v-slide-group {
    height: 80px;
}

.v-tab {
    background-color: var(--ISDA-main-color2-1);
    color: var(--ISDA-main-color-1) !important;
    box-shadow: none;
}

.v-card {
    margin-top: 50px !important;
    border-radius: 6px;
    box-shadow: gray 0px 0px 3px 0px;
    background-color: var(--ISDA-main-color2-1);
}

.div-pass1,
.div-pass2,
.div-pass3,
.div-pass4 {
    position: relative;
}

.div-pass > div {
    position: absolute;
    width: 100%;
}

.fa-eye.one,
.fa-eye-slash.one,
.fa-eye.two,
.fa-eye-slash.two,
.fa-eye.three,
.fa-eye-slash.three,
.fa-eye.four,
.fa-eye-slash.four {
    position: absolute !important;
    right: 10px;
    top: 20px;
}
</style>
