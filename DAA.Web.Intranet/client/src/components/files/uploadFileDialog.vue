<template>
    <v-dialog
        v-model="showDialog"
        persistent
    >
        <v-card
            :title="multiple ? t('digitalObjects.uploadFiles') : t('digitalObjects.uploadFile')"
            class="dialog-v-card"
        >
            <v-card-item>
                <v-row>
                    <v-col>
                        <UploadFile
                            v-model="files"
                            name="fldFileUpload"
                            :label="multiple ? t('digitalObjects.selectFiles') : t('digitalObjects.selectFile')"
                            :multiple="multiple"
                            :required="true"
                            :packageType="packageType"
                        />        
                    </v-col>
                </v-row>
                <v-row>
                    <v-col>    
                        <!-- <v-checkbox
                            v-model="overwriteExisting"
                            name="fldOverwriteExisting"
                            :label="$t('files.columns.overwriteExisting')"
                        ></v-checkbox> -->
                        <Switch
                            v-if="skipValidationEnabled"
                            v-model="skipFileValidation"
                            :label="t('packageATemplates.skipValidation')"
                            :large="false"
                            :showLabel="true"
                        />
                    </v-col>
                </v-row>
            </v-card-item>
            <v-card-actions>
                <v-spacer></v-spacer>
                <submit-btn
                    :disabled="files.length <= 0"
                    @click="dialogBtnClickHandler(true)"
                >
                    {{ t('common.save') }}
                </submit-btn>
                <cancel-btn
                    @click="dialogBtnClickHandler(false)"
                >
                    {{ t('common.cancel') }}
                </cancel-btn>
                <v-spacer></v-spacer>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>
<script lang="ts">
    import { defineComponent, computed, ref } from 'vue';
    import { useI18n } from 'vue-i18n';

    import UploadFile from '@/components/files/uploadFile.vue';
    import Switch from '@/components/checkbox/switch.vue';

    export default defineComponent({
    name: 'UploadFileDialog',
    components: {
        UploadFile,  
        Switch,
    },
    props: {
        modelValue: {
            type: Boolean,
            required: true,
        },
        multiple: {
            type: Boolean,
            default: false,
        },
        skipValidationEnabled: {
            type: Boolean,
            default: false,
        },
        packageType: {
            type: String,
            required: false,
        },
    },
    emits: ['update:modelValue','save', 'cancel'],
    setup(props, context) {
        const { t } = useI18n();

        const showDialog = computed({
        get: () => props.modelValue,
        set: (value) => context.emit("update:modelValue", value),
        });

        const files = ref<File[]>([]);
        //const overwriteExisting = ref<boolean>(false);
        const skipFileValidation = ref<boolean>(false);

        const dialogBtnClickHandler = (result: boolean) => {
            if (result) {
                //context.emit('save', files.value, overwriteExisting.value);
                context.emit('save', files.value, skipFileValidation.value);
            } else {
                files.value = [];
                skipFileValidation.value = false;
                //overwriteExisting.value = false;
                context.emit('cancel');
            }
        }

        return {
            t,
            showDialog,
            files,
            skipFileValidation,
            //overwriteExisting,
            dialogBtnClickHandler,

        }
    },
});
</script>
<style scoped>
.dialog-v-card {
    min-width: 50vw;
    /* min-height: 50vh;
    max-height: 75vh; */
    max-width: 75vw;
    margin: auto;
}
</style>