<template>
<Loader :isLoading="isLoading" />
    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('films.display') }}</v-card-title>
        <v-container>
            <v-expansion-panels v-model="panel" multiple>
                <film-copies-data-panel :filmData="model"></film-copies-data-panel>
                <v-expansion-panel :value="'full-film'">
                    <v-expansion-panel-title>{{ t('films.buttons.display') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <film-documents :packageId="model.packageBId || 0"> </film-documents>
                    </v-expansion-panel-text>
                </v-expansion-panel>
            </v-expansion-panels>
        </v-container>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';

import { Film } from '@/models/film';
import filmService from '@/services/film.service';
import { IFilm } from '@/interfaces/film';
import FilmCopiesDataPanel from '@/components/films/copiesDataPanel.vue';
import FilmDocuments from '@/views/films/documents/Index.vue';
import { useRouter } from 'vue-router';
import { useRedirect } from '@/helpers/router.helper';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'DisplayFilmFull',
    components: {
        Loader,
        FilmCopiesDataPanel,
        FilmDocuments,
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
        const model = ref<IFilm>(new Film());
        const panel = ref(['full-film']);
        const router = useRouter();
        const isLoading = ref(false);

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

        const goBack = () => {
            useRedirect(router, 'FilmsForReader');
        };

        onMounted(async () => {
            window.scrollTo(0, 0);
            await getFilmData();
        });

        return {
            t,
            model,
            panel,
            goBack,
            isLoading,
        };
    },
});
</script>

<style lang="scss" scoped>
//@import "@/assets/styles/index.scss";
@import '@/assets/styles/display-create-edit.scss';
</style>
