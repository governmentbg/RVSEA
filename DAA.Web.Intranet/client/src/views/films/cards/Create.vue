<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('filmCards.create') }}</v-card-title>

        <Form @submit="submitFilmCardData">
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
    </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, inject, onMounted, Ref } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { Message } from '@/models/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { IFilmCard } from '@/interfaces/film';
import { FilmCard } from '@/models/film';
import { IDropdownOption } from '@/interfaces/dropdown';
import { NomenclatureCode } from '@/enums/nomenclature';
import filmCardService from '@/services/filmCard.service';
import dropdownService from '@/services/dropdown.service';
import { defaultGuidString } from '@/helpers/format.helper';

import { Form } from 'vee-validate';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { FilmCardParentData } from '@/models/film';
import CardGeneralDataEditPanel from '@/components/films/cards/cardGeneralDataEditPanel.vue';
import CardDocumentsEditPanel from '@/components/films/cards/cardDocumentsEditPanel.vue';

export default defineComponent({
    name: 'CreateFilmCard',
    components: {
        Form,
        CardGeneralDataEditPanel,
        CardDocumentsEditPanel,
        Breadcrumbs,
    },
    props: {
        filmId: {
            type: String,
            required: false,
        },
    },
    setup(props) {
        const { t } = useI18n();

        const message = inject('notificationMessage') as Ref<IMessage>;

        const panel = ref(['general', 'dates', 'copies', 'docs']);

        const router = useRouter();
        const goBack = () => {
            if (props.filmId) {
                useRedirectWithId(router, 'DisplayFilm', props.filmId);
            } else {
                useRedirect(router, 'Films');
            }
        };

        const goEdit = (sysId: string) => {
            useRedirect(router, "EditFilmCard", {
              filmId: props.filmId,
              id: sysId,
            });
        }

        const filmCardData = ref<IFilmCard>(new FilmCard());
        const filmCardParentData = ref<FilmCardParentData>(new FilmCardParentData());
        const isBusy = ref(false);

        const getParentData = async () => {
            isBusy.value = true;
            try {
                const result = await filmCardService.getParentData(props.filmId || '0');
                isBusy.value = false;
                filmCardParentData.value = new FilmCardParentData(result);
                filmCardData.value.inventoryNumber = filmCardParentData.value.inventoryNumber;
                filmCardData.value.archiveId = filmCardParentData.value.archiveId;
                filmCardData.value.archiveName = filmCardParentData.value.archiveName;
                filmCardData.value.countryId = filmCardParentData.value.countryId;
                filmCardData.value.countryName = filmCardParentData.value.countryName;
                filmCardData.value.countryCode = filmCardParentData.value.countryCode;
                filmCardData.value.filmId = filmCardParentData.value.filmId;
                filmCardData.value.systemIdentifier = filmCardParentData.value.systemIdentifier;
                filmCardData.value.source = filmCardParentData.value.source;
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
            filmPackageDocs.value = await dropdownService.getFilmPackageBDocsUnused(props.filmId || '0', defaultGuidString());
        };

        const isValid = () => {
            if (
                (!filmCardData.value.framesCount || filmCardData.value.framesCount == 0) &&
                (!filmCardData.value.microfilmNegativeCount || filmCardData.value.microfilmNegativeCount == 0) &&
                (!filmCardData.value.microfilmPositiveCount || filmCardData.value.microfilmPositiveCount == 0) &&
                !filmCardData.value.photoCopy?.trim() &&
                !filmCardData.value.digitalCopy?.trim() &&
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

            isBusy.value = true;
            try {
                filmCardData.value.systemIdentifier = defaultGuidString();
                filmCardData.value.filmId = filmCardParentData.value.filmId;
                filmCardData.value.filmSystemIdentifier = filmCardParentData.value.systemIdentifier;
                const result = await filmCardService.createFilmCardDraft(filmCardData.value);
                isBusy.value = false;
                if (result.status == 200) {
                    goEdit(result.data.data);
                }
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

        onMounted(() => {
            getParentData();
            getLanguages();
            getFilmingExtents();
            getFilmPackageDocs();
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
                title: t('filmCards.create'),
                disabled: true,
            },
        ];
        return {
            t,
            panel,
            breadcrumbItems,
            filmCardData,
            submitFilmCardData,
            goBack,
            filmCardParentData,
            languages,
            filmingExtents,
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
