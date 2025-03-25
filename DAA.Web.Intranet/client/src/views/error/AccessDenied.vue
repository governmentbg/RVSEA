<template>
    <v-card>
        <v-card-text class="text-center text-error text-h6">{{ 
            t('error.accessDenied') 
        }}</v-card-text>
    </v-card>
</template>
<script lang="ts">
import { defineComponent } from 'vue'
import { useI18n } from 'vue-i18n';

export default defineComponent({
    name: 'AccessDenied',
    setup() {
        const { t } = useI18n();
        return {
            t,
        }
    }
})
</script>
