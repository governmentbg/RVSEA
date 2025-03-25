<template>
    <Loader :isLoading="loading" />
    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <div class="text-center">
            <h3>{{ $t('applications.create.application') }}</h3>
        </div>
        <div class="loader" v-if="loading"></div>
        <v-container>
            <v-card class="mb-3">
                <v-card-title class="v-card-title-uppercase">{{ $t('applications.application') }}</v-card-title>
                <v-card-text>
                    <v-row>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.create.creator') }}
                            </div>
                            <div>
                                {{ application.applicantFullName }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.create.email') }}
                            </div>
                            <div>
                                {{ application.applicantEmail }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.create.phone') }}
                            </div>
                            <div>
                                {{ application.applicantPhone }}
                            </div>
                        </v-col>
                        <v-col cols="12">
                            <div class="fw-bold">
                                {{ $t('applications.create.address') }}
                            </div>
                            <div>
                                {{ application.address }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.create.representativeOf') }}
                            </div>
                            <div>
                                {{ application.organization }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.create.organizationEIK') }}
                            </div>
                            <div>
                                {{ application.organizationEIK }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.create.organizationRepresentative') }}
                            </div>
                            <div>
                                {{ application.organizationRepresentative }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.create.archive') }}
                            </div>
                            <div>
                                {{ application.archive }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.create.applicationType') }}
                            </div>
                            <div>
                                {{ application.type }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.create.documentsOwner') }}
                            </div>
                            <div>
                                {{ application.documentsOwner }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.create.documentsSize') }}
                            </div>
                            <div>
                                {{ application.documentsSize }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.create.documentsPeriod') }}
                            </div>
                            <div>
                                {{ application.documentsPeriod }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.create.documentsOrigin') }}
                            </div>
                            <div>
                                {{ application.documentsOriginType }}
                            </div>
                        </v-col>
                    </v-row>
                    <hr />
                    <v-row>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.display.applicationDate') }}
                            </div>
                            <div>
                                {{ formatDateTime(application.applicationDate) }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.display.status') }}
                            </div>
                            <div>
                                {{ application.status }}
                            </div>
                        </v-col>
                        <v-col md="4" v-if="application.rejectReason">
                            <div class="fw-bold">
                                {{ $t('applications.display.rejectReason') }}
                            </div>
                            <div>
                                {{ application.rejectReason }}
                            </div>
                        </v-col>
                        <v-col md="4" v-else-if="application.packageARejectReason">
                            <div class="fw-bold">
                                {{ $t('applications.display.rejectReason') }}
                            </div>
                            <div>
                                {{ application.packageARejectReason }}
                            </div>
                        </v-col>
                        <v-col md="4" v-else-if="application.packageBRejectReason">
                            <div class="fw-bold">
                                {{ $t('applications.display.rejectReason') }}
                            </div>
                            <div>
                                {{ application.packageBRejectReason }}
                            </div>
                        </v-col>
                        <v-col md="4" v-if="application.redirectedFromArchiveName">
                            <div class="fw-bold">
                                {{ $t('applications.display.redirectedFromArchive') }}
                            </div>
                            <div>
                                {{ application.redirectedFromArchiveName }}
                            </div>
                        </v-col>
                        <v-col md="4" v-if="application.redirectedToArchiveName">
                            <div class="fw-bold">
                                {{ $t('applications.display.redirectedToArchive') }}
                            </div>
                            <div>
                                {{ application.redirectedToArchiveName }}
                            </div>
                        </v-col>
                    </v-row>
                </v-card-text>
            </v-card>
            <PackagesDisplay
                :applicationId="id"
                :readonly="true"
                v-if="application && application.statusId > Status.addPackages && application.typeId !== 'assembled'"
            ></PackagesDisplay>
            <PackagesDisplayWithImport
                :applicationId="id"
                :readonly="true"
                v-if="application && application.statusId > Status.addPackages && application.typeId === 'assembled'"
            ></PackagesDisplayWithImport>
            <v-row>
                <v-col cols="12" class="text-center my-3">
                    <v-btn class="cancel" variant="outlined" color="primary" @click="$router.back()"
                        >{{ $t('common.back') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ $t('applications.backApplicationTooltip') }}
                        </v-tooltip>
                    </v-btn>
                </v-col>
            </v-row>
        </v-container>
        <!-- <v-overlay :model-value="loading" class="align-center justify-center">
			<v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
		</v-overlay> -->
    </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, onBeforeMount } from 'vue';
import applicationService from '@/services/applications.service';
import { formatDateTime } from '@/helpers/format.helper';
import { useStore } from '@/store/app';
import { useStore as useUserStore } from '@/store/user';
import { IApplicationDisplay } from '@/models/applications';
import { ProfileType } from '@/enums/profile';
import { useRedirect } from '@/helpers/router.helper';
import { useRouter } from 'vue-router';
import PackagesDisplay from '@/components/packageA/display.vue';
import PackagesDisplayWithImport from '@/components/packageA/displayWithImport.vue';
import Loader from '@/components/loader/loader.vue';

//eslint-di
export enum Status {
    new = 1, // eslint-disable-line
    approved = 2, // eslint-disable-line
    rejected = 3, // eslint-disable-line
    addPackages = 4, // eslint-disable-line
    updatePackages = 5, // eslint-disable-line
    rejectedByCommittee = 6, // eslint-disable-line
    approvedByCommittee = 7, // eslint-disable-line
    awaitingCommittee = 8, // eslint-disable-line
    committeeDecisionUpdate = 9, // eslint-disable-line
    registration = 10, // eslint-disable-line
    registrationComplete = 11, // eslint-disable-line
    packagesApproval = 12, // eslint-disable-line
}

export default defineComponent({
    name: 'ApplicationsDisplay',
    components: {
        PackagesDisplay,
        PackagesDisplayWithImport,
        Loader,
    },
    props: {
        id: {
            type: Number,
            required: true,
        },
    },
    setup(props) {
        const appStore = useStore();
        const loading = ref(true);
        const application = ref({} as IApplicationDisplay);
        const uStore = useUserStore();
        const router = useRouter();

        const isUserFDN = () => {
            if (uStore.getters.profileType != ProfileType.FundCreator) {
                console.log(uStore.getters.profileType);
                useRedirect(router, 'AccessDenied');
            }
        };

        applicationService
            .get(props.id)
            .then((response) => {
                application.value = response.data as IApplicationDisplay;
            })
            .catch((error) => console.log(error))
            .then(() => {
                loading.value = false;
            });
        onBeforeMount(() => {
            isUserFDN();
        });

        return {
            application,
            appStore,
            formatDateTime,
            loading,
            isUserFDN,
            Status,
        };
    },
    methods: {},
    computed: {
        downloadUrl() {
            const url = `${this.appStore.getters.baseUrl}/api/EDocsCollectingApplications/download/${this.application.id}`;
            return url;
        },
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
</style>
