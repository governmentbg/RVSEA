<template>
    <information-carousel />

    <v-expansion-panels  v-model="panel" multiple class="mt-0">
        <v-expansion-panel class="mt-2">
            <v-expansion-panel-title>{{ $t('common.calendar') }}</v-expansion-panel-title>
            <v-expansion-panel-text class="mt-0">
                <information-calendar />
            </v-expansion-panel-text>
        </v-expansion-panel>
        <v-expansion-panel class="mt-2">
            <v-expansion-panel-title>{{ $t('navigation.top.search') }}</v-expansion-panel-title>
            <v-expansion-panel-text class="mt-0"> 
                <searchEngine />
            </v-expansion-panel-text>
        </v-expansion-panel>
    </v-expansion-panels>
</template>

<script lang="ts">
import { defineComponent, ref } from 'vue';
import searchEngine from '@/components/searchEngine/Index.vue';
import InformationCarousel from '@/components/information/informationCarousel.vue';
import InformationCalendar from '@/components/information/informationCalendar.vue';

export default defineComponent({
    name: 'Home',
    components: { searchEngine, InformationCarousel, InformationCalendar },
    setup() {
        const panel = ref(1);
        return { searchEngine, panel };
    },
});
</script>
<!-- 
<style land="scss" scoped>
.v-container div {
    text-align: center !important;
    /*font-size: 32px;*/
    margin-top: 50px;
    color: var(--ISDA-main-color4);
}
</style> -->
