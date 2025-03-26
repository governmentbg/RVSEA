<template>
<Loader :isLoading="isLoading" />
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('films.display') }}</v-card-title>

        <v-container v-if="filmData">
            <v-expansion-panels v-model="panel" multiple>
                <film-system-data-panel :filmData="filmData"></film-system-data-panel>
                <timeline-panel
                    v-if="!hideTimeline"
                    :processId="filmData.currentProcessId || 0"
                    :showExpanded="false"
                ></timeline-panel>

                <film-general-data-panel :filmData="filmData"></film-general-data-panel>
                <!-- <film-copies-data-panel :filmData="filmData"></film-copies-data-panel> -->

                <v-expansion-panel :value="'packageA'" v-if="!hidePackagePanel">
                    <v-expansion-panel-title>{{ t('filmDocuments.packageA') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <film-documents
                            v-if="filmData && filmData.systemIdentifier"
                            :filmId="id || ''"
                            :packageId="filmData.packageAId || 0"
                            :packageType="'A'"
                            :readonly="!canEditPackages"
                        >
                        </film-documents>
                    </v-expansion-panel-text>
                </v-expansion-panel>

                <v-expansion-panel :value="'packageB'" v-if="!hidePackagePanel">
                    <v-expansion-panel-title>{{ t('filmDocuments.packageB') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <film-documents
                            v-if="filmData && filmData.systemIdentifier"
                            :filmId="id || ''"
                            :packageId="filmData.packageBId || 0"
                            :packageType="'B'"
                            :readonly="!canEditPackages"
                        >
                        </film-documents>
                    </v-expansion-panel-text>
                </v-expansion-panel>

                <v-expansion-panel value="cards" v-if="!hideCardsPanel">
                    <v-expansion-panel-title>{{ t('films.panels.cards') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <film-cards
                            v-if="filmData && filmData.systemIdentifier"
                            :filmId="filmData.systemIdentifier || ''"
                            :hasExternalSource="filmData.hasExternalSource"
                            :externalIdentifier="filmData.externalIdentifier"
                            :showComponentTitle="false"
                            :readonly="!canEditCards"
                        />
                    </v-expansion-panel-text>
                </v-expansion-panel>
            </v-expansion-panels>

            <film-processes :filmData="filmData" @refresh="refresh" v-if="!hideProcesses"></film-processes>
            <film-buttons :filmData="filmData" @refresh="refresh"></film-buttons>
        </v-container>
        <v-alert v-else
            prominent
            type="error"
            variant="outlined"
            >
            {{t('common.noDataMessage')}}
        </v-alert>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, inject, Ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { Message } from '@/models/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import filmService from '@/services/film.service';
import { IFilm } from '@/interfaces/film';
import { Film } from '@/models/film';

import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import FilmSystemDataPanel from '@/components/films/systemDataPanel.vue';
import FilmGeneralDataPanel from '@/components/films/generalDataPanel.vue';
import FilmDocuments from '@/views/films/documents/Index.vue';
import FilmCards from '@/views/films/cards/Index.vue';
import FilmButtons from '@/components/films/buttons.vue';
import TimelinePanel from '@/components/process/timelinePanel.vue';
import FilmProcesses from '@/components/films/processes.vue';
import { ProcessType, ProcessStep } from '@/enums/process';
import { RoleNames } from '@/enums/roles';
import { useStore } from '@/store/user';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'DisplayFilm',
    components: {
        Loader,
        FilmSystemDataPanel,
        FilmGeneralDataPanel,
        FilmDocuments,
        FilmCards,
        FilmButtons,
        TimelinePanel,
        FilmProcesses,
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
        const message = inject('notificationMessage') as Ref<IMessage>;

        const isLoading = ref(false);

        const panel = ref(['system', 'timeline', 'general', 'copies', 'packageA', 'packageB', 'cards']);

        const canEdit = computed(() => userStore.getters.hasRole(RoleNames.GroupI));

        const filmData = ref<IFilm>(new Film());
        const isBusy = ref(false);

        const getFilmData = async () => {
            isBusy.value = true;
            try {
                isLoading.value = true;
                filmData.value = await filmService.displayFilm(
                    props.id,
                    props.hasExternalSource,
                    props.externalIdentifier
                );
                isBusy.value = false;
            } catch (error: unknown) {
                console.error(error);
                isBusy.value = false;
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            } finally {
                isLoading.value = false;
            }
        };

        const refresh = async () => {
            filmData.value = new Film();
            await getFilmData();
        };

        const hideTimeline = computed(() => !filmData.value.currentProcessId || filmData.value.currentProcessId == 0);
        const hidePackagePanel = computed(
            () =>
                (filmData.value.currentProcessTypeId == ProcessType.FilmRegisterData &&
                    filmData.value.currentStepTypeId == ProcessStep.Film_RegisterData) ||
                filmData.value.externalIdentifier
        );
        const hideCardsPanel = computed(() => filmData.value.currentProcessTypeId == ProcessType.FilmRegisterData);
        const hideProcesses = computed(
            () =>
                (filmData.value.currentProcessId && filmData.value.currentProcessId > 0) ||
                filmData.value.externalIdentifier
        );

        const canEditPackages = computed(
            () =>
                canEdit.value == true &&
                ((filmData.value.currentProcessTypeId == ProcessType.FilmRegisterData &&
                    filmData.value.currentStepTypeId == ProcessStep.Film_CreatePackages) ||
                    (filmData.value.currentProcessTypeId == ProcessType.FilmEditData &&
                        (filmData.value.currentStepTypeId == ProcessStep.Film_EditAllData ||
                            filmData.value.currentStepTypeId == ProcessStep.Film_ReturnAllForEdit)))
        );
        const canEditCards = computed(
            () =>
                canEdit.value == true &&
                ((filmData.value.currentProcessTypeId == ProcessType.FilmRegisterCard &&
                    (filmData.value.currentStepTypeId == ProcessStep.Film_RegisterCardData ||
                        filmData.value.currentStepTypeId == ProcessStep.Film_ReturnCardForEdit)) ||
                    (filmData.value.currentProcessTypeId == ProcessType.FilmEditData &&
                        (filmData.value.currentStepTypeId == ProcessStep.Film_EditAllData ||
                            filmData.value.currentStepTypeId == ProcessStep.Film_ReturnAllForEdit)))
        );

        onMounted(async () => {
            await getFilmData();
        });
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('archives.kmf'),
                disabled: false,
                to: { name: 'Films' },
            },
            {
                title: t('films.columns.inventoryNumber'),
                disabled: true,
            },
        ];
        return {
            t,
            panel,
            filmData,
            message,
            refresh,
            hideTimeline,
            hidePackagePanel,
            breadcrumbItems,
            hideCardsPanel,
            hideProcesses,
            canEditPackages,
            canEditCards,
            isBusy,
            isLoading,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
