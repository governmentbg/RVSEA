<template>
    <v-dialog
        v-model="showDialog"
        persistent
    >
        <template v-slot:activator="{ props }">
            <v-btn 
                v-if="activatorButtonIcon" 
                :icon="activatorButtonIcon" 
                v-bind="props" 
                :color="activatorButtonColor"
                :variant="activatorButtonVariant"
                :class="activatorButtonCssClass" 
                :disabled="disabled" 
            />
            <v-btn 
                v-else 
                v-bind="props" 
                :color="activatorButtonColor"
                :variant="activatorButtonVariant"
                :class="activatorButtonCssClass" 
                :disabled="disabled"
            >{{ 
                activatorButtonText 
            }}</v-btn>
        </template>
        <v-card>
            <v-card-text>
                {{ confirmationText }}
            </v-card-text>
            <v-card-text v-if="commentInputEnabled">
                <text-area-field
                    name="fldComment"
                    :label="t('common.comment')"
                    v-model="comment"
                    :validation="commentInputRequired ? 'required' : ''"
                />
            </v-card-text>
            <v-card-actions style="margin-bottom: 25px;">
                <v-spacer></v-spacer>
                <dialog-btn
                style="margin-right: 15px;"
                    @click="dialogBtnClickHandler(true)"
                >
                    {{ confirmButtonText }}
                </dialog-btn>
                <cancel-btn
                    @click="dialogBtnClickHandler(false)"
                >
                    {{ cancelButtonText }}
                </cancel-btn>
                <v-spacer></v-spacer>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>
<script lang="ts">
import { defineComponent, ref } from 'vue';
import { useI18n } from 'vue-i18n';

import TextAreaField from '@/components/field/textarea.field.vue';

export default defineComponent({
    name: "ConfirmDialog",
    components: {
        TextAreaField,
    },
	emits: ['confirm', 'cancel'],
    props: {
        activatorButtonText: {
            type: String,
            required: false,
        },
        activatorButtonIcon: {
            type: String,
            required: false,
        },
        activatorButtonVariant: {
            type: String,
            required: false,
        },
        activatorButtonColor: {
            type: String,
            required: false,
        },
        activatorButtonCssClass: {
            type: String,
            required: false,
        },
        confirmationText: {
            type: String,
            required: true,
        },
        confirmButtonText: {
            type: String,
            required: true,
        },
        cancelButtonText: {
            type: String,
            required: true,
        },
        commentInputEnabled: {
            type: Boolean,
            default: false,
        },
        commentInputRequired: {
            type: Boolean,
            default: false,
        },
        disabled: {
            type: Boolean,
            default: false,
        }
    },
    setup(props, context) {
        const { t } = useI18n();

        const showDialog = ref<boolean>(false);

        const comment = ref<string>('');

        const dialogBtnClickHandler = (confirmed: boolean) => {
            if (confirmed) {
                context.emit('confirm', comment.value);
            } else {
                context.emit('cancel');
            }
            showDialog.value = false;
            comment.value = '';
        }

        return {
            t,
            showDialog,
            comment,
            dialogBtnClickHandler,
        }
    },
})
</script>

<style lang="scss" scoped>

@import "@/assets/styles/dialog.scss"

</style>