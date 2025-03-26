<template>
<Loader :isLoading="isLoading" />
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('filmCards.display') }}</v-card-title>

        <v-container v-if="filmCardData">
            <v-expansion-panels v-model="panel" multiple>
                <card-general-data-panel :filmCardData="filmCardData"></card-general-data-panel>

                <!-- <card-dates-panel :filmCardData="filmCardData"></card-dates-panel> -->

                <!-- <card-copies-data-panel :filmCardData="filmCardData"></card-copies-data-panel> -->

                <card-documents-panel
                    v-if="!hasExternalSource"
                    :filmCardData="filmCardData"
                    :filmPackageDocs="filmPackageDocs || []"
                ></card-documents-panel>
            </v-expansion-panels>
            <v-row class="mt-3">
                <v-col class="d-flex justify-content-center">
                    <!-- <v-btn @click="goEdit" :disabled="isBusy">{{ t("common.edit") }}</v-btn>
          <v-divider vertical></v-divider> -->
                    <v-btn v-if="!filmCardData.isDraft" @click="printCard" :disabled="isBusy" class="printBtn"
                        >{{ t('filmCards.buttons.print') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('filmCards.buttons.printTooltip') }}
                        </v-tooltip>
                    </v-btn>
                    <v-btn class="cancel" @click="goBack" :disabled="isBusy"
                        >{{ t('common.back') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('filmCards.buttons.backTooltip') }}
                        </v-tooltip>
                    </v-btn>
                </v-col>
            </v-row>
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
import { defineComponent, onMounted, ref, inject, Ref } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { Message } from '@/models/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import filmCardService from '@/services/filmCard.service';
import { IFilmCard } from '@/interfaces/film';
import { FilmCard } from '@/models/film';
import { IDropdownOption } from '@/interfaces/dropdown';
import dropdownService from '@/services/dropdown.service';

import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import CardGeneralDataPanel from '@/components/films/cards/cardGeneralDataPanel.vue';
import CardDocumentsPanel from '@/components/films/cards/cardDocumentsPanel.vue';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'DisplayFilmCard',
    components: {
        Loader,
        CardGeneralDataPanel,
        CardDocumentsPanel,
        Breadcrumbs,
    },
    props: {
        id: {
            type: String,
            required: true,
        },
        filmId: {
            type: String,
            required: false,
        },
        hasExternalSource: {
            type: Boolean,
            default: false,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();

        const isLoading = ref(false);

        const message = inject('notificationMessage') as Ref<IMessage>;

        const panel = ref(['general', 'dates', 'copies', 'docs']);

        const router = useRouter();
        const isBusy = ref(false);

        const goEdit = () => {
            useRedirect(router, 'EditFilmCard', {
                filmId: props.filmId || undefined,
                id: props.id,
            });
        };

        const goBack = () => {
            if (props.hasExternalSource == true) {
                useRedirect(
                    router,
                    'DisplayFilm',
                    { id: ' ' },
                    {
                        hasExternalSource: String(props.hasExternalSource),
                        externalIdentifier: props.filmId,
                    }
                );
            } else if (props.filmId) {
                useRedirectWithId(router, 'DisplayFilm', props.filmId);
            } else {
                useRedirect(router, 'Films');
            }
        };

        const printCard = () => {
            if (props.id) {
                const { href } = router.resolve({ name: 'PrintFilmCard', params: { cardId: props.id } });
                window.open(href, '_blank');
            }
        };

        const filmPackageDocs = ref<IDropdownOption[]>([]);
        const getFilmPackageDocs = async () => {
            if (!props.hasExternalSource) {
                isLoading.value = true;
                filmPackageDocs.value = await dropdownService.getFilmPackageBDocs(props.filmId || '0');
                isLoading.value = false;
            }
        };

        const filmCardData = ref<IFilmCard>(new FilmCard());
        const getFilmCardData = async () => {
            isBusy.value = true;
            try {
                isLoading.value = true;
                if (props.hasExternalSource) {
                    filmCardData.value = await filmCardService.displayFilmCard(undefined, true, Number(props.id));
                } else {
                    filmCardData.value = await filmCardService.displayFilmCard(props.id);
                }
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
                disabled: false,
                to: { name: 'DisplayFilm', params: { id: props.filmId } },
            },
            {
                title: t('filmCards.display'),
                disabled: true,
            },
        ];

        onMounted(() => {
            getFilmCardData();
            getFilmPackageDocs();
        });

        return {
            t,
            panel,
            filmCardData,
            goEdit,
            goBack,
            printCard,
            breadcrumbItems,
            message,
            filmPackageDocs,
            isBusy,
            isLoading,
        };
    },
});
</script>

<style lang="scss" scoped>
.printBtn {
    position: absolute;
    right: 15px;
}
</style>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
