<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <Form @submit="submitUserData">
                    <v-card-title>{{ t('users.panels.general') }}</v-card-title>
                    <div class="main-form">
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldUserName"
                                    :label="t('users.columns.userName')"
                                    v-model="userData.userName"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col>
                                <text-field
                                    name="fldEmail"
                                    :label="t('users.columns.email')"
                                    v-model="userData.email"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldFirstName"
                                    :label="t('users.columns.firstName')"
                                    v-model="userData.firstName"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldSurname"
                                    :label="t('users.columns.surname')"
                                    v-model="userData.surname"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldLastName"
                                    :label="t('users.columns.lastName')"
                                    v-model="userData.lastName"
                                />
                            </v-col>
                        </v-row>
                        <v-row v-if="userData.userProfileType == profileType.CardHolder">
                            <v-col class="col-12">
                                <text-field
                                    name="fldLibraryCardNumber"
                                    :label="t('users.columns.libraryCardNumber')"
                                    v-model="userData.libraryCardNumber"
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
                                />
                            </v-col>
                        </v-row>
                        </div>
                <!-- <v-expansion-panel
                value="globalRoles"
            >
                <v-expansion-panel-title>{{ 
                    t('users.panels.globalRoles') 
                }}</v-expansion-panel-title>
                <v-expansion-panel-text>
                    <v-row>
                     <v-col class="col-12">
                        <checkbox-list 
                          :items="rolesData.filter(r => !r.groupName)" 
                          valueProp="code" 
                          v-model="userData.roles" 
                        />
                     </v-col>
                   </v-row>
                   {{ userData.roles }}
                </v-expansion-panel-text>
            </v-expansion-panel>
            <v-expansion-panel
                v-for="(archive) in archivesData"
                :key="archive"
                :value="archive.id"
                :readonly="userData.archives.findIndex(a => a === archive.id) < 0"
            >
                <v-expansion-panel-title>
                    <v-switch 
                        v-model="userData.archives"
                        :label="archive.label"
                        :value="archive.id"
                        density="compact"
                        hide-details="auto"
                        color="primary"
                        @click.stop="panelSwitchClicked($event, archive)"
                        @change="panelSwitchChanged($event, archive)"
                    />
                </v-expansion-panel-title>
                <v-expansion-panel-text>
                    <checkbox-list 
                    :items="rolesData.filter(r => r.groupName === archive.label)" 
                    valueProp="code" 
                    v-model="userData.roles"
                    :disabled="userData.archives.findIndex(a => a === archive.id) < 0"
                    />
                </v-expansion-panel-text>
            </v-expansion-panel> -->
            <v-row>
                <v-col class="d-flex mt-3 mb-3 justify-content-center">
                    <v-btn class="mr-4" type="submit">{{ t('common.save') }}
                        <v-tooltip
                            activator="parent"
                            location="bottom"
                        >
                        {{t('common.saveTooltip')}}
                        </v-tooltip>
                    </v-btn>
                    <v-divider vertical></v-divider>
                    <v-btn class="clear bg-secondary" @click="goBack">{{ t('common.cancel') }}
                        <v-tooltip
                            activator="parent"
                            location="bottom"
                        >
                        {{t('users.buttons.cancelTooltip')}}
                        </v-tooltip>
                    </v-btn>
                </v-col>
            </v-row>
        </Form>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, onMounted, computed, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect } from '@/helpers/router.helper';
import { Message } from '@/models/notification';
import { ApplicationUserProfileType, ProfileEntityType } from '@/enums/profile';
import { IDropdownOption } from '@/interfaces/dropdown';
import { IUserInfo } from '@/interfaces/userInfo';
import { UserInfo } from '@/models/userInfo';
import userService from '@/services/user.service';
import dropdownService from '@/services/dropdown.service';
import { Form } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';
import { IMessage } from '../../../interfaces/notification';
import { ResponseResult } from '../../../models/responseResult';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';

export default defineComponent({
    name: 'EditUser',
    components: {
        Form,
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
        const goBack = () => {
            useRedirect(router, 'ExternalUsers');
        };

        const panel = ref([0]);

        const userData = ref<IUserInfo>(new UserInfo());
        const getUserData = async () => {
            try {
                userData.value = await userService.displayUser(props.userid);
                console.log(userData.value);
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

        const rolesData = ref<IDropdownOption[]>([]);
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

        const panelSwitchClicked = (event: Event) => {
            event.cancelBubble = true;
        };
        const panelSwitchChanged = (event: Event, value: IDropdownOption) => {
            if (userData.value.archives) {
                if (userData.value.archives.findIndex((a) => a === value.id) > -1) {
                    panel.value.push(value.id!);
                } else {
                    const roles = rolesData.value.filter((r) => r.groupName === value.label);
                    userData.value.roles = userData.value.roles?.filter((r) => !roles.find((i) => i.code === r));

                    panel.value.splice(panel.value.indexOf(value.id!), 1);
                }
            }
        };

        const submitUserData = async () => {
            if (userData.value) {
                try {
                    const result = await userService.updateUser(userData.value);
                    if (result.status == 200) {
                        message.value = new Message({
                            text: t('common.successfullyEdit'),
                            display: true,
                            type: 'success',
                            timeout: 5000,
                        })
                        goBack();
                    } else {
                        message.value = new Message({
                            text: result.response.data.message,
                            display: true,
                        });
                    }
                } catch (error: unknown) {
                    console.log(error);
                    const errorResult = error as ResponseResult;
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                        display: true,
                    });
                }
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
            breadcrumbItems,
            archivesData,
            rolesData,
            goBack,
            panelSwitchClicked,
            panelSwitchChanged,
            submitUserData,
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
