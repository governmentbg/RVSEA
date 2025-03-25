<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase"
            >{{ t('registration.index.grid.titles.registration') }}
            {{ t('registration.index.cardHolder') }}</v-card-title
        >

        <Form @submit="onSubmit">
            <v-container>
                <v-window v-model="registrationProfile">
                    <v-window-item :value="profileType.ReaderInReadingRoom">
                        <v-row class="mt-3">
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldUsername"
                                    :label="t('registration.index.grid.cols.username')"
                                    v-model="model.username"
                                    validation="required"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldPassword"
                                    :label="t('registration.index.grid.cols.password')"
                                    v-model="model.password"
                                    type="password"
                                    :validation="'required'"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldPasswordConfirmation"
                                    :label="t('registration.index.grid.cols.passwordConfirmation')"
                                    v-model="model.passwordConfirmation"
                                    type="password"
                                    :validation="'required|confirmed:@fldPassword'"
                                />
                            </v-col>
                        </v-row>
                    </v-window-item>
                </v-window>
                <v-row>
                    <v-col class="col-12 d-flex justify-content-center mt-10">
                        <v-btn type="submit">{{ t('registration.index.grid.btn.submit') }}
                            <v-tooltip
                                activator="parent"
                                location="bottom"
                            >
                            {{t('registration.index.grid.btn.submitTooltip')}}
                            </v-tooltip>
                        </v-btn>
                    </v-col>
                </v-row>
            </v-container>
        </Form>
    </v-card>
</template>
<script lang="ts">
import { computed, defineComponent, inject, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect } from '@/helpers/router.helper';
import authenticationService from '@/services/authentication.service';
import { RegistrationModel } from '@/models/authentication';
import { ApplicationUserProfileType, ProfileEntityType } from '@/enums/profile';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import TextField from '@/components/field/text.field.vue';
import { Form } from 'vee-validate';
import { IMessage } from '@/interfaces/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';

export default defineComponent({
    name: 'Register',
    components: {
        Form,
        TextField,
        Breadcrumbs,
    },
    props: {
        regType: {
            type: String,
        },
    },
    setup() {
        const { t } = useI18n();

        const router = useRouter();

        const registrationProfile = ref(null);
        const model = ref(new RegistrationModel());
        const profileType = computed(() => ApplicationUserProfileType);
        const profileEntityType = ProfileEntityType.Individual;

        const message = inject('notificationMessage') as Ref<IMessage>;

        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const onSubmit = async (values: any, formActions: any) => {
            console.log('values', values);
            console.log('resetForm', formActions);

            try {
                if (registrationProfile.value) {
                    model.value.profileType = registrationProfile.value;
                }
                model.value.email = 'defaultEmail@abv.bg';
                model.value.emailConfirmation = 'defaultEmail@abv.bg';

                await authenticationService.registerReader(model.value);

                message.value = new Message({
                    title: t('registration.index.grid.btn.successResultTitle'),
                    text: t('registration.index.grid.btn.successResultTitle'),
                    type: 'success',
                    display: true,
                });

                useRedirect(router, 'ReaderUsers');
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.readerProfiles'),
                disabled: false,
                to: { name: 'ReaderUsers' },
            },
            {
                title: t('registration.index.grid.titles.registration'),
                disabled: true,
            },
        ];
        return {
            t,
            registrationProfile,
            model,
            profileType,
            breadcrumbItems,
            profileEntityType,
            message,
            onSubmit,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
