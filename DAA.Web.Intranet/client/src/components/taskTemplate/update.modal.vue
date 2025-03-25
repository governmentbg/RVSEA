<template>
    <v-row justify="start">
        <v-dialog persistent v-model="showModal">
            <v-card class="vw-50 p-3">
                <v-card-title class="text-h5 text-center">
                    {{ $t('packageATemplates.updateTitle') }}
                </v-card-title>
                <div class="d-flex justify-content-center w-100" v-if="loading">
                    <v-progress-circular :size="50" :width="5" color="primary" indeterminate></v-progress-circular>
                </div>
                <Form @submit="onSubmit" v-show="!loading">
                    <v-card-text>
                        <v-container>
                            <v-row>
                                <v-col cols="12">
                                    <label class="ddl" for="fldProcessesSteps">{{
                                        t('tasksTemplates.processSteps')
                                    }}</label>
                                    <Dropdown
                                        v-model="model.processesStepId"
                                        name="fldProcessesSteps"
                                        :label="t('tasksTemplates.processSteps')"
                                        labelProp="label"
                                        valueProp="code"
                                        :multiselect="true"
                                        :items="items"
                                        required="required"
                                    />
                                </v-col>
                                <v-col cols="12">
                                    <text-field
                                        v-model="model.title"
                                        :label="t('tasksTemplates.title')"
                                        :validation="'required'"
                                    ></text-field>
                                </v-col>
                                <v-col cols="12">
                                    <text-area-field
                                        v-model="model.description"
                                        :label="t('tasksTemplates.description')"
                                        :validation="'required'"
                                    ></text-area-field>
                                </v-col>
                                <v-col cols="12">
                                    <text-field
                                        v-model="model.relatedContentUrl"
                                        :label="t('tasksTemplates.relatedContentUrl')"
                                        :readonly="true"
                                    ></text-field>
                                </v-col>
                            </v-row>
                        </v-container>
                    </v-card-text>
                    <v-card-actions>
                        <v-spacer></v-spacer>
                        <submit-btn
                            v-if="model.processesStepId"
                            type="submit"
                            :disabled="model.processesStepId.length < 1 || loading"
                        >
                            {{ t('common.edit') }}
                        </submit-btn>
                        <cancel-btn @click="onClose" :disabled="loading">
                            {{ t('common.cancel') }}
                        </cancel-btn>
                    </v-card-actions>
                </Form>
            </v-card>
        </v-dialog>
    </v-row>
</template>

<script lang="ts">
import { defineComponent, ref, PropType, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { Form } from 'vee-validate';
import { TaskTemplateUpdateModel } from '@/models/taskTemplate';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import taskService from '@/services/taskTemplate.service';
import { IDropdownOption } from '@/interfaces/dropdown';
import Dropdown from '@/components/dropdown/dropdown.vue';
import { ResponseResult } from '@/models/responseResult';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
export default defineComponent({
    components: {
        TextField,
        TextAreaField,
        Form,
        Dropdown,
    },
    emits: ['updated', 'update:show'],
    props: {
        modelValue: {
            type: Number,
            required: true,
        },
        show: {
            type: Boolean,
            required: true,
        },
        items: {
            type: Array as PropType<IDropdownOption[]>,
            default: () => [],
        },
    },
    setup(props) {
        const { t } = useI18n();
        const model = ref(new TaskTemplateUpdateModel());
        const loading = ref(false);
        const message = inject('notificationMessage') as Ref<IMessage>;
        const showModal = ref(false);

        const loadData = () => {
            loading.value = true;
            taskService
                .getTemplate(props.modelValue)
                .then((data) => {
                    model.value = new TaskTemplateUpdateModel(data);
                    console.log(data);
                    model.value.description = data.description;
                })
                .catch((err) => console.log(err))
                .then(() => (loading.value = false));
        };

        return {
            t,
            loadData,
            loading,
            model,
            showModal,
            message,
        };
    },
    methods: {
        onClose() {
            this.showModal = false;
        },
        onSubmit() {
            this.loading = true;
            this.model.relatedContentUrl = '#displayUrl#';

            taskService
                .update(this.model)
                .then(() => {
                    this.$emit('updated');
                    this.onClose();
                    this.message = new Message({
                        text: this.t('common.successfullyEdit'),
                        display: true,
                        type: 'success',
                        timeout: 5000,
                    });
                })
                .catch((err: unknown) => {
                    const errorResult = err as ResponseResult;
                    this.message = new Message({
                        text: errorResult.showMessage ? errorResult.message : this.t('error.basic'),
                        display: true,
                    });
                })
                .then(() => (this.loading = false));
        },
    },
    watch: {
        show: function (val: boolean) {
            if (this.showModal !== val) {
                this.showModal = val;
            }

            if (this.show === true) {
                this.loadData();
            }
        },
        showModal: function () {
            this.$emit('update:show', this.showModal);
        },
    },
});
</script>

<style scoped lang="scss">
.vw-50 {
    width: 50vw;
    min-height: 30vh;
}

@import '@/assets/styles/dialog.scss';
</style>
