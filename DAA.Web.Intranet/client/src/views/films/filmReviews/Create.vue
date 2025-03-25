<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <create-film-review-form
                @submit="submitFilmReviewData"
                v-model="filmReviewData"
                @created="goBack"
            ></create-film-review-form>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, onMounted, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect } from '@/helpers/router.helper';
import CreateFilmReviewForm from '@/components/films/createFilmReviewForm.vue';
import { IDropdownOption } from '@/interfaces/dropdown';
import dropdownService from '@/services/dropdown.service';
import { IFilmReview } from '@/interfaces/film';
import { FilmReview } from '@/models/film';
import filmService from '@/services/film.service';
import { ResponseResult } from '@/models/responseResult';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { defaultGuidString } from '@/helpers/format.helper';
export default defineComponent({
    name: 'CreateFilmReview',
    components: {
        CreateFilmReviewForm,
        Breadcrumbs,
    },
    setup(_, { emit }) {
        const { t } = useI18n();
        const router = useRouter();
        const goBack = () => {
            useRedirect(router, 'DisplayFilmReviews');
        };

        const message = inject('notificationMessage') as Ref<IMessage>;

        const filmReviewData = ref<IFilmReview>(new FilmReview());

        const readerProfiles = ref<IDropdownOption[]>([]);
        const getReaderProfiles = () => {
            dropdownService.getReaderProfiles().then((data) => (readerProfiles.value = data));
        };

        const films = ref<IDropdownOption[]>([]);
        const getFilms = () => {
            dropdownService.getAllFilms().then((data) => (films.value = data));
        };

        const submitFilmReviewData = async () => {
            try {
                filmReviewData.value.systemIdentifier = defaultGuidString();
                filmReviewData.value.accessAllowed = true;
                filmReviewData.value.deleted = false;
                filmReviewData.value.readerName = `${filmReviewData.value.firstName} ${filmReviewData.value.surname} ${filmReviewData.value.lastName}`;

                const result = await filmService.createFilmReview(filmReviewData.value);
                if (result.status == 200) {
                    emit('created', result.data);
                    goBack();
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const onCancel = () => {
            emit('cancel');
        };
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.readerAccessRecords'),
                disabled: false,
                to: { name: 'DisplayFilmReviews' },
            },
            {
                title: t('filmReviews.index.grid.cols.accessCreationForm'),
                disabled: true,
            },
        ];
        onMounted(async () => {
            await getReaderProfiles();
            await getFilms();
        });
        return {
            goBack,
            readerProfiles,
            breadcrumbItems,
            filmReviewData,
            films,
            submitFilmReviewData,
            onCancel,
            t,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
