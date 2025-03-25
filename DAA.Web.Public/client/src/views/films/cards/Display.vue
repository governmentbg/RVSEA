<template>
<Loader :isLoading="isLoading" />
    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('filmCards.display') }}</v-card-title>

        <v-container>
            <v-expansion-panels v-model="panel" multiple>
                <card-general-data-panel :filmCardData="filmCardData"></card-general-data-panel>
            </v-expansion-panels>
            <v-row class="mt-3">
                <v-col class="d-flex justify-content-center">
                    <IsdaEServices />
                    <v-btn class="cancel" @click="goBack" :disabled="isBusy"
                        >{{ t('common.back') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('common.backKmfTooltip') }}
                        </v-tooltip>
                    </v-btn>
                </v-col>
            </v-row>
        </v-container>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, inject, Ref } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { Message } from '@/models/notification';

import filmCardService from '@/services/filmCard.service';
import { IFilmCard } from '@/interfaces/film';
import { FilmCard } from '@/models/film';
import { IDropdownOption } from '@/interfaces/dropdown';

import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import CardGeneralDataPanel from '@/components/films/cards/cardGeneralDataPanel.vue';
import IsdaEServices from '@/components/films/buttons.vue';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'DisplayFilmCard',
    components: {
        Loader,
        CardGeneralDataPanel,
        IsdaEServices,
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
        const panel = ref(['general', 'dates', 'copies', 'docs']);
        const router = useRouter();
        const isBusy = ref(false);
        const filmPackageDocs = ref<IDropdownOption[]>([]);
        const filmCardData = ref<IFilmCard>(new FilmCard());
        const isLoading = ref(false);

        const goBack = () => {
            router.go(-1);
        };

        const getFilmCardData = async () => {
            isBusy.value = true;
            try {
                isLoading.value = true;
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
            } finally {
                isLoading.value = false;
            }
        };

        onMounted(() => {
            window.scrollTo(0, 0);
            getFilmCardData();
        });

        return {
            t,
            panel,
            filmCardData,
            goBack,
            message,
            filmPackageDocs,
            isBusy,
            isLoading,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';

:deep(button) {
    margin-top: 0px !important;
}
</style>
