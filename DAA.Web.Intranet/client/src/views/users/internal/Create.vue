<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('users.create') }}</v-card-title>
        <Form @submit="submitUserData">
            <v-expansion-panels v-model="panel" multiple>
                <v-expansion-panel :value="0">
                    <v-expansion-panel-title>{{ t('users.panels.general') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldUserName"
                                    :label="t('users.columns.userName')"
                                    v-model="userData.userName"
                                    validation="required"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldFirstName"
                                    :label="t('users.columns.firstName')"
                                    v-model="userData.firstName"
                                    validation="required"
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
                                    validation="required"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldOrganization"
                                    :label="t('users.columns.organization')"
                                    v-model="userData.organization"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDepartment"
                                    :label="t('users.columns.department')"
                                    v-model="userData.department"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldJobTitle"
                                    :label="t('users.columns.jobTitle')"
                                    v-model="userData.jobTitle"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col>
                                <text-field
                                    name="fldEmail"
                                    :label="t('users.columns.email')"
                                    v-model="userData.email"
                                    validation="required|email"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="globalRoles">
                    <v-expansion-panel-title>{{ t('users.panels.globalRoles') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <checkbox-list
                                    :items="rolesData.filter((r) => !r.groupName)"
                                    valueProp="code"
                                    v-model="userData.roles"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel
                    v-for="archive in archivesData"
                    :key="archive"
                    :value="archive.id"
                    :readonly="userData.archives.findIndex((a) => a === archive.id) < 0"
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
                            :items="rolesData.filter((r) => r.groupName === archive.label)"
                            valueProp="code"
                            v-model="userData.roles"
                            :disabled="userData.archives.findIndex((a) => a === archive.id) < 0"
                        />
                    </v-expansion-panel-text>
                </v-expansion-panel>
            </v-expansion-panels>
            <v-row>
                <v-col class="d-flex mt-3 mb-3 justify-content-center">
                    <v-btn class="mr-4" :disabled="!createButtonIsActive" type="submit"
                        >{{ t('common.save') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('common.saveTooltip') }}
                        </v-tooltip>
                    </v-btn>
                    <v-divider vertical></v-divider>
                    <v-btn class="clear bg-secondary" @click="goBack"
                        >{{ t('common.cancel') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('users.buttons.cancelTooltip') }}
                        </v-tooltip>
                    </v-btn>
                </v-col>
            </v-row>
        </Form>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, inject, onMounted, Ref } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useRedirect } from '@/helpers/router.helper';

import userService from '@/services/user.service';
import dropdownService from '@/services/dropdown.service';
import { UserInfo } from '@/models/userInfo';
import { IDropdownOption } from '@/interfaces/dropdown';
import { Message } from '@/models/notification';
import { AuthenticationType } from '@/enums/authType';
import { ApplicationUserType } from '@/enums/userType';
import { ApplicationUserProfileType } from '@/enums/profile';
import { ResponseResult } from '@/models/responseResult';
import { Form } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';
import CheckboxList from '@/components/checkbox/checkboxlist.vue';
import { IMessage } from '@/interfaces/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';

export default defineComponent({
    name: 'CreateUser',
    components: {
        Form,
        TextField,
        CheckboxList,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();

        const message = inject('notificationMessage') as Ref<IMessage>;
        const createButtonIsActive = ref(true);
        const panel = ref([0]);

        const router = useRouter();
        const goBack = () => {
            useRedirect(router, 'Users');
        };

        const userData = ref(new UserInfo());

        const archivesData = ref<IDropdownOption[]>([]);
        const getArchivesData = async () => {
            try {
                archivesData.value = await dropdownService.getArchives();
            } catch (error: unknown) {
                console.error(error);
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
                console.error(error);
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
            if (userData.value.archives.findIndex((a) => a === value.id) > -1) {
                panel.value.push(value.id!);
            } else {
                const roles = rolesData.value.filter((r) => r.groupName === value.label);
                userData.value.roles = userData.value.roles?.filter((r) => !roles.find((i) => i.code === r));

                panel.value.splice(panel.value.indexOf(value.id!), 1);
            }
        };

        const submitUserData = async () => {
            try {
                createButtonIsActive.value = false;
                userData.value.authenticationType = AuthenticationType.Negotiate;
                userData.value.userType = ApplicationUserType.Internal;
                userData.value.userProfileType = ApplicationUserProfileType.Employee;
                const result = await userService.createUser(userData.value);
                if (result.status == 200) {
                    message.value = new Message({
                        text: t('common.successfullyCreated'),
                        display: true,
                        type: 'success',
                        timeout: 5000,
                    });
                    createButtonIsActive.value = true;
                    goBack();
                }
            } catch (error: unknown) {
                console.error(error);
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
                createButtonIsActive.value = true;
            }
        };
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.internalUsers'),
                disabled: false,
                to: { name: 'Users' },
            },
            {
                title: t('users.create'),
                disabled: true,
            },
        ];
        onMounted(async () => {
            await getArchivesData();
            await getRoles();
        });

        return {
            t,
            panel,
            userData,
            createButtonIsActive,
            breadcrumbItems,
            archivesData,
            rolesData,
            submitUserData,
            goBack,
            panelSwitchClicked,
            panelSwitchChanged,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
