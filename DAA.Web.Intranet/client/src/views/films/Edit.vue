<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('films.edit') }}</v-card-title>

        <Form @submit="submitFilmData" @invalid-submit="showHintMessageForRequiredFields" ref="filmForm" v-if="filmData">
            <v-container>
                <v-expansion-panels v-model="panel" multiple>
                    <general-data-edit-panel                        
                        ref="generalDataEditRef"
                        :filmData="filmData"
                        :archives="archives"
                        :countries="countries"
                    ></general-data-edit-panel>

                    <!-- <copies-data-edit-panel :filmData="filmData" ref="copiesDataEditRef"></copies-data-edit-panel> -->
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
                            {{t('films.buttons.cancelTooltip')}}
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
import { useRedirect } from '@/helpers/router.helper';
import { Message } from '@/models/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import filmService from '@/services/film.service';
import dropdownService from '@/services/dropdown.service';
import { IFilm } from '@/interfaces/film';
import { Film } from '@/models/film';
import { IDropdownOption } from '@/interfaces/dropdown';
import { NomenclatureCode } from '@/enums/nomenclature';

import { Form } from 'vee-validate';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import GeneralDataEditPanel from '@/components/films/generalDataEditPanel.vue';

export default defineComponent({
    name: 'EditFilm',
    components: {
        Form,
        GeneralDataEditPanel,
        Breadcrumbs,
    },
    props: {
        id: {
            type: String,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const router = useRouter();
        const goBack = () => {
            useRedirect(router, 'Films');
        };

        const panel = ref(['general', 'copies']);

        const archives = ref<IDropdownOption[]>([]);
        const getArchives = async () => {
            archives.value = await dropdownService.getCentralArchive();
        };

        const countries = ref<IDropdownOption[]>([]);
        const getCountries = async () => {
            countries.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.FilmCountry);
        };

        const filmData = ref<IFilm>(new Film());
        const isBusy = ref(false);

        const getFilmData = async () => {
            isBusy.value = true;
            try {
                filmData.value = await filmService.displayFilm(props.id);
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

        const filmForm = ref();
        const generalDataEditRef = ref();

        const showHintMessageForRequiredFields = () => {
            message.value = new Message({
                text: t('common.requiredFields'),
                display: true,
            });
        };

        const validateForm = () => {
            (filmForm.value! as typeof Form).validate();
        };

        const isValidData = () => {
            validateForm();

            let isValidCopiesData = true;
            if (generalDataEditRef.value) {
                isValidCopiesData = generalDataEditRef.value.isValid();
                if (!isValidCopiesData) {
                    message.value = new Message({
                        text: t('films.copiesValidation'),
                        display: true,
                    });
                    return false;
                }
            }

            return true;
        };

        const submitFilmData = async () => {
            if (!isValidData()) {
                return;
            }

            if (filmData.value) {
                isBusy.value = true;
                try {
                    const result = await filmService.updateFilm(filmData.value);
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
            getArchives();
            getCountries();
            getFilmData();
        });
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('archives.kmf'),
                to: { name: 'Films' },
                disabled: false,
            },
            {
                title: t('films.edit'),
                disabled: true,
            },
        ];
        return {
            t,
            panel,
            archives,
            countries,
            filmData,
            goBack,
            showHintMessageForRequiredFields,
            breadcrumbItems,
            submitFilmData,
            generalDataEditRef,
            filmForm,
            isBusy,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
