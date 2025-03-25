<template>
    <v-dialog v-model="dialog" persistent>
        <template v-slot:activator="{ props }">
            <v-btn v-bind="props">
                {{ $t('common.add') }}
            </v-btn>
        </template>
        <v-card class="vw-50 p-3">
            <v-card-title class="text-h5 text-center">
                {{ $t('packages.addDocumentTitle') }}
            </v-card-title>
            <div class="d-flex justify-content-center" v-if="loading">
                <v-progress-circular :size="50" :width="5" color="primary" indeterminate></v-progress-circular>
            </div>
            <Form @submit="onSubmit" v-show="!loading">
                <v-card-text>
                    <v-container>
                        <v-row>
                            <v-col cols="12" v-if="requireType">
                                <label :class="[requireType == true ? 'required' : '']" for="fldLanguage">{{
                                    $t('packageATemplates.title')
                                }}</label>
                                <DropdownComponent
                                    :label="$t('packageATemplates.title')"
                                    :items="templates"
                                    :valueProp="'id'"
                                    :labelProp="'title'"
                                    v-model="model.documentTypeId"
                                    :required="requireType"
                                ></DropdownComponent>
                            </v-col>
                            <v-col cols="12">
                                <label class="required" for="fldfile"> {{ $t('packageATemplates.file') }}</label>
                                <v-file-input
                                    :label="$t('packageATemplates.file')"
                                    prepend-icon="mdi mdi-paperclip"
                                    v-model="files"
                                    :multiple="attachMultipleFiles"
                                    truncate-length="15"
                                    hide-details="auto"
                                ></v-file-input>
                                <v-row v-if="requiredAttach" class="offset-1 justify-start mt-1">
                                    <span style="color: #b00020 !important; font-size: 12px">
                                        {{
                                            $t('packageATemplates.requiredField', {
                                                label: $t('packageATemplates.file'),
                                            })
                                        }}</span
                                    ></v-row
                                >
                            </v-col>
                            <v-col cols="12" v-if="showSkipValidation">
                                <Switch
                                    v-model="attachMultipleFiles"
                                    :label="t('packageATemplates.attachMultipleFiles')"
                                    :large="false"
                                    :showLabel="true"
                                />
                            </v-col>
                            <v-col cols="12" v-if="showSkipValidation">
                                <Switch
                                    v-model="model.skipValidation"
                                    :label="t('packageATemplates.skipValidation')"
                                    :large="false"
                                    :showLabel="true"
                                />
                            </v-col>
                            <v-col cols="12" v-if="showAttachSignatureFile">
                                <Switch
                                    :label="t('packageATemplates.attachSignatureFile')"
                                    :large="false"
                                    :showLabel="true"
                                    v-model="model.signatureFile"
                                />
                            </v-col>
                            <v-col cols="12" v-if="!attachMultipleFiles">
                                <!-- <label :class="[requireType == true ? 'required' : '']" for="fldLanguage">{{
                                    $t('packageATemplates.description')
                                }}</label> -->
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
                    <submit-btn type="submit" :disabled="loading">
                        {{ $t('common.save') }}
                    </submit-btn>
                    <cancel-btn @click="onClose" :disabled="loading">
                        {{ $t('common.cancel') }}
                    </cancel-btn>
                </v-card-actions>
            </Form>
        </v-card>
    </v-dialog>
</template>

<script lang="ts">
import { defineComponent, ref, watch, inject, Ref, computed } from 'vue';
import { Form } from 'vee-validate';
import { useI18n } from 'vue-i18n';
import { useStore } from '@/store/app';

import { IPackageATemplate } from '@/models/packageATemplate';
import { IPackageAAddFile } from '@/models/packages';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { IMessage } from '@/interfaces/notification';

import TextAreaField from '@/components/field/textarea.field.vue';
import DropdownComponent from '@/components/dropdown/dropdown.vue';
import Switch from '@/components/checkbox/switch.vue';

import packageAService from '@/services/packageATemplates.service';
import packagesService from '@/services/packages.service';

import { formatBytesToMB } from '@/helpers/format.helper';

export default defineComponent({
    components: {
        DropdownComponent,
        TextAreaField,
        Form,
        Switch,
    },
    emits: ['created'],
    props: {
        packageId: {
            type: Number,
            required: true,
        },
        processId: {
            type: Number,
            required: true,
        },
        packageType: {
            type: String,
            default: 'A'
        },
        requireType: {
            type: Boolean,
            default: true,
        },
        showSkipValidation: {
            type: Boolean,
            default: false,
        },
        showAttachSignatureFile: {
            type: Boolean,
            default: false,
        },
        inventoryIdentifier: {
            type: String,
            default: '',
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const dialog = ref(false);
        const fileInput = ref();
        const model = ref({} as IPackageAAddFile);
        const files = ref([] as File[]);
        const templates = ref([] as IPackageATemplate[]);
        const inventorySysIdentifier = computed(() => props.inventoryIdentifier);
        const requiredAttach = ref(false);
        const showMessage = ref(false);
        const loading = ref(false);
        const attachMultipleFiles = ref(false);
        const store = useStore();
        // const submitDisabled = computed(() => {

        // 	const test = (!props.requireType || !model.value.documentTypeId) || !model.value.file;
        // 	return test;
        // });
        const packageId = computed(() => props.packageId);
        model.value.packageId = packageId.value;
        // const setPackageId = () => {
        //     model.value.packageId = props.packageId;
        // };
        // setPackageId();

        const loadTemplates = () => {
            packageAService
                .getEmptyTemplates(props.packageId, props.processId)
                .then((data) => {
                    templates.value = data;
                })
                .catch((err) => {
                    console.log(err);
                });
        };
        loadTemplates();

        watch(
            () => packageId.value,
            (val) => {
                model.value.packageId = val;
            }
        );

        watch(
            () => dialog,
            (val) => {
                templates.value = [];
                if (val.value === true) {
                    loadTemplates();
                }
            }
        );

        watch(
            () => attachMultipleFiles.value,
            (val) => {
                if (val === true) {
                    model.value.description = '';
                    model.value.file = new File([], '.');
                }
                model.value.files = [] as File[];
                files.value = [] as File[];
            }
        );

        return {
            showMessage,
            fileInput,
            attachMultipleFiles,
            requiredAttach,
            dialog,
            files,
            loading,
            model,
            //submitDisabled,
            templates,
            message,
            inventorySysIdentifier,
            store,
            t,
        };
    },
    methods: {
        onClose() {
            this.model = {
                packageId: this.packageId,
                description: '',
                documentTypeId: 0,
                file: new File([], ''),
                files: [] as File[],
                skipValidation: false,
                signatureFile: false,
            };
            this.attachMultipleFiles = false;
            this.files = [];
            this.dialog = false;
            this.requiredAttach = false;
        },
        onSubmit() {
            if (this.requireType && !this.model.documentTypeId) {
                return;
            }
            if (!this.model.files?.length && this.attachMultipleFiles) {
                this.requiredAttach = true;
                return;
            }
            if (!this.model.file && !this.attachMultipleFiles) {
                this.requiredAttach = true;
                return;
            }

            if (!this.showSkipValidation) {
                this.model.skipValidation = true;
            }

            this.loading = true;
            
            const maxPackageSizeInMB = this.packageType === 'B' ? this.store.getters.maxPackageSizeInMB : this.store.getters.maxPackageAFileSizeInMB;
            const totalInMB = formatBytesToMB(this.model.file.size);
            if(totalInMB >= maxPackageSizeInMB){
                this.message = new Message({
                        text: this.$t('error.fileSizeOverLimit', {fileSize: totalInMB, limit: this.store.getters.maxPackageAFileSizeInMB}),
                        display: true,
                    });
                this.loading = false;
                return;
            }

            packagesService
                .addDocumentToPAckage(this.model, this.inventorySysIdentifier)
                .then((id: number) => {
                    console.log(id);
                    this.$emit('created', { ...this.model, id });
                    this.onClose();
                    //TODO show success message
                })
                .catch((error: unknown) => {
                    const errorResult = error as ResponseResult;
                    this.message = new Message({
                        text: errorResult.showMessage ? errorResult.message : this.t('error.basic'),
                        display: true,
                    });
                })
                .then(() => (this.loading = false));
        },
    },
    watch: {
        files: function (value: File[]) {
            if (!this.attachMultipleFiles) {
                this.model.file = value[0] || null;
                if (this.model.file != null) {
                    this.requiredAttach = false;
                }
            } else {
                this.model.files = value;
                if (this.model.files != null) {
                    this.requiredAttach = false;
                }
            }
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
