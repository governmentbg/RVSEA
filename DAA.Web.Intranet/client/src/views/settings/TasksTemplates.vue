<template>
    <Breadcrumbs :items="breadcrumbItems" />
    <Loader :isLoading="loading" />
    <v-container>
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <h3 class="text-center mb-3">
                {{ t('tasksTemplates.mainTitle') }}
            </h3>
            <CreateModal v-if="processesSteps" :items="processesSteps" class="mb-3 create-modal"></CreateModal>
            <v-row class="mt-3">
                <div class="col col-12 col-md-10 col-xl-10 mx-auto">
                    <div class="py-3">
                        <div>
                            <label class="ddl" for="fldProcessesSteps">{{ t('tasksTemplates.processSteps') }}</label>
                            <Dropdown
                                v-model="processesStep"
                                name="fldProcessesSteps"
                                :label="t('tasksTemplates.processSteps')"
                                labelProp="label"
                                valueProp="code"
                                :multiselect="false"
                                :items="processesSteps"
                            />
                        </div>
                    </div>
                </div>
            </v-row>
            <div v-if="processesStep">
                <!-- <div class="d-flex justify-content-center" v-if="loading">
                    <v-progress-circular :size="70" :width="7" color="primary" indeterminate></v-progress-circular>
                </div> -->
                <v-row v-if="!loading && !templates.length">
                    <v-col>
                        <v-alert color="red-darken-4" variant="outlined">
                            {{ t('tasksTemplates.noTemplates') }}
                        </v-alert>
                    </v-col>
                </v-row>
                <div v-if="templates && templates.length > 0">
                    <v-card class="p-3">
                        <v-list lines="two">
                            <v-list-item v-for="(item, i) in templates" :key="i">
                                <v-row class="border-bottom">
                                    <v-col cols="12" md="4" xl="4">
                                        <div class="d-flex align-items-start">
                                            <v-menu transition="scale-transition">
                                                <template v-slot:activator="{ props }">
                                                    <v-icon v-bind="props">mdi-dots-vertical</v-icon>
                                                </template>

                                                <v-list>
                                                    <v-list-item @click="update(item.taskTemplateId)">
                                                        <v-list-item-title>
                                                            <v-icon color="blue-darken-4">mdi-pencil</v-icon>
                                                            {{ t('common.edit') }}</v-list-item-title
                                                        >
                                                    </v-list-item>
                                                    <!-- <v-list-item @click="remove(item)">
                                                        <v-list-item-title>
                                                            <v-icon color="red-darken-4">mdi-delete</v-icon>
                                                            {{ t('common.delete') }}</v-list-item-title
                                                        >
                                                    </v-list-item> -->
                                                </v-list>
                                            </v-menu>
                                            <div>{{ item.title }}</div>
                                        </div>
                                    </v-col>
                                    <v-col cols="12" md="4" xl="4">
                                        <div>
                                            {{ item.description }}
                                        </div>
                                    </v-col>
                                    <v-col cols="12" md="4" xl="4">
                                        <div>{{ item.relatedContentUrl }}</div>
                                    </v-col>
                                </v-row>
                            </v-list-item>
                        </v-list>
                    </v-card>
                </div>
            </div>
            <UpdateModal
                v-if="processesSteps"
                :items="processesSteps"
                v-model:show="editDialog"
                v-model="editId"
                @updated="loadTemplates"
            ></UpdateModal>
        </v-card>
    </v-container>
</template>

<script lang="ts">
import { defineComponent, ref, watch, onMounted } from 'vue';
import { ITaskTemplate } from '@/models/taskTemplate';
import { useI18n } from 'vue-i18n';
import CreateModal from '@/components/taskTemplate/create.modal.vue';
import UpdateModal from '@/components/taskTemplate/update.modal.vue';
import { useStore } from '@/store/app';
import { IDropdownOption } from '@/interfaces/dropdown';
import dropdownService from '@/services/dropdown.service';
import Dropdown from '@/components/dropdown/dropdown.vue';
import taskTemplateService from '@/services/taskTemplate.service';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    components: {
        CreateModal,
        UpdateModal,
        Dropdown,
        Breadcrumbs,
        Loader,
    },

    setup() {
        const store = useStore();
        const { t } = useI18n();
        const templates = ref([] as ITaskTemplate[]);
        const processesStep = ref(null as number | null);
        const editDialog = ref(false);
        const editId = ref(0 as number);
        let text = '';
        const regex = new RegExp('<p>|</p>');

        const loading = ref(false);
        const loadTemplates = () => {
            templates.value = [];
            loading.value = true;

            taskTemplateService
                .get(processesStep.value!)
                .then((data) => {
                    templates.value = data;
                    templates.value.forEach((model) => {
                        text = model.description.split(regex)[1];
                        model.description = text;
                    });
                })
                .catch((err) => console.log(err))
                .then(() => (loading.value = false));
        };
        const update = (id: number) => {
            editId.value = id;
            editDialog.value = true;
        };

        const processesSteps = ref<IDropdownOption[]>([]);
        const getProcessesSteps = async () => {
            processesSteps.value = await dropdownService
                .getProcessesSteps()
                .then((data) => (processesSteps.value = data));
        };

        onMounted(() => {
            getProcessesSteps();
        });

        watch(
            () => processesStep.value,
            () => {
                loadTemplates();
            }
        );
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.tasksTemplates'),
                disabled: true,
            },
        ];
        return {
            store,
            t,
            templates,
            processesSteps,
            processesStep,
            getProcessesSteps,
            loadTemplates,
            update,
            loading,
            editId,
            editDialog,
            breadcrumbItems,
        };
    },
    methods: {
        onCreated() {
            this.loadTemplates();
        },
        buildUrl(id: number) {
            return this.store.getters.baseUrl + '/api/TasksTemplates/' + id;
        },
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/dialog.scss';
@import '@/assets/styles/breadcrumbs.scss';

:deep(.v-card) {
    padding-bottom: 200px;
    box-shadow: 0px 0px 10px -5px;
    margin-right: 10px;
    margin-left: 10px;
    margin-top: 30px !important;
}

:deep(.v-alert) {
    margin: 5px 30px;
}

:deep(.v-btn) {
    margin: 10px auto;
}

.ddl {
    margin-bottom: 10px;
}

:deep(.v-card.p-3) {
    padding-bottom: 0px !important;
    margin-bottom: 0px !important;
    box-shadow: none;
}
</style>
