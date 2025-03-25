<template>
    <v-row justify="start">
        <v-dialog v-model="dialog" persistent>
            <template v-slot:activator="{ props }">
                <v-col cols="12">
                    <v-btn v-bind="props">
                        {{ t('tasksTemplates.addTemplate') }}
                    </v-btn>
                </v-col>
            </template>
            <v-card class="vw-50 p-3">
                <v-card-title class="text-h5 text-center">
                    {{ t('tasksTemplates.createTitle') }}
                </v-card-title>
                <div class="d-flex justify-content-center" v-if="loading">
                    <v-progress-circular :size="50" :width="5" color="primary" indeterminate></v-progress-circular>
                </div>
                <Form @submit="onSubmit" v-show="!loading">
                    <v-card-text>
                        <v-container>
                            <v-row>
                                <v-col cols="12">
                                    <label class="required ddl" for="fldProcessesSteps">{{
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
                                        :searchable="true"
                                        ref="processesStepsDropdown"
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
                        <submit-btn  @click="onSubmit">
                            {{ t('common.create') }}
                        </submit-btn>
                        <cancel-btn @click="onClose">
                            {{ t('common.cancel') }}
                        </cancel-btn>
                        <!-- <v-btn color="primary" variant="outlined" type="submit" :disabled="loading">
                            {{ t('common.create') }}
                        </v-btn>
                        <v-btn class="cancel" color="red" variant="outlined" @click="onClose" :disabled="loading">
                            {{ t('common.cancel') }}
                        </v-btn> -->
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
import { TaskTemplateCreateModel } from '@/models/taskTemplate';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import taskService from '@/services/taskTemplate.service';
import { IDropdownOption } from '@/interfaces/dropdown';
import Dropdown from '@/components/dropdown/dropdown.vue';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';

export default defineComponent({
    components: {
        TextField,
        TextAreaField,
        Form,
        Dropdown,
    },
    props: {
        items: {
            type: Array as PropType<IDropdownOption[]>,
            default: () => [],
        },
    },
    emits: ['created'],
    setup() {
        const { t } = useI18n();
        const dialog = ref(false);
        const message = inject('notificationMessage') as Ref<IMessage>;
        const model = ref(new TaskTemplateCreateModel());
        model.value.relatedContentUrl = '#displayUrl#';
        const yesNoItems = [
            {
                value: false,
                title: 'No',
            },
            {
                value: true,
                title: 'Yes',
            },
        ];

        const loading = ref(false);

        return {
            t,
            dialog,
            loading,
            model,
            yesNoItems,
            message,
        };
    },
    methods: {
        onClose() {
            this.model = new TaskTemplateCreateModel();
            this.model.relatedContentUrl = '#displayUrl#';
            this.dialog = false;
        },
        onSubmit() {
            this.loading = true;
            this.model.relatedContentUrl = '#displayUrl#';
            taskService
                .create(this.model)
                .then((id: number) => {
                    this.$emit('created', { ...this.model, id });
                    this.onClose();
                    this.message = new Message({
                        text: this.t('common.successfullyCreated'),
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
});
</script>

<style scoped lang="scss">
.vw-50 {
    width: 50vw;
    min-height: 30vh;
}

.ddl {
    margin-bottom: 10px;
}
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/dialog.scss';

div:has(button) {
    display: flex;
}
</style>
