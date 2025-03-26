<template>
    <v-card>
        <v-card-text class="text-center lead text-muted text-h6">{{ 
            t('logout.message') 
        }}</v-card-text>
    </v-card>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import { useI18n } from 'vue-i18n';

export default defineComponent({
    name: 'Logout',
    setup() {
        const { t } = useI18n();
        return {
            t,
        }
    },
})
</script>

<style lang="scss" scoped>

.v-card {
    background-color: var(--ISDA-main-color2-1);
    margin: 50px !important;
    color: var(--ISDA-main-color1);
    box-shadow: gray 0px 0px 20px 0px;
}

</style>
