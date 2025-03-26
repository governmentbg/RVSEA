<template>
    <v-overlay persistent :model-value="isLoading" scroll-strategy="none" class="align-center justify-center">
        <v-row dense>
            <v-col>
                <v-progress-circular indeterminate :color="color" :size="size"></v-progress-circular>
            </v-col>
        </v-row>
        <v-row dense>
            <v-col>
                <v-btn v-if="showCancel" color="primary" @click="cancelButton">{{ t('common.cancel') }}</v-btn>
            </v-col>
        </v-row>
    </v-overlay>
</template>
<script lang="ts">
import { defineComponent } from 'vue';
import { useI18n } from 'vue-i18n';

export default defineComponent({
    name: 'Loader',
    emits: ['cancel'],
    props: {
        isLoading: {
            type: Boolean,
            default: false,
        },
        size: {
            type: Number,
            default: 96,
        },
        color: {
            type: String,
            default: 'secondary-darken-2',
        },
        showCancel: {
            type: Boolean,
            default: false,
        },
    },
    setup(props, context) {
        const { t } = useI18n();

        const cancelButton = () => {
            context.emit('cancel');
        };

        return {
            t,
            cancelButton,
        };
    },
});
</script>
<style scoped>
/* button.cancel {
    background-color: var(--ISDA-main-color1);
    color: white;
} */
</style>
