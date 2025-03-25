<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-expansion-panels v-model="panel" multiple>
            <v-expansion-panel value="general">
                <v-expansion-panel-title>{{ t('users.panels.general') }}</v-expansion-panel-title>
                <v-expansion-panel-text>
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
                            <text-field name="fldSurname" :label="t('users.columns.surname')" :disabled="true" />
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
                    <v-row>
                        <v-col class="col-12">
                            <text-field
                                name="fldOrganization"
                                :label="t('users.columns.organization')"
                                v-model="userData.organization"
                                :disabled="true"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col class="col-12">
                            <text-field
                                name="fldDepartment"
                                :label="t('users.columns.department')"
                                v-model="userData.department"
                                :disabled="true"
                            />
                        </v-col>
                    </v-row>
                    <v-row>
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
                        <v-col>
                            <text-field
                                name="fldEmail"
                                :label="t('users.columns.email')"
                                v-model="userData.email"
                                :disabled="true"
                            />
                        </v-col>
                    </v-row>
                </v-expansion-panel-text>
            </v-expansion-panel>
            <v-expansion-panel value="roles">
                <v-expansion-panel-title>{{ t('users.panels.roles') }}</v-expansion-panel-title>
                <v-expansion-panel-text>
                    <v-row>
                        <v-col class="col-12">
                            <span v-if="!userGlobalRoles" class="v-card-title-uppercase for-margin-bottom">{{
                                t('users.panels.globalRoles')
                            }}</span>
                            <div v-if="!userGlobalRoles">
                                <span
                                    >Служител {{ userData.displayName }} няма {{ t('users.panels.globalRoles') }}</span
                                >
                            </div>
                            <v-list-item
                                density="compact"
                                v-for="item in userGlobalRoles.sort()"
                                :key="item"
                                :value="item"
                                :title="item"
                            />
                            <v-divider></v-divider>
                            <span class="v-card-title-uppercase for-margin-bottom"
                                >{{ t('users.panels.roles') }} в {{ t('archives.title') }}</span
                            >
                            <div v-if="!userRoles">
                                <span
                                    >Служител {{ userData.displayName }} няма {{ t('users.panels.roles') }} в
                                    {{ t('archives.title') }}</span
                                >
                            </div>
                            <v-list-item
                                density="compact"
                                v-for="item in userRoles.sort()"
                                :key="item"
                                :value="item"
                                :title="item"
                            />
                        </v-col>
                    </v-row>
                </v-expansion-panel-text>
            </v-expansion-panel>
        </v-expansion-panels>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { Message } from '@/models/notification';

import { UserProfileAndRolesModel } from '@/models/profile';
import { IDropdownOption } from '@/interfaces/dropdown';
import profileService from '@/services/authentication.service';
import dropdownService from '@/services/dropdown.service';
import { ResponseResult } from '@/models/responseResult';
import TextField from '@/components/field/text.field.vue';
import { IMessage } from '@/interfaces/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';

export default defineComponent({
    name: 'DisplayUser',
    components: {
        TextField,
        Breadcrumbs,
    },

    setup() {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const panel = ref(['roles']);
        const userData = ref<UserProfileAndRolesModel>(new UserProfileAndRolesModel());

        const getUserData = async () => {
            try {
                userData.value = await profileService.displayCurrentUser();
            } catch (error: unknown) {
                console.error(error);
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
                console.error(error);
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
                console.error(error);
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const userRoles = ref<string[]>();
        userRoles.value = [];
        const userGlobalRoles = ref<string[]>();
        userGlobalRoles.value = [];
        const getUserRoles = async () => {
            try {
                if (userData.value.roles) {
                    userData.value.roles.forEach((roleId) => {
                        if (rolesData.value) {
                            const role = rolesData.value.filter((r) => r.code?.toString() == roleId)[0];
                            if (role.groupName) {
                                const archive = archivesData.value.filter((a) => a.label == role.groupName)[0];
                                userRoles.value?.push(`${archive.label}: ${role.label}`);
                            } else {
                                userGlobalRoles.value?.push(role.label!);
                            }
                        }
                    });
                }
            } catch (error: unknown) {
                console.error(error);
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
                title: t('users.panels.general'),
                disabled: true,
            },
        ];
        onMounted(async () => {
            await getUserData();
            await getArchivesData();
            await getRoles();
            await getUserRoles();
        });

        return {
            t,
            panel,
            userData,
            archivesData,
            rolesData,
            breadcrumbItems,
            message,
            getUserRoles,
            userGlobalRoles,
            userRoles,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';

.for-margin-bottom {
    display: inline-block;
    margin-bottom: 20px;
}

// .v-expansion-panel {
//     margin-top: 0px;
// }
</style>
