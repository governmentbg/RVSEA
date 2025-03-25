<template>
<Loader :isLoading="isLoading" />
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('filmDocuments.display') }}</v-card-title>

        <v-container v-if="filmDocData">
            <v-expansion-panels v-model="panel" multiple>
                <v-expansion-panel value="doc">
                    <v-expansion-panel-title>{{ t('filmDocuments.title') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-6">
                                <text-field
                                    name="fldDocType"
                                    :label="t('filmDocuments.docType')"
                                    v-model="filmDocData.documentTypeName"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-6" v-if="filmDocData.filePath">
                                <label></label>
                                <div>
                                    {{ filmDocData.fileName }}
                                    <a :href="buildFileDownloadUrl(id)" class="text-decoration-none">
                                        <v-tooltip>
                                            <template v-slot:activator="{ props }">
                                                <v-icon color="primary" dark v-bind="props"> mdi-download </v-icon>
                                            </template>
                                            <span>{{ $t('common.download') }}</span>
                                        </v-tooltip>
                                    </a>
                                </div>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-area-field
                                    name="fldDescription"
                                    :label="t('filmDocuments.description')"
                                    v-model="filmDocData.description"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
            </v-expansion-panels>
            <v-row class="mt-3">
                <v-col class="d-flex justify-content-center">
                    <v-btn class="cancel" @click="goBack"
                        >{{ t('common.back') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('filmDocuments.backTooltip') }}
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
import { defineComponent, ref, inject, onMounted, Ref } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { Message } from '@/models/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { IFilmPackageDocument } from '@/interfaces/film';
import { FilmPackageDocument } from '@/models/film';
import filmDocumentService from '@/services/filmDocument.service';

import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'DisplayFilmDocument',
    components: {
        Loader,
        TextField,
        TextAreaField,
        Breadcrumbs,
    },
    props: {
        filmId: {
            type: String,
            required: true,
        },
        packageType: {
            type: String,
            required: true,
        },
        id: {
            type: Number,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();

        const isLoading = ref(false);

        const message = inject('notificationMessage') as Ref<IMessage>;

        const panel = ref(['doc']);

        const router = useRouter();
        const isBusy = ref(false);

        const goEdit = () => {
            useRedirect(router, 'EditFilmDocument', {
                filmId: props.filmId,
                packageType: props.packageType,
                id: props.id,
            });
        };

        const goBack = () => {
            if (props.filmId) {
                useRedirectWithId(router, 'DisplayFilm', props.filmId);
            } else {
                useRedirect(router, 'Films');
            }
        };

        const filmDocData = ref<IFilmPackageDocument>(new FilmPackageDocument());
        const getFilmDocumentData = async () => {
            isBusy.value = true;
            try {
                isLoading.value = true;
                filmDocData.value = await filmDocumentService.displayFilmDocument(props.id);
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

        const buildFileDownloadUrl = (docId: number) => {
            return filmDocumentService.getFileDownloadUrl(docId);
        };

        onMounted(getFilmDocumentData);

        const breadcrumbItems = ref([
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
                title: t('documents.document'),
                disabled: true,
            },
        ]);
        return {
            t,
            panel,
            filmDocData,
            goEdit,
            goBack,
            message,
            buildFileDownloadUrl,
            isBusy,
            breadcrumbItems,
            isLoading,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
