<template>
    <v-btn @click="goToIsdaEServices">{{ t('films.buttons.redirectToIsdaEServices') }}
        <v-tooltip
            activator="parent"
            location="bottom"
        >
        {{t('films.buttons.redirectToIsdaEServicesTooltip')}}
        </v-tooltip>
    </v-btn>
</template>
<script lang="ts">
import { defineComponent } from 'vue';
import { useI18n } from 'vue-i18n';
import filmService from '@/services/film.service';

export default defineComponent({
    name: 'IsdaEServices',
    setup() {
        const { t } = useI18n();
        const goToIsdaEServices = async () => {
            const link = await filmService.getIsdaEServicesLink();
            window.open(link);
        };
        return {
            t,
            goToIsdaEServices,
        };
    },
});
</script>

<style lang="scss" scoped>

@import "@/assets/styles/index.scss";

</style>
