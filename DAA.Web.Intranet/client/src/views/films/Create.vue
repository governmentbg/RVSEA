<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('films.create') }}</v-card-title>

        <Form @submit="submitFilmData" ref="filmForm" @invalid-submit="showHintMessageForRequiredFields">
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
    </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, inject, onMounted, Ref } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { Message } from '@/models/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { IFilm } from '@/interfaces/film';
import { Film } from '@/models/film';
import { IDropdownOption } from '@/interfaces/dropdown';
import { NomenclatureCode } from '@/enums/nomenclature';
import filmService from '@/services/film.service';
import dropdownService from '@/services/dropdown.service';
import { defaultGuidString } from '@/helpers/format.helper';

import { Form } from 'vee-validate';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import GeneralDataEditPanel from '@/components/films/generalDataEditPanel.vue';

export default defineComponent({
    name: 'CreateFilm',
    components: {
        Form,
        GeneralDataEditPanel,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();

        const message = inject('notificationMessage') as Ref<IMessage>;

        const panel = ref(['general', 'copies']);

        const router = useRouter();
        const goBack = () => {
            useRedirect(router, 'Films');
        };

        const goEdit = (sysId: string) => {
            useRedirectWithId(router, 'EditFilm', sysId || '');
        };

        const filmData = ref<IFilm>(new Film());
        const isBusy = ref(false);

        const nextNumber = ref(0);
        const getNextNumber = async () => {
            try {
                nextNumber.value = await filmService.getNextInventoryNumber();
                filmData.value.inventoryNumber = nextNumber.value;
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const archives = ref<IDropdownOption[]>([]);
        const getArchives = async () => {
            archives.value = await dropdownService.getCentralArchive();
            if (archives.value.length == 1) {
                filmData.value.archiveId = archives.value[0].id;
            }
        };

        const countries = ref<IDropdownOption[]>([]);
        const getCountries = async () => {
            countries.value = await dropdownService.getNomenclaturesByCode(NomenclatureCode.FilmCountry);
        };

        const filmForm = ref();
        const generalDataEditRef = ref();

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

            isBusy.value = true;
            try {
                filmData.value.systemIdentifier = defaultGuidString();
                const result = await filmService.createFilm(filmData.value);
                isBusy.value = false;
                if (result.status == 200) {
                    goEdit(result.data.data);
                }
            } catch (error: unknown) {
                isBusy.value = false;
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const showHintMessageForRequiredFields = () => {
            message.value = new Message({
                text: t('common.requiredFields'),
                display: true,
            });
        };

        onMounted(() => {
            getNextNumber();
            getArchives();
            getCountries();
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
                title: t('films.create'),
                disabled: true,
            },
        ];
        return {
            t,
            panel,
            filmData,
            archives,
            countries,
            submitFilmData,
            showHintMessageForRequiredFields,
            goBack,
            breadcrumbItems,
            filmForm,
            generalDataEditRef,
            isBusy,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
