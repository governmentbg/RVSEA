<template>
    <v-row justify="start">
        <v-dialog v-model="dialog" persistent>
            <template v-slot:activator="{ props }">
                <v-col cols="12">
                    <v-btn class="ml-10" v-bind="props">
                        {{ $t('packageATemplates.addTemplate') }}
                    </v-btn>
                </v-col>
            </template>
            <v-card class="vw-50 p-3">
                <v-card-title class="text-h5 text-center">
                    {{ $t('packageATemplates.createTitle') }}
                </v-card-title>
                <div class="d-flex justify-content-center" v-if="loading">
                    <v-progress-circular :size="50" :width="5" color="primary" indeterminate></v-progress-circular>
                </div>

                <Form @submit="onSubmit" v-show="!loading">
                    <v-card-text>
                        <v-container>
                            <v-row>
                                <v-col cols="12">
                                    <text-field
                                        v-model="model.title"
                                        :label="$t('packageATemplates.title')"
                                        validation="required"
                                    ></text-field>
                                </v-col>
                                <v-col cols="12">
                                    <v-file-input
                                        :label="$t('packageATemplates.file') + '*'"
                                        prepend-icon="mdi mdi-paperclip"
                                        v-model="files"
                                        truncate-length="15"
                                        hide-details="auto"
                                    ></v-file-input>
                                </v-col>
                                <v-col cols="12">
                                    <v-switch
                                        v-model="model.required"
                                        hide-details
                                        inset
                                        color="primary"
                                        :label="$t('packageATemplates.required')"
                                    ></v-switch>
                                </v-col>
                                <v-col cols="12">
                                    <text-area-field
                                        v-model="model.description"
                                        :label="$t('packageATemplates.description')"
                                    ></text-area-field>
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
                        <!-- <v-btn class="mr-4" type="submit" :disabled="loading">
                            {{ $t('common.create') }}
                        </v-btn>
                        <v-btn class="clear bg-secondary" @click="onClose" :disabled="loading">
                            {{ $t('common.cancel') }}
                        </v-btn> -->
                    </v-card-actions>
                </Form>
            </v-card>
        </v-dialog>
    </v-row>
</template>

<script lang="ts">
import { defineComponent, inject, Ref, ref } from 'vue';
import { Form } from 'vee-validate';
import { PackageATemplateCreateModel } from '@/models/packageATemplate';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import packageAService from '@/services/packageATemplates.service';
import { useI18n } from 'vue-i18n';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';

export default defineComponent({
    components: {
        TextField,
        TextAreaField,
        Form,
    },
    emits: ['created'],
    props: {
        procedureId: {
            type: Number,
            required: true,
        },
    },
    setup() {
        const dialog = ref(false);
        const model = ref(new PackageATemplateCreateModel());
        const files = ref([] as File[]);
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        
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
            dialog,
            files,
            loading,
            t,
            message,
            model,
            yesNoItems,
        };
    },
    methods: {
        onClose() {
            this.model = new PackageATemplateCreateModel();
            this.files = [];
            this.dialog = false;
        },
        onSubmit() {
            this.loading = true;
            if (!this.files.length) {
                this.message = new Message({
                    text: this.t('common.thisFileFieldIsRequired'),
                    display: true,
                });
                this.loading = false;
                return;
            }
            this.model.static = false;
            this.model.procedureId = parseInt(this.procedureId.toString());

            packageAService
                .create(this.model)
                .then((id: number) => {
                    console.log(id);
                    this.$emit('created', { ...this.model, id });
                    this.onClose();
                    this.message = new Message({
                        text: this.t('common.successfullyCreated'),
                        type: 'success',
                        timeout: 5000,
                        display: true,
                    });
                })
                .catch((err) => {
                    console.error(err);
                    this.message = new Message({
                        text: this.t('error.basic'),
                        display: true,
                    });
                })
                .then(() => (this.loading = false));
        },
    },
    watch: {
        files: function (value: File[]) {
            this.model.file = value[0] || null;
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
