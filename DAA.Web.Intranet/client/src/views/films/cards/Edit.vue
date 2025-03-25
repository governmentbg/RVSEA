<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('filmCards.edit') }}</v-card-title>
        <Form @submit="submitFilmCardData" v-if="filmCardData">
            <v-container>
                <v-expansion-panels v-model="panel" multiple>
                    <card-general-data-edit-panel 
                        :filmCardData="filmCardData" 
                        :languages="languages"
                        :filmingExtents="filmingExtents"
                    ></card-general-data-edit-panel>

                    <!-- <card-dates-edit-panel
                        :filmCardData="filmCardData"
                        :languages="languages"
                        :filmingExtents="filmingExtents"
                    ></card-dates-edit-panel> -->

                    <!-- <card-copies-data-edit-panel :filmCardData="filmCardData"></card-copies-data-edit-panel> -->

                    <card-documents-edit-panel
                        :filmCardData="filmCardData"
                        :filmPackageDocs="filmPackageDocs || []"
                    ></card-documents-edit-panel>
                </v-expansion-panels>
                <v-row class="mt-3">
                    <v-col class="d-flex justify-content-center">
                        <v-btn type="submit" :disabled="isBusy">{{ t('common.save') }}
                            <v-tooltip
                                activator="parent"
                                location="bottom"
                            >
                            {{t('common.saveTooltip')}}
                            </v-tooltip>
                        </v-btn>
                        <v-divider vertical></v-divider>
                        <v-btn class="cancel" @click="goBack" :disabled="isBusy">{{ t('common.cancel') }}
                            <v-tooltip
                                activator="parent"
                                location="bottom"
                            >
                            {{t('filmCards.buttons.cancelTooltip')}}
                            </v-tooltip>
                        </v-btn>
                    </v-col>
                </v-row>
            </v-container>
        </Form>
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
import { defineComponent, ref, onMounted, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { Message } from '@/models/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import filmCardService from '@/services/filmCard.service';
import dropdownService from '@/services/dropdown.service';
import { IFilmCard } from '@/interfaces/film';
import { FilmCard } from '@/models/film';
import { IDropdownOption } from '@/interfaces/dropdown';
import { NomenclatureCode } from '@/enums/nomenclature';

import { Form } from 'vee-validate';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import CardGeneralDataEditPanel from '@/components/films/cards/cardGeneralDataEditPanel.vue';
import CardDocumentsEditPanel from '@/components/films/cards/cardDocumentsEditPanel.vue';

export default defineComponent({
    name: 'EditFilmCard',
    components: {
        Form,
        CardGeneralDataEditPanel,
        CardDocumentsEditPanel,
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
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const router = useRouter();
        const goBack = () => {
            if (props.filmId) {
                useRedirectWithId(router, 'DisplayFilm', props.filmId);
            } else {
                useRedirect(router, 'Films');
            }
        };

        const panel = ref(['general', 'dates', 'copies', 'docs']);
        const isBusy = ref(false);

        const languages = ref<IDropdownOption[]>([]);
        const getLanguages = async () => {
            languages.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.Language);
        };

        const filmingExtents = ref<IDropdownOption[]>([]);
        const getFilmingExtents = async () => {
            filmingExtents.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.FilmingExtent);
        };

        const filmPackageDocs = ref<IDropdownOption[]>([]);
        const getFilmPackageDocs = async () => {
            //filmPackageDocs.value = await dropdownService.getFilmPackageBDocs(props.filmId || '0');
            filmPackageDocs.value = await dropdownService.getFilmPackageBDocsUnused(props.filmId || '0', props.id);
        };

        const filmCardData = ref<IFilmCard>(new FilmCard());
        const getFilmCardData = async () => {
            isBusy.value = true;
            try {
                filmCardData.value = await filmCardService.displayFilmCard(props.id);
                isBusy.value = false;
            } catch (error: unknown) {
                console.error(error);
                isBusy.value = false;
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const isValid = () => {
            if (
                (!filmCardData.value.framesCount || filmCardData.value.framesCount == 0) &&
                (!filmCardData.value.microfilmNegativeCount || filmCardData.value.microfilmNegativeCount == 0) &&
                (!filmCardData.value.microfilmPositiveCount || filmCardData.value.microfilmPositiveCount == 0) &&
                !filmCardData.value.photoCopy?.trim() &&
                !filmCardData.value.digitalCopy?.trim() &&
                !filmCardData.value.size?.trim() &&
                !filmCardData.value.other?.trim()
            ) {
                message.value = new Message({
                    text: t('films.copiesValidation'),
                    display: true,
                });
                return false;
            } else {
                return true;
            }
        };

        const submitFilmCardData = async () => {
            if (!isValid()) {
                return;
            }

            if (filmCardData.value) {
                isBusy.value = true;
                try {
                    const result = await filmCardService.updateFilmCard(filmCardData.value);
                    isBusy.value = false;
                    if (result.status == 200) {
                        router.go(0);
                    } else {
                        message.value = new Message({
                            text: result.response.data.message,
                            display: true,
                        });
                    }
                } catch (error: unknown) {
                    console.log(error);
                    isBusy.value = false;
                    const errorResult = error as ResponseResult;
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                        display: true,
                    });
                }
            }
        };

        onMounted(() => {
            getLanguages();
            getFilmingExtents();
            getFilmPackageDocs();
            getFilmCardData();
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
                title: t('films.display'),
                disabled: false,
                to: { name: 'Films', params: { id: props.filmId } },
            },
            {
                title: t('filmCards.edit'),
                disabled: true,
            },
        ];

        return {
            t,
            panel,
            languages,
            filmingExtents,
            filmCardData,
            goBack,
            breadcrumbItems,
            submitFilmCardData,
            filmPackageDocs,
            isBusy,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
