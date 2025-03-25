<template>
<Loader :isLoading="isLoading" />
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('films.display') }}</v-card-title>
        <v-container>
            <v-expansion-panels v-model="panel" multiple>
                <film-copies-data-panel :filmData="model"></film-copies-data-panel>
                <v-expansion-panel value="cards">
                    <v-expansion-panel-title v-if="canSeeCards">{{ t('films.panels.cards') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <film-cards :filmId="id" :showComponentTitle="false" :readonly="true" />
                    </v-expansion-panel-text>
                    <IsdaEServices />
                </v-expansion-panel>
            </v-expansion-panels>
        </v-container>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, onMounted, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from '@/store/user';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { Film } from '@/models/film';
import filmService from '@/services/film.service';
import { IFilm } from '@/interfaces/film';
import FilmCopiesDataPanel from '@/components/films/copiesDataPanel.vue';
import FilmCards from '@/views/films/cards/Index.vue';
import IsdaEServices from '@/components/films/buttons.vue';
import Loader from '@/components/loader/loader.vue';

//import { ProcessType } from '@/enums/process';

export default defineComponent({
    name: 'DisplayFilm',
    components: {
        Loader,
        FilmCopiesDataPanel,
        FilmCards,
        IsdaEServices,
        Breadcrumbs,
    },
    props: {
        id: {
            type: String,
        },
        hasExternalSource: {
            type: Boolean,
        },
        externalIdentifier: {
            type: Number,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const userStore = useStore();
        const model = ref<IFilm>(new Film());
        const panel = ref(['general', 'copy', 'cards']);
        const isLoading = ref(false);

        const canSeeCards = computed(() => userStore.getters.isAuthenticated);

        const getFilmData = async () => {
            try {
                isLoading.value = true;
                model.value = await filmService.displayFilm(
                    props.id,
                    props.hasExternalSource,
                    props.externalIdentifier
                );
            } catch (error: unknown) {
                console.error(error);
            } finally {
                isLoading.value = false;
            }
        };

        const breadcrumbItems = computed(() => [
            {
                title: model.value.countryName,
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('films.inventoryNumber'),
                disabled: true,
            },
        ]);
        onMounted(async () => {
            window.scrollTo(0, 0);
            await getFilmData();
        });

        return {
            t,
            model,
            panel,
            canSeeCards,
            breadcrumbItems,
            isLoading,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';

:deep(button) {
    margin-top: 0px !important;
}
</style>
