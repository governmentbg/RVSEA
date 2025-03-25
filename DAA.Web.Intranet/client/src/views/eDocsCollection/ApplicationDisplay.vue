<template>
    <Breadcrumbs :items="breadcrumbItems" />
    <Loader :isLoading="loading" />
    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <div class="text-center">
            <h3>{{ $t('applications.displayTitle') }} &numero;{{ application.number }}</h3>
        </div>
        <v-container>
            <v-card>
                <v-card-text>
                    <h4>{{ $t('applications.display.title') }}</h4>
                </v-card-text>
                <v-card-text>
                    <v-row>

                        <v-col v-if="application.statusId == applicationStatus.registrationComplete" md="4">
                            <div class="fw-bold">
                                {{ $t('eDocsCollection.index.grid.cols.archive') }}
                            </div>
                            <div>
                                <router-link :to="`/settings/archives/display/${application.archiveId}`" target="_blank">{{
                                    application.archive
                                }}</router-link>
                            </div>
                        </v-col>
                        <v-col v-if="application.statusId == applicationStatus.registrationComplete" md="4">
                            <div class="fw-bold">
                                {{ $t('eDocsCollection.index.grid.cols.fund') }}
                            </div>
                            <div>
                                <router-link :to="`/funds/display/${application.fundSysId}`" target="_blank">{{
                                    application.fundNumber
                                }}</router-link>
                            </div>
                        </v-col>
                        <v-col v-if="application.statusId == applicationStatus.registrationComplete" md="4">
                            <div class="fw-bold">
                                {{ $t('eDocsCollection.index.grid.cols.inventory') }}
                            </div>
                            <div>
                                <router-link
                                    :to="`/inventories/display/${application.inventorySysId}`"
                                    target="_blank"
                                    >{{ application.inventorySysId }}</router-link
                                >
                            </div>
                        </v-col>

                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.display.creator') }}
                            </div>
                            <div>
                                {{ application.applicantFullName }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.display.email') }}
                            </div>
                            <div>
                                {{ application.applicantEmail }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.display.phone') }}
                            </div>
                            <div>
                                {{ application.applicantPhone }}
                            </div>
                        </v-col>
                        <v-col cols="12">
                            <div class="fw-bold">
                                {{ $t('applications.display.address') }}
                            </div>
                            <div>
                                {{ application.address }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.display.representativeOf') }}
                            </div>
                            <div>
                                {{ application.organization }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.display.organizationEIK') }}
                            </div>
                            <div>
                                {{ application.organizationEIK }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.display.organizationRepresentative') }}
                            </div>
                            <div>
                                {{ application.organizationRepresentative }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.display.archive') }}
                            </div>
                            <div>
                                {{ application.archive }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.display.applicationType') }}
                            </div>
                            <div>
                                {{ application.type }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.display.documentsOwner') }}
                            </div>
                            <div>
                                {{ application.documentsOwner }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.display.documentsSize') }}
                            </div>
                            <div>
                                {{ application.documentsSize }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.display.documentsPeriod') }}
                            </div>
                            <div>
                                {{ application.documentsPeriod }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('applications.display.documentsOrigin') }}
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
                <v-row v-if="application.statusId === applicationStatus.new" class="mb-3">
                    <v-col class="text-center d-flex gap-2 justify-content-center">
                        <v-btn @click="onApproveClick">{{ $t('applications.grid.btns.approve') }}</v-btn>
                        <v-btn color="danger" @click="onRejectClick">{{ $t('applications.grid.btns.reject') }}</v-btn>
                    </v-col>
                </v-row>
            </v-card>
            <v-card v-if="application.statusId !== applicationStatus.new">
                <v-card-text> <h4>Пакети</h4> </v-card-text>
                <v-card-text>
                    <v-row>
                        <v-col>
                            <ListPackages
                                :applicationId="id"
                                :readonly="application.statusId !== applicationStatus.packagesApproval"
                                :applicationTypeId="application.typeId"
                            ></ListPackages>
                        </v-col>
                    </v-row>
                </v-card-text>
            </v-card>
            <v-card v-if="application.statusId !== applicationStatus.new">
                <v-card-text> <h4>Процес</h4> </v-card-text>
                <v-card-text>
                    <v-row v-if="process">
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('eDocsCollection.index.grid.cols.type') }}
                            </div>
                            <div>
                                {{ process.processTypeTitle }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('eDocsCollection.index.grid.cols.startedOn') }}
                            </div>
                            <div>
                                {{ formatDateTime(process.createdOn) }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('eDocsCollection.index.grid.cols.startedBy') }}
                            </div>
                            <div>
                                {{ process.createdByDisplayName }}
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('eDocsCollection.index.grid.cols.archive') }}
                            </div>
                            <div>
                                <router-link :to="`/settings/archives/display/${process.archiveId}`" target="_blank">{{
                                    process.archiveName
                                }}</router-link>
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('eDocsCollection.index.grid.cols.fund') }}
                            </div>
                            <div>
                                <router-link :to="`/funds/display/${process.fundSystemId}`" target="_blank">{{
                                    process.fundNumber
                                }}</router-link>
                            </div>
                        </v-col>
                        <v-col md="4">
                            <div class="fw-bold">
                                {{ $t('eDocsCollection.index.grid.cols.inventory') }}
                            </div>
                            <div>
                                <router-link
                                    :to="`/inventories/display/${process.inventorySystemId}`"
                                    target="_blank"
                                    >{{ process.inventorySystemId }}</router-link
                                >
                            </div>
                        </v-col>
                    </v-row>
                    <v-alert border="start" border-color="error" elevation="2" prominent v-if="!process">
                        <v-col>
                            {{ $t('applications.noProcessMsg') }}
                        </v-col>
                    </v-alert>
                </v-card-text>
            </v-card>
        </v-container>

        <v-dialog v-model="showApprove" persistent>
            <v-card>
                <v-card-title class="text-h5">
                    {{ $t('applications.approvement') }}
                </v-card-title>
                <v-card-text>
                    <div>
                        {{ $t('applications.assignTo') }}
                    </div>
                    <div>
                        <Dropdown
                            :items="users"
                            v-model="application.assignToId"
                            :valueProp="'code'"
                            :labelProp="'label'"
                        />
                        <div class="text-danger" v-if="users.length === 0">
                            {{ $t('applications.noUsersOfGroup', { group: roleNames.GroupB }) }}
                        </div>
                    </div>
                </v-card-text>
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <dialog-btn :disabled="!application.assignToId" @click="approve">
                        {{ $t('common.save') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('common.saveTooltip') }}
                        </v-tooltip>
                    </dialog-btn>
                    <cancel-btn text @click="hideApprove">
                        {{ $t('common.cancel') }}
                    </cancel-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>

        <v-dialog v-model="showReject" persistent>
            <v-card style="min-width: 300px">
                <v-card-title class="text-h5">
                    {{ $t('applications.rejection') }}
                </v-card-title>
                <v-card-text>
                    <div>
                        {{ $t('applications.rejectReason') }}
                    </div>
                    <div>
                        <TextField v-model="application.rejectReason"></TextField>
                    </div>
                </v-card-text>
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <dialog-btn :disabled="!application.rejectReason" @click="reject">
                        {{ $t('common.save') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('common.saveTooltip') }}
                        </v-tooltip>
                    </dialog-btn>
                    <cancel-btn @click="hideReject">
                        {{ $t('common.cancel') }}
                    </cancel-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>

        <!-- <v-overlay :model-value="loading" class="align-center justify-center">
            <v-progress-circular indeterminate size="64" color="primary"></v-progress-circular>
        </v-overlay> -->
    </v-card>
</template>

<script lang="ts">
import { computed, defineComponent, ref } from 'vue';
import applicationService from '@/services/applications.service';
import { IApplicationDisplay } from '@/models/applications';
import { formatDateTime } from '@/helpers/format.helper';
import { useStore } from '@/store/app';
import dropdownService from '@/services/dropdown.service';
import { RoleNames } from '@/enums/roles';
import TextField from '@/components/field/text.field.vue';
import { IDropdownOption } from '@/interfaces/dropdown';
import { Status as ApplicationStatus } from '@/enums/applications';
import ListPackages from '@/components/packageA/listForApproval.vue';
import { IProcess } from '@/interfaces/process';
import { useI18n } from 'vue-i18n';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import Loader from '@/components/loader/loader.vue';
import Dropdown from '@/components/dropdown/dropdown.vue';
export default defineComponent({
    name: 'ApplicationsDisplay',
    components: {
        ListPackages,
        TextField,
        Breadcrumbs,
        Loader,
        Dropdown,
    },
    props: {
        id: {
            type: Number,
            required: true,
        },
    },
    setup(props) {
        const appStore = useStore();
        const dialog = ref(false);
        const loading = ref(true);
        const application = ref({} as IApplicationDisplay);
        const process = ref({} as IProcess);
        const users = ref([] as IDropdownOption[]);
        const { t } = useI18n();
        applicationService
            .get(props.id)
            .then((data) => {
                application.value = data;
            })
            .catch((error) => console.log(error))
            .then(() => {
                loading.value = false;
                dropdownService.getUsersInRoles(application.value.archiveId, [RoleNames.GroupB]).then((data) => {
                    users.value = [...data];
                });
            });

        applicationService
            .getRelatedProcess(props.id)
            .then((data) => {
                process.value = data;
            })
            .catch((error) => console.log(error));

        const breadcrumbItems = ref([
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('applications.title'),
                to: { name: 'ЕDocsCollectingApplications' },
                disabled: false,
            },
            {
                title: computed(() => application.value.type),
                disabled: true,
            },
        ]);
        return {
            t,
            application,
            breadcrumbItems,
            applicationStatus: ApplicationStatus,
            appStore,
            dialog,
            dropdownService,
            formatDateTime,
            loading,
            process,
            roleNames: RoleNames,
            users,
        };
    },
    data() {
        return {
            showApprove: false,
            showReject: false,
        };
    },
    methods: {
        onApproveClick() {
            console.log('approved');
            this.showApprove = true;
        },
        onRejectClick() {
            console.log('rejected');
            this.showReject = true;
        },
        hideApprove() {
            this.showApprove = false;
            this.application.assignToId = '';
        },
        hideReject() {
            this.showReject = false;
            this.application.rejectReason = '';
        },
        approve() {
            this.showApprove = false;
            this.loading = true;
            applicationService
                .approve({
                    id: this.application.id,
                    userId: this.application.assignToId,
                })
                .then(() => this.$router.push('/edocscollection/applications'))
                .catch((err) => console.log(err))
                .then(() => (this.loading = false));
        },
        reject() {
            this.showReject = false;
            this.loading = true;
            applicationService
                .reject({
                    id: this.application.id,
                    reason: this.application.rejectReason,
                })
                .then(() => this.$router.push({ name: 'ЕDocsCollectingApplications' }))
                .catch((err) => console.log(err))
                .then(() => (this.loading = false));
        },
    },
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
@import '@/assets/styles/dialog.scss';
@import '@/assets/styles/breadcrumbs.scss';

:deep(.v-overlay__content > div.v-card) {
    min-height: 300px !important;
    min-width: 300px !important;
}
</style>
