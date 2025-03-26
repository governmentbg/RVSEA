<template>
    <v-dialog v-model="dialog" persistent>
        <Form @submit="submit" @invalid-submit="showHintMessageForRequiredFields">
            <v-card class="vw-50 p-3">
                <v-card-text>
                    <div class="main-form">
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldUserName"
                                    :label="t('registration.columns.userName')"
                                    v-model="userData.userName"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldFirstName"
                                    :label="t('registration.columns.firstName')"
                                    v-model="userData.firstName"
                                    validation="required"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldSurname"
                                    :label="t('registration.columns.surname')"
                                    v-model="userData.surname"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldLastName"
                                    :label="t('registration.columns.lastName')"
                                    v-model="userData.lastName"
                                    validation="required"
                                />
                            </v-col>
                        </v-row>
                        <v-row v-if="userData.profileType == profileType.CardHolder">
                            <v-col class="col-12">
                                <text-field
                                    name="fldLibraryCardNumber"
                                    :label="t('registration.columns.libraryCardNumber')"
                                    v-model="userData.libraryCardNumber"
                                    validation="required"
                                />
                            </v-col>
                        </v-row>
                        <v-row
                            v-if="
                                userData.profileType == profileType.FundCreator &&
                                userData.entityType == profileEntityType.LegalEntity
                            "
                        >
                            <v-col class="col-12">
                                <text-field
                                    name="fldOrganization"
                                    :label="t('registration.columns.organization')"
                                    v-model="userData.organization"
                                    validation="required"
                                />
                            </v-col>
                        </v-row>
                        <v-row
                            v-if="
                                userData.profileType == profileType.FundCreator &&
                                userData.entityType == profileEntityType.LegalEntity
                            "
                        >
                            <v-col>
                                <text-field
                                    name="fldEeik"
                                    :label="t('registration.columns.eik')"
                                    v-model="userData.eik"
                                    validation="required|numeric|"
                                />
                            </v-col>
                        </v-row>
                        <v-row
                            v-if="
                                userData.profileType == profileType.FundCreator &&
                                userData.entityType == profileEntityType.LegalEntity
                            "
                        >
                            <v-col class="col-12">
                                <text-field
                                    name="fldDepartment"
                                    :label="t('registration.columns.department')"
                                    v-model="userData.department"
                                    validation="required"
                                />
                            </v-col>
                        </v-row>
                        <v-row
                            v-if="
                                userData.profileType == profileType.FundCreator &&
                                userData.entityType == profileEntityType.LegalEntity
                            "
                        >
                            <v-col class="col-12">
                                <text-field
                                    name="fldJobTitle"
                                    :label="t('registration.columns.jobTitle')"
                                    v-model="userData.jobTitle"
                                    validation="required"
                                />
                            </v-col>
                        </v-row>
                        <v-row v-if="userData.profileType == profileType.FundCreator">
                            <v-col class="col-12">
                                <text-field
                                    name="fldAddress"
                                    :label="t('registration.columns.address')"
                                    v-model="userData.address"
                                    validation="required"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col>
                                <text-field
                                    name="fldEmail"
                                    :label="t('registration.columns.email')"
                                    v-model="userData.email"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col>
                                <text-field
                                    name="fldPhone"
                                    :label="t('registration.columns.phone')"
                                    v-model="userData.phone"
                                    validation="numeric"
                                />
                            </v-col>
                        </v-row>
                    </div>
                </v-card-text>

                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn :disabled="awaitResponce" type="submit" color="success" variant="outlined">
                        {{ $t('common.save') }}
                    </v-btn>
                    <v-btn color="primary" variant="outlined" @click="onClose">
                        {{ $t('common.close') }}
                    </v-btn>
                    <v-spacer></v-spacer>
                </v-card-actions>
            </v-card>
        </Form>
    </v-dialog>
</template>

<script lang="ts">
import authenticationService from '@/services/authentication.service';
import { computed, defineComponent, inject, Ref, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { Form } from 'vee-validate';
import { formatDate } from '@/helpers/format.helper';
import TextField from '@/components/field/text.field.vue';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { ProfileEntityType, ProfileType } from '@/enums/profile';
import { ResponseResult } from '@/models/responseResult';
import userProfileService from '@/services/profile.service';
import { UserProfileModel } from '@/models/profile';
import router from '@/router';
import { useStore } from '@/store/user/index';
import { ActionTypes } from '@/store/user/actions';
export default defineComponent({
    name: 'EditUserProfile',
    components: {
        TextField,
        Form,
    },
    props: {
        show: {
            type: Boolean,
            required: true,
        },
    },
    setup(props, content) {
        const { t } = useI18n();
        const userStore = useStore();
        const profileType = computed(() => ProfileType);
        const dialog = ref(false);
        const profileEntityType = computed(() => ProfileEntityType);
        const message = inject('notificationMessage') as Ref<IMessage>;
        const userData = ref<UserProfileModel>(new UserProfileModel());
        const awaitResponce = ref(false);
        const submit = async () => {
            try {
                awaitResponce.value = true;
                const result = await userProfileService.updateUser(userData.value);
                await loadData();
                if (result.status == 200) {
                    userStore.dispatch(ActionTypes.SetUserDisplayName, userData.value.displayName);
                    message.value = new Message({
                        text: t('common.successfullyEdit'),
                        type: 'success',
                        display: true,
                        timeout: 5000,
                    });
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            } finally {
                dialog.value = false;
                content.emit('update:show', false);
                router.go(0);
                awaitResponce.value = false;
            }
        };
        const loadData = async () => {
            userData.value = await authenticationService.getUserData();
        };

        const showHintMessageForRequiredFields = () => {
            message.value = new Message({
                text: t('common.requiredFields'),
                display: true,
            });
        };

        return {
            t,
            loadData,
            formatDate,
            showHintMessageForRequiredFields,
            submit,
            dialog,
            profileType,
            userData,
            profileEntityType,
            awaitResponce,
        };
    },
    methods: {
        onClose() {
            this.dialog = false;
            this.$emit('update:show', false);
        },
    },
    watch: {
        show: function (val: boolean) {
            if (val !== false) {
                this.loadData();
            }
            this.dialog = val;
        },
    },
});
</script>

<style scoped lang="scss">
.vw-50 {
    min-width: 50%;
    min-height: 50vh;
}
</style>
