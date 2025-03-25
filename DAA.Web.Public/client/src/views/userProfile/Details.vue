<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto mt-15">
        <v-card-title>{{ t('common.userProfile') }}</v-card-title>
        <div class="main-form">
            <v-row>
                <v-col class="col-12">
                    <text-field
                        name="fldUserName"
                        :label="t('registration.columns.userName')"
                        v-model="userData.userName"
                        :disabled="true"
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col class="col-12 col-lg-4">
                    <text-field
                        name="fldFirstName"
                        :label="t('registration.columns.firstName')"
                        v-model="userData.firstName"
                        :disabled="true"
                    />
                </v-col>
                <v-col class="col-12 col-lg-4">
                    <text-field
                        name="fldSurname"
                        :label="t('registration.columns.surname')"
                        v-model="userData.surname"
                        :disabled="true"
                    />
                </v-col>
                <v-col class="col-12 col-lg-4">
                    <text-field
                        name="fldLastName"
                        :label="t('registration.columns.lastName')"
                        v-model="userData.lastName"
                        :disabled="true"
                    />
                </v-col>
            </v-row>
            <v-row v-if="userData.profileType == profileType.CardHolder">
                <v-col class="col-12">
                    <text-field
                        name="fldLibraryCardNumber"
                        :label="t('registration.columns.libraryCardNumber')"
                        v-model="userData.libraryCardNumber"
                        :disabled="true"
                    />
                </v-col>
            </v-row>
            <v-row v-if="userData.libraryCardValidTo && userData.profileType == profileType.CardHolder">
                <v-col>
                    <text-field
                        name="fldlibaryCardValidTo"
                        :label="t('registration.columns.libaryCardValidTo')"
                        v-model="userData.libraryCardValidTo"
                        :disabled="true"
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
                        :disabled="true"
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
                        :disabled="true"
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
                        :disabled="true"
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
                        :disabled="true"
                    />
                </v-col>
            </v-row>
            <v-row v-if="userData.profileType == profileType.FundCreator">
                <v-col class="col-12">
                    <text-field
                        name="fldAddress"
                        :label="t('registration.columns.address')"
                        v-model="userData.address"
                        :disabled="true"
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
                        name="fldEmail"
                        :label="t('registration.columns.phone')"
                        v-model="userData.phone"
                        :disabled="true"
                    />
                </v-col>
            </v-row>
        </div>
        <v-row class="mb-3">
            <v-col class="d-flex mt-3 justify-content-center">
                <v-btn @click="showEditModal = true">{{ t('inventories.buttons.edit') }}</v-btn>
            </v-col>
        </v-row>
    </v-card>

    <EditUserModal v-model:show="showEditModal" />
</template>

<script lang="ts">
import authenticationService from '@/services/authentication.service';
import { defineComponent, onMounted, ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { formatDate } from '@/helpers/format.helper';
import EditUserModal from './Edit.vue';
import TextField from '@/components/field/text.field.vue';
import { ProfileType, ProfileEntityType } from '@/enums/profile';
import { UserProfileModel } from '@/models/profile';
export default defineComponent({
    name: 'ApplicationsCreate',
    components: { Breadcrumbs, EditUserModal, TextField },

    setup() {
        const { t } = useI18n();
        const userData = ref<UserProfileModel>(new UserProfileModel());
        const showEditModal = ref(false);
        const profileType = computed(() => ProfileType);
        const profileEntityType = computed(() => ProfileEntityType);

        const getUserData = async () => {
            userData.value = await authenticationService.getUserData();
            userData.value.libraryCardValidTo = formatDate(userData.value.libraryCardValidTo as string);
        };

        const breadcrumbItems = computed(() => [
            {
                title: t('navigation.left.home'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('common.userProfile'),
                disabled: true,
            },
        ]);

        onMounted(() => {
            getUserData();
        });

        return {
            t,
            formatDate,
            showEditModal,
            userData,
            profileEntityType,
            profileType,
            breadcrumbItems,
        };
    },
});
</script>
<style lang="scss" scoped>
@import '@/assets/styles/breadcrumbs.scss';

.main-form {
    margin: 12px;
}
</style>
