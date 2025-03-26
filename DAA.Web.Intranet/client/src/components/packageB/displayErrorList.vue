<template>
    <p id="import-error-message" class="mt-5 mb-5" style="color: red">{{ t('error.importErrorMessage') }}</p>
    <span class="mt-5">
        <v-row class="darken">
            <v-col class="col-2">
                <div class="ml-2">
                    <span class="text-white">{{ t('reports.sheet') }}</span>
                </div>
            </v-col>
            <v-col class="col-1">
                <div>
                    <span class="text-white">{{ t('reports.row') }}</span>
                </div>
            </v-col>
            <v-col class="col-3">
                <div>
                    <span class="text-white">{{ t('reports.col') }}</span>
                </div>
            </v-col>
            <v-col class="col-6">
                <div>
                    <span class="text-white">{{ t('reports.description') }}</span>
                </div>
            </v-col>
        </v-row>
        <v-row v-for="(item, index) in items" :key="index">
            <v-col class="col-2">
                <span class="ml-2">{{ item.sheet }}</span>
            </v-col>
            <v-col class="col-1">
                <span>{{ item.row }}</span>
            </v-col>
            <v-col class="col-3">
                <span>{{ item.col }}</span>
            </v-col>
            <v-col class="col-6">
                <span>{{ item.description }}</span>
            </v-col>
        </v-row>
    </span>
</template>
<script lang="ts">
import { ImportErrorList } from '@/models/packages';
import { defineComponent } from 'vue';
import { PropType } from 'vue';
import { useI18n } from 'vue-i18n';

export default defineComponent({
    props: {
        items: {
            type: Array as PropType<ImportErrorList[]>,
            default: () => [],
        },
    },
    setup() {
        const { t } = useI18n();
        return { t };
    },
});
</script>
<style scoped>
.darken {
    background-color: rgb(170, 0, 0);
}
#import-error-message {
    background-color: rgba(255, 0, 0, 0.276);
    padding: 1em;
    border-radius: 200px;
    color: rgb(138, 0, 0) !important;
    font-size: 1.2rem;
}
</style>
