<template>
    <Breadcrumbs :items="breadcrumbItems" />
    <Loader :isLoading="loading" />
    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <div class="text-center">
            <h3>{{ $t('applications.newApplication') }}</h3>
        </div>
        <div class="loader" v-if="loading"></div>
        <v-container>
            <Form @submit="showConfirm" ref="form">
                <v-row class="mb-3">
                    <v-col md="4" cols="12">
                        <div>
                            <TextField
                                :modelValue="userProfile.fullName"
                                :disabled="true"
                                :validation="'required'"
                                :label="$t('applications.create.creator')"
                            ></TextField>
                        </div>
                    </v-col>
                    <v-col md="4">
                        <div>
                            <TextField
                                :modelValue="userProfile.email"
                                :disabled="true"
                                :label="$t('applications.create.email')"
                            ></TextField>
                        </div>
                    </v-col>
                    <v-col md="4">
                        <div>
                            <TextField v-model="phone" :label="$t('applications.create.phone')"></TextField>
                        </div>
                    </v-col>
                    <v-col cols="12">
                        <div>
                            <TextField
                                :modelValue="userProfile.address"
                                :disabled="true"
                                :label="$t('applications.create.address')"
                            ></TextField>
                        </div>
                    </v-col>
                </v-row>
                <v-row class="mb-3">
                    <v-col md="4" cols="12">
                        <div>
                            <TextField
                                v-model="organization"
                                :label="$t('applications.create.representativeOf')"
                            ></TextField>
                        </div>
                    </v-col>
                    <v-col md="4" cols="12">
                        <div>
                            <TextField
                                v-model="organizationEIK"
                                :label="$t('applications.create.organizationEIK')"
                            ></TextField>
                        </div>
                    </v-col>
                    <v-col md="4" cols="12">
                        <div>
                            <TextField
                                v-model="organizationRepresentative"
                                :label="$t('applications.create.organizationRepresentative')"
                            ></TextField>
                        </div>
                    </v-col>
                </v-row>
                <v-row class="mb-3">
                    <v-col md="4">
                        <div>
                            <SelectField
                                :items="archives"
                                v-model="archiveId"
                                :valueProp="'id'"
                                :required="true"
                                name="archive"
                                :label="$t('applications.create.archive') + '*'"
                            ></SelectField>
                        </div>
                    </v-col>
                    <v-col md="4">
                        <div>
                            <SelectField
                                :items="applicationTypes"
                                v-model="type"
                                :valueProp="'code'"
                                :required="true"
                                name="applicationType"
                                :label="$t('applications.create.applicationType') + '*'"
                            ></SelectField>
                        </div>
                    </v-col>
                    <v-col md="4" cols="12">
                        <div>
                            <TextField
                                name="documentsOwner"
                                v-model="documentsOwner"
                                :validation="'required'"
                                :label="$t('applications.create.documentsOwner')"
                            ></TextField>
                        </div>
                    </v-col>
                    <v-col md="4" cols="12">
                        <div>
                            <TextField
                                name="documentsSize"
                                v-model="documentsSize"
                                :validation="'positiveNumber'"
                                :label="$t('applications.create.documentsSize')"
                                type="number"
                            ></TextField>
                        </div>
                    </v-col>
                    <v-col md="4" cols="12">
                        <div>
                            <TextField
                                name="documentsPeriod"
                                :label="$t('applications.create.documentsPeriod')"
                                v-model="documentsPeriod"
                                validation="required|documentsPeriod"
                            ></TextField>
                        </div>
                    </v-col>
                    <v-col md="4" cols="12">
                        <div>
                            <SelectField
                                :items="originTypes"
                                v-model="originType"
                                :valueProp="'code'"
                                :required="true"
                                name="originType"
                                :label="$t('applications.create.documentsOrigin') + '*'"
                            ></SelectField>
                        </div>
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="text-center">
                        <v-btn class="me-3" color="primary" variant="outlined" type="submit"
                            >{{ $t('common.send') }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ $t('applications.sendApplicationTooltip') }}
                            </v-tooltip>
                        </v-btn>
                        <v-btn class="cancel" color="danger" variant="outlined" type="button" @click="goBack"
                            >{{ $t('common.cancel') }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ $t('applications.cancelApplicationTooltip') }}
                            </v-tooltip>
                        </v-btn>
                    </v-col>
                </v-row>
            </Form>
        </v-container>

        <v-dialog id="dialog-to-center" v-model="dialog" persistent>
            <v-card>
                <v-card-title class="text-h5">
                    {{ $t('applications.create.confirmTitle') }}
                </v-card-title>
                <v-card-text>{{ $t('applications.create.confirmMessage') }}</v-card-text>
                <v-card-actions>
                    <!-- <v-spacer></v-spacer> -->
                    <v-col class="text-center">
                        <v-btn color="blue darken-1" text @click="submitApplication">
                            {{ $t('common.yes') }}
                        </v-btn>
                        <v-btn class="cancel" color="red darken-1" text @click="dialog = false">
                            {{ $t('common.no') }}
                        </v-btn>
                    </v-col>
                </v-card-actions>
            </v-card>
        </v-dialog>

        <!-- <v-overlay :model-value="loading" class="align-center justify-center">
			<v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
		</v-overlay> -->
    </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, onBeforeMount, computed, inject, Ref } from 'vue';
import { useStore as useUserStore } from '@/store/user';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import applicationService from '@/services/applications.service';
import { ApplicationCreateModel } from '@/models/applications';
import dropdownService from '@/services/dropdown.service';
import { IDropdownOption } from '@/interfaces/dropdown';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { useI18n } from 'vue-i18n';
import profileService from '@/services/profile.service';
import { UserProfileModel } from '@/models/profile';
import { Form, ValidationResult } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';
import SelectField from '@/components/dropdown/select.vue';
import { ProfileType } from '@/enums/profile';
import { useRedirect } from '@/helpers/router.helper';
import { useRouter } from 'vue-router';
import Loader from '@/components/loader/loader.vue';
import { ResponseResult } from '@/models/responseResult';

export default defineComponent({
    name: 'ApplicationsCreate',
    components: {
        Breadcrumbs,
        SelectField,
        TextField,
        Form,
        Loader,
    },
    setup() {
        const message = inject('notificationMessage') as Ref<IMessage>;
        const router = useRouter();
        const isUserFDN = () => {
            if (userStore.getters.profileType != ProfileType.FundCreator) {
                useRedirect(router, 'AccessDenied');
            }
        };

        const { t } = useI18n();
        const userStore = useUserStore();
        const userName = ref(userStore.getters.fullName);
        const email = ref(userStore.getters.email);
        const application = ref(null as File | null);
        const archiveId = ref<string>();
        const type = ref<string>();
        const dialog = ref(false);
        const loading = ref(true);
        const archives = ref([] as IDropdownOption[]);
        const applicationTypes = ref([] as IDropdownOption[]);
        const userProfile = ref({} as UserProfileModel);
        const documentsOwner = ref<string>('');
        const documentsSize = ref<number>(0);
        const documentsPeriod = ref<string>('');
        const organization = ref();
        const organizationRepresentative = ref();
        const organizationEIK = ref();
        const phone = ref();
        const originType = ref<string>();
        const originTypes = ref([
            {
                code: 'insitutional',
                label: 'Документи от учрежденски произход (обработени)',
            },
            {
                code: 'insitutional_raw',
                label: 'Документи от учрежденски произход (необработени)',
            },
            {
                code: 'personal_raw',
                label: 'Документи от личен произход (необработени)',
            },
        ] as IDropdownOption[]);

        Promise.all([
            dropdownService.getArchives(),
            dropdownService.getApplicationTypes(),
            profileService.getProfile(),
        ]).then((values) => {
            archives.value = values[0];
            applicationTypes.value = values[1];
            userProfile.value = values[2];
            loading.value = false;
        });

        const breadcrumbItems = computed(() => [
            {
                title: t('navigation.left.home'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('applications.myApplications'),
                disabled: false,
                to: { name: 'Applications' },
            },
            {
                title: t('applications.newApplication'),
                disabled: true,
            },
        ]);
        onBeforeMount(() => {
            isUserFDN();
        });

        return {
            message,
            application,
            applicationTypes,
            archiveId,
            archives,
            breadcrumbItems,
            dialog,
            documentsOwner,
            documentsPeriod,
            documentsSize,
            email,
            loading,
            originType,
            originTypes,
            organization,
            organizationEIK,
            organizationRepresentative,
            phone,
            type,
            userName,
            userProfile,
            userStore,
            isUserFDN,
        };
    },
    methods: {
        goBack() {
            this.$router.back();
        },
        onFileChange(file: File) {
            this.application = file || null;
        },
        showConfirm() {
            (this.$refs.form as typeof Form).validate().then((result: ValidationResult) => {
                if (result.valid) {
                    this.dialog = true;
                }
            });
        },
        submitApplication() {
            this.dialog = false;
            this.loading = true;

            const model = new ApplicationCreateModel({
                archiveId: this.archiveId!,
                type: this.type!,
                applicantId: this.userStore.getters.userId,
                applicantFullName: this.userProfile.fullName || '',
                applicantPhone: this.phone || null,
                organizationEIK: this.organizationEIK || null,
                organizationRepresentative: this.organizationRepresentative,
                documentsOwner: this.documentsOwner,
                documentsSize: this.documentsSize || 0,
                documentsPeriod: this.documentsPeriod,
                documentsOriginType: this.originType!,
                organization: this.organization || '',
                applicantEmail: this.userProfile.email || '',
                address: this.userProfile.address || '',
            });

            applicationService
                .create(model)
                .then(() => {
                    //TODO show message
                    this.$router.push({ name: 'Applications' });
                })
                .catch((error) => {
                    console.error(error);
                    const errorResult = error as ResponseResult;
                    this.message = new Message({
                        text: errorResult.showMessage ? errorResult.message : this.$t('error.basic'),
                        display: true,
                    });
                })
                .then(() => (this.loading = false));
        },
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';

.v-dialog {
    max-width: 500px;
}

#dialog-to-center {
    justify-content: center !important;
    text-align: center !important;
}

#dialog-to-center .v-card .v-card-title {
    text-align: center !important;
}
</style>
