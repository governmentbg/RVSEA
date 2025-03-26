<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
                <v-card-title>{{ t('users.panels.general') }}</v-card-title>
                <div class="main-form">
                    <v-row>
                        <v-col class="col-12">
                            <text-field
                                name="fldUserName"
                                :label="t('users.columns.userName')"
                                v-model="userData.userName"
                                :disabled="true"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12 col-lg-4">
                            <text-field
                                name="fldFirstName"
                                :label="t('users.columns.firstName')"
                                v-model="userData.firstName"
                                :disabled="true"
                            />
                        </v-col>
                        <v-col class="col-12 col-lg-4">
                            <text-field name="fldSurname" :label="t('users.columns.surname')" v-model="userData.surname" :disabled="true" />
                        </v-col>
                        <v-col class="col-12 col-lg-4">
                            <text-field
                                name="fldLastName"
                                :label="t('users.columns.lastName')"
                                v-model="userData.lastName"
                                :disabled="true"
                            />
                        </v-col>
                    </v-row>
                    <v-row v-if="userData.userProfileType == profileType.CardHolder">
                        <v-col class="col-12">
                            <text-field
                                name="fldLibraryCardNumber"
                                :label="t('users.columns.libraryCardNumber')"
                                v-model="userData.libraryCardNumber"
                                :disabled="true"
                            />
                        </v-col>
                    </v-row>
                    <v-row
                        v-if="
                            userData.userProfileType == profileType.FundCreator &&
                            userData.profileEntityType == profileEntityType.LegalEntity
                        "
                    >
                        <v-col class="col-12">
                            <text-field
                                name="fldOrganization"
                                :label="t('users.columns.organization')"
                                v-model="userData.organization"
                                :disabled="true"
                            />
                        </v-col>
                    </v-row>
                    <v-row
                        v-if="
                            userData.userProfileType == profileType.FundCreator &&
                            userData.profileEntityType == profileEntityType.LegalEntity
                        "
                    >
                        <v-col class="col-12">
                            <text-field
                                name="fldDepartment"
                                :label="t('users.columns.department')"
                                v-model="userData.department"
                                :disabled="true"
                            />
                        </v-col>
                    </v-row>
                    <v-row
                        v-if="
                            userData.userProfileType == profileType.FundCreator &&
                            userData.profileEntityType == profileEntityType.LegalEntity
                        "
                    >
                        <v-col class="col-12">
                            <text-field
                                name="fldJobTitle"
                                :label="t('users.columns.jobTitle')"
                                v-model="userData.jobTitle"
                                :disabled="true"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12">
                            <text-field
                                name="fldAddress"
                                :label="t('users.columns.address')"
                                v-model="userData.address"
                                :disabled="true"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col>
                            <text-field
                                name="fldEmail"
                                :label="t('users.columns.email')"
                                v-model="userData.email"
                                :disabled="true"
                            />
                        </v-col>
                    </v-row>
                    </div>
            <!-- <v-expansion-panel
            value="roles"
        >
            <v-expansion-panel-title>{{ 
                t('users.panels.roles') 
            }}</v-expansion-panel-title>
            <v-expansion-panel-text>
                <v-row>
                     <v-col class="col-12">
                        <checkbox-list 
                          :items="rolesData.filter(r => !r.groupName)" 
                          valueProp="code" 
                          v-model="userData.roles" 
                          :disabled="true"
                        />
                     </v-col>
                   </v-row>
            </v-expansion-panel-text>
        </v-expansion-panel> -->
        <v-row>
            <v-col class="d-flex mt-3 mb-3 justify-content-center">
                <v-btn class="mr-4" @click="goEdit">{{ t('common.edit') }}
                    <v-tooltip
                        activator="parent"
                        location="bottom"
                    >
                    {{t('users.buttons.editTooltip')}}
                    </v-tooltip>
                </v-btn>
                <v-divider vertical></v-divider>
                <v-btn class="clear bg-secondary" @click="goBack">{{ t('common.back') }}
                    <v-tooltip
                        activator="parent"
                        location="bottom"
                    >
                    {{t('users.buttons.backTooltip')}}
                    </v-tooltip>
                </v-btn>
            </v-col>
        </v-row>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, computed, inject, Ref } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { Message } from '@/models/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { ApplicationUserProfileType, ProfileEntityType } from '@/enums/profile';
import { IUserInfo } from '@/interfaces/userInfo';
import { UserInfo } from '@/models/userInfo';
import { IDropdownOption } from '@/interfaces/dropdown';
import userService from '@/services/user.service';
import dropdownService from '@/services/dropdown.service';

import TextField from '@/components/field/text.field.vue';
import { IMessage } from '../../../interfaces/notification';
import { ResponseResult } from '../../../models/responseResult';

export default defineComponent({
    name: 'DisplayUser',
    components: {
        TextField,
        Breadcrumbs,
    },
    props: {
        userid: { type: String, required: true },
    },
    setup(props) {
        const { t } = useI18n();

        const message = inject('notificationMessage') as Ref<IMessage>;

        const profileType = computed(() => ApplicationUserProfileType);
        const profileEntityType = computed(() => ProfileEntityType);

        const router = useRouter();
        const goEdit = () => {
            useRedirectWithId(router, 'EditExternalUser', props.userid);
        };
        const goBack = () => {
            useRedirect(router, 'ExternalUsers');
        };

        const panel = ref(['general']);

        const userData = ref<IUserInfo>(new UserInfo());
        const getUserData = async () => {
            try {
                userData.value = await userService.displayUser(props.userid);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const archivesData = ref<IDropdownOption[]>([]);
        const getArchivesData = async () => {
            try {
                archivesData.value = await dropdownService.getArchives();
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const rolesData = ref<IDropdownOption[]>();
        const getRoles = async () => {
            try {
                rolesData.value = await dropdownService.getRoles();
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
                title: t('navigation.left.externalUsers'),
                disabled: false,
                to: { name: 'ExternalUsers' },
            },
            {
                title: t('users.panels.general'),
                disabled: true,
            },
        ];
        onMounted(async () => {
            await getUserData();
            await getArchivesData();
            await getRoles();
        });

        return {
            t,
            panel,
            userData,
            archivesData,
            rolesData,
            goEdit,
            goBack,
            breadcrumbItems,
            message,
            profileType,
            profileEntityType,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';

.main-form {
    margin: 12px;
}

</style>
