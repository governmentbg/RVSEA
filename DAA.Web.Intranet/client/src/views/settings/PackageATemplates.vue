<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container>
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <h3 class="text-center mb-3">
                {{ $t('packageATemplates.mainTitle') }}
            </h3>
            <v-row class="mt-3">
                <div class="col col-12 col-md-6 col-xl-6 mx-auto">
                    <div class="py-3">
                        <div>
                            <v-select
                                :items="procedureTypes"
                                item-value="id"
                                item-title="label"
                                v-model="procedureType"
                                :label="$t('packageATemplates.process')"
                                variant="solo"
                            ></v-select>
                        </div>
                    </div>
                </div>
            </v-row>
            <div v-if="procedureType">
                <div class="d-flex justify-content-center" v-if="loading">
                    <v-progress-circular :size="70" :width="7" color="primary" indeterminate></v-progress-circular>
                </div>
                <CreateModal class="mb-3" @created="onCreated" :procedureId="procedureType"></CreateModal>
                <v-row v-if="!loading && !templates.length">
                    <v-col>
                        <v-alert color="red-darken-4" variant="outlined">
                            {{ $t('packageATemplates.noTemplates') }}
                        </v-alert>
                    </v-col>
                </v-row>
                <div v-if="templates && templates.length > 0">
                    <v-card class="p-3">
                        <v-list lines="two">
                            <v-list-item v-for="(item, i) in templates" :key="i">
                                <v-row class="border-bottom">
                                    <v-col cols="12" md="6" xl="3">
                                        <div class="d-flex align-items-start">
                                            <v-menu v-if="!item.static" transition="scale-transition">
                                                <template v-slot:activator="{ props }">
                                                    <v-icon v-bind="props">mdi-dots-vertical</v-icon>
                                                </template>

                                                <v-list>
                                                    <v-list-item @click="update(item.id)">
                                                        <v-list-item-title>
                                                            <v-icon color="blue-darken-4">mdi-pencil</v-icon>
                                                            {{ $t('common.edit') }}</v-list-item-title
                                                        >
                                                    </v-list-item>
                                                    <v-list-item @click="remove(item)">
                                                        <v-list-item-title>
                                                            <v-icon color="red-darken-4">mdi-delete</v-icon>
                                                            {{ $t('common.delete') }}</v-list-item-title
                                                        >
                                                    </v-list-item>
                                                </v-list>
                                            </v-menu>
                                            <div>{{ item.title }}</div>
                                        </div>
                                    </v-col>
                                    <v-col cols="12" md="6" xl="3">
                                        <div>
                                            {{ item.fileName }}
                                            <a :href="buildUrl(item.id)" class="text-decoration-none">
                                                <v-tooltip>
                                                    <template v-slot:activator="{ props }">
                                                        <v-icon color="primary" dark v-bind="props">
                                                            mdi-download
                                                        </v-icon>
                                                    </template>
                                                    <span>{{ $t('common.download') }}</span>
                                                </v-tooltip>
                                            </a>
                                        </div>
                                    </v-col>
                                    <v-col cols="12" md="6" xl="2">
                                        <div>
                                            {{
                                                item.required
                                                    ? $t('packageATemplates.required')
                                                    : $t('packageATemplates.notRequired')
                                            }}
                                        </div>
                                    </v-col>
                                    <v-col cols="12" md="6" xl="4">
                                        <div>{{ item.description }}</div>
                                    </v-col>
                                </v-row>
                            </v-list-item>
                        </v-list>
                    </v-card>
                </div>
            </div>
            <UpdateModal v-model:show="editDialog" v-model="editId" @updated="loadTemplates"></UpdateModal>
        </v-card>
    </v-container>
</template>

<script lang="ts">
import { IDropdownOption } from '@/interfaces/dropdown';
import dropdownService from '@/services/dropdown.service';
import { defineComponent, ref, watch } from 'vue';
import packageAService from '@/services/packageATemplates.service';
import { IPackageATemplate } from '@/models/packageATemplate';
import CreateModal from '@/components/packageATemplate/create.modal.vue';
import UpdateModal from '@/components/packageATemplate/update.modal.vue';
import { formatYesNo } from '@/helpers/format.helper';
import packageATemplateService from '@/services/packageATemplates.service';
import { useStore } from '@/store/app';
import { useI18n } from 'vue-i18n';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';

export default defineComponent({
    components: {
        CreateModal,
        UpdateModal,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();
        const store = useStore();
        const procedureTypes = ref([] as Array<IDropdownOption>);
        const templates = ref([] as IPackageATemplate[]);
        const procedureType = ref(null as number | null);
        const loading = ref(false);
        const editDialog = ref(false);
        const editId = ref(0 as number);
        const loadTemplates = () => {
            templates.value = [];
            loading.value = true;
            packageAService
                .get(procedureType.value!)
                .then((data) => {templates.value = data; loading.value = false})
                .catch((err) => console.log(err))
                .then(() => (loading.value = false));
        };
        const update = (id: number) => {
            editId.value = id;
            editDialog.value = true;
        };
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('packageATemplates.mainTitle'),
                disabled: true,
            },
        ];
        watch(
            () => procedureType.value,
            () => {
                loadTemplates();
            }
        );

        dropdownService
            .getCollectingProcedures()
            .then((data) => {
                procedureTypes.value = data;
            })
            .catch((err) => console.log(err));

        return {
            t,
            editDialog,
            editId,
            formatYesNo: formatYesNo,
            loading,
            loadTemplates,
            procedureType,
            procedureTypes,
            store,
            templates,
            update,
            breadcrumbItems,
        };
    },
    methods: {
        buildUrl(id: number) {
            return this.store.getters.baseUrl + '/api/PackageATemplates/download/' + id;
        },
        onCreated() {
            this.loadTemplates();
        },
        remove(item: IPackageATemplate) {
            const conf = confirm(this.$t('packageATemplates.deleteConfirmMessage', [item.title]));

            if (conf) {
                //TODO global loading
                packageATemplateService
                    .delete(item.id)
                    .then(() => {
                        //TODO success message
                        this.loadTemplates();
                    })
                    .catch(() => {
                        //TODO show error
                    });
            }
        },
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/dialog.scss';
@import '@/assets/styles/breadcrumbs.scss';

:deep(.v-card:last-of-type) {
    padding-bottom: 15px;
    margin-bottom: 0px !important;
    margin-top: 30px !important;
}
</style>
